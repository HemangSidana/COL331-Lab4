#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "x86.h"
#include "proc.h"
#include "buf.h"

struct swap_slot ss[NSLOTS];

void init_slot(){
  for(int i = 0; i<NSLOTS; i++){
    ss[i].is_free = 1;
  }
}

pte_t* victim_page(){
    while(1){
        struct proc *p = victim_proc();
        int count = 0;
        for(int i = 0; i < p->sz; i+=PGSIZE){
            pte_t* pte = walkpgdir(p->pgdir, (void*)i, 0);
            if(*pte & PTE_P){
                if(!(*pte & PTE_A)){
                    if (p->rss > 0){
                        p->rss -= PGSIZE;
                    }
                    return pte;
                }else{
                    count++;
                }
            }
        }
        unset_access(p->pgdir,count);
    }
    return 0;
}

void unset_access(pde_t* p, int count){
    int z = (count+9)/10;
    int i=0;
    while(z){
        pte_t* pte = walkpgdir(p, (void*)i, 0);
        if(*pte & PTE_P){
            if(*pte & PTE_A){
                *pte &= ~PTE_A;
                z--;
            }
        }
        i+=PGSIZE;
    }
}

void allocate_page(){
    pte_t* pte = victim_page();
    uint slot = NSLOTS;
    for(slot=0; slot<NSLOTS; slot++){
        if(ss[slot].is_free) break;
    }
    if(slot == NSLOTS){
        panic("Slots filled");
    }
    char* page = (char*)P2V(PTE_ADDR(*pte));   
    write_page(page,2+8*slot);
    ss[slot].is_free = 0;
    ss[slot].page_perm = PTE_FLAGS(*pte);
    *pte= slot << 12 | PTE_S;
    kfree(page);
    return;
}

void clean_swap(pde_t* pde){
    for(int i = 0; i < NPTENTRIES; i++){
        if(pde[i] & PTE_S){
            uint slot = PTE_ADDR(pde[i]) >> 12;
            ss[slot].is_free = 1;
        }
    }
}

void page_fault(){
    uint va = rcr2();
    struct proc *p = myproc();
    pte_t *pte = walkpgdir(p->pgdir, (void*)va, 0);
    if((*pte & PTE_S)){
        uint slot = *pte >> 12;
        char* page = kalloc();
        read_page(page, 8*slot+2);
        uint permissions = ss[slot].page_perm;
        ss[slot].is_free = 1;
        *pte = PTE_ADDR(V2P(page)) | PTE_FLAGS(permissions);
        *pte = *pte | PTE_A;
        p->rss += PGSIZE;
    }
}