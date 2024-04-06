
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 10 66 11 80       	mov    $0x80116610,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 20 33 10 80       	mov    $0x80103320,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	57                   	push   %edi
80100044:	89 d7                	mov    %edx,%edi
80100046:	56                   	push   %esi
80100047:	89 c6                	mov    %eax,%esi
80100049:	53                   	push   %ebx
8010004a:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
8010004d:	68 20 b5 10 80       	push   $0x8010b520
80100052:	e8 e9 48 00 00       	call   80104940 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100057:	8b 1d 70 fc 10 80    	mov    0x8010fc70,%ebx
8010005d:	83 c4 10             	add    $0x10,%esp
80100060:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
80100066:	75 13                	jne    8010007b <bget+0x3b>
80100068:	eb 26                	jmp    80100090 <bget+0x50>
8010006a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100070:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100073:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
80100079:	74 15                	je     80100090 <bget+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010007b:	39 73 04             	cmp    %esi,0x4(%ebx)
8010007e:	75 f0                	jne    80100070 <bget+0x30>
80100080:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100083:	75 eb                	jne    80100070 <bget+0x30>
      b->refcnt++;
80100085:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100089:	eb 3f                	jmp    801000ca <bget+0x8a>
8010008b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010008f:	90                   	nop
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100090:	8b 1d 6c fc 10 80    	mov    0x8010fc6c,%ebx
80100096:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
8010009c:	75 0d                	jne    801000ab <bget+0x6b>
8010009e:	eb 4f                	jmp    801000ef <bget+0xaf>
801000a0:	8b 5b 50             	mov    0x50(%ebx),%ebx
801000a3:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
801000a9:	74 44                	je     801000ef <bget+0xaf>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000ab:	8b 43 4c             	mov    0x4c(%ebx),%eax
801000ae:	85 c0                	test   %eax,%eax
801000b0:	75 ee                	jne    801000a0 <bget+0x60>
801000b2:	f6 03 04             	testb  $0x4,(%ebx)
801000b5:	75 e9                	jne    801000a0 <bget+0x60>
      b->dev = dev;
801000b7:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000ba:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000c3:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000ca:	83 ec 0c             	sub    $0xc,%esp
801000cd:	68 20 b5 10 80       	push   $0x8010b520
801000d2:	e8 09 48 00 00       	call   801048e0 <release>
      acquiresleep(&b->lock);
801000d7:	8d 43 0c             	lea    0xc(%ebx),%eax
801000da:	89 04 24             	mov    %eax,(%esp)
801000dd:	e8 9e 45 00 00       	call   80104680 <acquiresleep>
      return b;
801000e2:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e8:	89 d8                	mov    %ebx,%eax
801000ea:	5b                   	pop    %ebx
801000eb:	5e                   	pop    %esi
801000ec:	5f                   	pop    %edi
801000ed:	5d                   	pop    %ebp
801000ee:	c3                   	ret    
  panic("bget: no buffers");
801000ef:	83 ec 0c             	sub    $0xc,%esp
801000f2:	68 60 79 10 80       	push   $0x80107960
801000f7:	e8 b4 03 00 00       	call   801004b0 <panic>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100100 <binit>:
{
80100100:	55                   	push   %ebp
80100101:	89 e5                	mov    %esp,%ebp
80100103:	53                   	push   %ebx
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100104:	bb 54 b5 10 80       	mov    $0x8010b554,%ebx
{
80100109:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
8010010c:	68 71 79 10 80       	push   $0x80107971
80100111:	68 20 b5 10 80       	push   $0x8010b520
80100116:	e8 55 46 00 00       	call   80104770 <initlock>
  bcache.head.next = &bcache.head;
8010011b:	83 c4 10             	add    $0x10,%esp
8010011e:	b8 1c fc 10 80       	mov    $0x8010fc1c,%eax
  bcache.head.prev = &bcache.head;
80100123:	c7 05 6c fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc6c
8010012a:	fc 10 80 
  bcache.head.next = &bcache.head;
8010012d:	c7 05 70 fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc70
80100134:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100137:	eb 09                	jmp    80100142 <binit+0x42>
80100139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100140:	89 d3                	mov    %edx,%ebx
    b->next = bcache.head.next;
80100142:	89 43 54             	mov    %eax,0x54(%ebx)
    initsleeplock(&b->lock, "buffer");
80100145:	83 ec 08             	sub    $0x8,%esp
80100148:	8d 43 0c             	lea    0xc(%ebx),%eax
    b->prev = &bcache.head;
8010014b:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100152:	68 78 79 10 80       	push   $0x80107978
80100157:	50                   	push   %eax
80100158:	e8 e3 44 00 00       	call   80104640 <initsleeplock>
    bcache.head.next->prev = b;
8010015d:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100162:	8d 93 5c 02 00 00    	lea    0x25c(%ebx),%edx
80100168:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010016b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010016e:	89 d8                	mov    %ebx,%eax
80100170:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100176:	81 fb c0 f9 10 80    	cmp    $0x8010f9c0,%ebx
8010017c:	75 c2                	jne    80100140 <binit+0x40>
}
8010017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100181:	c9                   	leave  
80100182:	c3                   	ret    
80100183:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010018a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100190 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100190:	55                   	push   %ebp
80100191:	89 e5                	mov    %esp,%ebp
80100193:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100196:	8b 55 0c             	mov    0xc(%ebp),%edx
80100199:	8b 45 08             	mov    0x8(%ebp),%eax
8010019c:	e8 9f fe ff ff       	call   80100040 <bget>
  if((b->flags & B_VALID) == 0) {
801001a1:	f6 00 02             	testb  $0x2,(%eax)
801001a4:	74 0a                	je     801001b0 <bread+0x20>
    iderw(b);
  }
  return b;
}
801001a6:	c9                   	leave  
801001a7:	c3                   	ret    
801001a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001af:	90                   	nop
    iderw(b);
801001b0:	83 ec 0c             	sub    $0xc,%esp
801001b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b6:	50                   	push   %eax
801001b7:	e8 84 23 00 00       	call   80102540 <iderw>
801001bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001bf:	83 c4 10             	add    $0x10,%esp
}
801001c2:	c9                   	leave  
801001c3:	c3                   	ret    
801001c4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801001cf:	90                   	nop

801001d0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001d0:	55                   	push   %ebp
801001d1:	89 e5                	mov    %esp,%ebp
801001d3:	53                   	push   %ebx
801001d4:	83 ec 10             	sub    $0x10,%esp
801001d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001da:	8d 43 0c             	lea    0xc(%ebx),%eax
801001dd:	50                   	push   %eax
801001de:	e8 3d 45 00 00       	call   80104720 <holdingsleep>
801001e3:	83 c4 10             	add    $0x10,%esp
801001e6:	85 c0                	test   %eax,%eax
801001e8:	74 0f                	je     801001f9 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001ea:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001ed:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001f3:	c9                   	leave  
  iderw(b);
801001f4:	e9 47 23 00 00       	jmp    80102540 <iderw>
    panic("bwrite");
801001f9:	83 ec 0c             	sub    $0xc,%esp
801001fc:	68 7f 79 10 80       	push   $0x8010797f
80100201:	e8 aa 02 00 00       	call   801004b0 <panic>
80100206:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010020d:	8d 76 00             	lea    0x0(%esi),%esi

80100210 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100210:	55                   	push   %ebp
80100211:	89 e5                	mov    %esp,%ebp
80100213:	56                   	push   %esi
80100214:	53                   	push   %ebx
80100215:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
80100218:	8d 73 0c             	lea    0xc(%ebx),%esi
8010021b:	83 ec 0c             	sub    $0xc,%esp
8010021e:	56                   	push   %esi
8010021f:	e8 fc 44 00 00       	call   80104720 <holdingsleep>
80100224:	83 c4 10             	add    $0x10,%esp
80100227:	85 c0                	test   %eax,%eax
80100229:	74 66                	je     80100291 <brelse+0x81>
    panic("brelse");

  releasesleep(&b->lock);
8010022b:	83 ec 0c             	sub    $0xc,%esp
8010022e:	56                   	push   %esi
8010022f:	e8 ac 44 00 00       	call   801046e0 <releasesleep>

  acquire(&bcache.lock);
80100234:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010023b:	e8 00 47 00 00       	call   80104940 <acquire>
  b->refcnt--;
80100240:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100243:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
80100246:	83 e8 01             	sub    $0x1,%eax
80100249:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010024c:	85 c0                	test   %eax,%eax
8010024e:	75 2f                	jne    8010027f <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100250:	8b 43 54             	mov    0x54(%ebx),%eax
80100253:	8b 53 50             	mov    0x50(%ebx),%edx
80100256:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100259:	8b 43 50             	mov    0x50(%ebx),%eax
8010025c:	8b 53 54             	mov    0x54(%ebx),%edx
8010025f:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100262:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
    b->prev = &bcache.head;
80100267:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    b->next = bcache.head.next;
8010026e:	89 43 54             	mov    %eax,0x54(%ebx)
    bcache.head.next->prev = b;
80100271:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
80100276:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100279:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  }
  
  release(&bcache.lock);
8010027f:	c7 45 08 20 b5 10 80 	movl   $0x8010b520,0x8(%ebp)
}
80100286:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100289:	5b                   	pop    %ebx
8010028a:	5e                   	pop    %esi
8010028b:	5d                   	pop    %ebp
  release(&bcache.lock);
8010028c:	e9 4f 46 00 00       	jmp    801048e0 <release>
    panic("brelse");
80100291:	83 ec 0c             	sub    $0xc,%esp
80100294:	68 86 79 10 80       	push   $0x80107986
80100299:	e8 12 02 00 00       	call   801004b0 <panic>
8010029e:	66 90                	xchg   %ax,%ax

801002a0 <write_page_to_disk>:
//PAGEBREAK!
// Blank page.

void
write_page_to_disk(uint dev, char *pg, uint blk)
{
801002a0:	55                   	push   %ebp
801002a1:	89 e5                	mov    %esp,%ebp
801002a3:	57                   	push   %edi
801002a4:	56                   	push   %esi
801002a5:	53                   	push   %ebx
801002a6:	83 ec 1c             	sub    $0x1c,%esp
801002a9:	8b 7d 10             	mov    0x10(%ebp),%edi
801002ac:	8b 75 0c             	mov    0xc(%ebp),%esi
801002af:	8d 47 08             	lea    0x8(%edi),%eax
801002b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801002b5:	8d 76 00             	lea    0x0(%esi),%esi
  struct buf* buffer;
  int blockno=0;
  for(int i=0;i<8;i++){
    // begin_op();           //for atomicity , the block must be written to the disk
    blockno=blk+i;
    buffer=bget(ROOTDEV,blockno);
801002b8:	89 fa                	mov    %edi,%edx
801002ba:	b8 01 00 00 00       	mov    $0x1,%eax
801002bf:	e8 7c fd ff ff       	call   80100040 <bget>
    /*
    Writing physical page to disk by dividing it into 8 pieces (4096 bytes/8 = 512 bytes = 1 block)
    As one page requires 8 disk blocks
    */
    memmove(buffer->data,pg + i*512,512);   // write 512 bytes to the block
801002c4:	83 ec 04             	sub    $0x4,%esp
    buffer=bget(ROOTDEV,blockno);
801002c7:	89 c3                	mov    %eax,%ebx
    memmove(buffer->data,pg + i*512,512);   // write 512 bytes to the block
801002c9:	8d 40 5c             	lea    0x5c(%eax),%eax
801002cc:	68 00 02 00 00       	push   $0x200
801002d1:	56                   	push   %esi
801002d2:	50                   	push   %eax
801002d3:	e8 c8 47 00 00       	call   80104aa0 <memmove>
  if(!holdingsleep(&b->lock))
801002d8:	8d 43 0c             	lea    0xc(%ebx),%eax
801002db:	89 04 24             	mov    %eax,(%esp)
801002de:	e8 3d 44 00 00       	call   80104720 <holdingsleep>
801002e3:	83 c4 10             	add    $0x10,%esp
801002e6:	85 c0                	test   %eax,%eax
801002e8:	74 2d                	je     80100317 <write_page_to_disk+0x77>
  iderw(b);
801002ea:	83 ec 0c             	sub    $0xc,%esp
  b->flags |= B_DIRTY;
801002ed:	83 0b 04             	orl    $0x4,(%ebx)
  for(int i=0;i<8;i++){
801002f0:	83 c7 01             	add    $0x1,%edi
801002f3:	81 c6 00 02 00 00    	add    $0x200,%esi
  iderw(b);
801002f9:	53                   	push   %ebx
801002fa:	e8 41 22 00 00       	call   80102540 <iderw>
    bwrite(buffer);
    brelse(buffer);                               //release lock
801002ff:	89 1c 24             	mov    %ebx,(%esp)
80100302:	e8 09 ff ff ff       	call   80100210 <brelse>
  for(int i=0;i<8;i++){
80100307:	83 c4 10             	add    $0x10,%esp
8010030a:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
8010030d:	75 a9                	jne    801002b8 <write_page_to_disk+0x18>
    // end_op();
  }
}
8010030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100312:	5b                   	pop    %ebx
80100313:	5e                   	pop    %esi
80100314:	5f                   	pop    %edi
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    
    panic("bwrite");
80100317:	83 ec 0c             	sub    $0xc,%esp
8010031a:	68 7f 79 10 80       	push   $0x8010797f
8010031f:	e8 8c 01 00 00       	call   801004b0 <panic>
80100324:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010032b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010032f:	90                   	nop

80100330 <read_page_from_disk>:


void
read_page_from_disk(uint dev, char *pg, uint blk)
{
80100330:	55                   	push   %ebp
80100331:	89 e5                	mov    %esp,%ebp
80100333:	57                   	push   %edi
80100334:	56                   	push   %esi
80100335:	53                   	push   %ebx
80100336:	83 ec 1c             	sub    $0x1c,%esp
80100339:	8b 5d 10             	mov    0x10(%ebp),%ebx
8010033c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010033f:	8d 43 08             	lea    0x8(%ebx),%eax
80100342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100345:	eb 34                	jmp    8010037b <read_page_from_disk+0x4b>
80100347:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010034e:	66 90                	xchg   %ax,%ax
  int blockno=0;
  for(int i=0;i<8;i++){

    blockno=blk+i;
    buffer=bread(ROOTDEV,blockno);    //if present in buffer, returns from buffer else from disk
    memmove(pg+i*512, buffer->data,512);  //write to pg from buffer
80100350:	83 ec 04             	sub    $0x4,%esp
80100353:	8d 47 5c             	lea    0x5c(%edi),%eax
  for(int i=0;i<8;i++){
80100356:	83 c3 01             	add    $0x1,%ebx
    memmove(pg+i*512, buffer->data,512);  //write to pg from buffer
80100359:	68 00 02 00 00       	push   $0x200
8010035e:	50                   	push   %eax
8010035f:	56                   	push   %esi
  for(int i=0;i<8;i++){
80100360:	81 c6 00 02 00 00    	add    $0x200,%esi
    memmove(pg+i*512, buffer->data,512);  //write to pg from buffer
80100366:	e8 35 47 00 00       	call   80104aa0 <memmove>
    brelse(buffer);                   //release lock
8010036b:	89 3c 24             	mov    %edi,(%esp)
8010036e:	e8 9d fe ff ff       	call   80100210 <brelse>
  for(int i=0;i<8;i++){
80100373:	83 c4 10             	add    $0x10,%esp
80100376:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100379:	74 25                	je     801003a0 <read_page_from_disk+0x70>
  b = bget(dev, blockno);
8010037b:	89 da                	mov    %ebx,%edx
8010037d:	b8 01 00 00 00       	mov    $0x1,%eax
80100382:	e8 b9 fc ff ff       	call   80100040 <bget>
80100387:	89 c7                	mov    %eax,%edi
  if((b->flags & B_VALID) == 0) {
80100389:	f6 00 02             	testb  $0x2,(%eax)
8010038c:	75 c2                	jne    80100350 <read_page_from_disk+0x20>
    iderw(b);
8010038e:	83 ec 0c             	sub    $0xc,%esp
80100391:	50                   	push   %eax
80100392:	e8 a9 21 00 00       	call   80102540 <iderw>
80100397:	83 c4 10             	add    $0x10,%esp
8010039a:	eb b4                	jmp    80100350 <read_page_from_disk+0x20>
8010039c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }

}
801003a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801003a3:	5b                   	pop    %ebx
801003a4:	5e                   	pop    %esi
801003a5:	5f                   	pop    %edi
801003a6:	5d                   	pop    %ebp
801003a7:	c3                   	ret    
801003a8:	66 90                	xchg   %ax,%ax
801003aa:	66 90                	xchg   %ax,%ax
801003ac:	66 90                	xchg   %ax,%ax
801003ae:	66 90                	xchg   %ax,%ax

801003b0 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
801003b0:	55                   	push   %ebp
801003b1:	89 e5                	mov    %esp,%ebp
801003b3:	57                   	push   %edi
801003b4:	56                   	push   %esi
801003b5:	53                   	push   %ebx
801003b6:	83 ec 18             	sub    $0x18,%esp
801003b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
801003bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
801003bf:	ff 75 08             	push   0x8(%ebp)
  target = n;
801003c2:	89 df                	mov    %ebx,%edi
  iunlock(ip);
801003c4:	e8 f7 16 00 00       	call   80101ac0 <iunlock>
  acquire(&cons.lock);
801003c9:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801003d0:	e8 6b 45 00 00       	call   80104940 <acquire>
  while(n > 0){
801003d5:	83 c4 10             	add    $0x10,%esp
801003d8:	85 db                	test   %ebx,%ebx
801003da:	0f 8e 94 00 00 00    	jle    80100474 <consoleread+0xc4>
    while(input.r == input.w){
801003e0:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801003e5:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
801003eb:	74 25                	je     80100412 <consoleread+0x62>
801003ed:	eb 59                	jmp    80100448 <consoleread+0x98>
801003ef:	90                   	nop
      if(myproc()->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801003f0:	83 ec 08             	sub    $0x8,%esp
801003f3:	68 20 ff 10 80       	push   $0x8010ff20
801003f8:	68 00 ff 10 80       	push   $0x8010ff00
801003fd:	e8 8e 3f 00 00       	call   80104390 <sleep>
    while(input.r == input.w){
80100402:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80100407:	83 c4 10             	add    $0x10,%esp
8010040a:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
80100410:	75 36                	jne    80100448 <consoleread+0x98>
      if(myproc()->killed){
80100412:	e8 39 38 00 00       	call   80103c50 <myproc>
80100417:	8b 48 28             	mov    0x28(%eax),%ecx
8010041a:	85 c9                	test   %ecx,%ecx
8010041c:	74 d2                	je     801003f0 <consoleread+0x40>
        release(&cons.lock);
8010041e:	83 ec 0c             	sub    $0xc,%esp
80100421:	68 20 ff 10 80       	push   $0x8010ff20
80100426:	e8 b5 44 00 00       	call   801048e0 <release>
        ilock(ip);
8010042b:	5a                   	pop    %edx
8010042c:	ff 75 08             	push   0x8(%ebp)
8010042f:	e8 ac 15 00 00       	call   801019e0 <ilock>
        return -1;
80100434:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
80100437:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
8010043a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010043f:	5b                   	pop    %ebx
80100440:	5e                   	pop    %esi
80100441:	5f                   	pop    %edi
80100442:	5d                   	pop    %ebp
80100443:	c3                   	ret    
80100444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = input.buf[input.r++ % INPUT_BUF];
80100448:	8d 50 01             	lea    0x1(%eax),%edx
8010044b:	89 15 00 ff 10 80    	mov    %edx,0x8010ff00
80100451:	89 c2                	mov    %eax,%edx
80100453:	83 e2 7f             	and    $0x7f,%edx
80100456:	0f be 8a 80 fe 10 80 	movsbl -0x7fef0180(%edx),%ecx
    if(c == C('D')){  // EOF
8010045d:	80 f9 04             	cmp    $0x4,%cl
80100460:	74 37                	je     80100499 <consoleread+0xe9>
    *dst++ = c;
80100462:	83 c6 01             	add    $0x1,%esi
    --n;
80100465:	83 eb 01             	sub    $0x1,%ebx
    *dst++ = c;
80100468:	88 4e ff             	mov    %cl,-0x1(%esi)
    if(c == '\n')
8010046b:	83 f9 0a             	cmp    $0xa,%ecx
8010046e:	0f 85 64 ff ff ff    	jne    801003d8 <consoleread+0x28>
  release(&cons.lock);
80100474:	83 ec 0c             	sub    $0xc,%esp
80100477:	68 20 ff 10 80       	push   $0x8010ff20
8010047c:	e8 5f 44 00 00       	call   801048e0 <release>
  ilock(ip);
80100481:	58                   	pop    %eax
80100482:	ff 75 08             	push   0x8(%ebp)
80100485:	e8 56 15 00 00       	call   801019e0 <ilock>
  return target - n;
8010048a:	89 f8                	mov    %edi,%eax
8010048c:	83 c4 10             	add    $0x10,%esp
}
8010048f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return target - n;
80100492:	29 d8                	sub    %ebx,%eax
}
80100494:	5b                   	pop    %ebx
80100495:	5e                   	pop    %esi
80100496:	5f                   	pop    %edi
80100497:	5d                   	pop    %ebp
80100498:	c3                   	ret    
      if(n < target){
80100499:	39 fb                	cmp    %edi,%ebx
8010049b:	73 d7                	jae    80100474 <consoleread+0xc4>
        input.r--;
8010049d:	a3 00 ff 10 80       	mov    %eax,0x8010ff00
801004a2:	eb d0                	jmp    80100474 <consoleread+0xc4>
801004a4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801004ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801004af:	90                   	nop

801004b0 <panic>:
{
801004b0:	55                   	push   %ebp
801004b1:	89 e5                	mov    %esp,%ebp
801004b3:	56                   	push   %esi
801004b4:	53                   	push   %ebx
801004b5:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
801004b8:	fa                   	cli    
  cons.locking = 0;
801004b9:	c7 05 54 ff 10 80 00 	movl   $0x0,0x8010ff54
801004c0:	00 00 00 
  getcallerpcs(&s, pcs);
801004c3:	8d 5d d0             	lea    -0x30(%ebp),%ebx
801004c6:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
801004c9:	e8 e2 26 00 00       	call   80102bb0 <lapicid>
801004ce:	83 ec 08             	sub    $0x8,%esp
801004d1:	50                   	push   %eax
801004d2:	68 8d 79 10 80       	push   $0x8010798d
801004d7:	e8 f4 02 00 00       	call   801007d0 <cprintf>
  cprintf(s);
801004dc:	58                   	pop    %eax
801004dd:	ff 75 08             	push   0x8(%ebp)
801004e0:	e8 eb 02 00 00       	call   801007d0 <cprintf>
  cprintf("\n");
801004e5:	c7 04 24 7b 83 10 80 	movl   $0x8010837b,(%esp)
801004ec:	e8 df 02 00 00       	call   801007d0 <cprintf>
  getcallerpcs(&s, pcs);
801004f1:	8d 45 08             	lea    0x8(%ebp),%eax
801004f4:	5a                   	pop    %edx
801004f5:	59                   	pop    %ecx
801004f6:	53                   	push   %ebx
801004f7:	50                   	push   %eax
801004f8:	e8 93 42 00 00       	call   80104790 <getcallerpcs>
  for(i=0; i<10; i++)
801004fd:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
80100500:	83 ec 08             	sub    $0x8,%esp
80100503:	ff 33                	push   (%ebx)
  for(i=0; i<10; i++)
80100505:	83 c3 04             	add    $0x4,%ebx
    cprintf(" %p", pcs[i]);
80100508:	68 a1 79 10 80       	push   $0x801079a1
8010050d:	e8 be 02 00 00       	call   801007d0 <cprintf>
  for(i=0; i<10; i++)
80100512:	83 c4 10             	add    $0x10,%esp
80100515:	39 f3                	cmp    %esi,%ebx
80100517:	75 e7                	jne    80100500 <panic+0x50>
  panicked = 1; // freeze other CPU
80100519:	c7 05 58 ff 10 80 01 	movl   $0x1,0x8010ff58
80100520:	00 00 00 
  for(;;)
80100523:	eb fe                	jmp    80100523 <panic+0x73>
80100525:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010052c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100530 <consputc.part.0>:
consputc(int c)
80100530:	55                   	push   %ebp
80100531:	89 e5                	mov    %esp,%ebp
80100533:	57                   	push   %edi
80100534:	56                   	push   %esi
80100535:	53                   	push   %ebx
80100536:	89 c3                	mov    %eax,%ebx
80100538:	83 ec 1c             	sub    $0x1c,%esp
  if(c == BACKSPACE){
8010053b:	3d 00 01 00 00       	cmp    $0x100,%eax
80100540:	0f 84 ea 00 00 00    	je     80100630 <consputc.part.0+0x100>
    uartputc(c);
80100546:	83 ec 0c             	sub    $0xc,%esp
80100549:	50                   	push   %eax
8010054a:	e8 51 5b 00 00       	call   801060a0 <uartputc>
8010054f:	83 c4 10             	add    $0x10,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100552:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100557:	b8 0e 00 00 00       	mov    $0xe,%eax
8010055c:	89 fa                	mov    %edi,%edx
8010055e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010055f:	be d5 03 00 00       	mov    $0x3d5,%esi
80100564:	89 f2                	mov    %esi,%edx
80100566:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100567:	0f b6 c8             	movzbl %al,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010056a:	89 fa                	mov    %edi,%edx
8010056c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100571:	c1 e1 08             	shl    $0x8,%ecx
80100574:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100575:	89 f2                	mov    %esi,%edx
80100577:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
80100578:	0f b6 c0             	movzbl %al,%eax
8010057b:	09 c8                	or     %ecx,%eax
  if(c == '\n')
8010057d:	83 fb 0a             	cmp    $0xa,%ebx
80100580:	0f 84 92 00 00 00    	je     80100618 <consputc.part.0+0xe8>
  else if(c == BACKSPACE){
80100586:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
8010058c:	74 72                	je     80100600 <consputc.part.0+0xd0>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010058e:	0f b6 db             	movzbl %bl,%ebx
80100591:	8d 70 01             	lea    0x1(%eax),%esi
80100594:	80 cf 07             	or     $0x7,%bh
80100597:	66 89 9c 00 00 80 0b 	mov    %bx,-0x7ff48000(%eax,%eax,1)
8010059e:	80 
  if(pos < 0 || pos > 25*80)
8010059f:	81 fe d0 07 00 00    	cmp    $0x7d0,%esi
801005a5:	0f 8f fb 00 00 00    	jg     801006a6 <consputc.part.0+0x176>
  if((pos/80) >= 24){  // Scroll up.
801005ab:	81 fe 7f 07 00 00    	cmp    $0x77f,%esi
801005b1:	0f 8f a9 00 00 00    	jg     80100660 <consputc.part.0+0x130>
  outb(CRTPORT+1, pos>>8);
801005b7:	89 f0                	mov    %esi,%eax
  crt[pos] = ' ' | 0x0700;
801005b9:	8d b4 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
801005c0:	88 45 e7             	mov    %al,-0x19(%ebp)
  outb(CRTPORT+1, pos>>8);
801005c3:	0f b6 fc             	movzbl %ah,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801005c6:	bb d4 03 00 00       	mov    $0x3d4,%ebx
801005cb:	b8 0e 00 00 00       	mov    $0xe,%eax
801005d0:	89 da                	mov    %ebx,%edx
801005d2:	ee                   	out    %al,(%dx)
801005d3:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801005d8:	89 f8                	mov    %edi,%eax
801005da:	89 ca                	mov    %ecx,%edx
801005dc:	ee                   	out    %al,(%dx)
801005dd:	b8 0f 00 00 00       	mov    $0xf,%eax
801005e2:	89 da                	mov    %ebx,%edx
801005e4:	ee                   	out    %al,(%dx)
801005e5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
801005e9:	89 ca                	mov    %ecx,%edx
801005eb:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
801005ec:	b8 20 07 00 00       	mov    $0x720,%eax
801005f1:	66 89 06             	mov    %ax,(%esi)
}
801005f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005f7:	5b                   	pop    %ebx
801005f8:	5e                   	pop    %esi
801005f9:	5f                   	pop    %edi
801005fa:	5d                   	pop    %ebp
801005fb:	c3                   	ret    
801005fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(pos > 0) --pos;
80100600:	8d 70 ff             	lea    -0x1(%eax),%esi
80100603:	85 c0                	test   %eax,%eax
80100605:	75 98                	jne    8010059f <consputc.part.0+0x6f>
80100607:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
8010060b:	be 00 80 0b 80       	mov    $0x800b8000,%esi
80100610:	31 ff                	xor    %edi,%edi
80100612:	eb b2                	jmp    801005c6 <consputc.part.0+0x96>
80100614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pos += 80 - pos%80;
80100618:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
8010061d:	f7 e2                	mul    %edx
8010061f:	c1 ea 06             	shr    $0x6,%edx
80100622:	8d 04 92             	lea    (%edx,%edx,4),%eax
80100625:	c1 e0 04             	shl    $0x4,%eax
80100628:	8d 70 50             	lea    0x50(%eax),%esi
8010062b:	e9 6f ff ff ff       	jmp    8010059f <consputc.part.0+0x6f>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100630:	83 ec 0c             	sub    $0xc,%esp
80100633:	6a 08                	push   $0x8
80100635:	e8 66 5a 00 00       	call   801060a0 <uartputc>
8010063a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100641:	e8 5a 5a 00 00       	call   801060a0 <uartputc>
80100646:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010064d:	e8 4e 5a 00 00       	call   801060a0 <uartputc>
80100652:	83 c4 10             	add    $0x10,%esp
80100655:	e9 f8 fe ff ff       	jmp    80100552 <consputc.part.0+0x22>
8010065a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100660:	83 ec 04             	sub    $0x4,%esp
    pos -= 80;
80100663:	8d 5e b0             	lea    -0x50(%esi),%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100666:	8d b4 36 60 7f 0b 80 	lea    -0x7ff480a0(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
8010066d:	bf 07 00 00 00       	mov    $0x7,%edi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100672:	68 60 0e 00 00       	push   $0xe60
80100677:	68 a0 80 0b 80       	push   $0x800b80a0
8010067c:	68 00 80 0b 80       	push   $0x800b8000
80100681:	e8 1a 44 00 00       	call   80104aa0 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100686:	b8 80 07 00 00       	mov    $0x780,%eax
8010068b:	83 c4 0c             	add    $0xc,%esp
8010068e:	29 d8                	sub    %ebx,%eax
80100690:	01 c0                	add    %eax,%eax
80100692:	50                   	push   %eax
80100693:	6a 00                	push   $0x0
80100695:	56                   	push   %esi
80100696:	e8 65 43 00 00       	call   80104a00 <memset>
  outb(CRTPORT+1, pos);
8010069b:	88 5d e7             	mov    %bl,-0x19(%ebp)
8010069e:	83 c4 10             	add    $0x10,%esp
801006a1:	e9 20 ff ff ff       	jmp    801005c6 <consputc.part.0+0x96>
    panic("pos under/overflow");
801006a6:	83 ec 0c             	sub    $0xc,%esp
801006a9:	68 a5 79 10 80       	push   $0x801079a5
801006ae:	e8 fd fd ff ff       	call   801004b0 <panic>
801006b3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801006ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801006c0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801006c0:	55                   	push   %ebp
801006c1:	89 e5                	mov    %esp,%ebp
801006c3:	57                   	push   %edi
801006c4:	56                   	push   %esi
801006c5:	53                   	push   %ebx
801006c6:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
801006c9:	ff 75 08             	push   0x8(%ebp)
{
801006cc:	8b 75 10             	mov    0x10(%ebp),%esi
  iunlock(ip);
801006cf:	e8 ec 13 00 00       	call   80101ac0 <iunlock>
  acquire(&cons.lock);
801006d4:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801006db:	e8 60 42 00 00       	call   80104940 <acquire>
  for(i = 0; i < n; i++)
801006e0:	83 c4 10             	add    $0x10,%esp
801006e3:	85 f6                	test   %esi,%esi
801006e5:	7e 25                	jle    8010070c <consolewrite+0x4c>
801006e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801006ea:	8d 3c 33             	lea    (%ebx,%esi,1),%edi
  if(panicked){
801006ed:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
    consputc(buf[i] & 0xff);
801006f3:	0f b6 03             	movzbl (%ebx),%eax
  if(panicked){
801006f6:	85 d2                	test   %edx,%edx
801006f8:	74 06                	je     80100700 <consolewrite+0x40>
  asm volatile("cli");
801006fa:	fa                   	cli    
    for(;;)
801006fb:	eb fe                	jmp    801006fb <consolewrite+0x3b>
801006fd:	8d 76 00             	lea    0x0(%esi),%esi
80100700:	e8 2b fe ff ff       	call   80100530 <consputc.part.0>
  for(i = 0; i < n; i++)
80100705:	83 c3 01             	add    $0x1,%ebx
80100708:	39 df                	cmp    %ebx,%edi
8010070a:	75 e1                	jne    801006ed <consolewrite+0x2d>
  release(&cons.lock);
8010070c:	83 ec 0c             	sub    $0xc,%esp
8010070f:	68 20 ff 10 80       	push   $0x8010ff20
80100714:	e8 c7 41 00 00       	call   801048e0 <release>
  ilock(ip);
80100719:	58                   	pop    %eax
8010071a:	ff 75 08             	push   0x8(%ebp)
8010071d:	e8 be 12 00 00       	call   801019e0 <ilock>

  return n;
}
80100722:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100725:	89 f0                	mov    %esi,%eax
80100727:	5b                   	pop    %ebx
80100728:	5e                   	pop    %esi
80100729:	5f                   	pop    %edi
8010072a:	5d                   	pop    %ebp
8010072b:	c3                   	ret    
8010072c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100730 <printint>:
{
80100730:	55                   	push   %ebp
80100731:	89 e5                	mov    %esp,%ebp
80100733:	57                   	push   %edi
80100734:	56                   	push   %esi
80100735:	53                   	push   %ebx
80100736:	83 ec 2c             	sub    $0x2c,%esp
80100739:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010073c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  if(sign && (sign = xx < 0))
8010073f:	85 c9                	test   %ecx,%ecx
80100741:	74 04                	je     80100747 <printint+0x17>
80100743:	85 c0                	test   %eax,%eax
80100745:	78 6d                	js     801007b4 <printint+0x84>
    x = xx;
80100747:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010074e:	89 c1                	mov    %eax,%ecx
  i = 0;
80100750:	31 db                	xor    %ebx,%ebx
80100752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    buf[i++] = digits[x % base];
80100758:	89 c8                	mov    %ecx,%eax
8010075a:	31 d2                	xor    %edx,%edx
8010075c:	89 de                	mov    %ebx,%esi
8010075e:	89 cf                	mov    %ecx,%edi
80100760:	f7 75 d4             	divl   -0x2c(%ebp)
80100763:	8d 5b 01             	lea    0x1(%ebx),%ebx
80100766:	0f b6 92 d0 79 10 80 	movzbl -0x7fef8630(%edx),%edx
  }while((x /= base) != 0);
8010076d:	89 c1                	mov    %eax,%ecx
    buf[i++] = digits[x % base];
8010076f:	88 54 1d d7          	mov    %dl,-0x29(%ebp,%ebx,1)
  }while((x /= base) != 0);
80100773:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
80100776:	73 e0                	jae    80100758 <printint+0x28>
  if(sign)
80100778:	8b 4d d0             	mov    -0x30(%ebp),%ecx
8010077b:	85 c9                	test   %ecx,%ecx
8010077d:	74 0c                	je     8010078b <printint+0x5b>
    buf[i++] = '-';
8010077f:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    buf[i++] = digits[x % base];
80100784:	89 de                	mov    %ebx,%esi
    buf[i++] = '-';
80100786:	ba 2d 00 00 00       	mov    $0x2d,%edx
  while(--i >= 0)
8010078b:	8d 5c 35 d7          	lea    -0x29(%ebp,%esi,1),%ebx
8010078f:	0f be c2             	movsbl %dl,%eax
  if(panicked){
80100792:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100798:	85 d2                	test   %edx,%edx
8010079a:	74 04                	je     801007a0 <printint+0x70>
8010079c:	fa                   	cli    
    for(;;)
8010079d:	eb fe                	jmp    8010079d <printint+0x6d>
8010079f:	90                   	nop
801007a0:	e8 8b fd ff ff       	call   80100530 <consputc.part.0>
  while(--i >= 0)
801007a5:	8d 45 d7             	lea    -0x29(%ebp),%eax
801007a8:	39 c3                	cmp    %eax,%ebx
801007aa:	74 0e                	je     801007ba <printint+0x8a>
    consputc(buf[i]);
801007ac:	0f be 03             	movsbl (%ebx),%eax
801007af:	83 eb 01             	sub    $0x1,%ebx
801007b2:	eb de                	jmp    80100792 <printint+0x62>
    x = -xx;
801007b4:	f7 d8                	neg    %eax
801007b6:	89 c1                	mov    %eax,%ecx
801007b8:	eb 96                	jmp    80100750 <printint+0x20>
}
801007ba:	83 c4 2c             	add    $0x2c,%esp
801007bd:	5b                   	pop    %ebx
801007be:	5e                   	pop    %esi
801007bf:	5f                   	pop    %edi
801007c0:	5d                   	pop    %ebp
801007c1:	c3                   	ret    
801007c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801007c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801007d0 <cprintf>:
{
801007d0:	55                   	push   %ebp
801007d1:	89 e5                	mov    %esp,%ebp
801007d3:	57                   	push   %edi
801007d4:	56                   	push   %esi
801007d5:	53                   	push   %ebx
801007d6:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801007d9:	a1 54 ff 10 80       	mov    0x8010ff54,%eax
801007de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
801007e1:	85 c0                	test   %eax,%eax
801007e3:	0f 85 27 01 00 00    	jne    80100910 <cprintf+0x140>
  if (fmt == 0)
801007e9:	8b 75 08             	mov    0x8(%ebp),%esi
801007ec:	85 f6                	test   %esi,%esi
801007ee:	0f 84 ac 01 00 00    	je     801009a0 <cprintf+0x1d0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007f4:	0f b6 06             	movzbl (%esi),%eax
  argp = (uint*)(void*)(&fmt + 1);
801007f7:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007fa:	31 db                	xor    %ebx,%ebx
801007fc:	85 c0                	test   %eax,%eax
801007fe:	74 56                	je     80100856 <cprintf+0x86>
    if(c != '%'){
80100800:	83 f8 25             	cmp    $0x25,%eax
80100803:	0f 85 cf 00 00 00    	jne    801008d8 <cprintf+0x108>
    c = fmt[++i] & 0xff;
80100809:	83 c3 01             	add    $0x1,%ebx
8010080c:	0f b6 14 1e          	movzbl (%esi,%ebx,1),%edx
    if(c == 0)
80100810:	85 d2                	test   %edx,%edx
80100812:	74 42                	je     80100856 <cprintf+0x86>
    switch(c){
80100814:	83 fa 70             	cmp    $0x70,%edx
80100817:	0f 84 90 00 00 00    	je     801008ad <cprintf+0xdd>
8010081d:	7f 51                	jg     80100870 <cprintf+0xa0>
8010081f:	83 fa 25             	cmp    $0x25,%edx
80100822:	0f 84 c0 00 00 00    	je     801008e8 <cprintf+0x118>
80100828:	83 fa 64             	cmp    $0x64,%edx
8010082b:	0f 85 f4 00 00 00    	jne    80100925 <cprintf+0x155>
      printint(*argp++, 10, 1);
80100831:	8d 47 04             	lea    0x4(%edi),%eax
80100834:	b9 01 00 00 00       	mov    $0x1,%ecx
80100839:	ba 0a 00 00 00       	mov    $0xa,%edx
8010083e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100841:	8b 07                	mov    (%edi),%eax
80100843:	e8 e8 fe ff ff       	call   80100730 <printint>
80100848:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010084b:	83 c3 01             	add    $0x1,%ebx
8010084e:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
80100852:	85 c0                	test   %eax,%eax
80100854:	75 aa                	jne    80100800 <cprintf+0x30>
  if(locking)
80100856:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100859:	85 c0                	test   %eax,%eax
8010085b:	0f 85 22 01 00 00    	jne    80100983 <cprintf+0x1b3>
}
80100861:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100864:	5b                   	pop    %ebx
80100865:	5e                   	pop    %esi
80100866:	5f                   	pop    %edi
80100867:	5d                   	pop    %ebp
80100868:	c3                   	ret    
80100869:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100870:	83 fa 73             	cmp    $0x73,%edx
80100873:	75 33                	jne    801008a8 <cprintf+0xd8>
      if((s = (char*)*argp++) == 0)
80100875:	8d 47 04             	lea    0x4(%edi),%eax
80100878:	8b 3f                	mov    (%edi),%edi
8010087a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010087d:	85 ff                	test   %edi,%edi
8010087f:	0f 84 e3 00 00 00    	je     80100968 <cprintf+0x198>
      for(; *s; s++)
80100885:	0f be 07             	movsbl (%edi),%eax
80100888:	84 c0                	test   %al,%al
8010088a:	0f 84 08 01 00 00    	je     80100998 <cprintf+0x1c8>
  if(panicked){
80100890:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100896:	85 d2                	test   %edx,%edx
80100898:	0f 84 b2 00 00 00    	je     80100950 <cprintf+0x180>
8010089e:	fa                   	cli    
    for(;;)
8010089f:	eb fe                	jmp    8010089f <cprintf+0xcf>
801008a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
801008a8:	83 fa 78             	cmp    $0x78,%edx
801008ab:	75 78                	jne    80100925 <cprintf+0x155>
      printint(*argp++, 16, 0);
801008ad:	8d 47 04             	lea    0x4(%edi),%eax
801008b0:	31 c9                	xor    %ecx,%ecx
801008b2:	ba 10 00 00 00       	mov    $0x10,%edx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801008b7:	83 c3 01             	add    $0x1,%ebx
      printint(*argp++, 16, 0);
801008ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
801008bd:	8b 07                	mov    (%edi),%eax
801008bf:	e8 6c fe ff ff       	call   80100730 <printint>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801008c4:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
      printint(*argp++, 16, 0);
801008c8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801008cb:	85 c0                	test   %eax,%eax
801008cd:	0f 85 2d ff ff ff    	jne    80100800 <cprintf+0x30>
801008d3:	eb 81                	jmp    80100856 <cprintf+0x86>
801008d5:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
801008d8:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
801008de:	85 c9                	test   %ecx,%ecx
801008e0:	74 14                	je     801008f6 <cprintf+0x126>
801008e2:	fa                   	cli    
    for(;;)
801008e3:	eb fe                	jmp    801008e3 <cprintf+0x113>
801008e5:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
801008e8:	a1 58 ff 10 80       	mov    0x8010ff58,%eax
801008ed:	85 c0                	test   %eax,%eax
801008ef:	75 6c                	jne    8010095d <cprintf+0x18d>
801008f1:	b8 25 00 00 00       	mov    $0x25,%eax
801008f6:	e8 35 fc ff ff       	call   80100530 <consputc.part.0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801008fb:	83 c3 01             	add    $0x1,%ebx
801008fe:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
80100902:	85 c0                	test   %eax,%eax
80100904:	0f 85 f6 fe ff ff    	jne    80100800 <cprintf+0x30>
8010090a:	e9 47 ff ff ff       	jmp    80100856 <cprintf+0x86>
8010090f:	90                   	nop
    acquire(&cons.lock);
80100910:	83 ec 0c             	sub    $0xc,%esp
80100913:	68 20 ff 10 80       	push   $0x8010ff20
80100918:	e8 23 40 00 00       	call   80104940 <acquire>
8010091d:	83 c4 10             	add    $0x10,%esp
80100920:	e9 c4 fe ff ff       	jmp    801007e9 <cprintf+0x19>
  if(panicked){
80100925:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
8010092b:	85 c9                	test   %ecx,%ecx
8010092d:	75 31                	jne    80100960 <cprintf+0x190>
8010092f:	b8 25 00 00 00       	mov    $0x25,%eax
80100934:	89 55 e0             	mov    %edx,-0x20(%ebp)
80100937:	e8 f4 fb ff ff       	call   80100530 <consputc.part.0>
8010093c:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100942:	85 d2                	test   %edx,%edx
80100944:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100947:	74 2e                	je     80100977 <cprintf+0x1a7>
80100949:	fa                   	cli    
    for(;;)
8010094a:	eb fe                	jmp    8010094a <cprintf+0x17a>
8010094c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100950:	e8 db fb ff ff       	call   80100530 <consputc.part.0>
      for(; *s; s++)
80100955:	83 c7 01             	add    $0x1,%edi
80100958:	e9 28 ff ff ff       	jmp    80100885 <cprintf+0xb5>
8010095d:	fa                   	cli    
    for(;;)
8010095e:	eb fe                	jmp    8010095e <cprintf+0x18e>
80100960:	fa                   	cli    
80100961:	eb fe                	jmp    80100961 <cprintf+0x191>
80100963:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100967:	90                   	nop
        s = "(null)";
80100968:	bf b8 79 10 80       	mov    $0x801079b8,%edi
      for(; *s; s++)
8010096d:	b8 28 00 00 00       	mov    $0x28,%eax
80100972:	e9 19 ff ff ff       	jmp    80100890 <cprintf+0xc0>
80100977:	89 d0                	mov    %edx,%eax
80100979:	e8 b2 fb ff ff       	call   80100530 <consputc.part.0>
8010097e:	e9 c8 fe ff ff       	jmp    8010084b <cprintf+0x7b>
    release(&cons.lock);
80100983:	83 ec 0c             	sub    $0xc,%esp
80100986:	68 20 ff 10 80       	push   $0x8010ff20
8010098b:	e8 50 3f 00 00       	call   801048e0 <release>
80100990:	83 c4 10             	add    $0x10,%esp
}
80100993:	e9 c9 fe ff ff       	jmp    80100861 <cprintf+0x91>
      if((s = (char*)*argp++) == 0)
80100998:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010099b:	e9 ab fe ff ff       	jmp    8010084b <cprintf+0x7b>
    panic("null fmt");
801009a0:	83 ec 0c             	sub    $0xc,%esp
801009a3:	68 bf 79 10 80       	push   $0x801079bf
801009a8:	e8 03 fb ff ff       	call   801004b0 <panic>
801009ad:	8d 76 00             	lea    0x0(%esi),%esi

801009b0 <consoleintr>:
{
801009b0:	55                   	push   %ebp
801009b1:	89 e5                	mov    %esp,%ebp
801009b3:	57                   	push   %edi
801009b4:	56                   	push   %esi
  int c, doprocdump = 0;
801009b5:	31 f6                	xor    %esi,%esi
{
801009b7:	53                   	push   %ebx
801009b8:	83 ec 18             	sub    $0x18,%esp
801009bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  acquire(&cons.lock);
801009be:	68 20 ff 10 80       	push   $0x8010ff20
801009c3:	e8 78 3f 00 00       	call   80104940 <acquire>
  while((c = getc()) >= 0){
801009c8:	83 c4 10             	add    $0x10,%esp
801009cb:	eb 1a                	jmp    801009e7 <consoleintr+0x37>
801009cd:	8d 76 00             	lea    0x0(%esi),%esi
    switch(c){
801009d0:	83 fb 08             	cmp    $0x8,%ebx
801009d3:	0f 84 d7 00 00 00    	je     80100ab0 <consoleintr+0x100>
801009d9:	83 fb 10             	cmp    $0x10,%ebx
801009dc:	0f 85 32 01 00 00    	jne    80100b14 <consoleintr+0x164>
801009e2:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
801009e7:	ff d7                	call   *%edi
801009e9:	89 c3                	mov    %eax,%ebx
801009eb:	85 c0                	test   %eax,%eax
801009ed:	0f 88 05 01 00 00    	js     80100af8 <consoleintr+0x148>
    switch(c){
801009f3:	83 fb 15             	cmp    $0x15,%ebx
801009f6:	74 78                	je     80100a70 <consoleintr+0xc0>
801009f8:	7e d6                	jle    801009d0 <consoleintr+0x20>
801009fa:	83 fb 7f             	cmp    $0x7f,%ebx
801009fd:	0f 84 ad 00 00 00    	je     80100ab0 <consoleintr+0x100>
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100a03:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100a08:	89 c2                	mov    %eax,%edx
80100a0a:	2b 15 00 ff 10 80    	sub    0x8010ff00,%edx
80100a10:	83 fa 7f             	cmp    $0x7f,%edx
80100a13:	77 d2                	ja     801009e7 <consoleintr+0x37>
        input.buf[input.e++ % INPUT_BUF] = c;
80100a15:	8d 48 01             	lea    0x1(%eax),%ecx
  if(panicked){
80100a18:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
        input.buf[input.e++ % INPUT_BUF] = c;
80100a1e:	83 e0 7f             	and    $0x7f,%eax
80100a21:	89 0d 08 ff 10 80    	mov    %ecx,0x8010ff08
        c = (c == '\r') ? '\n' : c;
80100a27:	83 fb 0d             	cmp    $0xd,%ebx
80100a2a:	0f 84 13 01 00 00    	je     80100b43 <consoleintr+0x193>
        input.buf[input.e++ % INPUT_BUF] = c;
80100a30:	88 98 80 fe 10 80    	mov    %bl,-0x7fef0180(%eax)
  if(panicked){
80100a36:	85 d2                	test   %edx,%edx
80100a38:	0f 85 10 01 00 00    	jne    80100b4e <consoleintr+0x19e>
80100a3e:	89 d8                	mov    %ebx,%eax
80100a40:	e8 eb fa ff ff       	call   80100530 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100a45:	83 fb 0a             	cmp    $0xa,%ebx
80100a48:	0f 84 14 01 00 00    	je     80100b62 <consoleintr+0x1b2>
80100a4e:	83 fb 04             	cmp    $0x4,%ebx
80100a51:	0f 84 0b 01 00 00    	je     80100b62 <consoleintr+0x1b2>
80100a57:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80100a5c:	83 e8 80             	sub    $0xffffff80,%eax
80100a5f:	39 05 08 ff 10 80    	cmp    %eax,0x8010ff08
80100a65:	75 80                	jne    801009e7 <consoleintr+0x37>
80100a67:	e9 fb 00 00 00       	jmp    80100b67 <consoleintr+0x1b7>
80100a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      while(input.e != input.w &&
80100a70:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100a75:	39 05 04 ff 10 80    	cmp    %eax,0x8010ff04
80100a7b:	0f 84 66 ff ff ff    	je     801009e7 <consoleintr+0x37>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100a81:	83 e8 01             	sub    $0x1,%eax
80100a84:	89 c2                	mov    %eax,%edx
80100a86:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100a89:	80 ba 80 fe 10 80 0a 	cmpb   $0xa,-0x7fef0180(%edx)
80100a90:	0f 84 51 ff ff ff    	je     801009e7 <consoleintr+0x37>
  if(panicked){
80100a96:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
        input.e--;
80100a9c:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
  if(panicked){
80100aa1:	85 d2                	test   %edx,%edx
80100aa3:	74 33                	je     80100ad8 <consoleintr+0x128>
80100aa5:	fa                   	cli    
    for(;;)
80100aa6:	eb fe                	jmp    80100aa6 <consoleintr+0xf6>
80100aa8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100aaf:	90                   	nop
      if(input.e != input.w){
80100ab0:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100ab5:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
80100abb:	0f 84 26 ff ff ff    	je     801009e7 <consoleintr+0x37>
        input.e--;
80100ac1:	83 e8 01             	sub    $0x1,%eax
80100ac4:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
  if(panicked){
80100ac9:	a1 58 ff 10 80       	mov    0x8010ff58,%eax
80100ace:	85 c0                	test   %eax,%eax
80100ad0:	74 56                	je     80100b28 <consoleintr+0x178>
80100ad2:	fa                   	cli    
    for(;;)
80100ad3:	eb fe                	jmp    80100ad3 <consoleintr+0x123>
80100ad5:	8d 76 00             	lea    0x0(%esi),%esi
80100ad8:	b8 00 01 00 00       	mov    $0x100,%eax
80100add:	e8 4e fa ff ff       	call   80100530 <consputc.part.0>
      while(input.e != input.w &&
80100ae2:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100ae7:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
80100aed:	75 92                	jne    80100a81 <consoleintr+0xd1>
80100aef:	e9 f3 fe ff ff       	jmp    801009e7 <consoleintr+0x37>
80100af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&cons.lock);
80100af8:	83 ec 0c             	sub    $0xc,%esp
80100afb:	68 20 ff 10 80       	push   $0x8010ff20
80100b00:	e8 db 3d 00 00       	call   801048e0 <release>
  if(doprocdump) {
80100b05:	83 c4 10             	add    $0x10,%esp
80100b08:	85 f6                	test   %esi,%esi
80100b0a:	75 2b                	jne    80100b37 <consoleintr+0x187>
}
80100b0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100b0f:	5b                   	pop    %ebx
80100b10:	5e                   	pop    %esi
80100b11:	5f                   	pop    %edi
80100b12:	5d                   	pop    %ebp
80100b13:	c3                   	ret    
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100b14:	85 db                	test   %ebx,%ebx
80100b16:	0f 84 cb fe ff ff    	je     801009e7 <consoleintr+0x37>
80100b1c:	e9 e2 fe ff ff       	jmp    80100a03 <consoleintr+0x53>
80100b21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100b28:	b8 00 01 00 00       	mov    $0x100,%eax
80100b2d:	e8 fe f9 ff ff       	call   80100530 <consputc.part.0>
80100b32:	e9 b0 fe ff ff       	jmp    801009e7 <consoleintr+0x37>
}
80100b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100b3a:	5b                   	pop    %ebx
80100b3b:	5e                   	pop    %esi
80100b3c:	5f                   	pop    %edi
80100b3d:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100b3e:	e9 ed 39 00 00       	jmp    80104530 <procdump>
        input.buf[input.e++ % INPUT_BUF] = c;
80100b43:	c6 80 80 fe 10 80 0a 	movb   $0xa,-0x7fef0180(%eax)
  if(panicked){
80100b4a:	85 d2                	test   %edx,%edx
80100b4c:	74 0a                	je     80100b58 <consoleintr+0x1a8>
80100b4e:	fa                   	cli    
    for(;;)
80100b4f:	eb fe                	jmp    80100b4f <consoleintr+0x19f>
80100b51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100b58:	b8 0a 00 00 00       	mov    $0xa,%eax
80100b5d:	e8 ce f9 ff ff       	call   80100530 <consputc.part.0>
          input.w = input.e;
80100b62:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
          wakeup(&input.r);
80100b67:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
80100b6a:	a3 04 ff 10 80       	mov    %eax,0x8010ff04
          wakeup(&input.r);
80100b6f:	68 00 ff 10 80       	push   $0x8010ff00
80100b74:	e8 d7 38 00 00       	call   80104450 <wakeup>
80100b79:	83 c4 10             	add    $0x10,%esp
80100b7c:	e9 66 fe ff ff       	jmp    801009e7 <consoleintr+0x37>
80100b81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100b88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100b8f:	90                   	nop

80100b90 <consoleinit>:

void
consoleinit(void)
{
80100b90:	55                   	push   %ebp
80100b91:	89 e5                	mov    %esp,%ebp
80100b93:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100b96:	68 c8 79 10 80       	push   $0x801079c8
80100b9b:	68 20 ff 10 80       	push   $0x8010ff20
80100ba0:	e8 cb 3b 00 00       	call   80104770 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
80100ba5:	58                   	pop    %eax
80100ba6:	5a                   	pop    %edx
80100ba7:	6a 00                	push   $0x0
80100ba9:	6a 01                	push   $0x1
  devsw[CONSOLE].write = consolewrite;
80100bab:	c7 05 0c 09 11 80 c0 	movl   $0x801006c0,0x8011090c
80100bb2:	06 10 80 
  devsw[CONSOLE].read = consoleread;
80100bb5:	c7 05 08 09 11 80 b0 	movl   $0x801003b0,0x80110908
80100bbc:	03 10 80 
  cons.locking = 1;
80100bbf:	c7 05 54 ff 10 80 01 	movl   $0x1,0x8010ff54
80100bc6:	00 00 00 
  ioapicenable(IRQ_KBD, 0);
80100bc9:	e8 12 1b 00 00       	call   801026e0 <ioapicenable>
}
80100bce:	83 c4 10             	add    $0x10,%esp
80100bd1:	c9                   	leave  
80100bd2:	c3                   	ret    
80100bd3:	66 90                	xchg   %ax,%ax
80100bd5:	66 90                	xchg   %ax,%ax
80100bd7:	66 90                	xchg   %ax,%ax
80100bd9:	66 90                	xchg   %ax,%ax
80100bdb:	66 90                	xchg   %ax,%ax
80100bdd:	66 90                	xchg   %ax,%ax
80100bdf:	90                   	nop

80100be0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100be0:	55                   	push   %ebp
80100be1:	89 e5                	mov    %esp,%ebp
80100be3:	57                   	push   %edi
80100be4:	56                   	push   %esi
80100be5:	53                   	push   %ebx
80100be6:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bec:	e8 5f 30 00 00       	call   80103c50 <myproc>
80100bf1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100bf7:	e8 24 24 00 00       	call   80103020 <begin_op>

  if((ip = namei(path)) == 0){
80100bfc:	83 ec 0c             	sub    $0xc,%esp
80100bff:	ff 75 08             	push   0x8(%ebp)
80100c02:	e8 f9 16 00 00       	call   80102300 <namei>
80100c07:	83 c4 10             	add    $0x10,%esp
80100c0a:	85 c0                	test   %eax,%eax
80100c0c:	0f 84 02 03 00 00    	je     80100f14 <exec+0x334>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100c12:	83 ec 0c             	sub    $0xc,%esp
80100c15:	89 c3                	mov    %eax,%ebx
80100c17:	50                   	push   %eax
80100c18:	e8 c3 0d 00 00       	call   801019e0 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c1d:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100c23:	6a 34                	push   $0x34
80100c25:	6a 00                	push   $0x0
80100c27:	50                   	push   %eax
80100c28:	53                   	push   %ebx
80100c29:	e8 c2 10 00 00       	call   80101cf0 <readi>
80100c2e:	83 c4 20             	add    $0x20,%esp
80100c31:	83 f8 34             	cmp    $0x34,%eax
80100c34:	74 22                	je     80100c58 <exec+0x78>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100c36:	83 ec 0c             	sub    $0xc,%esp
80100c39:	53                   	push   %ebx
80100c3a:	e8 31 10 00 00       	call   80101c70 <iunlockput>
    end_op();
80100c3f:	e8 4c 24 00 00       	call   80103090 <end_op>
80100c44:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100c47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100c4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100c4f:	5b                   	pop    %ebx
80100c50:	5e                   	pop    %esi
80100c51:	5f                   	pop    %edi
80100c52:	5d                   	pop    %ebp
80100c53:	c3                   	ret    
80100c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(elf.magic != ELF_MAGIC)
80100c58:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100c5f:	45 4c 46 
80100c62:	75 d2                	jne    80100c36 <exec+0x56>
  if((pgdir = setupkvm()) == 0)
80100c64:	e8 c7 65 00 00       	call   80107230 <setupkvm>
80100c69:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100c6f:	85 c0                	test   %eax,%eax
80100c71:	74 c3                	je     80100c36 <exec+0x56>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c73:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100c7a:	00 
80100c7b:	8b b5 40 ff ff ff    	mov    -0xc0(%ebp),%esi
80100c81:	0f 84 ac 02 00 00    	je     80100f33 <exec+0x353>
  sz = 0;
80100c87:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100c8e:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c91:	31 ff                	xor    %edi,%edi
80100c93:	e9 8e 00 00 00       	jmp    80100d26 <exec+0x146>
80100c98:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100c9f:	90                   	nop
    if(ph.type != ELF_PROG_LOAD)
80100ca0:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100ca7:	75 6c                	jne    80100d15 <exec+0x135>
    if(ph.memsz < ph.filesz)
80100ca9:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100caf:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100cb5:	0f 82 87 00 00 00    	jb     80100d42 <exec+0x162>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cbb:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100cc1:	72 7f                	jb     80100d42 <exec+0x162>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cc3:	83 ec 04             	sub    $0x4,%esp
80100cc6:	50                   	push   %eax
80100cc7:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100ccd:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100cd3:	e8 78 63 00 00       	call   80107050 <allocuvm>
80100cd8:	83 c4 10             	add    $0x10,%esp
80100cdb:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100ce1:	85 c0                	test   %eax,%eax
80100ce3:	74 5d                	je     80100d42 <exec+0x162>
    if(ph.vaddr % PGSIZE != 0)
80100ce5:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100ceb:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100cf0:	75 50                	jne    80100d42 <exec+0x162>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cf2:	83 ec 0c             	sub    $0xc,%esp
80100cf5:	ff b5 14 ff ff ff    	push   -0xec(%ebp)
80100cfb:	ff b5 08 ff ff ff    	push   -0xf8(%ebp)
80100d01:	53                   	push   %ebx
80100d02:	50                   	push   %eax
80100d03:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100d09:	e8 52 62 00 00       	call   80106f60 <loaduvm>
80100d0e:	83 c4 20             	add    $0x20,%esp
80100d11:	85 c0                	test   %eax,%eax
80100d13:	78 2d                	js     80100d42 <exec+0x162>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d15:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100d1c:	83 c7 01             	add    $0x1,%edi
80100d1f:	83 c6 20             	add    $0x20,%esi
80100d22:	39 f8                	cmp    %edi,%eax
80100d24:	7e 3a                	jle    80100d60 <exec+0x180>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d26:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100d2c:	6a 20                	push   $0x20
80100d2e:	56                   	push   %esi
80100d2f:	50                   	push   %eax
80100d30:	53                   	push   %ebx
80100d31:	e8 ba 0f 00 00       	call   80101cf0 <readi>
80100d36:	83 c4 10             	add    $0x10,%esp
80100d39:	83 f8 20             	cmp    $0x20,%eax
80100d3c:	0f 84 5e ff ff ff    	je     80100ca0 <exec+0xc0>
    freevm(pgdir);
80100d42:	83 ec 0c             	sub    $0xc,%esp
80100d45:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100d4b:	e8 60 64 00 00       	call   801071b0 <freevm>
  if(ip){
80100d50:	83 c4 10             	add    $0x10,%esp
80100d53:	e9 de fe ff ff       	jmp    80100c36 <exec+0x56>
80100d58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100d5f:	90                   	nop
  sz = PGROUNDUP(sz);
80100d60:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100d66:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
80100d6c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d72:	8d b7 00 20 00 00    	lea    0x2000(%edi),%esi
  iunlockput(ip);
80100d78:	83 ec 0c             	sub    $0xc,%esp
80100d7b:	53                   	push   %ebx
80100d7c:	e8 ef 0e 00 00       	call   80101c70 <iunlockput>
  end_op();
80100d81:	e8 0a 23 00 00       	call   80103090 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d86:	83 c4 0c             	add    $0xc,%esp
80100d89:	56                   	push   %esi
80100d8a:	57                   	push   %edi
80100d8b:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100d91:	57                   	push   %edi
80100d92:	e8 b9 62 00 00       	call   80107050 <allocuvm>
80100d97:	83 c4 10             	add    $0x10,%esp
80100d9a:	89 c6                	mov    %eax,%esi
80100d9c:	85 c0                	test   %eax,%eax
80100d9e:	0f 84 94 00 00 00    	je     80100e38 <exec+0x258>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100da4:	83 ec 08             	sub    $0x8,%esp
80100da7:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
  for(argc = 0; argv[argc]; argc++) {
80100dad:	89 f3                	mov    %esi,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100daf:	50                   	push   %eax
80100db0:	57                   	push   %edi
  for(argc = 0; argv[argc]; argc++) {
80100db1:	31 ff                	xor    %edi,%edi
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100db3:	e8 18 65 00 00       	call   801072d0 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100db8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dbb:	83 c4 10             	add    $0x10,%esp
80100dbe:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
80100dc4:	8b 00                	mov    (%eax),%eax
80100dc6:	85 c0                	test   %eax,%eax
80100dc8:	0f 84 8b 00 00 00    	je     80100e59 <exec+0x279>
80100dce:	89 b5 f0 fe ff ff    	mov    %esi,-0x110(%ebp)
80100dd4:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100dda:	eb 23                	jmp    80100dff <exec+0x21f>
80100ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100de0:	8b 45 0c             	mov    0xc(%ebp),%eax
    ustack[3+argc] = sp;
80100de3:	89 9c bd 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100dea:	83 c7 01             	add    $0x1,%edi
    ustack[3+argc] = sp;
80100ded:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
  for(argc = 0; argv[argc]; argc++) {
80100df3:	8b 04 b8             	mov    (%eax,%edi,4),%eax
80100df6:	85 c0                	test   %eax,%eax
80100df8:	74 59                	je     80100e53 <exec+0x273>
    if(argc >= MAXARG)
80100dfa:	83 ff 20             	cmp    $0x20,%edi
80100dfd:	74 39                	je     80100e38 <exec+0x258>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dff:	83 ec 0c             	sub    $0xc,%esp
80100e02:	50                   	push   %eax
80100e03:	e8 f8 3d 00 00       	call   80104c00 <strlen>
80100e08:	29 c3                	sub    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e0a:	58                   	pop    %eax
80100e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e0e:	83 eb 01             	sub    $0x1,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e11:	ff 34 b8             	push   (%eax,%edi,4)
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e14:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e17:	e8 e4 3d 00 00       	call   80104c00 <strlen>
80100e1c:	83 c0 01             	add    $0x1,%eax
80100e1f:	50                   	push   %eax
80100e20:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e23:	ff 34 b8             	push   (%eax,%edi,4)
80100e26:	53                   	push   %ebx
80100e27:	56                   	push   %esi
80100e28:	e8 73 66 00 00       	call   801074a0 <copyout>
80100e2d:	83 c4 20             	add    $0x20,%esp
80100e30:	85 c0                	test   %eax,%eax
80100e32:	79 ac                	jns    80100de0 <exec+0x200>
80100e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    freevm(pgdir);
80100e38:	83 ec 0c             	sub    $0xc,%esp
80100e3b:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100e41:	e8 6a 63 00 00       	call   801071b0 <freevm>
80100e46:	83 c4 10             	add    $0x10,%esp
  return -1;
80100e49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e4e:	e9 f9 fd ff ff       	jmp    80100c4c <exec+0x6c>
80100e53:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e59:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100e60:	89 d9                	mov    %ebx,%ecx
  ustack[3+argc] = 0;
80100e62:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100e69:	00 00 00 00 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e6d:	29 c1                	sub    %eax,%ecx
  sp -= (3+argc+1) * 4;
80100e6f:	83 c0 0c             	add    $0xc,%eax
  ustack[1] = argc;
80100e72:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  sp -= (3+argc+1) * 4;
80100e78:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e7a:	50                   	push   %eax
80100e7b:	52                   	push   %edx
80100e7c:	53                   	push   %ebx
80100e7d:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
  ustack[0] = 0xffffffff;  // fake return PC
80100e83:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100e8a:	ff ff ff 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e8d:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e93:	e8 08 66 00 00       	call   801074a0 <copyout>
80100e98:	83 c4 10             	add    $0x10,%esp
80100e9b:	85 c0                	test   %eax,%eax
80100e9d:	78 99                	js     80100e38 <exec+0x258>
  for(last=s=path; *s; s++)
80100e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80100ea2:	8b 55 08             	mov    0x8(%ebp),%edx
80100ea5:	0f b6 00             	movzbl (%eax),%eax
80100ea8:	84 c0                	test   %al,%al
80100eaa:	74 13                	je     80100ebf <exec+0x2df>
80100eac:	89 d1                	mov    %edx,%ecx
80100eae:	66 90                	xchg   %ax,%ax
      last = s+1;
80100eb0:	83 c1 01             	add    $0x1,%ecx
80100eb3:	3c 2f                	cmp    $0x2f,%al
  for(last=s=path; *s; s++)
80100eb5:	0f b6 01             	movzbl (%ecx),%eax
      last = s+1;
80100eb8:	0f 44 d1             	cmove  %ecx,%edx
  for(last=s=path; *s; s++)
80100ebb:	84 c0                	test   %al,%al
80100ebd:	75 f1                	jne    80100eb0 <exec+0x2d0>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100ebf:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100ec5:	83 ec 04             	sub    $0x4,%esp
80100ec8:	6a 10                	push   $0x10
80100eca:	89 f8                	mov    %edi,%eax
80100ecc:	52                   	push   %edx
80100ecd:	83 c0 70             	add    $0x70,%eax
80100ed0:	50                   	push   %eax
80100ed1:	e8 ea 3c 00 00       	call   80104bc0 <safestrcpy>
  curproc->pgdir = pgdir;
80100ed6:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  oldpgdir = curproc->pgdir;
80100edc:	89 f8                	mov    %edi,%eax
80100ede:	8b 7f 08             	mov    0x8(%edi),%edi
  curproc->sz = sz;
80100ee1:	89 30                	mov    %esi,(%eax)
  curproc->pgdir = pgdir;
80100ee3:	89 48 08             	mov    %ecx,0x8(%eax)
  curproc->tf->eip = elf.entry;  // main
80100ee6:	89 c1                	mov    %eax,%ecx
80100ee8:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100eee:	8b 40 1c             	mov    0x1c(%eax),%eax
80100ef1:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100ef4:	8b 41 1c             	mov    0x1c(%ecx),%eax
80100ef7:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100efa:	89 0c 24             	mov    %ecx,(%esp)
80100efd:	e8 ce 5e 00 00       	call   80106dd0 <switchuvm>
  freevm(oldpgdir);
80100f02:	89 3c 24             	mov    %edi,(%esp)
80100f05:	e8 a6 62 00 00       	call   801071b0 <freevm>
  return 0;
80100f0a:	83 c4 10             	add    $0x10,%esp
80100f0d:	31 c0                	xor    %eax,%eax
80100f0f:	e9 38 fd ff ff       	jmp    80100c4c <exec+0x6c>
    end_op();
80100f14:	e8 77 21 00 00       	call   80103090 <end_op>
    cprintf("exec: fail\n");
80100f19:	83 ec 0c             	sub    $0xc,%esp
80100f1c:	68 e1 79 10 80       	push   $0x801079e1
80100f21:	e8 aa f8 ff ff       	call   801007d0 <cprintf>
    return -1;
80100f26:	83 c4 10             	add    $0x10,%esp
80100f29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f2e:	e9 19 fd ff ff       	jmp    80100c4c <exec+0x6c>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100f33:	be 00 20 00 00       	mov    $0x2000,%esi
80100f38:	31 ff                	xor    %edi,%edi
80100f3a:	e9 39 fe ff ff       	jmp    80100d78 <exec+0x198>
80100f3f:	90                   	nop

80100f40 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f40:	55                   	push   %ebp
80100f41:	89 e5                	mov    %esp,%ebp
80100f43:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100f46:	68 ed 79 10 80       	push   $0x801079ed
80100f4b:	68 60 ff 10 80       	push   $0x8010ff60
80100f50:	e8 1b 38 00 00       	call   80104770 <initlock>
}
80100f55:	83 c4 10             	add    $0x10,%esp
80100f58:	c9                   	leave  
80100f59:	c3                   	ret    
80100f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100f60 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f60:	55                   	push   %ebp
80100f61:	89 e5                	mov    %esp,%ebp
80100f63:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f64:	bb 94 ff 10 80       	mov    $0x8010ff94,%ebx
{
80100f69:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100f6c:	68 60 ff 10 80       	push   $0x8010ff60
80100f71:	e8 ca 39 00 00       	call   80104940 <acquire>
80100f76:	83 c4 10             	add    $0x10,%esp
80100f79:	eb 10                	jmp    80100f8b <filealloc+0x2b>
80100f7b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100f7f:	90                   	nop
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f80:	83 c3 18             	add    $0x18,%ebx
80100f83:	81 fb f4 08 11 80    	cmp    $0x801108f4,%ebx
80100f89:	74 25                	je     80100fb0 <filealloc+0x50>
    if(f->ref == 0){
80100f8b:	8b 43 04             	mov    0x4(%ebx),%eax
80100f8e:	85 c0                	test   %eax,%eax
80100f90:	75 ee                	jne    80100f80 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100f92:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100f95:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100f9c:	68 60 ff 10 80       	push   $0x8010ff60
80100fa1:	e8 3a 39 00 00       	call   801048e0 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100fa6:	89 d8                	mov    %ebx,%eax
      return f;
80100fa8:	83 c4 10             	add    $0x10,%esp
}
80100fab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100fae:	c9                   	leave  
80100faf:	c3                   	ret    
  release(&ftable.lock);
80100fb0:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100fb3:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100fb5:	68 60 ff 10 80       	push   $0x8010ff60
80100fba:	e8 21 39 00 00       	call   801048e0 <release>
}
80100fbf:	89 d8                	mov    %ebx,%eax
  return 0;
80100fc1:	83 c4 10             	add    $0x10,%esp
}
80100fc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100fc7:	c9                   	leave  
80100fc8:	c3                   	ret    
80100fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100fd0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fd0:	55                   	push   %ebp
80100fd1:	89 e5                	mov    %esp,%ebp
80100fd3:	53                   	push   %ebx
80100fd4:	83 ec 10             	sub    $0x10,%esp
80100fd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100fda:	68 60 ff 10 80       	push   $0x8010ff60
80100fdf:	e8 5c 39 00 00       	call   80104940 <acquire>
  if(f->ref < 1)
80100fe4:	8b 43 04             	mov    0x4(%ebx),%eax
80100fe7:	83 c4 10             	add    $0x10,%esp
80100fea:	85 c0                	test   %eax,%eax
80100fec:	7e 1a                	jle    80101008 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100fee:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100ff1:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80100ff4:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100ff7:	68 60 ff 10 80       	push   $0x8010ff60
80100ffc:	e8 df 38 00 00       	call   801048e0 <release>
  return f;
}
80101001:	89 d8                	mov    %ebx,%eax
80101003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101006:	c9                   	leave  
80101007:	c3                   	ret    
    panic("filedup");
80101008:	83 ec 0c             	sub    $0xc,%esp
8010100b:	68 f4 79 10 80       	push   $0x801079f4
80101010:	e8 9b f4 ff ff       	call   801004b0 <panic>
80101015:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010101c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101020 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101020:	55                   	push   %ebp
80101021:	89 e5                	mov    %esp,%ebp
80101023:	57                   	push   %edi
80101024:	56                   	push   %esi
80101025:	53                   	push   %ebx
80101026:	83 ec 28             	sub    $0x28,%esp
80101029:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
8010102c:	68 60 ff 10 80       	push   $0x8010ff60
80101031:	e8 0a 39 00 00       	call   80104940 <acquire>
  if(f->ref < 1)
80101036:	8b 53 04             	mov    0x4(%ebx),%edx
80101039:	83 c4 10             	add    $0x10,%esp
8010103c:	85 d2                	test   %edx,%edx
8010103e:	0f 8e a5 00 00 00    	jle    801010e9 <fileclose+0xc9>
    panic("fileclose");
  if(--f->ref > 0){
80101044:	83 ea 01             	sub    $0x1,%edx
80101047:	89 53 04             	mov    %edx,0x4(%ebx)
8010104a:	75 44                	jne    80101090 <fileclose+0x70>
    release(&ftable.lock);
    return;
  }
  ff = *f;
8010104c:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80101050:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80101053:	8b 3b                	mov    (%ebx),%edi
  f->type = FD_NONE;
80101055:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
8010105b:	8b 73 0c             	mov    0xc(%ebx),%esi
8010105e:	88 45 e7             	mov    %al,-0x19(%ebp)
80101061:	8b 43 10             	mov    0x10(%ebx),%eax
  release(&ftable.lock);
80101064:	68 60 ff 10 80       	push   $0x8010ff60
  ff = *f;
80101069:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
8010106c:	e8 6f 38 00 00       	call   801048e0 <release>

  if(ff.type == FD_PIPE)
80101071:	83 c4 10             	add    $0x10,%esp
80101074:	83 ff 01             	cmp    $0x1,%edi
80101077:	74 57                	je     801010d0 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80101079:	83 ff 02             	cmp    $0x2,%edi
8010107c:	74 2a                	je     801010a8 <fileclose+0x88>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
8010107e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101081:	5b                   	pop    %ebx
80101082:	5e                   	pop    %esi
80101083:	5f                   	pop    %edi
80101084:	5d                   	pop    %ebp
80101085:	c3                   	ret    
80101086:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010108d:	8d 76 00             	lea    0x0(%esi),%esi
    release(&ftable.lock);
80101090:	c7 45 08 60 ff 10 80 	movl   $0x8010ff60,0x8(%ebp)
}
80101097:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010109a:	5b                   	pop    %ebx
8010109b:	5e                   	pop    %esi
8010109c:	5f                   	pop    %edi
8010109d:	5d                   	pop    %ebp
    release(&ftable.lock);
8010109e:	e9 3d 38 00 00       	jmp    801048e0 <release>
801010a3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801010a7:	90                   	nop
    begin_op();
801010a8:	e8 73 1f 00 00       	call   80103020 <begin_op>
    iput(ff.ip);
801010ad:	83 ec 0c             	sub    $0xc,%esp
801010b0:	ff 75 e0             	push   -0x20(%ebp)
801010b3:	e8 58 0a 00 00       	call   80101b10 <iput>
    end_op();
801010b8:	83 c4 10             	add    $0x10,%esp
}
801010bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010be:	5b                   	pop    %ebx
801010bf:	5e                   	pop    %esi
801010c0:	5f                   	pop    %edi
801010c1:	5d                   	pop    %ebp
    end_op();
801010c2:	e9 c9 1f 00 00       	jmp    80103090 <end_op>
801010c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010ce:	66 90                	xchg   %ax,%ax
    pipeclose(ff.pipe, ff.writable);
801010d0:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
801010d4:	83 ec 08             	sub    $0x8,%esp
801010d7:	53                   	push   %ebx
801010d8:	56                   	push   %esi
801010d9:	e8 32 27 00 00       	call   80103810 <pipeclose>
801010de:	83 c4 10             	add    $0x10,%esp
}
801010e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010e4:	5b                   	pop    %ebx
801010e5:	5e                   	pop    %esi
801010e6:	5f                   	pop    %edi
801010e7:	5d                   	pop    %ebp
801010e8:	c3                   	ret    
    panic("fileclose");
801010e9:	83 ec 0c             	sub    $0xc,%esp
801010ec:	68 fc 79 10 80       	push   $0x801079fc
801010f1:	e8 ba f3 ff ff       	call   801004b0 <panic>
801010f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010fd:	8d 76 00             	lea    0x0(%esi),%esi

80101100 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101100:	55                   	push   %ebp
80101101:	89 e5                	mov    %esp,%ebp
80101103:	53                   	push   %ebx
80101104:	83 ec 04             	sub    $0x4,%esp
80101107:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
8010110a:	83 3b 02             	cmpl   $0x2,(%ebx)
8010110d:	75 31                	jne    80101140 <filestat+0x40>
    ilock(f->ip);
8010110f:	83 ec 0c             	sub    $0xc,%esp
80101112:	ff 73 10             	push   0x10(%ebx)
80101115:	e8 c6 08 00 00       	call   801019e0 <ilock>
    stati(f->ip, st);
8010111a:	58                   	pop    %eax
8010111b:	5a                   	pop    %edx
8010111c:	ff 75 0c             	push   0xc(%ebp)
8010111f:	ff 73 10             	push   0x10(%ebx)
80101122:	e8 99 0b 00 00       	call   80101cc0 <stati>
    iunlock(f->ip);
80101127:	59                   	pop    %ecx
80101128:	ff 73 10             	push   0x10(%ebx)
8010112b:	e8 90 09 00 00       	call   80101ac0 <iunlock>
    return 0;
  }
  return -1;
}
80101130:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return 0;
80101133:	83 c4 10             	add    $0x10,%esp
80101136:	31 c0                	xor    %eax,%eax
}
80101138:	c9                   	leave  
80101139:	c3                   	ret    
8010113a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101140:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80101143:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101148:	c9                   	leave  
80101149:	c3                   	ret    
8010114a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101150 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101150:	55                   	push   %ebp
80101151:	89 e5                	mov    %esp,%ebp
80101153:	57                   	push   %edi
80101154:	56                   	push   %esi
80101155:	53                   	push   %ebx
80101156:	83 ec 0c             	sub    $0xc,%esp
80101159:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010115c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010115f:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80101162:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80101166:	74 60                	je     801011c8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80101168:	8b 03                	mov    (%ebx),%eax
8010116a:	83 f8 01             	cmp    $0x1,%eax
8010116d:	74 41                	je     801011b0 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010116f:	83 f8 02             	cmp    $0x2,%eax
80101172:	75 5b                	jne    801011cf <fileread+0x7f>
    ilock(f->ip);
80101174:	83 ec 0c             	sub    $0xc,%esp
80101177:	ff 73 10             	push   0x10(%ebx)
8010117a:	e8 61 08 00 00       	call   801019e0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010117f:	57                   	push   %edi
80101180:	ff 73 14             	push   0x14(%ebx)
80101183:	56                   	push   %esi
80101184:	ff 73 10             	push   0x10(%ebx)
80101187:	e8 64 0b 00 00       	call   80101cf0 <readi>
8010118c:	83 c4 20             	add    $0x20,%esp
8010118f:	89 c6                	mov    %eax,%esi
80101191:	85 c0                	test   %eax,%eax
80101193:	7e 03                	jle    80101198 <fileread+0x48>
      f->off += r;
80101195:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80101198:	83 ec 0c             	sub    $0xc,%esp
8010119b:	ff 73 10             	push   0x10(%ebx)
8010119e:	e8 1d 09 00 00       	call   80101ac0 <iunlock>
    return r;
801011a3:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
801011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011a9:	89 f0                	mov    %esi,%eax
801011ab:	5b                   	pop    %ebx
801011ac:	5e                   	pop    %esi
801011ad:	5f                   	pop    %edi
801011ae:	5d                   	pop    %ebp
801011af:	c3                   	ret    
    return piperead(f->pipe, addr, n);
801011b0:	8b 43 0c             	mov    0xc(%ebx),%eax
801011b3:	89 45 08             	mov    %eax,0x8(%ebp)
}
801011b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011b9:	5b                   	pop    %ebx
801011ba:	5e                   	pop    %esi
801011bb:	5f                   	pop    %edi
801011bc:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
801011bd:	e9 ee 27 00 00       	jmp    801039b0 <piperead>
801011c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801011c8:	be ff ff ff ff       	mov    $0xffffffff,%esi
801011cd:	eb d7                	jmp    801011a6 <fileread+0x56>
  panic("fileread");
801011cf:	83 ec 0c             	sub    $0xc,%esp
801011d2:	68 06 7a 10 80       	push   $0x80107a06
801011d7:	e8 d4 f2 ff ff       	call   801004b0 <panic>
801011dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801011e0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011e0:	55                   	push   %ebp
801011e1:	89 e5                	mov    %esp,%ebp
801011e3:	57                   	push   %edi
801011e4:	56                   	push   %esi
801011e5:	53                   	push   %ebx
801011e6:	83 ec 1c             	sub    $0x1c,%esp
801011e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801011ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
801011ef:	89 45 dc             	mov    %eax,-0x24(%ebp)
801011f2:	8b 45 10             	mov    0x10(%ebp),%eax
  int r;

  if(f->writable == 0)
801011f5:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
{
801011f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
801011fc:	0f 84 bd 00 00 00    	je     801012bf <filewrite+0xdf>
    return -1;
  if(f->type == FD_PIPE)
80101202:	8b 03                	mov    (%ebx),%eax
80101204:	83 f8 01             	cmp    $0x1,%eax
80101207:	0f 84 bf 00 00 00    	je     801012cc <filewrite+0xec>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010120d:	83 f8 02             	cmp    $0x2,%eax
80101210:	0f 85 c8 00 00 00    	jne    801012de <filewrite+0xfe>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101216:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
80101219:	31 f6                	xor    %esi,%esi
    while(i < n){
8010121b:	85 c0                	test   %eax,%eax
8010121d:	7f 30                	jg     8010124f <filewrite+0x6f>
8010121f:	e9 94 00 00 00       	jmp    801012b8 <filewrite+0xd8>
80101224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80101228:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
8010122b:	83 ec 0c             	sub    $0xc,%esp
8010122e:	ff 73 10             	push   0x10(%ebx)
        f->off += r;
80101231:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80101234:	e8 87 08 00 00       	call   80101ac0 <iunlock>
      end_op();
80101239:	e8 52 1e 00 00       	call   80103090 <end_op>

      if(r < 0)
        break;
      if(r != n1)
8010123e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101241:	83 c4 10             	add    $0x10,%esp
80101244:	39 c7                	cmp    %eax,%edi
80101246:	75 5c                	jne    801012a4 <filewrite+0xc4>
        panic("short filewrite");
      i += r;
80101248:	01 fe                	add    %edi,%esi
    while(i < n){
8010124a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
8010124d:	7e 69                	jle    801012b8 <filewrite+0xd8>
      int n1 = n - i;
8010124f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101252:	b8 00 06 00 00       	mov    $0x600,%eax
80101257:	29 f7                	sub    %esi,%edi
80101259:	39 c7                	cmp    %eax,%edi
8010125b:	0f 4f f8             	cmovg  %eax,%edi
      begin_op();
8010125e:	e8 bd 1d 00 00       	call   80103020 <begin_op>
      ilock(f->ip);
80101263:	83 ec 0c             	sub    $0xc,%esp
80101266:	ff 73 10             	push   0x10(%ebx)
80101269:	e8 72 07 00 00       	call   801019e0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010126e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101271:	57                   	push   %edi
80101272:	ff 73 14             	push   0x14(%ebx)
80101275:	01 f0                	add    %esi,%eax
80101277:	50                   	push   %eax
80101278:	ff 73 10             	push   0x10(%ebx)
8010127b:	e8 70 0b 00 00       	call   80101df0 <writei>
80101280:	83 c4 20             	add    $0x20,%esp
80101283:	85 c0                	test   %eax,%eax
80101285:	7f a1                	jg     80101228 <filewrite+0x48>
      iunlock(f->ip);
80101287:	83 ec 0c             	sub    $0xc,%esp
8010128a:	ff 73 10             	push   0x10(%ebx)
8010128d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101290:	e8 2b 08 00 00       	call   80101ac0 <iunlock>
      end_op();
80101295:	e8 f6 1d 00 00       	call   80103090 <end_op>
      if(r < 0)
8010129a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010129d:	83 c4 10             	add    $0x10,%esp
801012a0:	85 c0                	test   %eax,%eax
801012a2:	75 1b                	jne    801012bf <filewrite+0xdf>
        panic("short filewrite");
801012a4:	83 ec 0c             	sub    $0xc,%esp
801012a7:	68 0f 7a 10 80       	push   $0x80107a0f
801012ac:	e8 ff f1 ff ff       	call   801004b0 <panic>
801012b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    }
    return i == n ? n : -1;
801012b8:	89 f0                	mov    %esi,%eax
801012ba:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
801012bd:	74 05                	je     801012c4 <filewrite+0xe4>
801012bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
801012c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012c7:	5b                   	pop    %ebx
801012c8:	5e                   	pop    %esi
801012c9:	5f                   	pop    %edi
801012ca:	5d                   	pop    %ebp
801012cb:	c3                   	ret    
    return pipewrite(f->pipe, addr, n);
801012cc:	8b 43 0c             	mov    0xc(%ebx),%eax
801012cf:	89 45 08             	mov    %eax,0x8(%ebp)
}
801012d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012d5:	5b                   	pop    %ebx
801012d6:	5e                   	pop    %esi
801012d7:	5f                   	pop    %edi
801012d8:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
801012d9:	e9 d2 25 00 00       	jmp    801038b0 <pipewrite>
  panic("filewrite");
801012de:	83 ec 0c             	sub    $0xc,%esp
801012e1:	68 15 7a 10 80       	push   $0x80107a15
801012e6:	e8 c5 f1 ff ff       	call   801004b0 <panic>
801012eb:	66 90                	xchg   %ax,%ax
801012ed:	66 90                	xchg   %ax,%ax
801012ef:	90                   	nop

801012f0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801012f0:	55                   	push   %ebp
801012f1:	89 c1                	mov    %eax,%ecx
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801012f3:	89 d0                	mov    %edx,%eax
801012f5:	c1 e8 0c             	shr    $0xc,%eax
801012f8:	03 05 fc 25 11 80    	add    0x801125fc,%eax
{
801012fe:	89 e5                	mov    %esp,%ebp
80101300:	56                   	push   %esi
80101301:	53                   	push   %ebx
80101302:	89 d3                	mov    %edx,%ebx
  bp = bread(dev, BBLOCK(b, sb));
80101304:	83 ec 08             	sub    $0x8,%esp
80101307:	50                   	push   %eax
80101308:	51                   	push   %ecx
80101309:	e8 82 ee ff ff       	call   80100190 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
8010130e:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
80101310:	c1 fb 03             	sar    $0x3,%ebx
80101313:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101316:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
80101318:	83 e1 07             	and    $0x7,%ecx
8010131b:	b8 01 00 00 00       	mov    $0x1,%eax
  if((bp->data[bi/8] & m) == 0)
80101320:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
  m = 1 << (bi % 8);
80101326:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101328:	0f b6 4c 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%ecx
8010132d:	85 c1                	test   %eax,%ecx
8010132f:	74 23                	je     80101354 <bfree+0x64>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
80101331:	f7 d0                	not    %eax
  log_write(bp);
80101333:	83 ec 0c             	sub    $0xc,%esp
  bp->data[bi/8] &= ~m;
80101336:	21 c8                	and    %ecx,%eax
80101338:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
8010133c:	56                   	push   %esi
8010133d:	e8 be 1e 00 00       	call   80103200 <log_write>
  brelse(bp);
80101342:	89 34 24             	mov    %esi,(%esp)
80101345:	e8 c6 ee ff ff       	call   80100210 <brelse>
}
8010134a:	83 c4 10             	add    $0x10,%esp
8010134d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101350:	5b                   	pop    %ebx
80101351:	5e                   	pop    %esi
80101352:	5d                   	pop    %ebp
80101353:	c3                   	ret    
    panic("freeing free block");
80101354:	83 ec 0c             	sub    $0xc,%esp
80101357:	68 1f 7a 10 80       	push   $0x80107a1f
8010135c:	e8 4f f1 ff ff       	call   801004b0 <panic>
80101361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101368:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010136f:	90                   	nop

80101370 <balloc>:
{
80101370:	55                   	push   %ebp
80101371:	89 e5                	mov    %esp,%ebp
80101373:	57                   	push   %edi
80101374:	56                   	push   %esi
80101375:	53                   	push   %ebx
80101376:	83 ec 1c             	sub    $0x1c,%esp
  for(b = 0; b < sb.size; b += BPB){
80101379:	8b 0d e0 25 11 80    	mov    0x801125e0,%ecx
{
8010137f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101382:	85 c9                	test   %ecx,%ecx
80101384:	0f 84 87 00 00 00    	je     80101411 <balloc+0xa1>
8010138a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101391:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101394:	83 ec 08             	sub    $0x8,%esp
80101397:	89 f0                	mov    %esi,%eax
80101399:	c1 f8 0c             	sar    $0xc,%eax
8010139c:	03 05 fc 25 11 80    	add    0x801125fc,%eax
801013a2:	50                   	push   %eax
801013a3:	ff 75 d8             	push   -0x28(%ebp)
801013a6:	e8 e5 ed ff ff       	call   80100190 <bread>
801013ab:	83 c4 10             	add    $0x10,%esp
801013ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013b1:	a1 e0 25 11 80       	mov    0x801125e0,%eax
801013b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801013b9:	31 c0                	xor    %eax,%eax
801013bb:	eb 2f                	jmp    801013ec <balloc+0x7c>
801013bd:	8d 76 00             	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
801013c0:	89 c1                	mov    %eax,%ecx
801013c2:	bb 01 00 00 00       	mov    $0x1,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801013c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      m = 1 << (bi % 8);
801013ca:	83 e1 07             	and    $0x7,%ecx
801013cd:	d3 e3                	shl    %cl,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801013cf:	89 c1                	mov    %eax,%ecx
801013d1:	c1 f9 03             	sar    $0x3,%ecx
801013d4:	0f b6 7c 0a 5c       	movzbl 0x5c(%edx,%ecx,1),%edi
801013d9:	89 fa                	mov    %edi,%edx
801013db:	85 df                	test   %ebx,%edi
801013dd:	74 41                	je     80101420 <balloc+0xb0>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013df:	83 c0 01             	add    $0x1,%eax
801013e2:	83 c6 01             	add    $0x1,%esi
801013e5:	3d 00 10 00 00       	cmp    $0x1000,%eax
801013ea:	74 05                	je     801013f1 <balloc+0x81>
801013ec:	39 75 e0             	cmp    %esi,-0x20(%ebp)
801013ef:	77 cf                	ja     801013c0 <balloc+0x50>
    brelse(bp);
801013f1:	83 ec 0c             	sub    $0xc,%esp
801013f4:	ff 75 e4             	push   -0x1c(%ebp)
801013f7:	e8 14 ee ff ff       	call   80100210 <brelse>
  for(b = 0; b < sb.size; b += BPB){
801013fc:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
80101403:	83 c4 10             	add    $0x10,%esp
80101406:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101409:	39 05 e0 25 11 80    	cmp    %eax,0x801125e0
8010140f:	77 80                	ja     80101391 <balloc+0x21>
  panic("balloc: out of blocks");
80101411:	83 ec 0c             	sub    $0xc,%esp
80101414:	68 32 7a 10 80       	push   $0x80107a32
80101419:	e8 92 f0 ff ff       	call   801004b0 <panic>
8010141e:	66 90                	xchg   %ax,%ax
        bp->data[bi/8] |= m;  // Mark block in use.
80101420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
80101423:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
80101426:	09 da                	or     %ebx,%edx
80101428:	88 54 0f 5c          	mov    %dl,0x5c(%edi,%ecx,1)
        log_write(bp);
8010142c:	57                   	push   %edi
8010142d:	e8 ce 1d 00 00       	call   80103200 <log_write>
        brelse(bp);
80101432:	89 3c 24             	mov    %edi,(%esp)
80101435:	e8 d6 ed ff ff       	call   80100210 <brelse>
  bp = bread(dev, bno);
8010143a:	58                   	pop    %eax
8010143b:	5a                   	pop    %edx
8010143c:	56                   	push   %esi
8010143d:	ff 75 d8             	push   -0x28(%ebp)
80101440:	e8 4b ed ff ff       	call   80100190 <bread>
  memset(bp->data, 0, BSIZE);
80101445:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, bno);
80101448:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
8010144a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010144d:	68 00 02 00 00       	push   $0x200
80101452:	6a 00                	push   $0x0
80101454:	50                   	push   %eax
80101455:	e8 a6 35 00 00       	call   80104a00 <memset>
  log_write(bp);
8010145a:	89 1c 24             	mov    %ebx,(%esp)
8010145d:	e8 9e 1d 00 00       	call   80103200 <log_write>
  brelse(bp);
80101462:	89 1c 24             	mov    %ebx,(%esp)
80101465:	e8 a6 ed ff ff       	call   80100210 <brelse>
}
8010146a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010146d:	89 f0                	mov    %esi,%eax
8010146f:	5b                   	pop    %ebx
80101470:	5e                   	pop    %esi
80101471:	5f                   	pop    %edi
80101472:	5d                   	pop    %ebp
80101473:	c3                   	ret    
80101474:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010147b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010147f:	90                   	nop

80101480 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101480:	55                   	push   %ebp
80101481:	89 e5                	mov    %esp,%ebp
80101483:	57                   	push   %edi
80101484:	89 c7                	mov    %eax,%edi
80101486:	56                   	push   %esi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
80101487:	31 f6                	xor    %esi,%esi
{
80101489:	53                   	push   %ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010148a:	bb 94 09 11 80       	mov    $0x80110994,%ebx
{
8010148f:	83 ec 28             	sub    $0x28,%esp
80101492:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101495:	68 60 09 11 80       	push   $0x80110960
8010149a:	e8 a1 34 00 00       	call   80104940 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010149f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  acquire(&icache.lock);
801014a2:	83 c4 10             	add    $0x10,%esp
801014a5:	eb 1b                	jmp    801014c2 <iget+0x42>
801014a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801014ae:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801014b0:	39 3b                	cmp    %edi,(%ebx)
801014b2:	74 6c                	je     80101520 <iget+0xa0>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801014b4:	81 c3 90 00 00 00    	add    $0x90,%ebx
801014ba:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
801014c0:	73 26                	jae    801014e8 <iget+0x68>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801014c2:	8b 43 08             	mov    0x8(%ebx),%eax
801014c5:	85 c0                	test   %eax,%eax
801014c7:	7f e7                	jg     801014b0 <iget+0x30>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801014c9:	85 f6                	test   %esi,%esi
801014cb:	75 e7                	jne    801014b4 <iget+0x34>
801014cd:	85 c0                	test   %eax,%eax
801014cf:	75 76                	jne    80101547 <iget+0xc7>
801014d1:	89 de                	mov    %ebx,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801014d3:	81 c3 90 00 00 00    	add    $0x90,%ebx
801014d9:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
801014df:	72 e1                	jb     801014c2 <iget+0x42>
801014e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801014e8:	85 f6                	test   %esi,%esi
801014ea:	74 79                	je     80101565 <iget+0xe5>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
801014ec:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
801014ef:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801014f1:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
801014f4:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801014fb:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
80101502:	68 60 09 11 80       	push   $0x80110960
80101507:	e8 d4 33 00 00       	call   801048e0 <release>

  return ip;
8010150c:	83 c4 10             	add    $0x10,%esp
}
8010150f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101512:	89 f0                	mov    %esi,%eax
80101514:	5b                   	pop    %ebx
80101515:	5e                   	pop    %esi
80101516:	5f                   	pop    %edi
80101517:	5d                   	pop    %ebp
80101518:	c3                   	ret    
80101519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101520:	39 53 04             	cmp    %edx,0x4(%ebx)
80101523:	75 8f                	jne    801014b4 <iget+0x34>
      release(&icache.lock);
80101525:	83 ec 0c             	sub    $0xc,%esp
      ip->ref++;
80101528:	83 c0 01             	add    $0x1,%eax
      return ip;
8010152b:	89 de                	mov    %ebx,%esi
      release(&icache.lock);
8010152d:	68 60 09 11 80       	push   $0x80110960
      ip->ref++;
80101532:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101535:	e8 a6 33 00 00       	call   801048e0 <release>
      return ip;
8010153a:	83 c4 10             	add    $0x10,%esp
}
8010153d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101540:	89 f0                	mov    %esi,%eax
80101542:	5b                   	pop    %ebx
80101543:	5e                   	pop    %esi
80101544:	5f                   	pop    %edi
80101545:	5d                   	pop    %ebp
80101546:	c3                   	ret    
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101547:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010154d:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
80101553:	73 10                	jae    80101565 <iget+0xe5>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101555:	8b 43 08             	mov    0x8(%ebx),%eax
80101558:	85 c0                	test   %eax,%eax
8010155a:	0f 8f 50 ff ff ff    	jg     801014b0 <iget+0x30>
80101560:	e9 68 ff ff ff       	jmp    801014cd <iget+0x4d>
    panic("iget: no inodes");
80101565:	83 ec 0c             	sub    $0xc,%esp
80101568:	68 48 7a 10 80       	push   $0x80107a48
8010156d:	e8 3e ef ff ff       	call   801004b0 <panic>
80101572:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101580 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101580:	55                   	push   %ebp
80101581:	89 e5                	mov    %esp,%ebp
80101583:	57                   	push   %edi
80101584:	56                   	push   %esi
80101585:	89 c6                	mov    %eax,%esi
80101587:	53                   	push   %ebx
80101588:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010158b:	83 fa 0b             	cmp    $0xb,%edx
8010158e:	0f 86 8c 00 00 00    	jbe    80101620 <bmap+0xa0>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80101594:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
80101597:	83 fb 7f             	cmp    $0x7f,%ebx
8010159a:	0f 87 a2 00 00 00    	ja     80101642 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
801015a0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801015a6:	85 c0                	test   %eax,%eax
801015a8:	74 5e                	je     80101608 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
801015aa:	83 ec 08             	sub    $0x8,%esp
801015ad:	50                   	push   %eax
801015ae:	ff 36                	push   (%esi)
801015b0:	e8 db eb ff ff       	call   80100190 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
801015b5:	83 c4 10             	add    $0x10,%esp
801015b8:	8d 5c 98 5c          	lea    0x5c(%eax,%ebx,4),%ebx
    bp = bread(ip->dev, addr);
801015bc:	89 c2                	mov    %eax,%edx
    if((addr = a[bn]) == 0){
801015be:	8b 3b                	mov    (%ebx),%edi
801015c0:	85 ff                	test   %edi,%edi
801015c2:	74 1c                	je     801015e0 <bmap+0x60>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
801015c4:	83 ec 0c             	sub    $0xc,%esp
801015c7:	52                   	push   %edx
801015c8:	e8 43 ec ff ff       	call   80100210 <brelse>
801015cd:	83 c4 10             	add    $0x10,%esp
    return addr;
  }

  panic("bmap: out of range");
}
801015d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801015d3:	89 f8                	mov    %edi,%eax
801015d5:	5b                   	pop    %ebx
801015d6:	5e                   	pop    %esi
801015d7:	5f                   	pop    %edi
801015d8:	5d                   	pop    %ebp
801015d9:	c3                   	ret    
801015da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801015e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      a[bn] = addr = balloc(ip->dev);
801015e3:	8b 06                	mov    (%esi),%eax
801015e5:	e8 86 fd ff ff       	call   80101370 <balloc>
      log_write(bp);
801015ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801015ed:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
801015f0:	89 03                	mov    %eax,(%ebx)
801015f2:	89 c7                	mov    %eax,%edi
      log_write(bp);
801015f4:	52                   	push   %edx
801015f5:	e8 06 1c 00 00       	call   80103200 <log_write>
801015fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801015fd:	83 c4 10             	add    $0x10,%esp
80101600:	eb c2                	jmp    801015c4 <bmap+0x44>
80101602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101608:	8b 06                	mov    (%esi),%eax
8010160a:	e8 61 fd ff ff       	call   80101370 <balloc>
8010160f:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
80101615:	eb 93                	jmp    801015aa <bmap+0x2a>
80101617:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010161e:	66 90                	xchg   %ax,%ax
    if((addr = ip->addrs[bn]) == 0)
80101620:	8d 5a 14             	lea    0x14(%edx),%ebx
80101623:	8b 7c 98 0c          	mov    0xc(%eax,%ebx,4),%edi
80101627:	85 ff                	test   %edi,%edi
80101629:	75 a5                	jne    801015d0 <bmap+0x50>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010162b:	8b 00                	mov    (%eax),%eax
8010162d:	e8 3e fd ff ff       	call   80101370 <balloc>
80101632:	89 44 9e 0c          	mov    %eax,0xc(%esi,%ebx,4)
80101636:	89 c7                	mov    %eax,%edi
}
80101638:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010163b:	5b                   	pop    %ebx
8010163c:	89 f8                	mov    %edi,%eax
8010163e:	5e                   	pop    %esi
8010163f:	5f                   	pop    %edi
80101640:	5d                   	pop    %ebp
80101641:	c3                   	ret    
  panic("bmap: out of range");
80101642:	83 ec 0c             	sub    $0xc,%esp
80101645:	68 58 7a 10 80       	push   $0x80107a58
8010164a:	e8 61 ee ff ff       	call   801004b0 <panic>
8010164f:	90                   	nop

80101650 <readsb>:
{
80101650:	55                   	push   %ebp
80101651:	89 e5                	mov    %esp,%ebp
80101653:	53                   	push   %ebx
80101654:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
80101657:	6a 01                	push   $0x1
80101659:	ff 75 08             	push   0x8(%ebp)
8010165c:	e8 2f eb ff ff       	call   80100190 <bread>
  memmove(sb, bp->data, sizeof(*sb));
80101661:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
80101664:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
80101666:	8d 40 5c             	lea    0x5c(%eax),%eax
80101669:	6a 24                	push   $0x24
8010166b:	50                   	push   %eax
8010166c:	ff 75 0c             	push   0xc(%ebp)
8010166f:	e8 2c 34 00 00       	call   80104aa0 <memmove>
  brelse(bp);
80101674:	89 1c 24             	mov    %ebx,(%esp)
80101677:	e8 94 eb ff ff       	call   80100210 <brelse>
}
8010167c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010167f:	83 c4 10             	add    $0x10,%esp
    ss[i].page_perm=0;
80101682:	c7 05 c0 25 11 80 00 	movl   $0x0,0x801125c0
80101689:	00 00 00 
    ss[i].is_free=1;
8010168c:	c7 05 c4 25 11 80 01 	movl   $0x1,0x801125c4
80101693:	00 00 00 
    ss[i].page_perm=0;
80101696:	c7 05 c8 25 11 80 00 	movl   $0x0,0x801125c8
8010169d:	00 00 00 
    ss[i].is_free=1;
801016a0:	c7 05 cc 25 11 80 01 	movl   $0x1,0x801125cc
801016a7:	00 00 00 
    ss[i].page_perm=0;
801016aa:	c7 05 d0 25 11 80 00 	movl   $0x0,0x801125d0
801016b1:	00 00 00 
    ss[i].is_free=1;
801016b4:	c7 05 d4 25 11 80 01 	movl   $0x1,0x801125d4
801016bb:	00 00 00 
    ss[i].page_perm=0;
801016be:	c7 05 d8 25 11 80 00 	movl   $0x0,0x801125d8
801016c5:	00 00 00 
    ss[i].is_free=1;
801016c8:	c7 05 dc 25 11 80 01 	movl   $0x1,0x801125dc
801016cf:	00 00 00 
}
801016d2:	c9                   	leave  
801016d3:	c3                   	ret    
801016d4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801016db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801016df:	90                   	nop

801016e0 <add_page>:
uint add_page(char* data, int permissions){
801016e0:	55                   	push   %ebp
801016e1:	89 e5                	mov    %esp,%ebp
801016e3:	57                   	push   %edi
  for(i=0; i<4; i++){
801016e4:	31 ff                	xor    %edi,%edi
uint add_page(char* data, int permissions){
801016e6:	56                   	push   %esi
801016e7:	53                   	push   %ebx
801016e8:	83 ec 1c             	sub    $0x1c,%esp
801016eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if(ss[i].is_free) break;
801016ee:	8b 04 fd c4 25 11 80 	mov    -0x7feeda3c(,%edi,8),%eax
801016f5:	85 c0                	test   %eax,%eax
801016f7:	75 27                	jne    80101720 <add_page+0x40>
  for(i=0; i<4; i++){
801016f9:	83 c7 01             	add    $0x1,%edi
801016fc:	83 ff 04             	cmp    $0x4,%edi
801016ff:	75 ed                	jne    801016ee <add_page+0xe>
    cprintf("IN RETURN -1");
80101701:	83 ec 0c             	sub    $0xc,%esp
    return -1;
80101704:	bf ff ff ff ff       	mov    $0xffffffff,%edi
    cprintf("IN RETURN -1");
80101709:	68 6b 7a 10 80       	push   $0x80107a6b
8010170e:	e8 bd f0 ff ff       	call   801007d0 <cprintf>
    return -1;
80101713:	83 c4 10             	add    $0x10,%esp
}
80101716:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101719:	89 f8                	mov    %edi,%eax
8010171b:	5b                   	pop    %ebx
8010171c:	5e                   	pop    %esi
8010171d:	5f                   	pop    %edi
8010171e:	5d                   	pop    %ebp
8010171f:	c3                   	ret    
  ss[i].page_perm= permissions;
80101720:	8b 55 0c             	mov    0xc(%ebp),%edx
80101723:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  ss[i].is_free=0;
80101729:	c7 04 fd c4 25 11 80 	movl   $0x0,-0x7feeda3c(,%edi,8)
80101730:	00 00 00 00 
  ss[i].page_perm= permissions;
80101734:	8d 34 fd 02 00 00 00 	lea    0x2(,%edi,8),%esi
8010173b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010173e:	89 14 fd c0 25 11 80 	mov    %edx,-0x7feeda40(,%edi,8)
  for(int j=0;j<8;j++){
80101745:	8d 76 00             	lea    0x0(%esi),%esi
    write_page_to_disk(ROOTDEV,cur,2+8*i+j);
80101748:	83 ec 04             	sub    $0x4,%esp
8010174b:	56                   	push   %esi
  for(int j=0;j<8;j++){
8010174c:	83 c6 01             	add    $0x1,%esi
    write_page_to_disk(ROOTDEV,cur,2+8*i+j);
8010174f:	53                   	push   %ebx
    cur+= BSIZE;
80101750:	81 c3 00 02 00 00    	add    $0x200,%ebx
    write_page_to_disk(ROOTDEV,cur,2+8*i+j);
80101756:	6a 01                	push   $0x1
80101758:	e8 43 eb ff ff       	call   801002a0 <write_page_to_disk>
  for(int j=0;j<8;j++){
8010175d:	83 c4 10             	add    $0x10,%esp
80101760:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
80101763:	75 e3                	jne    80101748 <add_page+0x68>
}
80101765:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101768:	89 f8                	mov    %edi,%eax
8010176a:	5b                   	pop    %ebx
8010176b:	5e                   	pop    %esi
8010176c:	5f                   	pop    %edi
8010176d:	5d                   	pop    %ebp
8010176e:	c3                   	ret    
8010176f:	90                   	nop

80101770 <iinit>:
{
80101770:	55                   	push   %ebp
80101771:	89 e5                	mov    %esp,%ebp
80101773:	56                   	push   %esi
80101774:	be c0 25 11 80       	mov    $0x801125c0,%esi
80101779:	53                   	push   %ebx
8010177a:	bb a0 09 11 80       	mov    $0x801109a0,%ebx
  initlock(&icache.lock, "icache");
8010177f:	83 ec 08             	sub    $0x8,%esp
80101782:	68 78 7a 10 80       	push   $0x80107a78
80101787:	68 60 09 11 80       	push   $0x80110960
8010178c:	e8 df 2f 00 00       	call   80104770 <initlock>
  for(i = 0; i < NINODE; i++) {
80101791:	83 c4 10             	add    $0x10,%esp
80101794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    initsleeplock(&icache.inode[i].lock, "inode");
80101798:	83 ec 08             	sub    $0x8,%esp
8010179b:	68 7f 7a 10 80       	push   $0x80107a7f
801017a0:	53                   	push   %ebx
  for(i = 0; i < NINODE; i++) {
801017a1:	81 c3 90 00 00 00    	add    $0x90,%ebx
    initsleeplock(&icache.inode[i].lock, "inode");
801017a7:	e8 94 2e 00 00       	call   80104640 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801017ac:	83 c4 10             	add    $0x10,%esp
801017af:	39 de                	cmp    %ebx,%esi
801017b1:	75 e5                	jne    80101798 <iinit+0x28>
  bp = bread(dev, 1);
801017b3:	83 ec 08             	sub    $0x8,%esp
801017b6:	6a 01                	push   $0x1
801017b8:	ff 75 08             	push   0x8(%ebp)
801017bb:	e8 d0 e9 ff ff       	call   80100190 <bread>
  memmove(sb, bp->data, sizeof(*sb));
801017c0:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
801017c3:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801017c5:	8d 40 5c             	lea    0x5c(%eax),%eax
801017c8:	6a 24                	push   $0x24
801017ca:	50                   	push   %eax
801017cb:	68 e0 25 11 80       	push   $0x801125e0
801017d0:	e8 cb 32 00 00       	call   80104aa0 <memmove>
  brelse(bp);
801017d5:	89 1c 24             	mov    %ebx,(%esp)
801017d8:	e8 33 ea ff ff       	call   80100210 <brelse>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017dd:	ff 35 fc 25 11 80    	push   0x801125fc
801017e3:	ff 35 f8 25 11 80    	push   0x801125f8
801017e9:	ff 35 f4 25 11 80    	push   0x801125f4
801017ef:	ff 35 ec 25 11 80    	push   0x801125ec
801017f5:	ff 35 e8 25 11 80    	push   0x801125e8
801017fb:	ff 35 e4 25 11 80    	push   0x801125e4
80101801:	ff 35 e0 25 11 80    	push   0x801125e0
80101807:	68 e4 7a 10 80       	push   $0x80107ae4
    ss[i].page_perm=0;
8010180c:	c7 05 c0 25 11 80 00 	movl   $0x0,0x801125c0
80101813:	00 00 00 
    ss[i].is_free=1;
80101816:	c7 05 c4 25 11 80 01 	movl   $0x1,0x801125c4
8010181d:	00 00 00 
    ss[i].page_perm=0;
80101820:	c7 05 c8 25 11 80 00 	movl   $0x0,0x801125c8
80101827:	00 00 00 
    ss[i].is_free=1;
8010182a:	c7 05 cc 25 11 80 01 	movl   $0x1,0x801125cc
80101831:	00 00 00 
    ss[i].page_perm=0;
80101834:	c7 05 d0 25 11 80 00 	movl   $0x0,0x801125d0
8010183b:	00 00 00 
    ss[i].is_free=1;
8010183e:	c7 05 d4 25 11 80 01 	movl   $0x1,0x801125d4
80101845:	00 00 00 
    ss[i].page_perm=0;
80101848:	c7 05 d8 25 11 80 00 	movl   $0x0,0x801125d8
8010184f:	00 00 00 
    ss[i].is_free=1;
80101852:	c7 05 dc 25 11 80 01 	movl   $0x1,0x801125dc
80101859:	00 00 00 
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010185c:	e8 6f ef ff ff       	call   801007d0 <cprintf>
}
80101861:	83 c4 30             	add    $0x30,%esp
80101864:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101867:	5b                   	pop    %ebx
80101868:	5e                   	pop    %esi
80101869:	5d                   	pop    %ebp
8010186a:	c3                   	ret    
8010186b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010186f:	90                   	nop

80101870 <ialloc>:
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	57                   	push   %edi
80101874:	56                   	push   %esi
80101875:	53                   	push   %ebx
80101876:	83 ec 1c             	sub    $0x1c,%esp
80101879:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
8010187c:	83 3d e8 25 11 80 01 	cmpl   $0x1,0x801125e8
{
80101883:	8b 75 08             	mov    0x8(%ebp),%esi
80101886:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101889:	0f 86 91 00 00 00    	jbe    80101920 <ialloc+0xb0>
8010188f:	bf 01 00 00 00       	mov    $0x1,%edi
80101894:	eb 21                	jmp    801018b7 <ialloc+0x47>
80101896:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010189d:	8d 76 00             	lea    0x0(%esi),%esi
    brelse(bp);
801018a0:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801018a3:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
801018a6:	53                   	push   %ebx
801018a7:	e8 64 e9 ff ff       	call   80100210 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801018ac:	83 c4 10             	add    $0x10,%esp
801018af:	3b 3d e8 25 11 80    	cmp    0x801125e8,%edi
801018b5:	73 69                	jae    80101920 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
801018b7:	89 f8                	mov    %edi,%eax
801018b9:	83 ec 08             	sub    $0x8,%esp
801018bc:	c1 e8 03             	shr    $0x3,%eax
801018bf:	03 05 f8 25 11 80    	add    0x801125f8,%eax
801018c5:	50                   	push   %eax
801018c6:	56                   	push   %esi
801018c7:	e8 c4 e8 ff ff       	call   80100190 <bread>
    if(dip->type == 0){  // a free inode
801018cc:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
801018cf:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
801018d1:	89 f8                	mov    %edi,%eax
801018d3:	83 e0 07             	and    $0x7,%eax
801018d6:	c1 e0 06             	shl    $0x6,%eax
801018d9:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
801018dd:	66 83 39 00          	cmpw   $0x0,(%ecx)
801018e1:	75 bd                	jne    801018a0 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
801018e3:	83 ec 04             	sub    $0x4,%esp
801018e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801018e9:	6a 40                	push   $0x40
801018eb:	6a 00                	push   $0x0
801018ed:	51                   	push   %ecx
801018ee:	e8 0d 31 00 00       	call   80104a00 <memset>
      dip->type = type;
801018f3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801018f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801018fa:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
801018fd:	89 1c 24             	mov    %ebx,(%esp)
80101900:	e8 fb 18 00 00       	call   80103200 <log_write>
      brelse(bp);
80101905:	89 1c 24             	mov    %ebx,(%esp)
80101908:	e8 03 e9 ff ff       	call   80100210 <brelse>
      return iget(dev, inum);
8010190d:	83 c4 10             	add    $0x10,%esp
}
80101910:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
80101913:	89 fa                	mov    %edi,%edx
}
80101915:	5b                   	pop    %ebx
      return iget(dev, inum);
80101916:	89 f0                	mov    %esi,%eax
}
80101918:	5e                   	pop    %esi
80101919:	5f                   	pop    %edi
8010191a:	5d                   	pop    %ebp
      return iget(dev, inum);
8010191b:	e9 60 fb ff ff       	jmp    80101480 <iget>
  panic("ialloc: no inodes");
80101920:	83 ec 0c             	sub    $0xc,%esp
80101923:	68 85 7a 10 80       	push   $0x80107a85
80101928:	e8 83 eb ff ff       	call   801004b0 <panic>
8010192d:	8d 76 00             	lea    0x0(%esi),%esi

80101930 <iupdate>:
{
80101930:	55                   	push   %ebp
80101931:	89 e5                	mov    %esp,%ebp
80101933:	56                   	push   %esi
80101934:	53                   	push   %ebx
80101935:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101938:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010193b:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010193e:	83 ec 08             	sub    $0x8,%esp
80101941:	c1 e8 03             	shr    $0x3,%eax
80101944:	03 05 f8 25 11 80    	add    0x801125f8,%eax
8010194a:	50                   	push   %eax
8010194b:	ff 73 a4             	push   -0x5c(%ebx)
8010194e:	e8 3d e8 ff ff       	call   80100190 <bread>
  dip->type = ip->type;
80101953:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101957:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010195a:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010195c:	8b 43 a8             	mov    -0x58(%ebx),%eax
8010195f:	83 e0 07             	and    $0x7,%eax
80101962:	c1 e0 06             	shl    $0x6,%eax
80101965:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101969:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010196c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101970:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
80101973:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
80101977:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
8010197b:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
8010197f:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
80101983:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
80101987:	8b 53 fc             	mov    -0x4(%ebx),%edx
8010198a:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010198d:	6a 34                	push   $0x34
8010198f:	53                   	push   %ebx
80101990:	50                   	push   %eax
80101991:	e8 0a 31 00 00       	call   80104aa0 <memmove>
  log_write(bp);
80101996:	89 34 24             	mov    %esi,(%esp)
80101999:	e8 62 18 00 00       	call   80103200 <log_write>
  brelse(bp);
8010199e:	89 75 08             	mov    %esi,0x8(%ebp)
801019a1:	83 c4 10             	add    $0x10,%esp
}
801019a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801019a7:	5b                   	pop    %ebx
801019a8:	5e                   	pop    %esi
801019a9:	5d                   	pop    %ebp
  brelse(bp);
801019aa:	e9 61 e8 ff ff       	jmp    80100210 <brelse>
801019af:	90                   	nop

801019b0 <idup>:
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	53                   	push   %ebx
801019b4:	83 ec 10             	sub    $0x10,%esp
801019b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801019ba:	68 60 09 11 80       	push   $0x80110960
801019bf:	e8 7c 2f 00 00       	call   80104940 <acquire>
  ip->ref++;
801019c4:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
801019c8:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
801019cf:	e8 0c 2f 00 00       	call   801048e0 <release>
}
801019d4:	89 d8                	mov    %ebx,%eax
801019d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801019d9:	c9                   	leave  
801019da:	c3                   	ret    
801019db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801019df:	90                   	nop

801019e0 <ilock>:
{
801019e0:	55                   	push   %ebp
801019e1:	89 e5                	mov    %esp,%ebp
801019e3:	56                   	push   %esi
801019e4:	53                   	push   %ebx
801019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
801019e8:	85 db                	test   %ebx,%ebx
801019ea:	0f 84 b7 00 00 00    	je     80101aa7 <ilock+0xc7>
801019f0:	8b 53 08             	mov    0x8(%ebx),%edx
801019f3:	85 d2                	test   %edx,%edx
801019f5:	0f 8e ac 00 00 00    	jle    80101aa7 <ilock+0xc7>
  acquiresleep(&ip->lock);
801019fb:	83 ec 0c             	sub    $0xc,%esp
801019fe:	8d 43 0c             	lea    0xc(%ebx),%eax
80101a01:	50                   	push   %eax
80101a02:	e8 79 2c 00 00       	call   80104680 <acquiresleep>
  if(ip->valid == 0){
80101a07:	8b 43 4c             	mov    0x4c(%ebx),%eax
80101a0a:	83 c4 10             	add    $0x10,%esp
80101a0d:	85 c0                	test   %eax,%eax
80101a0f:	74 0f                	je     80101a20 <ilock+0x40>
}
80101a11:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101a14:	5b                   	pop    %ebx
80101a15:	5e                   	pop    %esi
80101a16:	5d                   	pop    %ebp
80101a17:	c3                   	ret    
80101a18:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101a1f:	90                   	nop
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a20:	8b 43 04             	mov    0x4(%ebx),%eax
80101a23:	83 ec 08             	sub    $0x8,%esp
80101a26:	c1 e8 03             	shr    $0x3,%eax
80101a29:	03 05 f8 25 11 80    	add    0x801125f8,%eax
80101a2f:	50                   	push   %eax
80101a30:	ff 33                	push   (%ebx)
80101a32:	e8 59 e7 ff ff       	call   80100190 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a37:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a3a:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a3c:	8b 43 04             	mov    0x4(%ebx),%eax
80101a3f:	83 e0 07             	and    $0x7,%eax
80101a42:	c1 e0 06             	shl    $0x6,%eax
80101a45:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101a49:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a4c:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
80101a4f:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101a53:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
80101a57:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
80101a5b:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
80101a5f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101a63:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
80101a67:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101a6b:	8b 50 fc             	mov    -0x4(%eax),%edx
80101a6e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a71:	6a 34                	push   $0x34
80101a73:	50                   	push   %eax
80101a74:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101a77:	50                   	push   %eax
80101a78:	e8 23 30 00 00       	call   80104aa0 <memmove>
    brelse(bp);
80101a7d:	89 34 24             	mov    %esi,(%esp)
80101a80:	e8 8b e7 ff ff       	call   80100210 <brelse>
    if(ip->type == 0)
80101a85:	83 c4 10             	add    $0x10,%esp
80101a88:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
80101a8d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101a94:	0f 85 77 ff ff ff    	jne    80101a11 <ilock+0x31>
      panic("ilock: no type");
80101a9a:	83 ec 0c             	sub    $0xc,%esp
80101a9d:	68 9d 7a 10 80       	push   $0x80107a9d
80101aa2:	e8 09 ea ff ff       	call   801004b0 <panic>
    panic("ilock");
80101aa7:	83 ec 0c             	sub    $0xc,%esp
80101aaa:	68 97 7a 10 80       	push   $0x80107a97
80101aaf:	e8 fc e9 ff ff       	call   801004b0 <panic>
80101ab4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101abb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101abf:	90                   	nop

80101ac0 <iunlock>:
{
80101ac0:	55                   	push   %ebp
80101ac1:	89 e5                	mov    %esp,%ebp
80101ac3:	56                   	push   %esi
80101ac4:	53                   	push   %ebx
80101ac5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101ac8:	85 db                	test   %ebx,%ebx
80101aca:	74 28                	je     80101af4 <iunlock+0x34>
80101acc:	83 ec 0c             	sub    $0xc,%esp
80101acf:	8d 73 0c             	lea    0xc(%ebx),%esi
80101ad2:	56                   	push   %esi
80101ad3:	e8 48 2c 00 00       	call   80104720 <holdingsleep>
80101ad8:	83 c4 10             	add    $0x10,%esp
80101adb:	85 c0                	test   %eax,%eax
80101add:	74 15                	je     80101af4 <iunlock+0x34>
80101adf:	8b 43 08             	mov    0x8(%ebx),%eax
80101ae2:	85 c0                	test   %eax,%eax
80101ae4:	7e 0e                	jle    80101af4 <iunlock+0x34>
  releasesleep(&ip->lock);
80101ae6:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101ae9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101aec:	5b                   	pop    %ebx
80101aed:	5e                   	pop    %esi
80101aee:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
80101aef:	e9 ec 2b 00 00       	jmp    801046e0 <releasesleep>
    panic("iunlock");
80101af4:	83 ec 0c             	sub    $0xc,%esp
80101af7:	68 ac 7a 10 80       	push   $0x80107aac
80101afc:	e8 af e9 ff ff       	call   801004b0 <panic>
80101b01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b08:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b0f:	90                   	nop

80101b10 <iput>:
{
80101b10:	55                   	push   %ebp
80101b11:	89 e5                	mov    %esp,%ebp
80101b13:	57                   	push   %edi
80101b14:	56                   	push   %esi
80101b15:	53                   	push   %ebx
80101b16:	83 ec 28             	sub    $0x28,%esp
80101b19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101b1c:	8d 7b 0c             	lea    0xc(%ebx),%edi
80101b1f:	57                   	push   %edi
80101b20:	e8 5b 2b 00 00       	call   80104680 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101b25:	8b 53 4c             	mov    0x4c(%ebx),%edx
80101b28:	83 c4 10             	add    $0x10,%esp
80101b2b:	85 d2                	test   %edx,%edx
80101b2d:	74 07                	je     80101b36 <iput+0x26>
80101b2f:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101b34:	74 32                	je     80101b68 <iput+0x58>
  releasesleep(&ip->lock);
80101b36:	83 ec 0c             	sub    $0xc,%esp
80101b39:	57                   	push   %edi
80101b3a:	e8 a1 2b 00 00       	call   801046e0 <releasesleep>
  acquire(&icache.lock);
80101b3f:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101b46:	e8 f5 2d 00 00       	call   80104940 <acquire>
  ip->ref--;
80101b4b:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101b4f:	83 c4 10             	add    $0x10,%esp
80101b52:	c7 45 08 60 09 11 80 	movl   $0x80110960,0x8(%ebp)
}
80101b59:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b5c:	5b                   	pop    %ebx
80101b5d:	5e                   	pop    %esi
80101b5e:	5f                   	pop    %edi
80101b5f:	5d                   	pop    %ebp
  release(&icache.lock);
80101b60:	e9 7b 2d 00 00       	jmp    801048e0 <release>
80101b65:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&icache.lock);
80101b68:	83 ec 0c             	sub    $0xc,%esp
80101b6b:	68 60 09 11 80       	push   $0x80110960
80101b70:	e8 cb 2d 00 00       	call   80104940 <acquire>
    int r = ip->ref;
80101b75:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101b78:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101b7f:	e8 5c 2d 00 00       	call   801048e0 <release>
    if(r == 1){
80101b84:	83 c4 10             	add    $0x10,%esp
80101b87:	83 fe 01             	cmp    $0x1,%esi
80101b8a:	75 aa                	jne    80101b36 <iput+0x26>
80101b8c:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101b92:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101b95:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101b98:	89 cf                	mov    %ecx,%edi
80101b9a:	eb 0b                	jmp    80101ba7 <iput+0x97>
80101b9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ba0:	83 c6 04             	add    $0x4,%esi
80101ba3:	39 fe                	cmp    %edi,%esi
80101ba5:	74 19                	je     80101bc0 <iput+0xb0>
    if(ip->addrs[i]){
80101ba7:	8b 16                	mov    (%esi),%edx
80101ba9:	85 d2                	test   %edx,%edx
80101bab:	74 f3                	je     80101ba0 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
80101bad:	8b 03                	mov    (%ebx),%eax
80101baf:	e8 3c f7 ff ff       	call   801012f0 <bfree>
      ip->addrs[i] = 0;
80101bb4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80101bba:	eb e4                	jmp    80101ba0 <iput+0x90>
80101bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101bc0:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101bc6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101bc9:	85 c0                	test   %eax,%eax
80101bcb:	75 2d                	jne    80101bfa <iput+0xea>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
80101bcd:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101bd0:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101bd7:	53                   	push   %ebx
80101bd8:	e8 53 fd ff ff       	call   80101930 <iupdate>
      ip->type = 0;
80101bdd:	31 c0                	xor    %eax,%eax
80101bdf:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101be3:	89 1c 24             	mov    %ebx,(%esp)
80101be6:	e8 45 fd ff ff       	call   80101930 <iupdate>
      ip->valid = 0;
80101beb:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101bf2:	83 c4 10             	add    $0x10,%esp
80101bf5:	e9 3c ff ff ff       	jmp    80101b36 <iput+0x26>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101bfa:	83 ec 08             	sub    $0x8,%esp
80101bfd:	50                   	push   %eax
80101bfe:	ff 33                	push   (%ebx)
80101c00:	e8 8b e5 ff ff       	call   80100190 <bread>
80101c05:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101c08:	83 c4 10             	add    $0x10,%esp
80101c0b:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
80101c11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101c14:	8d 70 5c             	lea    0x5c(%eax),%esi
80101c17:	89 cf                	mov    %ecx,%edi
80101c19:	eb 0c                	jmp    80101c27 <iput+0x117>
80101c1b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101c1f:	90                   	nop
80101c20:	83 c6 04             	add    $0x4,%esi
80101c23:	39 f7                	cmp    %esi,%edi
80101c25:	74 0f                	je     80101c36 <iput+0x126>
      if(a[j])
80101c27:	8b 16                	mov    (%esi),%edx
80101c29:	85 d2                	test   %edx,%edx
80101c2b:	74 f3                	je     80101c20 <iput+0x110>
        bfree(ip->dev, a[j]);
80101c2d:	8b 03                	mov    (%ebx),%eax
80101c2f:	e8 bc f6 ff ff       	call   801012f0 <bfree>
80101c34:	eb ea                	jmp    80101c20 <iput+0x110>
    brelse(bp);
80101c36:	83 ec 0c             	sub    $0xc,%esp
80101c39:	ff 75 e4             	push   -0x1c(%ebp)
80101c3c:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101c3f:	e8 cc e5 ff ff       	call   80100210 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101c44:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101c4a:	8b 03                	mov    (%ebx),%eax
80101c4c:	e8 9f f6 ff ff       	call   801012f0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101c51:	83 c4 10             	add    $0x10,%esp
80101c54:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101c5b:	00 00 00 
80101c5e:	e9 6a ff ff ff       	jmp    80101bcd <iput+0xbd>
80101c63:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101c70 <iunlockput>:
{
80101c70:	55                   	push   %ebp
80101c71:	89 e5                	mov    %esp,%ebp
80101c73:	56                   	push   %esi
80101c74:	53                   	push   %ebx
80101c75:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c78:	85 db                	test   %ebx,%ebx
80101c7a:	74 34                	je     80101cb0 <iunlockput+0x40>
80101c7c:	83 ec 0c             	sub    $0xc,%esp
80101c7f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101c82:	56                   	push   %esi
80101c83:	e8 98 2a 00 00       	call   80104720 <holdingsleep>
80101c88:	83 c4 10             	add    $0x10,%esp
80101c8b:	85 c0                	test   %eax,%eax
80101c8d:	74 21                	je     80101cb0 <iunlockput+0x40>
80101c8f:	8b 43 08             	mov    0x8(%ebx),%eax
80101c92:	85 c0                	test   %eax,%eax
80101c94:	7e 1a                	jle    80101cb0 <iunlockput+0x40>
  releasesleep(&ip->lock);
80101c96:	83 ec 0c             	sub    $0xc,%esp
80101c99:	56                   	push   %esi
80101c9a:	e8 41 2a 00 00       	call   801046e0 <releasesleep>
  iput(ip);
80101c9f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101ca2:	83 c4 10             	add    $0x10,%esp
}
80101ca5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101ca8:	5b                   	pop    %ebx
80101ca9:	5e                   	pop    %esi
80101caa:	5d                   	pop    %ebp
  iput(ip);
80101cab:	e9 60 fe ff ff       	jmp    80101b10 <iput>
    panic("iunlock");
80101cb0:	83 ec 0c             	sub    $0xc,%esp
80101cb3:	68 ac 7a 10 80       	push   $0x80107aac
80101cb8:	e8 f3 e7 ff ff       	call   801004b0 <panic>
80101cbd:	8d 76 00             	lea    0x0(%esi),%esi

80101cc0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101cc0:	55                   	push   %ebp
80101cc1:	89 e5                	mov    %esp,%ebp
80101cc3:	8b 55 08             	mov    0x8(%ebp),%edx
80101cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101cc9:	8b 0a                	mov    (%edx),%ecx
80101ccb:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101cce:	8b 4a 04             	mov    0x4(%edx),%ecx
80101cd1:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101cd4:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101cd8:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101cdb:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101cdf:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101ce3:	8b 52 58             	mov    0x58(%edx),%edx
80101ce6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ce9:	5d                   	pop    %ebp
80101cea:	c3                   	ret    
80101ceb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101cef:	90                   	nop

80101cf0 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101cf0:	55                   	push   %ebp
80101cf1:	89 e5                	mov    %esp,%ebp
80101cf3:	57                   	push   %edi
80101cf4:	56                   	push   %esi
80101cf5:	53                   	push   %ebx
80101cf6:	83 ec 1c             	sub    $0x1c,%esp
80101cf9:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cff:	8b 75 10             	mov    0x10(%ebp),%esi
80101d02:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101d05:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d08:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101d0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101d10:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101d13:	0f 84 a7 00 00 00    	je     80101dc0 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101d19:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101d1c:	8b 40 58             	mov    0x58(%eax),%eax
80101d1f:	39 c6                	cmp    %eax,%esi
80101d21:	0f 87 ba 00 00 00    	ja     80101de1 <readi+0xf1>
80101d27:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101d2a:	31 c9                	xor    %ecx,%ecx
80101d2c:	89 da                	mov    %ebx,%edx
80101d2e:	01 f2                	add    %esi,%edx
80101d30:	0f 92 c1             	setb   %cl
80101d33:	89 cf                	mov    %ecx,%edi
80101d35:	0f 82 a6 00 00 00    	jb     80101de1 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101d3b:	89 c1                	mov    %eax,%ecx
80101d3d:	29 f1                	sub    %esi,%ecx
80101d3f:	39 d0                	cmp    %edx,%eax
80101d41:	0f 43 cb             	cmovae %ebx,%ecx
80101d44:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101d47:	85 c9                	test   %ecx,%ecx
80101d49:	74 67                	je     80101db2 <readi+0xc2>
80101d4b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101d4f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d50:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101d53:	89 f2                	mov    %esi,%edx
80101d55:	c1 ea 09             	shr    $0x9,%edx
80101d58:	89 d8                	mov    %ebx,%eax
80101d5a:	e8 21 f8 ff ff       	call   80101580 <bmap>
80101d5f:	83 ec 08             	sub    $0x8,%esp
80101d62:	50                   	push   %eax
80101d63:	ff 33                	push   (%ebx)
80101d65:	e8 26 e4 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101d6a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101d6d:	b9 00 02 00 00       	mov    $0x200,%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d72:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101d74:	89 f0                	mov    %esi,%eax
80101d76:	25 ff 01 00 00       	and    $0x1ff,%eax
80101d7b:	29 fb                	sub    %edi,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101d7d:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101d80:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101d82:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101d86:	39 d9                	cmp    %ebx,%ecx
80101d88:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101d8b:	83 c4 0c             	add    $0xc,%esp
80101d8e:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101d8f:	01 df                	add    %ebx,%edi
80101d91:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
80101d93:	50                   	push   %eax
80101d94:	ff 75 e0             	push   -0x20(%ebp)
80101d97:	e8 04 2d 00 00       	call   80104aa0 <memmove>
    brelse(bp);
80101d9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101d9f:	89 14 24             	mov    %edx,(%esp)
80101da2:	e8 69 e4 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101da7:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101daa:	83 c4 10             	add    $0x10,%esp
80101dad:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101db0:	77 9e                	ja     80101d50 <readi+0x60>
  }
  return n;
80101db2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101db5:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101db8:	5b                   	pop    %ebx
80101db9:	5e                   	pop    %esi
80101dba:	5f                   	pop    %edi
80101dbb:	5d                   	pop    %ebp
80101dbc:	c3                   	ret    
80101dbd:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101dc0:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101dc4:	66 83 f8 09          	cmp    $0x9,%ax
80101dc8:	77 17                	ja     80101de1 <readi+0xf1>
80101dca:	8b 04 c5 00 09 11 80 	mov    -0x7feef700(,%eax,8),%eax
80101dd1:	85 c0                	test   %eax,%eax
80101dd3:	74 0c                	je     80101de1 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101dd5:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ddb:	5b                   	pop    %ebx
80101ddc:	5e                   	pop    %esi
80101ddd:	5f                   	pop    %edi
80101dde:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101ddf:	ff e0                	jmp    *%eax
      return -1;
80101de1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101de6:	eb cd                	jmp    80101db5 <readi+0xc5>
80101de8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101def:	90                   	nop

80101df0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101df0:	55                   	push   %ebp
80101df1:	89 e5                	mov    %esp,%ebp
80101df3:	57                   	push   %edi
80101df4:	56                   	push   %esi
80101df5:	53                   	push   %ebx
80101df6:	83 ec 1c             	sub    $0x1c,%esp
80101df9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfc:	8b 75 0c             	mov    0xc(%ebp),%esi
80101dff:	8b 55 14             	mov    0x14(%ebp),%edx
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e02:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101e07:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101e0a:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101e0d:	8b 75 10             	mov    0x10(%ebp),%esi
80101e10:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(ip->type == T_DEV){
80101e13:	0f 84 b7 00 00 00    	je     80101ed0 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101e19:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101e1c:	3b 70 58             	cmp    0x58(%eax),%esi
80101e1f:	0f 87 e7 00 00 00    	ja     80101f0c <writei+0x11c>
80101e25:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101e28:	31 d2                	xor    %edx,%edx
80101e2a:	89 f8                	mov    %edi,%eax
80101e2c:	01 f0                	add    %esi,%eax
80101e2e:	0f 92 c2             	setb   %dl
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101e31:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101e36:	0f 87 d0 00 00 00    	ja     80101f0c <writei+0x11c>
80101e3c:	85 d2                	test   %edx,%edx
80101e3e:	0f 85 c8 00 00 00    	jne    80101f0c <writei+0x11c>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101e44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101e4b:	85 ff                	test   %edi,%edi
80101e4d:	74 72                	je     80101ec1 <writei+0xd1>
80101e4f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e50:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101e53:	89 f2                	mov    %esi,%edx
80101e55:	c1 ea 09             	shr    $0x9,%edx
80101e58:	89 f8                	mov    %edi,%eax
80101e5a:	e8 21 f7 ff ff       	call   80101580 <bmap>
80101e5f:	83 ec 08             	sub    $0x8,%esp
80101e62:	50                   	push   %eax
80101e63:	ff 37                	push   (%edi)
80101e65:	e8 26 e3 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101e6a:	b9 00 02 00 00       	mov    $0x200,%ecx
80101e6f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101e72:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e75:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101e77:	89 f0                	mov    %esi,%eax
80101e79:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e7e:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101e80:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101e84:	39 d9                	cmp    %ebx,%ecx
80101e86:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101e89:	83 c4 0c             	add    $0xc,%esp
80101e8c:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101e8d:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101e8f:	ff 75 dc             	push   -0x24(%ebp)
80101e92:	50                   	push   %eax
80101e93:	e8 08 2c 00 00       	call   80104aa0 <memmove>
    log_write(bp);
80101e98:	89 3c 24             	mov    %edi,(%esp)
80101e9b:	e8 60 13 00 00       	call   80103200 <log_write>
    brelse(bp);
80101ea0:	89 3c 24             	mov    %edi,(%esp)
80101ea3:	e8 68 e3 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101ea8:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101eab:	83 c4 10             	add    $0x10,%esp
80101eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101eb1:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101eb4:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101eb7:	77 97                	ja     80101e50 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101eb9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101ebc:	3b 70 58             	cmp    0x58(%eax),%esi
80101ebf:	77 37                	ja     80101ef8 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101ec1:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101ec4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101ec7:	5b                   	pop    %ebx
80101ec8:	5e                   	pop    %esi
80101ec9:	5f                   	pop    %edi
80101eca:	5d                   	pop    %ebp
80101ecb:	c3                   	ret    
80101ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101ed0:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101ed4:	66 83 f8 09          	cmp    $0x9,%ax
80101ed8:	77 32                	ja     80101f0c <writei+0x11c>
80101eda:	8b 04 c5 04 09 11 80 	mov    -0x7feef6fc(,%eax,8),%eax
80101ee1:	85 c0                	test   %eax,%eax
80101ee3:	74 27                	je     80101f0c <writei+0x11c>
    return devsw[ip->major].write(ip, src, n);
80101ee5:	89 55 10             	mov    %edx,0x10(%ebp)
}
80101ee8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101eeb:	5b                   	pop    %ebx
80101eec:	5e                   	pop    %esi
80101eed:	5f                   	pop    %edi
80101eee:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101eef:	ff e0                	jmp    *%eax
80101ef1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101ef8:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101efb:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101efe:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101f01:	50                   	push   %eax
80101f02:	e8 29 fa ff ff       	call   80101930 <iupdate>
80101f07:	83 c4 10             	add    $0x10,%esp
80101f0a:	eb b5                	jmp    80101ec1 <writei+0xd1>
      return -1;
80101f0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f11:	eb b1                	jmp    80101ec4 <writei+0xd4>
80101f13:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101f20 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101f20:	55                   	push   %ebp
80101f21:	89 e5                	mov    %esp,%ebp
80101f23:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101f26:	6a 0e                	push   $0xe
80101f28:	ff 75 0c             	push   0xc(%ebp)
80101f2b:	ff 75 08             	push   0x8(%ebp)
80101f2e:	e8 dd 2b 00 00       	call   80104b10 <strncmp>
}
80101f33:	c9                   	leave  
80101f34:	c3                   	ret    
80101f35:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101f40 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101f40:	55                   	push   %ebp
80101f41:	89 e5                	mov    %esp,%ebp
80101f43:	57                   	push   %edi
80101f44:	56                   	push   %esi
80101f45:	53                   	push   %ebx
80101f46:	83 ec 1c             	sub    $0x1c,%esp
80101f49:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101f4c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101f51:	0f 85 85 00 00 00    	jne    80101fdc <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101f57:	8b 53 58             	mov    0x58(%ebx),%edx
80101f5a:	31 ff                	xor    %edi,%edi
80101f5c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101f5f:	85 d2                	test   %edx,%edx
80101f61:	74 3e                	je     80101fa1 <dirlookup+0x61>
80101f63:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101f67:	90                   	nop
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101f68:	6a 10                	push   $0x10
80101f6a:	57                   	push   %edi
80101f6b:	56                   	push   %esi
80101f6c:	53                   	push   %ebx
80101f6d:	e8 7e fd ff ff       	call   80101cf0 <readi>
80101f72:	83 c4 10             	add    $0x10,%esp
80101f75:	83 f8 10             	cmp    $0x10,%eax
80101f78:	75 55                	jne    80101fcf <dirlookup+0x8f>
      panic("dirlookup read");
    if(de.inum == 0)
80101f7a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101f7f:	74 18                	je     80101f99 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101f81:	83 ec 04             	sub    $0x4,%esp
80101f84:	8d 45 da             	lea    -0x26(%ebp),%eax
80101f87:	6a 0e                	push   $0xe
80101f89:	50                   	push   %eax
80101f8a:	ff 75 0c             	push   0xc(%ebp)
80101f8d:	e8 7e 2b 00 00       	call   80104b10 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101f92:	83 c4 10             	add    $0x10,%esp
80101f95:	85 c0                	test   %eax,%eax
80101f97:	74 17                	je     80101fb0 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101f99:	83 c7 10             	add    $0x10,%edi
80101f9c:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101f9f:	72 c7                	jb     80101f68 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101fa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101fa4:	31 c0                	xor    %eax,%eax
}
80101fa6:	5b                   	pop    %ebx
80101fa7:	5e                   	pop    %esi
80101fa8:	5f                   	pop    %edi
80101fa9:	5d                   	pop    %ebp
80101faa:	c3                   	ret    
80101fab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101faf:	90                   	nop
      if(poff)
80101fb0:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb3:	85 c0                	test   %eax,%eax
80101fb5:	74 05                	je     80101fbc <dirlookup+0x7c>
        *poff = off;
80101fb7:	8b 45 10             	mov    0x10(%ebp),%eax
80101fba:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101fbc:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101fc0:	8b 03                	mov    (%ebx),%eax
80101fc2:	e8 b9 f4 ff ff       	call   80101480 <iget>
}
80101fc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101fca:	5b                   	pop    %ebx
80101fcb:	5e                   	pop    %esi
80101fcc:	5f                   	pop    %edi
80101fcd:	5d                   	pop    %ebp
80101fce:	c3                   	ret    
      panic("dirlookup read");
80101fcf:	83 ec 0c             	sub    $0xc,%esp
80101fd2:	68 c6 7a 10 80       	push   $0x80107ac6
80101fd7:	e8 d4 e4 ff ff       	call   801004b0 <panic>
    panic("dirlookup not DIR");
80101fdc:	83 ec 0c             	sub    $0xc,%esp
80101fdf:	68 b4 7a 10 80       	push   $0x80107ab4
80101fe4:	e8 c7 e4 ff ff       	call   801004b0 <panic>
80101fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101ff0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101ff0:	55                   	push   %ebp
80101ff1:	89 e5                	mov    %esp,%ebp
80101ff3:	57                   	push   %edi
80101ff4:	56                   	push   %esi
80101ff5:	53                   	push   %ebx
80101ff6:	89 c3                	mov    %eax,%ebx
80101ff8:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101ffb:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101ffe:	89 55 dc             	mov    %edx,-0x24(%ebp)
80102001:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80102004:	0f 84 64 01 00 00    	je     8010216e <namex+0x17e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
8010200a:	e8 41 1c 00 00       	call   80103c50 <myproc>
  acquire(&icache.lock);
8010200f:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(myproc()->cwd);
80102012:	8b 70 6c             	mov    0x6c(%eax),%esi
  acquire(&icache.lock);
80102015:	68 60 09 11 80       	push   $0x80110960
8010201a:	e8 21 29 00 00       	call   80104940 <acquire>
  ip->ref++;
8010201f:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80102023:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
8010202a:	e8 b1 28 00 00       	call   801048e0 <release>
8010202f:	83 c4 10             	add    $0x10,%esp
80102032:	eb 07                	jmp    8010203b <namex+0x4b>
80102034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80102038:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
8010203b:	0f b6 03             	movzbl (%ebx),%eax
8010203e:	3c 2f                	cmp    $0x2f,%al
80102040:	74 f6                	je     80102038 <namex+0x48>
  if(*path == 0)
80102042:	84 c0                	test   %al,%al
80102044:	0f 84 06 01 00 00    	je     80102150 <namex+0x160>
  while(*path != '/' && *path != 0)
8010204a:	0f b6 03             	movzbl (%ebx),%eax
8010204d:	84 c0                	test   %al,%al
8010204f:	0f 84 10 01 00 00    	je     80102165 <namex+0x175>
80102055:	89 df                	mov    %ebx,%edi
80102057:	3c 2f                	cmp    $0x2f,%al
80102059:	0f 84 06 01 00 00    	je     80102165 <namex+0x175>
8010205f:	90                   	nop
80102060:	0f b6 47 01          	movzbl 0x1(%edi),%eax
    path++;
80102064:	83 c7 01             	add    $0x1,%edi
  while(*path != '/' && *path != 0)
80102067:	3c 2f                	cmp    $0x2f,%al
80102069:	74 04                	je     8010206f <namex+0x7f>
8010206b:	84 c0                	test   %al,%al
8010206d:	75 f1                	jne    80102060 <namex+0x70>
  len = path - s;
8010206f:	89 f8                	mov    %edi,%eax
80102071:	29 d8                	sub    %ebx,%eax
  if(len >= DIRSIZ)
80102073:	83 f8 0d             	cmp    $0xd,%eax
80102076:	0f 8e ac 00 00 00    	jle    80102128 <namex+0x138>
    memmove(name, s, DIRSIZ);
8010207c:	83 ec 04             	sub    $0x4,%esp
8010207f:	6a 0e                	push   $0xe
80102081:	53                   	push   %ebx
    path++;
80102082:	89 fb                	mov    %edi,%ebx
    memmove(name, s, DIRSIZ);
80102084:	ff 75 e4             	push   -0x1c(%ebp)
80102087:	e8 14 2a 00 00       	call   80104aa0 <memmove>
8010208c:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
8010208f:	80 3f 2f             	cmpb   $0x2f,(%edi)
80102092:	75 0c                	jne    801020a0 <namex+0xb0>
80102094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80102098:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
8010209b:	80 3b 2f             	cmpb   $0x2f,(%ebx)
8010209e:	74 f8                	je     80102098 <namex+0xa8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
801020a0:	83 ec 0c             	sub    $0xc,%esp
801020a3:	56                   	push   %esi
801020a4:	e8 37 f9 ff ff       	call   801019e0 <ilock>
    if(ip->type != T_DIR){
801020a9:	83 c4 10             	add    $0x10,%esp
801020ac:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801020b1:	0f 85 cd 00 00 00    	jne    80102184 <namex+0x194>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
801020b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801020ba:	85 c0                	test   %eax,%eax
801020bc:	74 09                	je     801020c7 <namex+0xd7>
801020be:	80 3b 00             	cmpb   $0x0,(%ebx)
801020c1:	0f 84 22 01 00 00    	je     801021e9 <namex+0x1f9>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801020c7:	83 ec 04             	sub    $0x4,%esp
801020ca:	6a 00                	push   $0x0
801020cc:	ff 75 e4             	push   -0x1c(%ebp)
801020cf:	56                   	push   %esi
801020d0:	e8 6b fe ff ff       	call   80101f40 <dirlookup>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801020d5:	8d 56 0c             	lea    0xc(%esi),%edx
    if((next = dirlookup(ip, name, 0)) == 0){
801020d8:	83 c4 10             	add    $0x10,%esp
801020db:	89 c7                	mov    %eax,%edi
801020dd:	85 c0                	test   %eax,%eax
801020df:	0f 84 e1 00 00 00    	je     801021c6 <namex+0x1d6>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801020e5:	83 ec 0c             	sub    $0xc,%esp
801020e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
801020eb:	52                   	push   %edx
801020ec:	e8 2f 26 00 00       	call   80104720 <holdingsleep>
801020f1:	83 c4 10             	add    $0x10,%esp
801020f4:	85 c0                	test   %eax,%eax
801020f6:	0f 84 30 01 00 00    	je     8010222c <namex+0x23c>
801020fc:	8b 56 08             	mov    0x8(%esi),%edx
801020ff:	85 d2                	test   %edx,%edx
80102101:	0f 8e 25 01 00 00    	jle    8010222c <namex+0x23c>
  releasesleep(&ip->lock);
80102107:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010210a:	83 ec 0c             	sub    $0xc,%esp
8010210d:	52                   	push   %edx
8010210e:	e8 cd 25 00 00       	call   801046e0 <releasesleep>
  iput(ip);
80102113:	89 34 24             	mov    %esi,(%esp)
80102116:	89 fe                	mov    %edi,%esi
80102118:	e8 f3 f9 ff ff       	call   80101b10 <iput>
8010211d:	83 c4 10             	add    $0x10,%esp
80102120:	e9 16 ff ff ff       	jmp    8010203b <namex+0x4b>
80102125:	8d 76 00             	lea    0x0(%esi),%esi
    name[len] = 0;
80102128:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010212b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
    memmove(name, s, len);
8010212e:	83 ec 04             	sub    $0x4,%esp
80102131:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102134:	50                   	push   %eax
80102135:	53                   	push   %ebx
    name[len] = 0;
80102136:	89 fb                	mov    %edi,%ebx
    memmove(name, s, len);
80102138:	ff 75 e4             	push   -0x1c(%ebp)
8010213b:	e8 60 29 00 00       	call   80104aa0 <memmove>
    name[len] = 0;
80102140:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102143:	83 c4 10             	add    $0x10,%esp
80102146:	c6 02 00             	movb   $0x0,(%edx)
80102149:	e9 41 ff ff ff       	jmp    8010208f <namex+0x9f>
8010214e:	66 90                	xchg   %ax,%ax
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102150:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102153:	85 c0                	test   %eax,%eax
80102155:	0f 85 be 00 00 00    	jne    80102219 <namex+0x229>
    iput(ip);
    return 0;
  }
  return ip;
}
8010215b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010215e:	89 f0                	mov    %esi,%eax
80102160:	5b                   	pop    %ebx
80102161:	5e                   	pop    %esi
80102162:	5f                   	pop    %edi
80102163:	5d                   	pop    %ebp
80102164:	c3                   	ret    
  while(*path != '/' && *path != 0)
80102165:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102168:	89 df                	mov    %ebx,%edi
8010216a:	31 c0                	xor    %eax,%eax
8010216c:	eb c0                	jmp    8010212e <namex+0x13e>
    ip = iget(ROOTDEV, ROOTINO);
8010216e:	ba 01 00 00 00       	mov    $0x1,%edx
80102173:	b8 01 00 00 00       	mov    $0x1,%eax
80102178:	e8 03 f3 ff ff       	call   80101480 <iget>
8010217d:	89 c6                	mov    %eax,%esi
8010217f:	e9 b7 fe ff ff       	jmp    8010203b <namex+0x4b>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80102184:	83 ec 0c             	sub    $0xc,%esp
80102187:	8d 5e 0c             	lea    0xc(%esi),%ebx
8010218a:	53                   	push   %ebx
8010218b:	e8 90 25 00 00       	call   80104720 <holdingsleep>
80102190:	83 c4 10             	add    $0x10,%esp
80102193:	85 c0                	test   %eax,%eax
80102195:	0f 84 91 00 00 00    	je     8010222c <namex+0x23c>
8010219b:	8b 46 08             	mov    0x8(%esi),%eax
8010219e:	85 c0                	test   %eax,%eax
801021a0:	0f 8e 86 00 00 00    	jle    8010222c <namex+0x23c>
  releasesleep(&ip->lock);
801021a6:	83 ec 0c             	sub    $0xc,%esp
801021a9:	53                   	push   %ebx
801021aa:	e8 31 25 00 00       	call   801046e0 <releasesleep>
  iput(ip);
801021af:	89 34 24             	mov    %esi,(%esp)
      return 0;
801021b2:	31 f6                	xor    %esi,%esi
  iput(ip);
801021b4:	e8 57 f9 ff ff       	call   80101b10 <iput>
      return 0;
801021b9:	83 c4 10             	add    $0x10,%esp
}
801021bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801021bf:	89 f0                	mov    %esi,%eax
801021c1:	5b                   	pop    %ebx
801021c2:	5e                   	pop    %esi
801021c3:	5f                   	pop    %edi
801021c4:	5d                   	pop    %ebp
801021c5:	c3                   	ret    
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801021c6:	83 ec 0c             	sub    $0xc,%esp
801021c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801021cc:	52                   	push   %edx
801021cd:	e8 4e 25 00 00       	call   80104720 <holdingsleep>
801021d2:	83 c4 10             	add    $0x10,%esp
801021d5:	85 c0                	test   %eax,%eax
801021d7:	74 53                	je     8010222c <namex+0x23c>
801021d9:	8b 4e 08             	mov    0x8(%esi),%ecx
801021dc:	85 c9                	test   %ecx,%ecx
801021de:	7e 4c                	jle    8010222c <namex+0x23c>
  releasesleep(&ip->lock);
801021e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801021e3:	83 ec 0c             	sub    $0xc,%esp
801021e6:	52                   	push   %edx
801021e7:	eb c1                	jmp    801021aa <namex+0x1ba>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801021e9:	83 ec 0c             	sub    $0xc,%esp
801021ec:	8d 5e 0c             	lea    0xc(%esi),%ebx
801021ef:	53                   	push   %ebx
801021f0:	e8 2b 25 00 00       	call   80104720 <holdingsleep>
801021f5:	83 c4 10             	add    $0x10,%esp
801021f8:	85 c0                	test   %eax,%eax
801021fa:	74 30                	je     8010222c <namex+0x23c>
801021fc:	8b 7e 08             	mov    0x8(%esi),%edi
801021ff:	85 ff                	test   %edi,%edi
80102201:	7e 29                	jle    8010222c <namex+0x23c>
  releasesleep(&ip->lock);
80102203:	83 ec 0c             	sub    $0xc,%esp
80102206:	53                   	push   %ebx
80102207:	e8 d4 24 00 00       	call   801046e0 <releasesleep>
}
8010220c:	83 c4 10             	add    $0x10,%esp
}
8010220f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102212:	89 f0                	mov    %esi,%eax
80102214:	5b                   	pop    %ebx
80102215:	5e                   	pop    %esi
80102216:	5f                   	pop    %edi
80102217:	5d                   	pop    %ebp
80102218:	c3                   	ret    
    iput(ip);
80102219:	83 ec 0c             	sub    $0xc,%esp
8010221c:	56                   	push   %esi
    return 0;
8010221d:	31 f6                	xor    %esi,%esi
    iput(ip);
8010221f:	e8 ec f8 ff ff       	call   80101b10 <iput>
    return 0;
80102224:	83 c4 10             	add    $0x10,%esp
80102227:	e9 2f ff ff ff       	jmp    8010215b <namex+0x16b>
    panic("iunlock");
8010222c:	83 ec 0c             	sub    $0xc,%esp
8010222f:	68 ac 7a 10 80       	push   $0x80107aac
80102234:	e8 77 e2 ff ff       	call   801004b0 <panic>
80102239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102240 <dirlink>:
{
80102240:	55                   	push   %ebp
80102241:	89 e5                	mov    %esp,%ebp
80102243:	57                   	push   %edi
80102244:	56                   	push   %esi
80102245:	53                   	push   %ebx
80102246:	83 ec 20             	sub    $0x20,%esp
80102249:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
8010224c:	6a 00                	push   $0x0
8010224e:	ff 75 0c             	push   0xc(%ebp)
80102251:	53                   	push   %ebx
80102252:	e8 e9 fc ff ff       	call   80101f40 <dirlookup>
80102257:	83 c4 10             	add    $0x10,%esp
8010225a:	85 c0                	test   %eax,%eax
8010225c:	75 67                	jne    801022c5 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010225e:	8b 7b 58             	mov    0x58(%ebx),%edi
80102261:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102264:	85 ff                	test   %edi,%edi
80102266:	74 29                	je     80102291 <dirlink+0x51>
80102268:	31 ff                	xor    %edi,%edi
8010226a:	8d 75 d8             	lea    -0x28(%ebp),%esi
8010226d:	eb 09                	jmp    80102278 <dirlink+0x38>
8010226f:	90                   	nop
80102270:	83 c7 10             	add    $0x10,%edi
80102273:	3b 7b 58             	cmp    0x58(%ebx),%edi
80102276:	73 19                	jae    80102291 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102278:	6a 10                	push   $0x10
8010227a:	57                   	push   %edi
8010227b:	56                   	push   %esi
8010227c:	53                   	push   %ebx
8010227d:	e8 6e fa ff ff       	call   80101cf0 <readi>
80102282:	83 c4 10             	add    $0x10,%esp
80102285:	83 f8 10             	cmp    $0x10,%eax
80102288:	75 4e                	jne    801022d8 <dirlink+0x98>
    if(de.inum == 0)
8010228a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010228f:	75 df                	jne    80102270 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80102291:	83 ec 04             	sub    $0x4,%esp
80102294:	8d 45 da             	lea    -0x26(%ebp),%eax
80102297:	6a 0e                	push   $0xe
80102299:	ff 75 0c             	push   0xc(%ebp)
8010229c:	50                   	push   %eax
8010229d:	e8 be 28 00 00       	call   80104b60 <strncpy>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022a2:	6a 10                	push   $0x10
  de.inum = inum;
801022a4:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022a7:	57                   	push   %edi
801022a8:	56                   	push   %esi
801022a9:	53                   	push   %ebx
  de.inum = inum;
801022aa:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022ae:	e8 3d fb ff ff       	call   80101df0 <writei>
801022b3:	83 c4 20             	add    $0x20,%esp
801022b6:	83 f8 10             	cmp    $0x10,%eax
801022b9:	75 2a                	jne    801022e5 <dirlink+0xa5>
  return 0;
801022bb:	31 c0                	xor    %eax,%eax
}
801022bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022c0:	5b                   	pop    %ebx
801022c1:	5e                   	pop    %esi
801022c2:	5f                   	pop    %edi
801022c3:	5d                   	pop    %ebp
801022c4:	c3                   	ret    
    iput(ip);
801022c5:	83 ec 0c             	sub    $0xc,%esp
801022c8:	50                   	push   %eax
801022c9:	e8 42 f8 ff ff       	call   80101b10 <iput>
    return -1;
801022ce:	83 c4 10             	add    $0x10,%esp
801022d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022d6:	eb e5                	jmp    801022bd <dirlink+0x7d>
      panic("dirlink read");
801022d8:	83 ec 0c             	sub    $0xc,%esp
801022db:	68 d5 7a 10 80       	push   $0x80107ad5
801022e0:	e8 cb e1 ff ff       	call   801004b0 <panic>
    panic("dirlink");
801022e5:	83 ec 0c             	sub    $0xc,%esp
801022e8:	68 06 81 10 80       	push   $0x80108106
801022ed:	e8 be e1 ff ff       	call   801004b0 <panic>
801022f2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102300 <namei>:

struct inode*
namei(char *path)
{
80102300:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102301:	31 d2                	xor    %edx,%edx
{
80102303:	89 e5                	mov    %esp,%ebp
80102305:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
80102308:	8b 45 08             	mov    0x8(%ebp),%eax
8010230b:	8d 4d ea             	lea    -0x16(%ebp),%ecx
8010230e:	e8 dd fc ff ff       	call   80101ff0 <namex>
}
80102313:	c9                   	leave  
80102314:	c3                   	ret    
80102315:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010231c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102320 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102320:	55                   	push   %ebp
  return namex(path, 1, name);
80102321:	ba 01 00 00 00       	mov    $0x1,%edx
{
80102326:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
80102328:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010232b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010232e:	5d                   	pop    %ebp
  return namex(path, 1, name);
8010232f:	e9 bc fc ff ff       	jmp    80101ff0 <namex>
80102334:	66 90                	xchg   %ax,%ax
80102336:	66 90                	xchg   %ax,%ax
80102338:	66 90                	xchg   %ax,%ax
8010233a:	66 90                	xchg   %ax,%ax
8010233c:	66 90                	xchg   %ax,%ax
8010233e:	66 90                	xchg   %ax,%ax

80102340 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102340:	55                   	push   %ebp
80102341:	89 e5                	mov    %esp,%ebp
80102343:	57                   	push   %edi
80102344:	56                   	push   %esi
80102345:	53                   	push   %ebx
80102346:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
80102349:	85 c0                	test   %eax,%eax
8010234b:	0f 84 b4 00 00 00    	je     80102405 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80102351:	8b 70 08             	mov    0x8(%eax),%esi
80102354:	89 c3                	mov    %eax,%ebx
80102356:	81 fe e7 03 00 00    	cmp    $0x3e7,%esi
8010235c:	0f 87 96 00 00 00    	ja     801023f8 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102362:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102367:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010236e:	66 90                	xchg   %ax,%ax
80102370:	89 ca                	mov    %ecx,%edx
80102372:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102373:	83 e0 c0             	and    $0xffffffc0,%eax
80102376:	3c 40                	cmp    $0x40,%al
80102378:	75 f6                	jne    80102370 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010237a:	31 ff                	xor    %edi,%edi
8010237c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102381:	89 f8                	mov    %edi,%eax
80102383:	ee                   	out    %al,(%dx)
80102384:	b8 01 00 00 00       	mov    $0x1,%eax
80102389:	ba f2 01 00 00       	mov    $0x1f2,%edx
8010238e:	ee                   	out    %al,(%dx)
8010238f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80102394:	89 f0                	mov    %esi,%eax
80102396:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80102397:	89 f0                	mov    %esi,%eax
80102399:	ba f4 01 00 00       	mov    $0x1f4,%edx
8010239e:	c1 f8 08             	sar    $0x8,%eax
801023a1:	ee                   	out    %al,(%dx)
801023a2:	ba f5 01 00 00       	mov    $0x1f5,%edx
801023a7:	89 f8                	mov    %edi,%eax
801023a9:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801023aa:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
801023ae:	ba f6 01 00 00       	mov    $0x1f6,%edx
801023b3:	c1 e0 04             	shl    $0x4,%eax
801023b6:	83 e0 10             	and    $0x10,%eax
801023b9:	83 c8 e0             	or     $0xffffffe0,%eax
801023bc:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
801023bd:	f6 03 04             	testb  $0x4,(%ebx)
801023c0:	75 16                	jne    801023d8 <idestart+0x98>
801023c2:	b8 20 00 00 00       	mov    $0x20,%eax
801023c7:	89 ca                	mov    %ecx,%edx
801023c9:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
801023ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
801023cd:	5b                   	pop    %ebx
801023ce:	5e                   	pop    %esi
801023cf:	5f                   	pop    %edi
801023d0:	5d                   	pop    %ebp
801023d1:	c3                   	ret    
801023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801023d8:	b8 30 00 00 00       	mov    $0x30,%eax
801023dd:	89 ca                	mov    %ecx,%edx
801023df:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
801023e0:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
801023e5:	8d 73 5c             	lea    0x5c(%ebx),%esi
801023e8:	ba f0 01 00 00       	mov    $0x1f0,%edx
801023ed:	fc                   	cld    
801023ee:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
801023f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801023f3:	5b                   	pop    %ebx
801023f4:	5e                   	pop    %esi
801023f5:	5f                   	pop    %edi
801023f6:	5d                   	pop    %ebp
801023f7:	c3                   	ret    
    panic("incorrect blockno");
801023f8:	83 ec 0c             	sub    $0xc,%esp
801023fb:	68 40 7b 10 80       	push   $0x80107b40
80102400:	e8 ab e0 ff ff       	call   801004b0 <panic>
    panic("idestart");
80102405:	83 ec 0c             	sub    $0xc,%esp
80102408:	68 37 7b 10 80       	push   $0x80107b37
8010240d:	e8 9e e0 ff ff       	call   801004b0 <panic>
80102412:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102420 <ideinit>:
{
80102420:	55                   	push   %ebp
80102421:	89 e5                	mov    %esp,%ebp
80102423:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80102426:	68 52 7b 10 80       	push   $0x80107b52
8010242b:	68 40 26 11 80       	push   $0x80112640
80102430:	e8 3b 23 00 00       	call   80104770 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102435:	58                   	pop    %eax
80102436:	a1 c4 27 11 80       	mov    0x801127c4,%eax
8010243b:	5a                   	pop    %edx
8010243c:	83 e8 01             	sub    $0x1,%eax
8010243f:	50                   	push   %eax
80102440:	6a 0e                	push   $0xe
80102442:	e8 99 02 00 00       	call   801026e0 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102447:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010244a:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010244f:	90                   	nop
80102450:	ec                   	in     (%dx),%al
80102451:	83 e0 c0             	and    $0xffffffc0,%eax
80102454:	3c 40                	cmp    $0x40,%al
80102456:	75 f8                	jne    80102450 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102458:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010245d:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102462:	ee                   	out    %al,(%dx)
80102463:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102468:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010246d:	eb 06                	jmp    80102475 <ideinit+0x55>
8010246f:	90                   	nop
  for(i=0; i<1000; i++){
80102470:	83 e9 01             	sub    $0x1,%ecx
80102473:	74 0f                	je     80102484 <ideinit+0x64>
80102475:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102476:	84 c0                	test   %al,%al
80102478:	74 f6                	je     80102470 <ideinit+0x50>
      havedisk1 = 1;
8010247a:	c7 05 20 26 11 80 01 	movl   $0x1,0x80112620
80102481:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102484:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102489:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010248e:	ee                   	out    %al,(%dx)
}
8010248f:	c9                   	leave  
80102490:	c3                   	ret    
80102491:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102498:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010249f:	90                   	nop

801024a0 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801024a0:	55                   	push   %ebp
801024a1:	89 e5                	mov    %esp,%ebp
801024a3:	57                   	push   %edi
801024a4:	56                   	push   %esi
801024a5:	53                   	push   %ebx
801024a6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801024a9:	68 40 26 11 80       	push   $0x80112640
801024ae:	e8 8d 24 00 00       	call   80104940 <acquire>

  if((b = idequeue) == 0){
801024b3:	8b 1d 24 26 11 80    	mov    0x80112624,%ebx
801024b9:	83 c4 10             	add    $0x10,%esp
801024bc:	85 db                	test   %ebx,%ebx
801024be:	74 63                	je     80102523 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
801024c0:	8b 43 58             	mov    0x58(%ebx),%eax
801024c3:	a3 24 26 11 80       	mov    %eax,0x80112624

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801024c8:	8b 33                	mov    (%ebx),%esi
801024ca:	f7 c6 04 00 00 00    	test   $0x4,%esi
801024d0:	75 2f                	jne    80102501 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024d2:	ba f7 01 00 00       	mov    $0x1f7,%edx
801024d7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801024de:	66 90                	xchg   %ax,%ax
801024e0:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801024e1:	89 c1                	mov    %eax,%ecx
801024e3:	83 e1 c0             	and    $0xffffffc0,%ecx
801024e6:	80 f9 40             	cmp    $0x40,%cl
801024e9:	75 f5                	jne    801024e0 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801024eb:	a8 21                	test   $0x21,%al
801024ed:	75 12                	jne    80102501 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
801024ef:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
801024f2:	b9 80 00 00 00       	mov    $0x80,%ecx
801024f7:	ba f0 01 00 00       	mov    $0x1f0,%edx
801024fc:	fc                   	cld    
801024fd:	f3 6d                	rep insl (%dx),%es:(%edi)

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801024ff:	8b 33                	mov    (%ebx),%esi
  b->flags &= ~B_DIRTY;
80102501:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
80102504:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
80102507:	83 ce 02             	or     $0x2,%esi
8010250a:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
8010250c:	53                   	push   %ebx
8010250d:	e8 3e 1f 00 00       	call   80104450 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102512:	a1 24 26 11 80       	mov    0x80112624,%eax
80102517:	83 c4 10             	add    $0x10,%esp
8010251a:	85 c0                	test   %eax,%eax
8010251c:	74 05                	je     80102523 <ideintr+0x83>
    idestart(idequeue);
8010251e:	e8 1d fe ff ff       	call   80102340 <idestart>
    release(&idelock);
80102523:	83 ec 0c             	sub    $0xc,%esp
80102526:	68 40 26 11 80       	push   $0x80112640
8010252b:	e8 b0 23 00 00       	call   801048e0 <release>

  release(&idelock);
}
80102530:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102533:	5b                   	pop    %ebx
80102534:	5e                   	pop    %esi
80102535:	5f                   	pop    %edi
80102536:	5d                   	pop    %ebp
80102537:	c3                   	ret    
80102538:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010253f:	90                   	nop

80102540 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102540:	55                   	push   %ebp
80102541:	89 e5                	mov    %esp,%ebp
80102543:	53                   	push   %ebx
80102544:	83 ec 10             	sub    $0x10,%esp
80102547:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010254a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010254d:	50                   	push   %eax
8010254e:	e8 cd 21 00 00       	call   80104720 <holdingsleep>
80102553:	83 c4 10             	add    $0x10,%esp
80102556:	85 c0                	test   %eax,%eax
80102558:	0f 84 c3 00 00 00    	je     80102621 <iderw+0xe1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010255e:	8b 03                	mov    (%ebx),%eax
80102560:	83 e0 06             	and    $0x6,%eax
80102563:	83 f8 02             	cmp    $0x2,%eax
80102566:	0f 84 a8 00 00 00    	je     80102614 <iderw+0xd4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010256c:	8b 53 04             	mov    0x4(%ebx),%edx
8010256f:	85 d2                	test   %edx,%edx
80102571:	74 0d                	je     80102580 <iderw+0x40>
80102573:	a1 20 26 11 80       	mov    0x80112620,%eax
80102578:	85 c0                	test   %eax,%eax
8010257a:	0f 84 87 00 00 00    	je     80102607 <iderw+0xc7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102580:	83 ec 0c             	sub    $0xc,%esp
80102583:	68 40 26 11 80       	push   $0x80112640
80102588:	e8 b3 23 00 00       	call   80104940 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010258d:	a1 24 26 11 80       	mov    0x80112624,%eax
  b->qnext = 0;
80102592:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102599:	83 c4 10             	add    $0x10,%esp
8010259c:	85 c0                	test   %eax,%eax
8010259e:	74 60                	je     80102600 <iderw+0xc0>
801025a0:	89 c2                	mov    %eax,%edx
801025a2:	8b 40 58             	mov    0x58(%eax),%eax
801025a5:	85 c0                	test   %eax,%eax
801025a7:	75 f7                	jne    801025a0 <iderw+0x60>
801025a9:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
801025ac:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
801025ae:	39 1d 24 26 11 80    	cmp    %ebx,0x80112624
801025b4:	74 3a                	je     801025f0 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801025b6:	8b 03                	mov    (%ebx),%eax
801025b8:	83 e0 06             	and    $0x6,%eax
801025bb:	83 f8 02             	cmp    $0x2,%eax
801025be:	74 1b                	je     801025db <iderw+0x9b>
    sleep(b, &idelock);
801025c0:	83 ec 08             	sub    $0x8,%esp
801025c3:	68 40 26 11 80       	push   $0x80112640
801025c8:	53                   	push   %ebx
801025c9:	e8 c2 1d 00 00       	call   80104390 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801025ce:	8b 03                	mov    (%ebx),%eax
801025d0:	83 c4 10             	add    $0x10,%esp
801025d3:	83 e0 06             	and    $0x6,%eax
801025d6:	83 f8 02             	cmp    $0x2,%eax
801025d9:	75 e5                	jne    801025c0 <iderw+0x80>
  }


  release(&idelock);
801025db:	c7 45 08 40 26 11 80 	movl   $0x80112640,0x8(%ebp)
}
801025e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025e5:	c9                   	leave  
  release(&idelock);
801025e6:	e9 f5 22 00 00       	jmp    801048e0 <release>
801025eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801025ef:	90                   	nop
    idestart(b);
801025f0:	89 d8                	mov    %ebx,%eax
801025f2:	e8 49 fd ff ff       	call   80102340 <idestart>
801025f7:	eb bd                	jmp    801025b6 <iderw+0x76>
801025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102600:	ba 24 26 11 80       	mov    $0x80112624,%edx
80102605:	eb a5                	jmp    801025ac <iderw+0x6c>
    panic("iderw: ide disk 1 not present");
80102607:	83 ec 0c             	sub    $0xc,%esp
8010260a:	68 81 7b 10 80       	push   $0x80107b81
8010260f:	e8 9c de ff ff       	call   801004b0 <panic>
    panic("iderw: nothing to do");
80102614:	83 ec 0c             	sub    $0xc,%esp
80102617:	68 6c 7b 10 80       	push   $0x80107b6c
8010261c:	e8 8f de ff ff       	call   801004b0 <panic>
    panic("iderw: buf not locked");
80102621:	83 ec 0c             	sub    $0xc,%esp
80102624:	68 56 7b 10 80       	push   $0x80107b56
80102629:	e8 82 de ff ff       	call   801004b0 <panic>
8010262e:	66 90                	xchg   %ax,%ax

80102630 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
80102630:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102631:	c7 05 74 26 11 80 00 	movl   $0xfec00000,0x80112674
80102638:	00 c0 fe 
{
8010263b:	89 e5                	mov    %esp,%ebp
8010263d:	56                   	push   %esi
8010263e:	53                   	push   %ebx
  ioapic->reg = reg;
8010263f:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80102646:	00 00 00 
  return ioapic->data;
80102649:	8b 15 74 26 11 80    	mov    0x80112674,%edx
8010264f:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
80102652:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
80102658:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010265e:	0f b6 15 c0 27 11 80 	movzbl 0x801127c0,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102665:	c1 ee 10             	shr    $0x10,%esi
80102668:	89 f0                	mov    %esi,%eax
8010266a:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
8010266d:	8b 41 10             	mov    0x10(%ecx),%eax
  id = ioapicread(REG_ID) >> 24;
80102670:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102673:	39 c2                	cmp    %eax,%edx
80102675:	74 16                	je     8010268d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102677:	83 ec 0c             	sub    $0xc,%esp
8010267a:	68 a0 7b 10 80       	push   $0x80107ba0
8010267f:	e8 4c e1 ff ff       	call   801007d0 <cprintf>
  ioapic->reg = reg;
80102684:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
8010268a:	83 c4 10             	add    $0x10,%esp
8010268d:	83 c6 21             	add    $0x21,%esi
{
80102690:	ba 10 00 00 00       	mov    $0x10,%edx
80102695:	b8 20 00 00 00       	mov    $0x20,%eax
8010269a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  ioapic->reg = reg;
801026a0:	89 11                	mov    %edx,(%ecx)

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801026a2:	89 c3                	mov    %eax,%ebx
  ioapic->data = data;
801026a4:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
  for(i = 0; i <= maxintr; i++){
801026aa:	83 c0 01             	add    $0x1,%eax
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801026ad:	81 cb 00 00 01 00    	or     $0x10000,%ebx
  ioapic->data = data;
801026b3:	89 59 10             	mov    %ebx,0x10(%ecx)
  ioapic->reg = reg;
801026b6:	8d 5a 01             	lea    0x1(%edx),%ebx
  for(i = 0; i <= maxintr; i++){
801026b9:	83 c2 02             	add    $0x2,%edx
  ioapic->reg = reg;
801026bc:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
801026be:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
801026c4:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
801026cb:	39 f0                	cmp    %esi,%eax
801026cd:	75 d1                	jne    801026a0 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801026cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
801026d2:	5b                   	pop    %ebx
801026d3:	5e                   	pop    %esi
801026d4:	5d                   	pop    %ebp
801026d5:	c3                   	ret    
801026d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801026dd:	8d 76 00             	lea    0x0(%esi),%esi

801026e0 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801026e0:	55                   	push   %ebp
  ioapic->reg = reg;
801026e1:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
{
801026e7:	89 e5                	mov    %esp,%ebp
801026e9:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801026ec:	8d 50 20             	lea    0x20(%eax),%edx
801026ef:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801026f3:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801026f5:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801026fb:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
801026fe:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102701:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
80102704:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80102706:	a1 74 26 11 80       	mov    0x80112674,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010270b:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
8010270e:	89 50 10             	mov    %edx,0x10(%eax)
}
80102711:	5d                   	pop    %ebp
80102712:	c3                   	ret    
80102713:	66 90                	xchg   %ax,%ax
80102715:	66 90                	xchg   %ax,%ax
80102717:	66 90                	xchg   %ax,%ax
80102719:	66 90                	xchg   %ax,%ax
8010271b:	66 90                	xchg   %ax,%ax
8010271d:	66 90                	xchg   %ax,%ax
8010271f:	90                   	nop

80102720 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102720:	55                   	push   %ebp
80102721:	89 e5                	mov    %esp,%ebp
80102723:	53                   	push   %ebx
80102724:	83 ec 04             	sub    $0x4,%esp
80102727:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010272a:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102730:	0f 85 82 00 00 00    	jne    801027b8 <kfree+0x98>
80102736:	81 fb 10 66 11 80    	cmp    $0x80116610,%ebx
8010273c:	72 7a                	jb     801027b8 <kfree+0x98>
8010273e:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102744:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
80102749:	77 6d                	ja     801027b8 <kfree+0x98>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010274b:	83 ec 04             	sub    $0x4,%esp
8010274e:	68 00 10 00 00       	push   $0x1000
80102753:	6a 01                	push   $0x1
80102755:	53                   	push   %ebx
80102756:	e8 a5 22 00 00       	call   80104a00 <memset>

  if(kmem.use_lock)
8010275b:	8b 15 b4 26 11 80    	mov    0x801126b4,%edx
80102761:	83 c4 10             	add    $0x10,%esp
80102764:	85 d2                	test   %edx,%edx
80102766:	75 28                	jne    80102790 <kfree+0x70>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102768:	a1 bc 26 11 80       	mov    0x801126bc,%eax
8010276d:	89 03                	mov    %eax,(%ebx)
  kmem.num_free_pages+=1;
  kmem.freelist = r;
  if(kmem.use_lock)
8010276f:	a1 b4 26 11 80       	mov    0x801126b4,%eax
  kmem.num_free_pages+=1;
80102774:	83 05 b8 26 11 80 01 	addl   $0x1,0x801126b8
  kmem.freelist = r;
8010277b:	89 1d bc 26 11 80    	mov    %ebx,0x801126bc
  if(kmem.use_lock)
80102781:	85 c0                	test   %eax,%eax
80102783:	75 23                	jne    801027a8 <kfree+0x88>
    release(&kmem.lock);
}
80102785:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102788:	c9                   	leave  
80102789:	c3                   	ret    
8010278a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    acquire(&kmem.lock);
80102790:	83 ec 0c             	sub    $0xc,%esp
80102793:	68 80 26 11 80       	push   $0x80112680
80102798:	e8 a3 21 00 00       	call   80104940 <acquire>
8010279d:	83 c4 10             	add    $0x10,%esp
801027a0:	eb c6                	jmp    80102768 <kfree+0x48>
801027a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
801027a8:	c7 45 08 80 26 11 80 	movl   $0x80112680,0x8(%ebp)
}
801027af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027b2:	c9                   	leave  
    release(&kmem.lock);
801027b3:	e9 28 21 00 00       	jmp    801048e0 <release>
    panic("kfree");
801027b8:	83 ec 0c             	sub    $0xc,%esp
801027bb:	68 d2 7b 10 80       	push   $0x80107bd2
801027c0:	e8 eb dc ff ff       	call   801004b0 <panic>
801027c5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801027cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801027d0 <freerange>:
{
801027d0:	55                   	push   %ebp
801027d1:	89 e5                	mov    %esp,%ebp
801027d3:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
801027d4:	8b 45 08             	mov    0x8(%ebp),%eax
{
801027d7:	8b 75 0c             	mov    0xc(%ebp),%esi
801027da:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801027db:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801027e1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801027ed:	39 de                	cmp    %ebx,%esi
801027ef:	72 2a                	jb     8010281b <freerange+0x4b>
801027f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801027f8:	83 ec 0c             	sub    $0xc,%esp
801027fb:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102801:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102807:	50                   	push   %eax
80102808:	e8 13 ff ff ff       	call   80102720 <kfree>
    kmem.num_free_pages+=1;
8010280d:	83 05 b8 26 11 80 01 	addl   $0x1,0x801126b8
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102814:	83 c4 10             	add    $0x10,%esp
80102817:	39 f3                	cmp    %esi,%ebx
80102819:	76 dd                	jbe    801027f8 <freerange+0x28>
}
8010281b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010281e:	5b                   	pop    %ebx
8010281f:	5e                   	pop    %esi
80102820:	5d                   	pop    %ebp
80102821:	c3                   	ret    
80102822:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102830 <kinit2>:
{
80102830:	55                   	push   %ebp
80102831:	89 e5                	mov    %esp,%ebp
80102833:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
80102834:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102837:	8b 75 0c             	mov    0xc(%ebp),%esi
8010283a:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010283b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102841:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102847:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010284d:	39 de                	cmp    %ebx,%esi
8010284f:	72 2a                	jb     8010287b <kinit2+0x4b>
80102851:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102858:	83 ec 0c             	sub    $0xc,%esp
8010285b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102861:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102867:	50                   	push   %eax
80102868:	e8 b3 fe ff ff       	call   80102720 <kfree>
    kmem.num_free_pages+=1;
8010286d:	83 05 b8 26 11 80 01 	addl   $0x1,0x801126b8
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102874:	83 c4 10             	add    $0x10,%esp
80102877:	39 de                	cmp    %ebx,%esi
80102879:	73 dd                	jae    80102858 <kinit2+0x28>
  kmem.use_lock = 1;
8010287b:	c7 05 b4 26 11 80 01 	movl   $0x1,0x801126b4
80102882:	00 00 00 
}
80102885:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102888:	5b                   	pop    %ebx
80102889:	5e                   	pop    %esi
8010288a:	5d                   	pop    %ebp
8010288b:	c3                   	ret    
8010288c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102890 <kinit1>:
{
80102890:	55                   	push   %ebp
80102891:	89 e5                	mov    %esp,%ebp
80102893:	56                   	push   %esi
80102894:	53                   	push   %ebx
80102895:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102898:	83 ec 08             	sub    $0x8,%esp
8010289b:	68 d8 7b 10 80       	push   $0x80107bd8
801028a0:	68 80 26 11 80       	push   $0x80112680
801028a5:	e8 c6 1e 00 00       	call   80104770 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
801028aa:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801028ad:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801028b0:	c7 05 b4 26 11 80 00 	movl   $0x0,0x801126b4
801028b7:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
801028ba:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801028c0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801028c6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801028cc:	39 de                	cmp    %ebx,%esi
801028ce:	72 23                	jb     801028f3 <kinit1+0x63>
    kfree(p);
801028d0:	83 ec 0c             	sub    $0xc,%esp
801028d3:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801028d9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801028df:	50                   	push   %eax
801028e0:	e8 3b fe ff ff       	call   80102720 <kfree>
    kmem.num_free_pages+=1;
801028e5:	83 05 b8 26 11 80 01 	addl   $0x1,0x801126b8
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801028ec:	83 c4 10             	add    $0x10,%esp
801028ef:	39 de                	cmp    %ebx,%esi
801028f1:	73 dd                	jae    801028d0 <kinit1+0x40>
}
801028f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801028f6:	5b                   	pop    %ebx
801028f7:	5e                   	pop    %esi
801028f8:	5d                   	pop    %ebp
801028f9:	c3                   	ret    
801028fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102900 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102900:	55                   	push   %ebp
80102901:	89 e5                	mov    %esp,%ebp
80102903:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102906:	8b 0d b4 26 11 80    	mov    0x801126b4,%ecx
8010290c:	85 c9                	test   %ecx,%ecx
8010290e:	75 40                	jne    80102950 <kalloc+0x50>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102910:	a1 bc 26 11 80       	mov    0x801126bc,%eax
  if(r)
80102915:	85 c0                	test   %eax,%eax
80102917:	74 50                	je     80102969 <kalloc+0x69>
  {
    kmem.freelist = r->next;
80102919:	8b 10                	mov    (%eax),%edx
    kmem.num_free_pages-=1;
8010291b:	83 2d b8 26 11 80 01 	subl   $0x1,0x801126b8
    kmem.freelist = r->next;
80102922:	89 15 bc 26 11 80    	mov    %edx,0x801126bc
  }
  else{
    cprintf("in kalloc else\n");
    r = (struct run *)allocate_page();
  }
  if(kmem.use_lock)
80102928:	8b 15 b4 26 11 80    	mov    0x801126b4,%edx
8010292e:	85 d2                	test   %edx,%edx
80102930:	75 06                	jne    80102938 <kalloc+0x38>
    release(&kmem.lock);
  return (char*)r;
}
80102932:	c9                   	leave  
80102933:	c3                   	ret    
80102934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    release(&kmem.lock);
80102938:	83 ec 0c             	sub    $0xc,%esp
8010293b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010293e:	68 80 26 11 80       	push   $0x80112680
80102943:	e8 98 1f 00 00       	call   801048e0 <release>
80102948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294b:	83 c4 10             	add    $0x10,%esp
}
8010294e:	c9                   	leave  
8010294f:	c3                   	ret    
    acquire(&kmem.lock);
80102950:	83 ec 0c             	sub    $0xc,%esp
80102953:	68 80 26 11 80       	push   $0x80112680
80102958:	e8 e3 1f 00 00       	call   80104940 <acquire>
  r = kmem.freelist;
8010295d:	a1 bc 26 11 80       	mov    0x801126bc,%eax
    acquire(&kmem.lock);
80102962:	83 c4 10             	add    $0x10,%esp
  if(r)
80102965:	85 c0                	test   %eax,%eax
80102967:	75 b0                	jne    80102919 <kalloc+0x19>
    cprintf("in kalloc else\n");
80102969:	83 ec 0c             	sub    $0xc,%esp
8010296c:	68 dd 7b 10 80       	push   $0x80107bdd
80102971:	e8 5a de ff ff       	call   801007d0 <cprintf>
    r = (struct run *)allocate_page();
80102976:	e8 35 4d 00 00       	call   801076b0 <allocate_page>
8010297b:	83 c4 10             	add    $0x10,%esp
8010297e:	eb a8                	jmp    80102928 <kalloc+0x28>

80102980 <num_of_FreePages>:
uint 
num_of_FreePages(void)
{
80102980:	55                   	push   %ebp
80102981:	89 e5                	mov    %esp,%ebp
80102983:	53                   	push   %ebx
80102984:	83 ec 10             	sub    $0x10,%esp
  acquire(&kmem.lock);
80102987:	68 80 26 11 80       	push   $0x80112680
8010298c:	e8 af 1f 00 00       	call   80104940 <acquire>

  uint num_free_pages = kmem.num_free_pages;
80102991:	8b 1d b8 26 11 80    	mov    0x801126b8,%ebx
  
  release(&kmem.lock);
80102997:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
8010299e:	e8 3d 1f 00 00       	call   801048e0 <release>
  
  return num_free_pages;
}
801029a3:	89 d8                	mov    %ebx,%eax
801029a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029a8:	c9                   	leave  
801029a9:	c3                   	ret    
801029aa:	66 90                	xchg   %ax,%ax
801029ac:	66 90                	xchg   %ax,%ax
801029ae:	66 90                	xchg   %ax,%ax

801029b0 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029b0:	ba 64 00 00 00       	mov    $0x64,%edx
801029b5:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801029b6:	a8 01                	test   $0x1,%al
801029b8:	0f 84 c2 00 00 00    	je     80102a80 <kbdgetc+0xd0>
{
801029be:	55                   	push   %ebp
801029bf:	ba 60 00 00 00       	mov    $0x60,%edx
801029c4:	89 e5                	mov    %esp,%ebp
801029c6:	53                   	push   %ebx
801029c7:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
801029c8:	8b 1d c0 26 11 80    	mov    0x801126c0,%ebx
  data = inb(KBDATAP);
801029ce:	0f b6 c8             	movzbl %al,%ecx
  if(data == 0xE0){
801029d1:	3c e0                	cmp    $0xe0,%al
801029d3:	74 5b                	je     80102a30 <kbdgetc+0x80>
    return 0;
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801029d5:	89 da                	mov    %ebx,%edx
801029d7:	83 e2 40             	and    $0x40,%edx
  } else if(data & 0x80){
801029da:	84 c0                	test   %al,%al
801029dc:	78 62                	js     80102a40 <kbdgetc+0x90>
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801029de:	85 d2                	test   %edx,%edx
801029e0:	74 09                	je     801029eb <kbdgetc+0x3b>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801029e2:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
801029e5:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
801029e8:	0f b6 c8             	movzbl %al,%ecx
  }

  shift |= shiftcode[data];
801029eb:	0f b6 91 20 7d 10 80 	movzbl -0x7fef82e0(%ecx),%edx
  shift ^= togglecode[data];
801029f2:	0f b6 81 20 7c 10 80 	movzbl -0x7fef83e0(%ecx),%eax
  shift |= shiftcode[data];
801029f9:	09 da                	or     %ebx,%edx
  shift ^= togglecode[data];
801029fb:	31 c2                	xor    %eax,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
801029fd:	89 d0                	mov    %edx,%eax
  shift ^= togglecode[data];
801029ff:	89 15 c0 26 11 80    	mov    %edx,0x801126c0
  c = charcode[shift & (CTL | SHIFT)][data];
80102a05:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
80102a08:	83 e2 08             	and    $0x8,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
80102a0b:	8b 04 85 00 7c 10 80 	mov    -0x7fef8400(,%eax,4),%eax
80102a12:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
80102a16:	74 0b                	je     80102a23 <kbdgetc+0x73>
    if('a' <= c && c <= 'z')
80102a18:	8d 50 9f             	lea    -0x61(%eax),%edx
80102a1b:	83 fa 19             	cmp    $0x19,%edx
80102a1e:	77 48                	ja     80102a68 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102a20:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102a23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a26:	c9                   	leave  
80102a27:	c3                   	ret    
80102a28:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a2f:	90                   	nop
    shift |= E0ESC;
80102a30:	83 cb 40             	or     $0x40,%ebx
    return 0;
80102a33:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
80102a35:	89 1d c0 26 11 80    	mov    %ebx,0x801126c0
}
80102a3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a3e:	c9                   	leave  
80102a3f:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102a40:	83 e0 7f             	and    $0x7f,%eax
80102a43:	85 d2                	test   %edx,%edx
80102a45:	0f 44 c8             	cmove  %eax,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
80102a48:	0f b6 81 20 7d 10 80 	movzbl -0x7fef82e0(%ecx),%eax
80102a4f:	83 c8 40             	or     $0x40,%eax
80102a52:	0f b6 c0             	movzbl %al,%eax
80102a55:	f7 d0                	not    %eax
80102a57:	21 d8                	and    %ebx,%eax
}
80102a59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    shift &= ~(shiftcode[data] | E0ESC);
80102a5c:	a3 c0 26 11 80       	mov    %eax,0x801126c0
    return 0;
80102a61:	31 c0                	xor    %eax,%eax
}
80102a63:	c9                   	leave  
80102a64:	c3                   	ret    
80102a65:	8d 76 00             	lea    0x0(%esi),%esi
    else if('A' <= c && c <= 'Z')
80102a68:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
80102a6b:	8d 50 20             	lea    0x20(%eax),%edx
}
80102a6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a71:	c9                   	leave  
      c += 'a' - 'A';
80102a72:	83 f9 1a             	cmp    $0x1a,%ecx
80102a75:	0f 42 c2             	cmovb  %edx,%eax
}
80102a78:	c3                   	ret    
80102a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80102a80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102a85:	c3                   	ret    
80102a86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a8d:	8d 76 00             	lea    0x0(%esi),%esi

80102a90 <kbdintr>:

void
kbdintr(void)
{
80102a90:	55                   	push   %ebp
80102a91:	89 e5                	mov    %esp,%ebp
80102a93:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102a96:	68 b0 29 10 80       	push   $0x801029b0
80102a9b:	e8 10 df ff ff       	call   801009b0 <consoleintr>
}
80102aa0:	83 c4 10             	add    $0x10,%esp
80102aa3:	c9                   	leave  
80102aa4:	c3                   	ret    
80102aa5:	66 90                	xchg   %ax,%ax
80102aa7:	66 90                	xchg   %ax,%ax
80102aa9:	66 90                	xchg   %ax,%ax
80102aab:	66 90                	xchg   %ax,%ax
80102aad:	66 90                	xchg   %ax,%ax
80102aaf:	90                   	nop

80102ab0 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
80102ab0:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102ab5:	85 c0                	test   %eax,%eax
80102ab7:	0f 84 cb 00 00 00    	je     80102b88 <lapicinit+0xd8>
  lapic[index] = value;
80102abd:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102ac4:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102ac7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102aca:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102ad1:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102ad4:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102ad7:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
80102ade:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102ae1:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102ae4:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
80102aeb:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
80102aee:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102af1:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
80102af8:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102afb:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102afe:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102b05:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102b08:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102b0b:	8b 50 30             	mov    0x30(%eax),%edx
80102b0e:	c1 ea 10             	shr    $0x10,%edx
80102b11:	81 e2 fc 00 00 00    	and    $0xfc,%edx
80102b17:	75 77                	jne    80102b90 <lapicinit+0xe0>
  lapic[index] = value;
80102b19:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102b20:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b23:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b26:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102b2d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b30:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b33:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102b3a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b3d:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b40:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102b47:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b4a:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b4d:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102b54:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b57:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b5a:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
80102b61:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
80102b64:	8b 50 20             	mov    0x20(%eax),%edx
80102b67:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102b6e:	66 90                	xchg   %ax,%ax
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102b70:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
80102b76:	80 e6 10             	and    $0x10,%dh
80102b79:	75 f5                	jne    80102b70 <lapicinit+0xc0>
  lapic[index] = value;
80102b7b:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102b82:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b85:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102b88:	c3                   	ret    
80102b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
80102b90:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102b97:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102b9a:	8b 50 20             	mov    0x20(%eax),%edx
}
80102b9d:	e9 77 ff ff ff       	jmp    80102b19 <lapicinit+0x69>
80102ba2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102bb0 <lapicid>:

int
lapicid(void)
{
  if (!lapic)
80102bb0:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102bb5:	85 c0                	test   %eax,%eax
80102bb7:	74 07                	je     80102bc0 <lapicid+0x10>
    return 0;
  return lapic[ID] >> 24;
80102bb9:	8b 40 20             	mov    0x20(%eax),%eax
80102bbc:	c1 e8 18             	shr    $0x18,%eax
80102bbf:	c3                   	ret    
    return 0;
80102bc0:	31 c0                	xor    %eax,%eax
}
80102bc2:	c3                   	ret    
80102bc3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102bca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102bd0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102bd0:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102bd5:	85 c0                	test   %eax,%eax
80102bd7:	74 0d                	je     80102be6 <lapiceoi+0x16>
  lapic[index] = value;
80102bd9:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102be0:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102be3:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102be6:	c3                   	ret    
80102be7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102bee:	66 90                	xchg   %ax,%ax

80102bf0 <microdelay>:
// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
}
80102bf0:	c3                   	ret    
80102bf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102bf8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102bff:	90                   	nop

80102c00 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102c00:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c01:	b8 0f 00 00 00       	mov    $0xf,%eax
80102c06:	ba 70 00 00 00       	mov    $0x70,%edx
80102c0b:	89 e5                	mov    %esp,%ebp
80102c0d:	53                   	push   %ebx
80102c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102c11:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102c14:	ee                   	out    %al,(%dx)
80102c15:	b8 0a 00 00 00       	mov    $0xa,%eax
80102c1a:	ba 71 00 00 00       	mov    $0x71,%edx
80102c1f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102c20:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102c22:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102c25:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
80102c2b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
80102c2d:	c1 e9 0c             	shr    $0xc,%ecx
  lapicw(ICRHI, apicid<<24);
80102c30:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
80102c32:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
80102c35:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102c38:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
80102c3e:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102c43:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102c49:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102c4c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102c53:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102c56:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102c59:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102c60:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102c63:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102c66:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102c6c:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102c6f:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102c75:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102c78:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102c7e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102c81:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102c87:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
80102c8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102c8d:	c9                   	leave  
80102c8e:	c3                   	ret    
80102c8f:	90                   	nop

80102c90 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102c90:	55                   	push   %ebp
80102c91:	b8 0b 00 00 00       	mov    $0xb,%eax
80102c96:	ba 70 00 00 00       	mov    $0x70,%edx
80102c9b:	89 e5                	mov    %esp,%ebp
80102c9d:	57                   	push   %edi
80102c9e:	56                   	push   %esi
80102c9f:	53                   	push   %ebx
80102ca0:	83 ec 4c             	sub    $0x4c,%esp
80102ca3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ca4:	ba 71 00 00 00       	mov    $0x71,%edx
80102ca9:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
80102caa:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cad:	bb 70 00 00 00       	mov    $0x70,%ebx
80102cb2:	88 45 b3             	mov    %al,-0x4d(%ebp)
80102cb5:	8d 76 00             	lea    0x0(%esi),%esi
80102cb8:	31 c0                	xor    %eax,%eax
80102cba:	89 da                	mov    %ebx,%edx
80102cbc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cbd:	b9 71 00 00 00       	mov    $0x71,%ecx
80102cc2:	89 ca                	mov    %ecx,%edx
80102cc4:	ec                   	in     (%dx),%al
80102cc5:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cc8:	89 da                	mov    %ebx,%edx
80102cca:	b8 02 00 00 00       	mov    $0x2,%eax
80102ccf:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cd0:	89 ca                	mov    %ecx,%edx
80102cd2:	ec                   	in     (%dx),%al
80102cd3:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cd6:	89 da                	mov    %ebx,%edx
80102cd8:	b8 04 00 00 00       	mov    $0x4,%eax
80102cdd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cde:	89 ca                	mov    %ecx,%edx
80102ce0:	ec                   	in     (%dx),%al
80102ce1:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ce4:	89 da                	mov    %ebx,%edx
80102ce6:	b8 07 00 00 00       	mov    $0x7,%eax
80102ceb:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cec:	89 ca                	mov    %ecx,%edx
80102cee:	ec                   	in     (%dx),%al
80102cef:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cf2:	89 da                	mov    %ebx,%edx
80102cf4:	b8 08 00 00 00       	mov    $0x8,%eax
80102cf9:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cfa:	89 ca                	mov    %ecx,%edx
80102cfc:	ec                   	in     (%dx),%al
80102cfd:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cff:	89 da                	mov    %ebx,%edx
80102d01:	b8 09 00 00 00       	mov    $0x9,%eax
80102d06:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d07:	89 ca                	mov    %ecx,%edx
80102d09:	ec                   	in     (%dx),%al
80102d0a:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d0c:	89 da                	mov    %ebx,%edx
80102d0e:	b8 0a 00 00 00       	mov    $0xa,%eax
80102d13:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d14:	89 ca                	mov    %ecx,%edx
80102d16:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102d17:	84 c0                	test   %al,%al
80102d19:	78 9d                	js     80102cb8 <cmostime+0x28>
  return inb(CMOS_RETURN);
80102d1b:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102d1f:	89 fa                	mov    %edi,%edx
80102d21:	0f b6 fa             	movzbl %dl,%edi
80102d24:	89 f2                	mov    %esi,%edx
80102d26:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102d29:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102d2d:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d30:	89 da                	mov    %ebx,%edx
80102d32:	89 7d c8             	mov    %edi,-0x38(%ebp)
80102d35:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102d38:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102d3c:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102d3f:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102d42:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102d46:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102d49:	31 c0                	xor    %eax,%eax
80102d4b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d4c:	89 ca                	mov    %ecx,%edx
80102d4e:	ec                   	in     (%dx),%al
80102d4f:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d52:	89 da                	mov    %ebx,%edx
80102d54:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102d57:	b8 02 00 00 00       	mov    $0x2,%eax
80102d5c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d5d:	89 ca                	mov    %ecx,%edx
80102d5f:	ec                   	in     (%dx),%al
80102d60:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d63:	89 da                	mov    %ebx,%edx
80102d65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102d68:	b8 04 00 00 00       	mov    $0x4,%eax
80102d6d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d6e:	89 ca                	mov    %ecx,%edx
80102d70:	ec                   	in     (%dx),%al
80102d71:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d74:	89 da                	mov    %ebx,%edx
80102d76:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102d79:	b8 07 00 00 00       	mov    $0x7,%eax
80102d7e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d7f:	89 ca                	mov    %ecx,%edx
80102d81:	ec                   	in     (%dx),%al
80102d82:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d85:	89 da                	mov    %ebx,%edx
80102d87:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102d8a:	b8 08 00 00 00       	mov    $0x8,%eax
80102d8f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d90:	89 ca                	mov    %ecx,%edx
80102d92:	ec                   	in     (%dx),%al
80102d93:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d96:	89 da                	mov    %ebx,%edx
80102d98:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102d9b:	b8 09 00 00 00       	mov    $0x9,%eax
80102da0:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102da1:	89 ca                	mov    %ecx,%edx
80102da3:	ec                   	in     (%dx),%al
80102da4:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102da7:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102daa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102dad:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102db0:	6a 18                	push   $0x18
80102db2:	50                   	push   %eax
80102db3:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102db6:	50                   	push   %eax
80102db7:	e8 94 1c 00 00       	call   80104a50 <memcmp>
80102dbc:	83 c4 10             	add    $0x10,%esp
80102dbf:	85 c0                	test   %eax,%eax
80102dc1:	0f 85 f1 fe ff ff    	jne    80102cb8 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102dc7:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
80102dcb:	75 78                	jne    80102e45 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102dcd:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102dd0:	89 c2                	mov    %eax,%edx
80102dd2:	83 e0 0f             	and    $0xf,%eax
80102dd5:	c1 ea 04             	shr    $0x4,%edx
80102dd8:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102ddb:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102dde:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102de1:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102de4:	89 c2                	mov    %eax,%edx
80102de6:	83 e0 0f             	and    $0xf,%eax
80102de9:	c1 ea 04             	shr    $0x4,%edx
80102dec:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102def:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102df2:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102df5:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102df8:	89 c2                	mov    %eax,%edx
80102dfa:	83 e0 0f             	and    $0xf,%eax
80102dfd:	c1 ea 04             	shr    $0x4,%edx
80102e00:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e03:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102e06:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102e09:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102e0c:	89 c2                	mov    %eax,%edx
80102e0e:	83 e0 0f             	and    $0xf,%eax
80102e11:	c1 ea 04             	shr    $0x4,%edx
80102e14:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e17:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102e1a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102e1d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102e20:	89 c2                	mov    %eax,%edx
80102e22:	83 e0 0f             	and    $0xf,%eax
80102e25:	c1 ea 04             	shr    $0x4,%edx
80102e28:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e2b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102e2e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102e31:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102e34:	89 c2                	mov    %eax,%edx
80102e36:	83 e0 0f             	and    $0xf,%eax
80102e39:	c1 ea 04             	shr    $0x4,%edx
80102e3c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e3f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102e42:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102e45:	8b 75 08             	mov    0x8(%ebp),%esi
80102e48:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102e4b:	89 06                	mov    %eax,(%esi)
80102e4d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102e50:	89 46 04             	mov    %eax,0x4(%esi)
80102e53:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102e56:	89 46 08             	mov    %eax,0x8(%esi)
80102e59:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102e5c:	89 46 0c             	mov    %eax,0xc(%esi)
80102e5f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102e62:	89 46 10             	mov    %eax,0x10(%esi)
80102e65:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102e68:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102e6b:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102e72:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e75:	5b                   	pop    %ebx
80102e76:	5e                   	pop    %esi
80102e77:	5f                   	pop    %edi
80102e78:	5d                   	pop    %ebp
80102e79:	c3                   	ret    
80102e7a:	66 90                	xchg   %ax,%ax
80102e7c:	66 90                	xchg   %ax,%ax
80102e7e:	66 90                	xchg   %ax,%ax

80102e80 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e80:	8b 0d 28 27 11 80    	mov    0x80112728,%ecx
80102e86:	85 c9                	test   %ecx,%ecx
80102e88:	0f 8e 8a 00 00 00    	jle    80102f18 <install_trans+0x98>
{
80102e8e:	55                   	push   %ebp
80102e8f:	89 e5                	mov    %esp,%ebp
80102e91:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102e92:	31 ff                	xor    %edi,%edi
{
80102e94:	56                   	push   %esi
80102e95:	53                   	push   %ebx
80102e96:	83 ec 0c             	sub    $0xc,%esp
80102e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102ea0:	a1 14 27 11 80       	mov    0x80112714,%eax
80102ea5:	83 ec 08             	sub    $0x8,%esp
80102ea8:	01 f8                	add    %edi,%eax
80102eaa:	83 c0 01             	add    $0x1,%eax
80102ead:	50                   	push   %eax
80102eae:	ff 35 24 27 11 80    	push   0x80112724
80102eb4:	e8 d7 d2 ff ff       	call   80100190 <bread>
80102eb9:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ebb:	58                   	pop    %eax
80102ebc:	5a                   	pop    %edx
80102ebd:	ff 34 bd 2c 27 11 80 	push   -0x7feed8d4(,%edi,4)
80102ec4:	ff 35 24 27 11 80    	push   0x80112724
  for (tail = 0; tail < log.lh.n; tail++) {
80102eca:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ecd:	e8 be d2 ff ff       	call   80100190 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ed2:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ed5:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ed7:	8d 46 5c             	lea    0x5c(%esi),%eax
80102eda:	68 00 02 00 00       	push   $0x200
80102edf:	50                   	push   %eax
80102ee0:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102ee3:	50                   	push   %eax
80102ee4:	e8 b7 1b 00 00       	call   80104aa0 <memmove>
    bwrite(dbuf);  // write dst to disk
80102ee9:	89 1c 24             	mov    %ebx,(%esp)
80102eec:	e8 df d2 ff ff       	call   801001d0 <bwrite>
    brelse(lbuf);
80102ef1:	89 34 24             	mov    %esi,(%esp)
80102ef4:	e8 17 d3 ff ff       	call   80100210 <brelse>
    brelse(dbuf);
80102ef9:	89 1c 24             	mov    %ebx,(%esp)
80102efc:	e8 0f d3 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102f01:	83 c4 10             	add    $0x10,%esp
80102f04:	39 3d 28 27 11 80    	cmp    %edi,0x80112728
80102f0a:	7f 94                	jg     80102ea0 <install_trans+0x20>
  }
}
80102f0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f0f:	5b                   	pop    %ebx
80102f10:	5e                   	pop    %esi
80102f11:	5f                   	pop    %edi
80102f12:	5d                   	pop    %ebp
80102f13:	c3                   	ret    
80102f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102f18:	c3                   	ret    
80102f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102f20 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f20:	55                   	push   %ebp
80102f21:	89 e5                	mov    %esp,%ebp
80102f23:	53                   	push   %ebx
80102f24:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f27:	ff 35 14 27 11 80    	push   0x80112714
80102f2d:	ff 35 24 27 11 80    	push   0x80112724
80102f33:	e8 58 d2 ff ff       	call   80100190 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102f38:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f3b:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102f3d:	a1 28 27 11 80       	mov    0x80112728,%eax
80102f42:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102f45:	85 c0                	test   %eax,%eax
80102f47:	7e 19                	jle    80102f62 <write_head+0x42>
80102f49:	31 d2                	xor    %edx,%edx
80102f4b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102f4f:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102f50:	8b 0c 95 2c 27 11 80 	mov    -0x7feed8d4(,%edx,4),%ecx
80102f57:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f5b:	83 c2 01             	add    $0x1,%edx
80102f5e:	39 d0                	cmp    %edx,%eax
80102f60:	75 ee                	jne    80102f50 <write_head+0x30>
  }
  bwrite(buf);
80102f62:	83 ec 0c             	sub    $0xc,%esp
80102f65:	53                   	push   %ebx
80102f66:	e8 65 d2 ff ff       	call   801001d0 <bwrite>
  brelse(buf);
80102f6b:	89 1c 24             	mov    %ebx,(%esp)
80102f6e:	e8 9d d2 ff ff       	call   80100210 <brelse>
}
80102f73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102f76:	83 c4 10             	add    $0x10,%esp
80102f79:	c9                   	leave  
80102f7a:	c3                   	ret    
80102f7b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102f7f:	90                   	nop

80102f80 <initlog>:
{
80102f80:	55                   	push   %ebp
80102f81:	89 e5                	mov    %esp,%ebp
80102f83:	53                   	push   %ebx
80102f84:	83 ec 3c             	sub    $0x3c,%esp
80102f87:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102f8a:	68 20 7e 10 80       	push   $0x80107e20
80102f8f:	68 e0 26 11 80       	push   $0x801126e0
80102f94:	e8 d7 17 00 00       	call   80104770 <initlock>
  readsb(dev, &sb);
80102f99:	58                   	pop    %eax
80102f9a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80102f9d:	5a                   	pop    %edx
80102f9e:	50                   	push   %eax
80102f9f:	53                   	push   %ebx
80102fa0:	e8 ab e6 ff ff       	call   80101650 <readsb>
  log.start = sb.logstart;
80102fa5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102fa8:	59                   	pop    %ecx
  log.dev = dev;
80102fa9:	89 1d 24 27 11 80    	mov    %ebx,0x80112724
  log.size = sb.nlog;
80102faf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  log.start = sb.logstart;
80102fb2:	a3 14 27 11 80       	mov    %eax,0x80112714
  log.size = sb.nlog;
80102fb7:	89 15 18 27 11 80    	mov    %edx,0x80112718
  struct buf *buf = bread(log.dev, log.start);
80102fbd:	5a                   	pop    %edx
80102fbe:	50                   	push   %eax
80102fbf:	53                   	push   %ebx
80102fc0:	e8 cb d1 ff ff       	call   80100190 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102fc5:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102fc8:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102fcb:	89 1d 28 27 11 80    	mov    %ebx,0x80112728
  for (i = 0; i < log.lh.n; i++) {
80102fd1:	85 db                	test   %ebx,%ebx
80102fd3:	7e 1d                	jle    80102ff2 <initlog+0x72>
80102fd5:	31 d2                	xor    %edx,%edx
80102fd7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102fde:	66 90                	xchg   %ax,%ax
    log.lh.block[i] = lh->block[i];
80102fe0:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102fe4:	89 0c 95 2c 27 11 80 	mov    %ecx,-0x7feed8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102feb:	83 c2 01             	add    $0x1,%edx
80102fee:	39 d3                	cmp    %edx,%ebx
80102ff0:	75 ee                	jne    80102fe0 <initlog+0x60>
  brelse(buf);
80102ff2:	83 ec 0c             	sub    $0xc,%esp
80102ff5:	50                   	push   %eax
80102ff6:	e8 15 d2 ff ff       	call   80100210 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102ffb:	e8 80 fe ff ff       	call   80102e80 <install_trans>
  log.lh.n = 0;
80103000:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
80103007:	00 00 00 
  write_head(); // clear the log
8010300a:	e8 11 ff ff ff       	call   80102f20 <write_head>
}
8010300f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103012:	83 c4 10             	add    $0x10,%esp
80103015:	c9                   	leave  
80103016:	c3                   	ret    
80103017:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010301e:	66 90                	xchg   %ax,%ax

80103020 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80103020:	55                   	push   %ebp
80103021:	89 e5                	mov    %esp,%ebp
80103023:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80103026:	68 e0 26 11 80       	push   $0x801126e0
8010302b:	e8 10 19 00 00       	call   80104940 <acquire>
80103030:	83 c4 10             	add    $0x10,%esp
80103033:	eb 18                	jmp    8010304d <begin_op+0x2d>
80103035:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80103038:	83 ec 08             	sub    $0x8,%esp
8010303b:	68 e0 26 11 80       	push   $0x801126e0
80103040:	68 e0 26 11 80       	push   $0x801126e0
80103045:	e8 46 13 00 00       	call   80104390 <sleep>
8010304a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
8010304d:	a1 20 27 11 80       	mov    0x80112720,%eax
80103052:	85 c0                	test   %eax,%eax
80103054:	75 e2                	jne    80103038 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103056:	a1 1c 27 11 80       	mov    0x8011271c,%eax
8010305b:	8b 15 28 27 11 80    	mov    0x80112728,%edx
80103061:	83 c0 01             	add    $0x1,%eax
80103064:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80103067:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
8010306a:	83 fa 1e             	cmp    $0x1e,%edx
8010306d:	7f c9                	jg     80103038 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
8010306f:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80103072:	a3 1c 27 11 80       	mov    %eax,0x8011271c
      release(&log.lock);
80103077:	68 e0 26 11 80       	push   $0x801126e0
8010307c:	e8 5f 18 00 00       	call   801048e0 <release>
      break;
    }
  }
}
80103081:	83 c4 10             	add    $0x10,%esp
80103084:	c9                   	leave  
80103085:	c3                   	ret    
80103086:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010308d:	8d 76 00             	lea    0x0(%esi),%esi

80103090 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103090:	55                   	push   %ebp
80103091:	89 e5                	mov    %esp,%ebp
80103093:	57                   	push   %edi
80103094:	56                   	push   %esi
80103095:	53                   	push   %ebx
80103096:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80103099:	68 e0 26 11 80       	push   $0x801126e0
8010309e:	e8 9d 18 00 00       	call   80104940 <acquire>
  log.outstanding -= 1;
801030a3:	a1 1c 27 11 80       	mov    0x8011271c,%eax
  if(log.committing)
801030a8:	8b 35 20 27 11 80    	mov    0x80112720,%esi
801030ae:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030b1:	8d 58 ff             	lea    -0x1(%eax),%ebx
801030b4:	89 1d 1c 27 11 80    	mov    %ebx,0x8011271c
  if(log.committing)
801030ba:	85 f6                	test   %esi,%esi
801030bc:	0f 85 22 01 00 00    	jne    801031e4 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
801030c2:	85 db                	test   %ebx,%ebx
801030c4:	0f 85 f6 00 00 00    	jne    801031c0 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
801030ca:	c7 05 20 27 11 80 01 	movl   $0x1,0x80112720
801030d1:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
801030d4:	83 ec 0c             	sub    $0xc,%esp
801030d7:	68 e0 26 11 80       	push   $0x801126e0
801030dc:	e8 ff 17 00 00       	call   801048e0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
801030e1:	8b 0d 28 27 11 80    	mov    0x80112728,%ecx
801030e7:	83 c4 10             	add    $0x10,%esp
801030ea:	85 c9                	test   %ecx,%ecx
801030ec:	7f 42                	jg     80103130 <end_op+0xa0>
    acquire(&log.lock);
801030ee:	83 ec 0c             	sub    $0xc,%esp
801030f1:	68 e0 26 11 80       	push   $0x801126e0
801030f6:	e8 45 18 00 00       	call   80104940 <acquire>
    wakeup(&log);
801030fb:	c7 04 24 e0 26 11 80 	movl   $0x801126e0,(%esp)
    log.committing = 0;
80103102:	c7 05 20 27 11 80 00 	movl   $0x0,0x80112720
80103109:	00 00 00 
    wakeup(&log);
8010310c:	e8 3f 13 00 00       	call   80104450 <wakeup>
    release(&log.lock);
80103111:	c7 04 24 e0 26 11 80 	movl   $0x801126e0,(%esp)
80103118:	e8 c3 17 00 00       	call   801048e0 <release>
8010311d:	83 c4 10             	add    $0x10,%esp
}
80103120:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103123:	5b                   	pop    %ebx
80103124:	5e                   	pop    %esi
80103125:	5f                   	pop    %edi
80103126:	5d                   	pop    %ebp
80103127:	c3                   	ret    
80103128:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010312f:	90                   	nop
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103130:	a1 14 27 11 80       	mov    0x80112714,%eax
80103135:	83 ec 08             	sub    $0x8,%esp
80103138:	01 d8                	add    %ebx,%eax
8010313a:	83 c0 01             	add    $0x1,%eax
8010313d:	50                   	push   %eax
8010313e:	ff 35 24 27 11 80    	push   0x80112724
80103144:	e8 47 d0 ff ff       	call   80100190 <bread>
80103149:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010314b:	58                   	pop    %eax
8010314c:	5a                   	pop    %edx
8010314d:	ff 34 9d 2c 27 11 80 	push   -0x7feed8d4(,%ebx,4)
80103154:	ff 35 24 27 11 80    	push   0x80112724
  for (tail = 0; tail < log.lh.n; tail++) {
8010315a:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010315d:	e8 2e d0 ff ff       	call   80100190 <bread>
    memmove(to->data, from->data, BSIZE);
80103162:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103165:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80103167:	8d 40 5c             	lea    0x5c(%eax),%eax
8010316a:	68 00 02 00 00       	push   $0x200
8010316f:	50                   	push   %eax
80103170:	8d 46 5c             	lea    0x5c(%esi),%eax
80103173:	50                   	push   %eax
80103174:	e8 27 19 00 00       	call   80104aa0 <memmove>
    bwrite(to);  // write the log
80103179:	89 34 24             	mov    %esi,(%esp)
8010317c:	e8 4f d0 ff ff       	call   801001d0 <bwrite>
    brelse(from);
80103181:	89 3c 24             	mov    %edi,(%esp)
80103184:	e8 87 d0 ff ff       	call   80100210 <brelse>
    brelse(to);
80103189:	89 34 24             	mov    %esi,(%esp)
8010318c:	e8 7f d0 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80103191:	83 c4 10             	add    $0x10,%esp
80103194:	3b 1d 28 27 11 80    	cmp    0x80112728,%ebx
8010319a:	7c 94                	jl     80103130 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
8010319c:	e8 7f fd ff ff       	call   80102f20 <write_head>
    install_trans(); // Now install writes to home locations
801031a1:	e8 da fc ff ff       	call   80102e80 <install_trans>
    log.lh.n = 0;
801031a6:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
801031ad:	00 00 00 
    write_head();    // Erase the transaction from the log
801031b0:	e8 6b fd ff ff       	call   80102f20 <write_head>
801031b5:	e9 34 ff ff ff       	jmp    801030ee <end_op+0x5e>
801031ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
801031c0:	83 ec 0c             	sub    $0xc,%esp
801031c3:	68 e0 26 11 80       	push   $0x801126e0
801031c8:	e8 83 12 00 00       	call   80104450 <wakeup>
  release(&log.lock);
801031cd:	c7 04 24 e0 26 11 80 	movl   $0x801126e0,(%esp)
801031d4:	e8 07 17 00 00       	call   801048e0 <release>
801031d9:	83 c4 10             	add    $0x10,%esp
}
801031dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801031df:	5b                   	pop    %ebx
801031e0:	5e                   	pop    %esi
801031e1:	5f                   	pop    %edi
801031e2:	5d                   	pop    %ebp
801031e3:	c3                   	ret    
    panic("log.committing");
801031e4:	83 ec 0c             	sub    $0xc,%esp
801031e7:	68 24 7e 10 80       	push   $0x80107e24
801031ec:	e8 bf d2 ff ff       	call   801004b0 <panic>
801031f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801031f8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801031ff:	90                   	nop

80103200 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103200:	55                   	push   %ebp
80103201:	89 e5                	mov    %esp,%ebp
80103203:	53                   	push   %ebx
80103204:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103207:	8b 15 28 27 11 80    	mov    0x80112728,%edx
{
8010320d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103210:	83 fa 1d             	cmp    $0x1d,%edx
80103213:	0f 8f 85 00 00 00    	jg     8010329e <log_write+0x9e>
80103219:	a1 18 27 11 80       	mov    0x80112718,%eax
8010321e:	83 e8 01             	sub    $0x1,%eax
80103221:	39 c2                	cmp    %eax,%edx
80103223:	7d 79                	jge    8010329e <log_write+0x9e>
    panic("too big a transaction");
  if (log.outstanding < 1)
80103225:	a1 1c 27 11 80       	mov    0x8011271c,%eax
8010322a:	85 c0                	test   %eax,%eax
8010322c:	7e 7d                	jle    801032ab <log_write+0xab>
    panic("log_write outside of trans");

  acquire(&log.lock);
8010322e:	83 ec 0c             	sub    $0xc,%esp
80103231:	68 e0 26 11 80       	push   $0x801126e0
80103236:	e8 05 17 00 00       	call   80104940 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010323b:	8b 15 28 27 11 80    	mov    0x80112728,%edx
80103241:	83 c4 10             	add    $0x10,%esp
80103244:	85 d2                	test   %edx,%edx
80103246:	7e 4a                	jle    80103292 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103248:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
8010324b:	31 c0                	xor    %eax,%eax
8010324d:	eb 08                	jmp    80103257 <log_write+0x57>
8010324f:	90                   	nop
80103250:	83 c0 01             	add    $0x1,%eax
80103253:	39 c2                	cmp    %eax,%edx
80103255:	74 29                	je     80103280 <log_write+0x80>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103257:	39 0c 85 2c 27 11 80 	cmp    %ecx,-0x7feed8d4(,%eax,4)
8010325e:	75 f0                	jne    80103250 <log_write+0x50>
      break;
  }
  log.lh.block[i] = b->blockno;
80103260:	89 0c 85 2c 27 11 80 	mov    %ecx,-0x7feed8d4(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80103267:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
8010326a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
8010326d:	c7 45 08 e0 26 11 80 	movl   $0x801126e0,0x8(%ebp)
}
80103274:	c9                   	leave  
  release(&log.lock);
80103275:	e9 66 16 00 00       	jmp    801048e0 <release>
8010327a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
80103280:	89 0c 95 2c 27 11 80 	mov    %ecx,-0x7feed8d4(,%edx,4)
    log.lh.n++;
80103287:	83 c2 01             	add    $0x1,%edx
8010328a:	89 15 28 27 11 80    	mov    %edx,0x80112728
80103290:	eb d5                	jmp    80103267 <log_write+0x67>
  log.lh.block[i] = b->blockno;
80103292:	8b 43 08             	mov    0x8(%ebx),%eax
80103295:	a3 2c 27 11 80       	mov    %eax,0x8011272c
  if (i == log.lh.n)
8010329a:	75 cb                	jne    80103267 <log_write+0x67>
8010329c:	eb e9                	jmp    80103287 <log_write+0x87>
    panic("too big a transaction");
8010329e:	83 ec 0c             	sub    $0xc,%esp
801032a1:	68 33 7e 10 80       	push   $0x80107e33
801032a6:	e8 05 d2 ff ff       	call   801004b0 <panic>
    panic("log_write outside of trans");
801032ab:	83 ec 0c             	sub    $0xc,%esp
801032ae:	68 49 7e 10 80       	push   $0x80107e49
801032b3:	e8 f8 d1 ff ff       	call   801004b0 <panic>
801032b8:	66 90                	xchg   %ax,%ax
801032ba:	66 90                	xchg   %ax,%ax
801032bc:	66 90                	xchg   %ax,%ax
801032be:	66 90                	xchg   %ax,%ax

801032c0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801032c0:	55                   	push   %ebp
801032c1:	89 e5                	mov    %esp,%ebp
801032c3:	53                   	push   %ebx
801032c4:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801032c7:	e8 64 09 00 00       	call   80103c30 <cpuid>
801032cc:	89 c3                	mov    %eax,%ebx
801032ce:	e8 5d 09 00 00       	call   80103c30 <cpuid>
801032d3:	83 ec 04             	sub    $0x4,%esp
801032d6:	53                   	push   %ebx
801032d7:	50                   	push   %eax
801032d8:	68 64 7e 10 80       	push   $0x80107e64
801032dd:	e8 ee d4 ff ff       	call   801007d0 <cprintf>
  idtinit();       // load idt register
801032e2:	e8 b9 29 00 00       	call   80105ca0 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801032e7:	e8 e4 08 00 00       	call   80103bd0 <mycpu>
801032ec:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801032ee:	b8 01 00 00 00       	mov    $0x1,%eax
801032f3:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
801032fa:	e8 81 0c 00 00       	call   80103f80 <scheduler>
801032ff:	90                   	nop

80103300 <mpenter>:
{
80103300:	55                   	push   %ebp
80103301:	89 e5                	mov    %esp,%ebp
80103303:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103306:	e8 b5 3a 00 00       	call   80106dc0 <switchkvm>
  seginit();
8010330b:	e8 20 3a 00 00       	call   80106d30 <seginit>
  lapicinit();
80103310:	e8 9b f7 ff ff       	call   80102ab0 <lapicinit>
  mpmain();
80103315:	e8 a6 ff ff ff       	call   801032c0 <mpmain>
8010331a:	66 90                	xchg   %ax,%ax
8010331c:	66 90                	xchg   %ax,%ax
8010331e:	66 90                	xchg   %ax,%ax

80103320 <main>:
{
80103320:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103324:	83 e4 f0             	and    $0xfffffff0,%esp
80103327:	ff 71 fc             	push   -0x4(%ecx)
8010332a:	55                   	push   %ebp
8010332b:	89 e5                	mov    %esp,%ebp
8010332d:	53                   	push   %ebx
8010332e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010332f:	83 ec 08             	sub    $0x8,%esp
80103332:	68 00 00 40 80       	push   $0x80400000
80103337:	68 10 66 11 80       	push   $0x80116610
8010333c:	e8 4f f5 ff ff       	call   80102890 <kinit1>
  kvmalloc();      // kernel page table
80103341:	e8 6a 3f 00 00       	call   801072b0 <kvmalloc>
  mpinit();        // detect other processors
80103346:	e8 a5 01 00 00       	call   801034f0 <mpinit>
  lapicinit();     // interrupt controller
8010334b:	e8 60 f7 ff ff       	call   80102ab0 <lapicinit>
  seginit();       // segment descriptors
80103350:	e8 db 39 00 00       	call   80106d30 <seginit>
  picinit();       // disable pic
80103355:	e8 96 03 00 00       	call   801036f0 <picinit>
  ioapicinit();    // another interrupt controller
8010335a:	e8 d1 f2 ff ff       	call   80102630 <ioapicinit>
  consoleinit();   // console hardware
8010335f:	e8 2c d8 ff ff       	call   80100b90 <consoleinit>
  uartinit();      // serial port
80103364:	e8 57 2c 00 00       	call   80105fc0 <uartinit>
  pinit();         // process table
80103369:	e8 42 08 00 00       	call   80103bb0 <pinit>
  tvinit();        // trap vectors
8010336e:	e8 ad 28 00 00       	call   80105c20 <tvinit>
  binit();         // buffer cache
80103373:	e8 88 cd ff ff       	call   80100100 <binit>
  fileinit();      // file table
80103378:	e8 c3 db ff ff       	call   80100f40 <fileinit>
  ideinit();       // disk 
8010337d:	e8 9e f0 ff ff       	call   80102420 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103382:	83 c4 0c             	add    $0xc,%esp
80103385:	68 8a 00 00 00       	push   $0x8a
8010338a:	68 8c b4 10 80       	push   $0x8010b48c
8010338f:	68 00 70 00 80       	push   $0x80007000
80103394:	e8 07 17 00 00       	call   80104aa0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103399:	83 c4 10             	add    $0x10,%esp
8010339c:	69 05 c4 27 11 80 b0 	imul   $0xb0,0x801127c4,%eax
801033a3:	00 00 00 
801033a6:	05 e0 27 11 80       	add    $0x801127e0,%eax
801033ab:	3d e0 27 11 80       	cmp    $0x801127e0,%eax
801033b0:	76 7e                	jbe    80103430 <main+0x110>
801033b2:	bb e0 27 11 80       	mov    $0x801127e0,%ebx
801033b7:	eb 20                	jmp    801033d9 <main+0xb9>
801033b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801033c0:	69 05 c4 27 11 80 b0 	imul   $0xb0,0x801127c4,%eax
801033c7:	00 00 00 
801033ca:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801033d0:	05 e0 27 11 80       	add    $0x801127e0,%eax
801033d5:	39 c3                	cmp    %eax,%ebx
801033d7:	73 57                	jae    80103430 <main+0x110>
    if(c == mycpu())  // We've started already.
801033d9:	e8 f2 07 00 00       	call   80103bd0 <mycpu>
801033de:	39 c3                	cmp    %eax,%ebx
801033e0:	74 de                	je     801033c0 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801033e2:	e8 19 f5 ff ff       	call   80102900 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
801033e7:	83 ec 08             	sub    $0x8,%esp
    *(void(**)(void))(code-8) = mpenter;
801033ea:	c7 05 f8 6f 00 80 00 	movl   $0x80103300,0x80006ff8
801033f1:	33 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801033f4:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
801033fb:	a0 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
801033fe:	05 00 10 00 00       	add    $0x1000,%eax
80103403:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
80103408:	0f b6 03             	movzbl (%ebx),%eax
8010340b:	68 00 70 00 00       	push   $0x7000
80103410:	50                   	push   %eax
80103411:	e8 ea f7 ff ff       	call   80102c00 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103416:	83 c4 10             	add    $0x10,%esp
80103419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103420:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103426:	85 c0                	test   %eax,%eax
80103428:	74 f6                	je     80103420 <main+0x100>
8010342a:	eb 94                	jmp    801033c0 <main+0xa0>
8010342c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103430:	83 ec 08             	sub    $0x8,%esp
80103433:	68 00 00 40 80       	push   $0x80400000
80103438:	68 00 00 40 80       	push   $0x80400000
8010343d:	e8 ee f3 ff ff       	call   80102830 <kinit2>
  cprintf("1\n");
80103442:	c7 04 24 2d 84 10 80 	movl   $0x8010842d,(%esp)
80103449:	e8 82 d3 ff ff       	call   801007d0 <cprintf>
  userinit();      // first user process
8010344e:	e8 2d 08 00 00       	call   80103c80 <userinit>
  cprintf("3\n");
80103453:	c7 04 24 53 84 10 80 	movl   $0x80108453,(%esp)
8010345a:	e8 71 d3 ff ff       	call   801007d0 <cprintf>
  mpmain();        // finish this processor's setup
8010345f:	e8 5c fe ff ff       	call   801032c0 <mpmain>
80103464:	66 90                	xchg   %ax,%ax
80103466:	66 90                	xchg   %ax,%ax
80103468:	66 90                	xchg   %ax,%ax
8010346a:	66 90                	xchg   %ax,%ax
8010346c:	66 90                	xchg   %ax,%ax
8010346e:	66 90                	xchg   %ax,%ax

80103470 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103470:	55                   	push   %ebp
80103471:	89 e5                	mov    %esp,%ebp
80103473:	57                   	push   %edi
80103474:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80103475:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
8010347b:	53                   	push   %ebx
  e = addr+len;
8010347c:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
8010347f:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
80103482:	39 de                	cmp    %ebx,%esi
80103484:	72 10                	jb     80103496 <mpsearch1+0x26>
80103486:	eb 50                	jmp    801034d8 <mpsearch1+0x68>
80103488:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010348f:	90                   	nop
80103490:	89 fe                	mov    %edi,%esi
80103492:	39 fb                	cmp    %edi,%ebx
80103494:	76 42                	jbe    801034d8 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103496:	83 ec 04             	sub    $0x4,%esp
80103499:	8d 7e 10             	lea    0x10(%esi),%edi
8010349c:	6a 04                	push   $0x4
8010349e:	68 78 7e 10 80       	push   $0x80107e78
801034a3:	56                   	push   %esi
801034a4:	e8 a7 15 00 00       	call   80104a50 <memcmp>
801034a9:	83 c4 10             	add    $0x10,%esp
801034ac:	85 c0                	test   %eax,%eax
801034ae:	75 e0                	jne    80103490 <mpsearch1+0x20>
801034b0:	89 f2                	mov    %esi,%edx
801034b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
801034b8:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
801034bb:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
801034be:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801034c0:	39 fa                	cmp    %edi,%edx
801034c2:	75 f4                	jne    801034b8 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801034c4:	84 c0                	test   %al,%al
801034c6:	75 c8                	jne    80103490 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801034c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801034cb:	89 f0                	mov    %esi,%eax
801034cd:	5b                   	pop    %ebx
801034ce:	5e                   	pop    %esi
801034cf:	5f                   	pop    %edi
801034d0:	5d                   	pop    %ebp
801034d1:	c3                   	ret    
801034d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801034d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801034db:	31 f6                	xor    %esi,%esi
}
801034dd:	5b                   	pop    %ebx
801034de:	89 f0                	mov    %esi,%eax
801034e0:	5e                   	pop    %esi
801034e1:	5f                   	pop    %edi
801034e2:	5d                   	pop    %ebp
801034e3:	c3                   	ret    
801034e4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801034eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801034ef:	90                   	nop

801034f0 <mpinit>:
  return conf;
}

void
mpinit(void)
{
801034f0:	55                   	push   %ebp
801034f1:	89 e5                	mov    %esp,%ebp
801034f3:	57                   	push   %edi
801034f4:	56                   	push   %esi
801034f5:	53                   	push   %ebx
801034f6:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801034f9:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103500:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80103507:	c1 e0 08             	shl    $0x8,%eax
8010350a:	09 d0                	or     %edx,%eax
8010350c:	c1 e0 04             	shl    $0x4,%eax
8010350f:	75 1b                	jne    8010352c <mpinit+0x3c>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103511:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80103518:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
8010351f:	c1 e0 08             	shl    $0x8,%eax
80103522:	09 d0                	or     %edx,%eax
80103524:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103527:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010352c:	ba 00 04 00 00       	mov    $0x400,%edx
80103531:	e8 3a ff ff ff       	call   80103470 <mpsearch1>
80103536:	89 c3                	mov    %eax,%ebx
80103538:	85 c0                	test   %eax,%eax
8010353a:	0f 84 40 01 00 00    	je     80103680 <mpinit+0x190>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103540:	8b 73 04             	mov    0x4(%ebx),%esi
80103543:	85 f6                	test   %esi,%esi
80103545:	0f 84 25 01 00 00    	je     80103670 <mpinit+0x180>
  if(memcmp(conf, "PCMP", 4) != 0)
8010354b:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010354e:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
  if(memcmp(conf, "PCMP", 4) != 0)
80103554:	6a 04                	push   $0x4
80103556:	68 7d 7e 10 80       	push   $0x80107e7d
8010355b:	50                   	push   %eax
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010355c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010355f:	e8 ec 14 00 00       	call   80104a50 <memcmp>
80103564:	83 c4 10             	add    $0x10,%esp
80103567:	85 c0                	test   %eax,%eax
80103569:	0f 85 01 01 00 00    	jne    80103670 <mpinit+0x180>
  if(conf->version != 1 && conf->version != 4)
8010356f:	0f b6 86 06 00 00 80 	movzbl -0x7ffffffa(%esi),%eax
80103576:	3c 01                	cmp    $0x1,%al
80103578:	74 08                	je     80103582 <mpinit+0x92>
8010357a:	3c 04                	cmp    $0x4,%al
8010357c:	0f 85 ee 00 00 00    	jne    80103670 <mpinit+0x180>
  if(sum((uchar*)conf, conf->length) != 0)
80103582:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
  for(i=0; i<len; i++)
80103589:	66 85 d2             	test   %dx,%dx
8010358c:	74 22                	je     801035b0 <mpinit+0xc0>
8010358e:	8d 3c 32             	lea    (%edx,%esi,1),%edi
80103591:	89 f0                	mov    %esi,%eax
  sum = 0;
80103593:	31 d2                	xor    %edx,%edx
80103595:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
80103598:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
  for(i=0; i<len; i++)
8010359f:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
801035a2:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
801035a4:	39 c7                	cmp    %eax,%edi
801035a6:	75 f0                	jne    80103598 <mpinit+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
801035a8:	84 d2                	test   %dl,%dl
801035aa:	0f 85 c0 00 00 00    	jne    80103670 <mpinit+0x180>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
801035b0:	8b 86 24 00 00 80    	mov    -0x7fffffdc(%esi),%eax
801035b6:	a3 c4 26 11 80       	mov    %eax,0x801126c4
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801035bb:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
801035c2:	8d 86 2c 00 00 80    	lea    -0x7fffffd4(%esi),%eax
  ismp = 1;
801035c8:	be 01 00 00 00       	mov    $0x1,%esi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801035cd:	03 55 e4             	add    -0x1c(%ebp),%edx
801035d0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801035d3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801035d7:	90                   	nop
801035d8:	39 d0                	cmp    %edx,%eax
801035da:	73 15                	jae    801035f1 <mpinit+0x101>
    switch(*p){
801035dc:	0f b6 08             	movzbl (%eax),%ecx
801035df:	80 f9 02             	cmp    $0x2,%cl
801035e2:	74 4c                	je     80103630 <mpinit+0x140>
801035e4:	77 3a                	ja     80103620 <mpinit+0x130>
801035e6:	84 c9                	test   %cl,%cl
801035e8:	74 56                	je     80103640 <mpinit+0x150>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801035ea:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801035ed:	39 d0                	cmp    %edx,%eax
801035ef:	72 eb                	jb     801035dc <mpinit+0xec>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
801035f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801035f4:	85 f6                	test   %esi,%esi
801035f6:	0f 84 d9 00 00 00    	je     801036d5 <mpinit+0x1e5>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
801035fc:	80 7b 0c 00          	cmpb   $0x0,0xc(%ebx)
80103600:	74 15                	je     80103617 <mpinit+0x127>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103602:	b8 70 00 00 00       	mov    $0x70,%eax
80103607:	ba 22 00 00 00       	mov    $0x22,%edx
8010360c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010360d:	ba 23 00 00 00       	mov    $0x23,%edx
80103612:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103613:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103616:	ee                   	out    %al,(%dx)
  }
}
80103617:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010361a:	5b                   	pop    %ebx
8010361b:	5e                   	pop    %esi
8010361c:	5f                   	pop    %edi
8010361d:	5d                   	pop    %ebp
8010361e:	c3                   	ret    
8010361f:	90                   	nop
    switch(*p){
80103620:	83 e9 03             	sub    $0x3,%ecx
80103623:	80 f9 01             	cmp    $0x1,%cl
80103626:	76 c2                	jbe    801035ea <mpinit+0xfa>
80103628:	31 f6                	xor    %esi,%esi
8010362a:	eb ac                	jmp    801035d8 <mpinit+0xe8>
8010362c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103630:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
80103634:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
80103637:	88 0d c0 27 11 80    	mov    %cl,0x801127c0
      continue;
8010363d:	eb 99                	jmp    801035d8 <mpinit+0xe8>
8010363f:	90                   	nop
      if(ncpu < NCPU) {
80103640:	8b 0d c4 27 11 80    	mov    0x801127c4,%ecx
80103646:	83 f9 07             	cmp    $0x7,%ecx
80103649:	7f 19                	jg     80103664 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010364b:	69 f9 b0 00 00 00    	imul   $0xb0,%ecx,%edi
80103651:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
80103655:	83 c1 01             	add    $0x1,%ecx
80103658:	89 0d c4 27 11 80    	mov    %ecx,0x801127c4
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010365e:	88 9f e0 27 11 80    	mov    %bl,-0x7feed820(%edi)
      p += sizeof(struct mpproc);
80103664:	83 c0 14             	add    $0x14,%eax
      continue;
80103667:	e9 6c ff ff ff       	jmp    801035d8 <mpinit+0xe8>
8010366c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    panic("Expect to run on an SMP");
80103670:	83 ec 0c             	sub    $0xc,%esp
80103673:	68 82 7e 10 80       	push   $0x80107e82
80103678:	e8 33 ce ff ff       	call   801004b0 <panic>
8010367d:	8d 76 00             	lea    0x0(%esi),%esi
{
80103680:	bb 00 00 0f 80       	mov    $0x800f0000,%ebx
80103685:	eb 13                	jmp    8010369a <mpinit+0x1aa>
80103687:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010368e:	66 90                	xchg   %ax,%ax
  for(p = addr; p < e; p += sizeof(struct mp))
80103690:	89 f3                	mov    %esi,%ebx
80103692:	81 fe 00 00 10 80    	cmp    $0x80100000,%esi
80103698:	74 d6                	je     80103670 <mpinit+0x180>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010369a:	83 ec 04             	sub    $0x4,%esp
8010369d:	8d 73 10             	lea    0x10(%ebx),%esi
801036a0:	6a 04                	push   $0x4
801036a2:	68 78 7e 10 80       	push   $0x80107e78
801036a7:	53                   	push   %ebx
801036a8:	e8 a3 13 00 00       	call   80104a50 <memcmp>
801036ad:	83 c4 10             	add    $0x10,%esp
801036b0:	85 c0                	test   %eax,%eax
801036b2:	75 dc                	jne    80103690 <mpinit+0x1a0>
801036b4:	89 da                	mov    %ebx,%edx
801036b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801036bd:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
801036c0:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
801036c3:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
801036c6:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801036c8:	39 d6                	cmp    %edx,%esi
801036ca:	75 f4                	jne    801036c0 <mpinit+0x1d0>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801036cc:	84 c0                	test   %al,%al
801036ce:	75 c0                	jne    80103690 <mpinit+0x1a0>
801036d0:	e9 6b fe ff ff       	jmp    80103540 <mpinit+0x50>
    panic("Didn't find a suitable machine");
801036d5:	83 ec 0c             	sub    $0xc,%esp
801036d8:	68 9c 7e 10 80       	push   $0x80107e9c
801036dd:	e8 ce cd ff ff       	call   801004b0 <panic>
801036e2:	66 90                	xchg   %ax,%ax
801036e4:	66 90                	xchg   %ax,%ax
801036e6:	66 90                	xchg   %ax,%ax
801036e8:	66 90                	xchg   %ax,%ax
801036ea:	66 90                	xchg   %ax,%ax
801036ec:	66 90                	xchg   %ax,%ax
801036ee:	66 90                	xchg   %ax,%ax

801036f0 <picinit>:
801036f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801036f5:	ba 21 00 00 00       	mov    $0x21,%edx
801036fa:	ee                   	out    %al,(%dx)
801036fb:	ba a1 00 00 00       	mov    $0xa1,%edx
80103700:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103701:	c3                   	ret    
80103702:	66 90                	xchg   %ax,%ax
80103704:	66 90                	xchg   %ax,%ax
80103706:	66 90                	xchg   %ax,%ax
80103708:	66 90                	xchg   %ax,%ax
8010370a:	66 90                	xchg   %ax,%ax
8010370c:	66 90                	xchg   %ax,%ax
8010370e:	66 90                	xchg   %ax,%ax

80103710 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103710:	55                   	push   %ebp
80103711:	89 e5                	mov    %esp,%ebp
80103713:	57                   	push   %edi
80103714:	56                   	push   %esi
80103715:	53                   	push   %ebx
80103716:	83 ec 0c             	sub    $0xc,%esp
80103719:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010371c:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
8010371f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103725:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010372b:	e8 30 d8 ff ff       	call   80100f60 <filealloc>
80103730:	89 03                	mov    %eax,(%ebx)
80103732:	85 c0                	test   %eax,%eax
80103734:	0f 84 a8 00 00 00    	je     801037e2 <pipealloc+0xd2>
8010373a:	e8 21 d8 ff ff       	call   80100f60 <filealloc>
8010373f:	89 06                	mov    %eax,(%esi)
80103741:	85 c0                	test   %eax,%eax
80103743:	0f 84 87 00 00 00    	je     801037d0 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103749:	e8 b2 f1 ff ff       	call   80102900 <kalloc>
8010374e:	89 c7                	mov    %eax,%edi
80103750:	85 c0                	test   %eax,%eax
80103752:	0f 84 b0 00 00 00    	je     80103808 <pipealloc+0xf8>
    goto bad;
  p->readopen = 1;
80103758:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010375f:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
80103762:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
80103765:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010376c:	00 00 00 
  p->nwrite = 0;
8010376f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103776:	00 00 00 
  p->nread = 0;
80103779:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103780:	00 00 00 
  initlock(&p->lock, "pipe");
80103783:	68 bb 7e 10 80       	push   $0x80107ebb
80103788:	50                   	push   %eax
80103789:	e8 e2 0f 00 00       	call   80104770 <initlock>
  (*f0)->type = FD_PIPE;
8010378e:	8b 03                	mov    (%ebx),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
80103790:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103793:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103799:	8b 03                	mov    (%ebx),%eax
8010379b:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010379f:	8b 03                	mov    (%ebx),%eax
801037a1:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801037a5:	8b 03                	mov    (%ebx),%eax
801037a7:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
801037aa:	8b 06                	mov    (%esi),%eax
801037ac:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801037b2:	8b 06                	mov    (%esi),%eax
801037b4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801037b8:	8b 06                	mov    (%esi),%eax
801037ba:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801037be:	8b 06                	mov    (%esi),%eax
801037c0:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
801037c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801037c6:	31 c0                	xor    %eax,%eax
}
801037c8:	5b                   	pop    %ebx
801037c9:	5e                   	pop    %esi
801037ca:	5f                   	pop    %edi
801037cb:	5d                   	pop    %ebp
801037cc:	c3                   	ret    
801037cd:	8d 76 00             	lea    0x0(%esi),%esi
  if(*f0)
801037d0:	8b 03                	mov    (%ebx),%eax
801037d2:	85 c0                	test   %eax,%eax
801037d4:	74 1e                	je     801037f4 <pipealloc+0xe4>
    fileclose(*f0);
801037d6:	83 ec 0c             	sub    $0xc,%esp
801037d9:	50                   	push   %eax
801037da:	e8 41 d8 ff ff       	call   80101020 <fileclose>
801037df:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801037e2:	8b 06                	mov    (%esi),%eax
801037e4:	85 c0                	test   %eax,%eax
801037e6:	74 0c                	je     801037f4 <pipealloc+0xe4>
    fileclose(*f1);
801037e8:	83 ec 0c             	sub    $0xc,%esp
801037eb:	50                   	push   %eax
801037ec:	e8 2f d8 ff ff       	call   80101020 <fileclose>
801037f1:	83 c4 10             	add    $0x10,%esp
}
801037f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
801037f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801037fc:	5b                   	pop    %ebx
801037fd:	5e                   	pop    %esi
801037fe:	5f                   	pop    %edi
801037ff:	5d                   	pop    %ebp
80103800:	c3                   	ret    
80103801:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
80103808:	8b 03                	mov    (%ebx),%eax
8010380a:	85 c0                	test   %eax,%eax
8010380c:	75 c8                	jne    801037d6 <pipealloc+0xc6>
8010380e:	eb d2                	jmp    801037e2 <pipealloc+0xd2>

80103810 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103810:	55                   	push   %ebp
80103811:	89 e5                	mov    %esp,%ebp
80103813:	56                   	push   %esi
80103814:	53                   	push   %ebx
80103815:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103818:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
8010381b:	83 ec 0c             	sub    $0xc,%esp
8010381e:	53                   	push   %ebx
8010381f:	e8 1c 11 00 00       	call   80104940 <acquire>
  if(writable){
80103824:	83 c4 10             	add    $0x10,%esp
80103827:	85 f6                	test   %esi,%esi
80103829:	74 65                	je     80103890 <pipeclose+0x80>
    p->writeopen = 0;
    wakeup(&p->nread);
8010382b:	83 ec 0c             	sub    $0xc,%esp
8010382e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
80103834:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010383b:	00 00 00 
    wakeup(&p->nread);
8010383e:	50                   	push   %eax
8010383f:	e8 0c 0c 00 00       	call   80104450 <wakeup>
80103844:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103847:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010384d:	85 d2                	test   %edx,%edx
8010384f:	75 0a                	jne    8010385b <pipeclose+0x4b>
80103851:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103857:	85 c0                	test   %eax,%eax
80103859:	74 15                	je     80103870 <pipeclose+0x60>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010385b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010385e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103861:	5b                   	pop    %ebx
80103862:	5e                   	pop    %esi
80103863:	5d                   	pop    %ebp
    release(&p->lock);
80103864:	e9 77 10 00 00       	jmp    801048e0 <release>
80103869:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    release(&p->lock);
80103870:	83 ec 0c             	sub    $0xc,%esp
80103873:	53                   	push   %ebx
80103874:	e8 67 10 00 00       	call   801048e0 <release>
    kfree((char*)p);
80103879:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010387c:	83 c4 10             	add    $0x10,%esp
}
8010387f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103882:	5b                   	pop    %ebx
80103883:	5e                   	pop    %esi
80103884:	5d                   	pop    %ebp
    kfree((char*)p);
80103885:	e9 96 ee ff ff       	jmp    80102720 <kfree>
8010388a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&p->nwrite);
80103890:	83 ec 0c             	sub    $0xc,%esp
80103893:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
80103899:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
801038a0:	00 00 00 
    wakeup(&p->nwrite);
801038a3:	50                   	push   %eax
801038a4:	e8 a7 0b 00 00       	call   80104450 <wakeup>
801038a9:	83 c4 10             	add    $0x10,%esp
801038ac:	eb 99                	jmp    80103847 <pipeclose+0x37>
801038ae:	66 90                	xchg   %ax,%ax

801038b0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801038b0:	55                   	push   %ebp
801038b1:	89 e5                	mov    %esp,%ebp
801038b3:	57                   	push   %edi
801038b4:	56                   	push   %esi
801038b5:	53                   	push   %ebx
801038b6:	83 ec 28             	sub    $0x28,%esp
801038b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801038bc:	53                   	push   %ebx
801038bd:	e8 7e 10 00 00       	call   80104940 <acquire>
  for(i = 0; i < n; i++){
801038c2:	8b 45 10             	mov    0x10(%ebp),%eax
801038c5:	83 c4 10             	add    $0x10,%esp
801038c8:	85 c0                	test   %eax,%eax
801038ca:	0f 8e c0 00 00 00    	jle    80103990 <pipewrite+0xe0>
801038d0:	8b 45 0c             	mov    0xc(%ebp),%eax
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801038d3:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801038d9:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
801038df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801038e2:	03 45 10             	add    0x10(%ebp),%eax
801038e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801038e8:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801038ee:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801038f4:	89 ca                	mov    %ecx,%edx
801038f6:	05 00 02 00 00       	add    $0x200,%eax
801038fb:	39 c1                	cmp    %eax,%ecx
801038fd:	74 3f                	je     8010393e <pipewrite+0x8e>
801038ff:	eb 67                	jmp    80103968 <pipewrite+0xb8>
80103901:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->readopen == 0 || myproc()->killed){
80103908:	e8 43 03 00 00       	call   80103c50 <myproc>
8010390d:	8b 48 28             	mov    0x28(%eax),%ecx
80103910:	85 c9                	test   %ecx,%ecx
80103912:	75 34                	jne    80103948 <pipewrite+0x98>
      wakeup(&p->nread);
80103914:	83 ec 0c             	sub    $0xc,%esp
80103917:	57                   	push   %edi
80103918:	e8 33 0b 00 00       	call   80104450 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010391d:	58                   	pop    %eax
8010391e:	5a                   	pop    %edx
8010391f:	53                   	push   %ebx
80103920:	56                   	push   %esi
80103921:	e8 6a 0a 00 00       	call   80104390 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103926:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010392c:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103932:	83 c4 10             	add    $0x10,%esp
80103935:	05 00 02 00 00       	add    $0x200,%eax
8010393a:	39 c2                	cmp    %eax,%edx
8010393c:	75 2a                	jne    80103968 <pipewrite+0xb8>
      if(p->readopen == 0 || myproc()->killed){
8010393e:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103944:	85 c0                	test   %eax,%eax
80103946:	75 c0                	jne    80103908 <pipewrite+0x58>
        release(&p->lock);
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	53                   	push   %ebx
8010394c:	e8 8f 0f 00 00       	call   801048e0 <release>
        return -1;
80103951:	83 c4 10             	add    $0x10,%esp
80103954:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103959:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010395c:	5b                   	pop    %ebx
8010395d:	5e                   	pop    %esi
8010395e:	5f                   	pop    %edi
8010395f:	5d                   	pop    %ebp
80103960:	c3                   	ret    
80103961:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103968:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010396b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010396e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103974:	89 8b 38 02 00 00    	mov    %ecx,0x238(%ebx)
8010397a:	0f b6 06             	movzbl (%esi),%eax
  for(i = 0; i < n; i++){
8010397d:	83 c6 01             	add    $0x1,%esi
80103980:	89 75 e4             	mov    %esi,-0x1c(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103983:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103987:	3b 75 e0             	cmp    -0x20(%ebp),%esi
8010398a:	0f 85 58 ff ff ff    	jne    801038e8 <pipewrite+0x38>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103990:	83 ec 0c             	sub    $0xc,%esp
80103993:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103999:	50                   	push   %eax
8010399a:	e8 b1 0a 00 00       	call   80104450 <wakeup>
  release(&p->lock);
8010399f:	89 1c 24             	mov    %ebx,(%esp)
801039a2:	e8 39 0f 00 00       	call   801048e0 <release>
  return n;
801039a7:	8b 45 10             	mov    0x10(%ebp),%eax
801039aa:	83 c4 10             	add    $0x10,%esp
801039ad:	eb aa                	jmp    80103959 <pipewrite+0xa9>
801039af:	90                   	nop

801039b0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801039b0:	55                   	push   %ebp
801039b1:	89 e5                	mov    %esp,%ebp
801039b3:	57                   	push   %edi
801039b4:	56                   	push   %esi
801039b5:	53                   	push   %ebx
801039b6:	83 ec 18             	sub    $0x18,%esp
801039b9:	8b 75 08             	mov    0x8(%ebp),%esi
801039bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801039bf:	56                   	push   %esi
801039c0:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
801039c6:	e8 75 0f 00 00       	call   80104940 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039cb:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
801039d1:	83 c4 10             	add    $0x10,%esp
801039d4:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
801039da:	74 2f                	je     80103a0b <piperead+0x5b>
801039dc:	eb 37                	jmp    80103a15 <piperead+0x65>
801039de:	66 90                	xchg   %ax,%ax
    if(myproc()->killed){
801039e0:	e8 6b 02 00 00       	call   80103c50 <myproc>
801039e5:	8b 48 28             	mov    0x28(%eax),%ecx
801039e8:	85 c9                	test   %ecx,%ecx
801039ea:	0f 85 80 00 00 00    	jne    80103a70 <piperead+0xc0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801039f0:	83 ec 08             	sub    $0x8,%esp
801039f3:	56                   	push   %esi
801039f4:	53                   	push   %ebx
801039f5:	e8 96 09 00 00       	call   80104390 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039fa:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
80103a00:	83 c4 10             	add    $0x10,%esp
80103a03:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
80103a09:	75 0a                	jne    80103a15 <piperead+0x65>
80103a0b:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
80103a11:	85 c0                	test   %eax,%eax
80103a13:	75 cb                	jne    801039e0 <piperead+0x30>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a15:	8b 55 10             	mov    0x10(%ebp),%edx
80103a18:	31 db                	xor    %ebx,%ebx
80103a1a:	85 d2                	test   %edx,%edx
80103a1c:	7f 20                	jg     80103a3e <piperead+0x8e>
80103a1e:	eb 2c                	jmp    80103a4c <piperead+0x9c>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103a20:	8d 48 01             	lea    0x1(%eax),%ecx
80103a23:	25 ff 01 00 00       	and    $0x1ff,%eax
80103a28:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
80103a2e:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
80103a33:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a36:	83 c3 01             	add    $0x1,%ebx
80103a39:	39 5d 10             	cmp    %ebx,0x10(%ebp)
80103a3c:	74 0e                	je     80103a4c <piperead+0x9c>
    if(p->nread == p->nwrite)
80103a3e:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103a44:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
80103a4a:	75 d4                	jne    80103a20 <piperead+0x70>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103a4c:	83 ec 0c             	sub    $0xc,%esp
80103a4f:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103a55:	50                   	push   %eax
80103a56:	e8 f5 09 00 00       	call   80104450 <wakeup>
  release(&p->lock);
80103a5b:	89 34 24             	mov    %esi,(%esp)
80103a5e:	e8 7d 0e 00 00       	call   801048e0 <release>
  return i;
80103a63:	83 c4 10             	add    $0x10,%esp
}
80103a66:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103a69:	89 d8                	mov    %ebx,%eax
80103a6b:	5b                   	pop    %ebx
80103a6c:	5e                   	pop    %esi
80103a6d:	5f                   	pop    %edi
80103a6e:	5d                   	pop    %ebp
80103a6f:	c3                   	ret    
      release(&p->lock);
80103a70:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80103a73:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
80103a78:	56                   	push   %esi
80103a79:	e8 62 0e 00 00       	call   801048e0 <release>
      return -1;
80103a7e:	83 c4 10             	add    $0x10,%esp
}
80103a81:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103a84:	89 d8                	mov    %ebx,%eax
80103a86:	5b                   	pop    %ebx
80103a87:	5e                   	pop    %esi
80103a88:	5f                   	pop    %edi
80103a89:	5d                   	pop    %ebp
80103a8a:	c3                   	ret    
80103a8b:	66 90                	xchg   %ax,%ax
80103a8d:	66 90                	xchg   %ax,%ax
80103a8f:	90                   	nop

80103a90 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a90:	55                   	push   %ebp
80103a91:	89 e5                	mov    %esp,%ebp
80103a93:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a94:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
{
80103a99:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103a9c:	68 60 2d 11 80       	push   $0x80112d60
80103aa1:	e8 9a 0e 00 00       	call   80104940 <acquire>
80103aa6:	83 c4 10             	add    $0x10,%esp
80103aa9:	eb 10                	jmp    80103abb <allocproc+0x2b>
80103aab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103aaf:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ab0:	83 eb 80             	sub    $0xffffff80,%ebx
80103ab3:	81 fb 94 4d 11 80    	cmp    $0x80114d94,%ebx
80103ab9:	74 75                	je     80103b30 <allocproc+0xa0>
    if(p->state == UNUSED)
80103abb:	8b 43 10             	mov    0x10(%ebx),%eax
80103abe:	85 c0                	test   %eax,%eax
80103ac0:	75 ee                	jne    80103ab0 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103ac2:	a1 04 b0 10 80       	mov    0x8010b004,%eax

  release(&ptable.lock);
80103ac7:	83 ec 0c             	sub    $0xc,%esp
  p->state = EMBRYO;
80103aca:	c7 43 10 01 00 00 00 	movl   $0x1,0x10(%ebx)
  p->pid = nextpid++;
80103ad1:	89 43 14             	mov    %eax,0x14(%ebx)
80103ad4:	8d 50 01             	lea    0x1(%eax),%edx
  release(&ptable.lock);
80103ad7:	68 60 2d 11 80       	push   $0x80112d60
  p->pid = nextpid++;
80103adc:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
  release(&ptable.lock);
80103ae2:	e8 f9 0d 00 00       	call   801048e0 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ae7:	e8 14 ee ff ff       	call   80102900 <kalloc>
80103aec:	83 c4 10             	add    $0x10,%esp
80103aef:	89 43 0c             	mov    %eax,0xc(%ebx)
80103af2:	85 c0                	test   %eax,%eax
80103af4:	74 53                	je     80103b49 <allocproc+0xb9>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103af6:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
80103afc:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
80103aff:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
80103b04:	89 53 1c             	mov    %edx,0x1c(%ebx)
  *(uint*)sp = (uint)trapret;
80103b07:	c7 40 14 12 5c 10 80 	movl   $0x80105c12,0x14(%eax)
  p->context = (struct context*)sp;
80103b0e:	89 43 20             	mov    %eax,0x20(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103b11:	6a 14                	push   $0x14
80103b13:	6a 00                	push   $0x0
80103b15:	50                   	push   %eax
80103b16:	e8 e5 0e 00 00       	call   80104a00 <memset>
  p->context->eip = (uint)forkret;
80103b1b:	8b 43 20             	mov    0x20(%ebx),%eax

  return p;
80103b1e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b21:	c7 40 10 60 3b 10 80 	movl   $0x80103b60,0x10(%eax)
}
80103b28:	89 d8                	mov    %ebx,%eax
80103b2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b2d:	c9                   	leave  
80103b2e:	c3                   	ret    
80103b2f:	90                   	nop
  release(&ptable.lock);
80103b30:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80103b33:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
80103b35:	68 60 2d 11 80       	push   $0x80112d60
80103b3a:	e8 a1 0d 00 00       	call   801048e0 <release>
}
80103b3f:	89 d8                	mov    %ebx,%eax
  return 0;
80103b41:	83 c4 10             	add    $0x10,%esp
}
80103b44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b47:	c9                   	leave  
80103b48:	c3                   	ret    
    p->state = UNUSED;
80103b49:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return 0;
80103b50:	31 db                	xor    %ebx,%ebx
}
80103b52:	89 d8                	mov    %ebx,%eax
80103b54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b57:	c9                   	leave  
80103b58:	c3                   	ret    
80103b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103b60 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80103b60:	55                   	push   %ebp
80103b61:	89 e5                	mov    %esp,%ebp
80103b63:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80103b66:	68 60 2d 11 80       	push   $0x80112d60
80103b6b:	e8 70 0d 00 00       	call   801048e0 <release>

  if (first) {
80103b70:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80103b75:	83 c4 10             	add    $0x10,%esp
80103b78:	85 c0                	test   %eax,%eax
80103b7a:	75 04                	jne    80103b80 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
80103b7c:	c9                   	leave  
80103b7d:	c3                   	ret    
80103b7e:	66 90                	xchg   %ax,%ax
    first = 0;
80103b80:	c7 05 00 b0 10 80 00 	movl   $0x0,0x8010b000
80103b87:	00 00 00 
    iinit(ROOTDEV);
80103b8a:	83 ec 0c             	sub    $0xc,%esp
80103b8d:	6a 01                	push   $0x1
80103b8f:	e8 dc db ff ff       	call   80101770 <iinit>
    initlog(ROOTDEV);
80103b94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103b9b:	e8 e0 f3 ff ff       	call   80102f80 <initlog>
}
80103ba0:	83 c4 10             	add    $0x10,%esp
80103ba3:	c9                   	leave  
80103ba4:	c3                   	ret    
80103ba5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103bb0 <pinit>:
{
80103bb0:	55                   	push   %ebp
80103bb1:	89 e5                	mov    %esp,%ebp
80103bb3:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103bb6:	68 c0 7e 10 80       	push   $0x80107ec0
80103bbb:	68 60 2d 11 80       	push   $0x80112d60
80103bc0:	e8 ab 0b 00 00       	call   80104770 <initlock>
}
80103bc5:	83 c4 10             	add    $0x10,%esp
80103bc8:	c9                   	leave  
80103bc9:	c3                   	ret    
80103bca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103bd0 <mycpu>:
{
80103bd0:	55                   	push   %ebp
80103bd1:	89 e5                	mov    %esp,%ebp
80103bd3:	56                   	push   %esi
80103bd4:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103bd5:	9c                   	pushf  
80103bd6:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103bd7:	f6 c4 02             	test   $0x2,%ah
80103bda:	75 46                	jne    80103c22 <mycpu+0x52>
  apicid = lapicid();
80103bdc:	e8 cf ef ff ff       	call   80102bb0 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103be1:	8b 35 c4 27 11 80    	mov    0x801127c4,%esi
80103be7:	85 f6                	test   %esi,%esi
80103be9:	7e 2a                	jle    80103c15 <mycpu+0x45>
80103beb:	31 d2                	xor    %edx,%edx
80103bed:	eb 08                	jmp    80103bf7 <mycpu+0x27>
80103bef:	90                   	nop
80103bf0:	83 c2 01             	add    $0x1,%edx
80103bf3:	39 f2                	cmp    %esi,%edx
80103bf5:	74 1e                	je     80103c15 <mycpu+0x45>
    if (cpus[i].apicid == apicid)
80103bf7:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103bfd:	0f b6 99 e0 27 11 80 	movzbl -0x7feed820(%ecx),%ebx
80103c04:	39 c3                	cmp    %eax,%ebx
80103c06:	75 e8                	jne    80103bf0 <mycpu+0x20>
}
80103c08:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
80103c0b:	8d 81 e0 27 11 80    	lea    -0x7feed820(%ecx),%eax
}
80103c11:	5b                   	pop    %ebx
80103c12:	5e                   	pop    %esi
80103c13:	5d                   	pop    %ebp
80103c14:	c3                   	ret    
  panic("unknown apicid\n");
80103c15:	83 ec 0c             	sub    $0xc,%esp
80103c18:	68 c7 7e 10 80       	push   $0x80107ec7
80103c1d:	e8 8e c8 ff ff       	call   801004b0 <panic>
    panic("mycpu called with interrupts enabled\n");
80103c22:	83 ec 0c             	sub    $0xc,%esp
80103c25:	68 b0 7f 10 80       	push   $0x80107fb0
80103c2a:	e8 81 c8 ff ff       	call   801004b0 <panic>
80103c2f:	90                   	nop

80103c30 <cpuid>:
cpuid() {
80103c30:	55                   	push   %ebp
80103c31:	89 e5                	mov    %esp,%ebp
80103c33:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103c36:	e8 95 ff ff ff       	call   80103bd0 <mycpu>
}
80103c3b:	c9                   	leave  
  return mycpu()-cpus;
80103c3c:	2d e0 27 11 80       	sub    $0x801127e0,%eax
80103c41:	c1 f8 04             	sar    $0x4,%eax
80103c44:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103c4a:	c3                   	ret    
80103c4b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103c4f:	90                   	nop

80103c50 <myproc>:
myproc(void) {
80103c50:	55                   	push   %ebp
80103c51:	89 e5                	mov    %esp,%ebp
80103c53:	53                   	push   %ebx
80103c54:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103c57:	e8 94 0b 00 00       	call   801047f0 <pushcli>
  c = mycpu();
80103c5c:	e8 6f ff ff ff       	call   80103bd0 <mycpu>
  p = c->proc;
80103c61:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103c67:	e8 d4 0b 00 00       	call   80104840 <popcli>
}
80103c6c:	89 d8                	mov    %ebx,%eax
80103c6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c71:	c9                   	leave  
80103c72:	c3                   	ret    
80103c73:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103c7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103c80 <userinit>:
{
80103c80:	55                   	push   %ebp
80103c81:	89 e5                	mov    %esp,%ebp
80103c83:	53                   	push   %ebx
80103c84:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103c87:	e8 04 fe ff ff       	call   80103a90 <allocproc>
80103c8c:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103c8e:	a3 94 4d 11 80       	mov    %eax,0x80114d94
  if((p->pgdir = setupkvm()) == 0)
80103c93:	e8 98 35 00 00       	call   80107230 <setupkvm>
80103c98:	89 43 08             	mov    %eax,0x8(%ebx)
80103c9b:	85 c0                	test   %eax,%eax
80103c9d:	0f 84 bd 00 00 00    	je     80103d60 <userinit+0xe0>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103ca3:	83 ec 04             	sub    $0x4,%esp
80103ca6:	68 2c 00 00 00       	push   $0x2c
80103cab:	68 60 b4 10 80       	push   $0x8010b460
80103cb0:	50                   	push   %eax
80103cb1:	e8 2a 32 00 00       	call   80106ee0 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103cb6:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103cb9:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103cbf:	6a 4c                	push   $0x4c
80103cc1:	6a 00                	push   $0x0
80103cc3:	ff 73 1c             	push   0x1c(%ebx)
80103cc6:	e8 35 0d 00 00       	call   80104a00 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103ccb:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103cce:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103cd3:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103cd6:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103cdb:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103cdf:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103ce2:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103ce6:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103ce9:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103ced:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103cf1:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103cf4:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103cf8:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103cfc:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103cff:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103d06:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103d09:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103d10:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103d13:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103d1a:	8d 43 70             	lea    0x70(%ebx),%eax
80103d1d:	6a 10                	push   $0x10
80103d1f:	68 f0 7e 10 80       	push   $0x80107ef0
80103d24:	50                   	push   %eax
80103d25:	e8 96 0e 00 00       	call   80104bc0 <safestrcpy>
  p->cwd = namei("/");
80103d2a:	c7 04 24 f9 7e 10 80 	movl   $0x80107ef9,(%esp)
80103d31:	e8 ca e5 ff ff       	call   80102300 <namei>
80103d36:	89 43 6c             	mov    %eax,0x6c(%ebx)
  acquire(&ptable.lock);
80103d39:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80103d40:	e8 fb 0b 00 00       	call   80104940 <acquire>
  p->state = RUNNABLE;
80103d45:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  release(&ptable.lock);
80103d4c:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80103d53:	e8 88 0b 00 00       	call   801048e0 <release>
}
80103d58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d5b:	83 c4 10             	add    $0x10,%esp
80103d5e:	c9                   	leave  
80103d5f:	c3                   	ret    
    panic("userinit: out of memory?");
80103d60:	83 ec 0c             	sub    $0xc,%esp
80103d63:	68 d7 7e 10 80       	push   $0x80107ed7
80103d68:	e8 43 c7 ff ff       	call   801004b0 <panic>
80103d6d:	8d 76 00             	lea    0x0(%esi),%esi

80103d70 <growproc>:
{
80103d70:	55                   	push   %ebp
80103d71:	89 e5                	mov    %esp,%ebp
80103d73:	56                   	push   %esi
80103d74:	53                   	push   %ebx
80103d75:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103d78:	e8 73 0a 00 00       	call   801047f0 <pushcli>
  c = mycpu();
80103d7d:	e8 4e fe ff ff       	call   80103bd0 <mycpu>
  p = c->proc;
80103d82:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103d88:	e8 b3 0a 00 00       	call   80104840 <popcli>
  sz = curproc->sz;
80103d8d:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103d8f:	85 f6                	test   %esi,%esi
80103d91:	7f 1d                	jg     80103db0 <growproc+0x40>
  } else if(n < 0){
80103d93:	75 3b                	jne    80103dd0 <growproc+0x60>
  switchuvm(curproc);
80103d95:	83 ec 0c             	sub    $0xc,%esp
  curproc->sz = sz;
80103d98:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103d9a:	53                   	push   %ebx
80103d9b:	e8 30 30 00 00       	call   80106dd0 <switchuvm>
  return 0;
80103da0:	83 c4 10             	add    $0x10,%esp
80103da3:	31 c0                	xor    %eax,%eax
}
80103da5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103da8:	5b                   	pop    %ebx
80103da9:	5e                   	pop    %esi
80103daa:	5d                   	pop    %ebp
80103dab:	c3                   	ret    
80103dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103db0:	83 ec 04             	sub    $0x4,%esp
80103db3:	01 c6                	add    %eax,%esi
80103db5:	56                   	push   %esi
80103db6:	50                   	push   %eax
80103db7:	ff 73 08             	push   0x8(%ebx)
80103dba:	e8 91 32 00 00       	call   80107050 <allocuvm>
80103dbf:	83 c4 10             	add    $0x10,%esp
80103dc2:	85 c0                	test   %eax,%eax
80103dc4:	75 cf                	jne    80103d95 <growproc+0x25>
      return -1;
80103dc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dcb:	eb d8                	jmp    80103da5 <growproc+0x35>
80103dcd:	8d 76 00             	lea    0x0(%esi),%esi
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103dd0:	83 ec 04             	sub    $0x4,%esp
80103dd3:	01 c6                	add    %eax,%esi
80103dd5:	56                   	push   %esi
80103dd6:	50                   	push   %eax
80103dd7:	ff 73 08             	push   0x8(%ebx)
80103dda:	e8 a1 33 00 00       	call   80107180 <deallocuvm>
80103ddf:	83 c4 10             	add    $0x10,%esp
80103de2:	85 c0                	test   %eax,%eax
80103de4:	75 af                	jne    80103d95 <growproc+0x25>
80103de6:	eb de                	jmp    80103dc6 <growproc+0x56>
80103de8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103def:	90                   	nop

80103df0 <fork>:
{
80103df0:	55                   	push   %ebp
80103df1:	89 e5                	mov    %esp,%ebp
80103df3:	57                   	push   %edi
80103df4:	56                   	push   %esi
80103df5:	53                   	push   %ebx
80103df6:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103df9:	e8 f2 09 00 00       	call   801047f0 <pushcli>
  c = mycpu();
80103dfe:	e8 cd fd ff ff       	call   80103bd0 <mycpu>
  p = c->proc;
80103e03:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103e09:	e8 32 0a 00 00       	call   80104840 <popcli>
  if((np = allocproc()) == 0){
80103e0e:	e8 7d fc ff ff       	call   80103a90 <allocproc>
80103e13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103e16:	85 c0                	test   %eax,%eax
80103e18:	0f 84 b7 00 00 00    	je     80103ed5 <fork+0xe5>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103e1e:	83 ec 08             	sub    $0x8,%esp
80103e21:	ff 33                	push   (%ebx)
80103e23:	89 c7                	mov    %eax,%edi
80103e25:	ff 73 08             	push   0x8(%ebx)
80103e28:	e8 f3 34 00 00       	call   80107320 <copyuvm>
80103e2d:	83 c4 10             	add    $0x10,%esp
80103e30:	89 47 08             	mov    %eax,0x8(%edi)
80103e33:	85 c0                	test   %eax,%eax
80103e35:	0f 84 a1 00 00 00    	je     80103edc <fork+0xec>
  np->sz = curproc->sz;
80103e3b:	8b 03                	mov    (%ebx),%eax
80103e3d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e40:	89 01                	mov    %eax,(%ecx)
  *np->tf = *curproc->tf;
80103e42:	8b 79 1c             	mov    0x1c(%ecx),%edi
  np->parent = curproc;
80103e45:	89 c8                	mov    %ecx,%eax
80103e47:	89 59 18             	mov    %ebx,0x18(%ecx)
  *np->tf = *curproc->tf;
80103e4a:	b9 13 00 00 00       	mov    $0x13,%ecx
80103e4f:	8b 73 1c             	mov    0x1c(%ebx),%esi
80103e52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103e54:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103e56:	8b 40 1c             	mov    0x1c(%eax),%eax
80103e59:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    if(curproc->ofile[i])
80103e60:	8b 44 b3 2c          	mov    0x2c(%ebx,%esi,4),%eax
80103e64:	85 c0                	test   %eax,%eax
80103e66:	74 13                	je     80103e7b <fork+0x8b>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e68:	83 ec 0c             	sub    $0xc,%esp
80103e6b:	50                   	push   %eax
80103e6c:	e8 5f d1 ff ff       	call   80100fd0 <filedup>
80103e71:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e74:	83 c4 10             	add    $0x10,%esp
80103e77:	89 44 b2 2c          	mov    %eax,0x2c(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
80103e7b:	83 c6 01             	add    $0x1,%esi
80103e7e:	83 fe 10             	cmp    $0x10,%esi
80103e81:	75 dd                	jne    80103e60 <fork+0x70>
  np->cwd = idup(curproc->cwd);
80103e83:	83 ec 0c             	sub    $0xc,%esp
80103e86:	ff 73 6c             	push   0x6c(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e89:	83 c3 70             	add    $0x70,%ebx
  np->cwd = idup(curproc->cwd);
80103e8c:	e8 1f db ff ff       	call   801019b0 <idup>
80103e91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e94:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
80103e97:	89 47 6c             	mov    %eax,0x6c(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e9a:	8d 47 70             	lea    0x70(%edi),%eax
80103e9d:	6a 10                	push   $0x10
80103e9f:	53                   	push   %ebx
80103ea0:	50                   	push   %eax
80103ea1:	e8 1a 0d 00 00       	call   80104bc0 <safestrcpy>
  pid = np->pid;
80103ea6:	8b 5f 14             	mov    0x14(%edi),%ebx
  acquire(&ptable.lock);
80103ea9:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80103eb0:	e8 8b 0a 00 00       	call   80104940 <acquire>
  np->state = RUNNABLE;
80103eb5:	c7 47 10 03 00 00 00 	movl   $0x3,0x10(%edi)
  release(&ptable.lock);
80103ebc:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80103ec3:	e8 18 0a 00 00       	call   801048e0 <release>
  return pid;
80103ec8:	83 c4 10             	add    $0x10,%esp
}
80103ecb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ece:	89 d8                	mov    %ebx,%eax
80103ed0:	5b                   	pop    %ebx
80103ed1:	5e                   	pop    %esi
80103ed2:	5f                   	pop    %edi
80103ed3:	5d                   	pop    %ebp
80103ed4:	c3                   	ret    
    return -1;
80103ed5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103eda:	eb ef                	jmp    80103ecb <fork+0xdb>
    kfree(np->kstack);
80103edc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103edf:	83 ec 0c             	sub    $0xc,%esp
80103ee2:	ff 73 0c             	push   0xc(%ebx)
80103ee5:	e8 36 e8 ff ff       	call   80102720 <kfree>
    np->kstack = 0;
80103eea:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103ef1:	83 c4 10             	add    $0x10,%esp
    np->state = UNUSED;
80103ef4:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return -1;
80103efb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103f00:	eb c9                	jmp    80103ecb <fork+0xdb>
80103f02:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103f10 <print_rss>:
{
80103f10:	55                   	push   %ebp
80103f11:	89 e5                	mov    %esp,%ebp
80103f13:	53                   	push   %ebx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f14:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
{
80103f19:	83 ec 10             	sub    $0x10,%esp
  cprintf("PrintingRSS\n");
80103f1c:	68 fb 7e 10 80       	push   $0x80107efb
80103f21:	e8 aa c8 ff ff       	call   801007d0 <cprintf>
  acquire(&ptable.lock);
80103f26:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80103f2d:	e8 0e 0a 00 00       	call   80104940 <acquire>
80103f32:	83 c4 10             	add    $0x10,%esp
80103f35:	8d 76 00             	lea    0x0(%esi),%esi
    if((p->state == UNUSED))
80103f38:	8b 43 10             	mov    0x10(%ebx),%eax
80103f3b:	85 c0                	test   %eax,%eax
80103f3d:	74 14                	je     80103f53 <print_rss+0x43>
    cprintf("((P)) id: %d, state: %d, rss: %d\n",p->pid,p->state,p->rss);
80103f3f:	ff 73 04             	push   0x4(%ebx)
80103f42:	50                   	push   %eax
80103f43:	ff 73 14             	push   0x14(%ebx)
80103f46:	68 d8 7f 10 80       	push   $0x80107fd8
80103f4b:	e8 80 c8 ff ff       	call   801007d0 <cprintf>
80103f50:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f53:	83 eb 80             	sub    $0xffffff80,%ebx
80103f56:	81 fb 94 4d 11 80    	cmp    $0x80114d94,%ebx
80103f5c:	75 da                	jne    80103f38 <print_rss+0x28>
  release(&ptable.lock);
80103f5e:	83 ec 0c             	sub    $0xc,%esp
80103f61:	68 60 2d 11 80       	push   $0x80112d60
80103f66:	e8 75 09 00 00       	call   801048e0 <release>
}
80103f6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f6e:	83 c4 10             	add    $0x10,%esp
80103f71:	c9                   	leave  
80103f72:	c3                   	ret    
80103f73:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103f80 <scheduler>:
{
80103f80:	55                   	push   %ebp
80103f81:	89 e5                	mov    %esp,%ebp
80103f83:	57                   	push   %edi
80103f84:	56                   	push   %esi
80103f85:	53                   	push   %ebx
80103f86:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80103f89:	e8 42 fc ff ff       	call   80103bd0 <mycpu>
  c->proc = 0;
80103f8e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103f95:	00 00 00 
  struct cpu *c = mycpu();
80103f98:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103f9a:	8d 78 04             	lea    0x4(%eax),%edi
80103f9d:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103fa0:	fb                   	sti    
    acquire(&ptable.lock);
80103fa1:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fa4:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
    acquire(&ptable.lock);
80103fa9:	68 60 2d 11 80       	push   $0x80112d60
80103fae:	e8 8d 09 00 00       	call   80104940 <acquire>
80103fb3:	83 c4 10             	add    $0x10,%esp
80103fb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103fbd:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->state != RUNNABLE)
80103fc0:	83 7b 10 03          	cmpl   $0x3,0x10(%ebx)
80103fc4:	75 33                	jne    80103ff9 <scheduler+0x79>
      switchuvm(p);
80103fc6:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80103fc9:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103fcf:	53                   	push   %ebx
80103fd0:	e8 fb 2d 00 00       	call   80106dd0 <switchuvm>
      swtch(&(c->scheduler), p->context);
80103fd5:	58                   	pop    %eax
80103fd6:	5a                   	pop    %edx
80103fd7:	ff 73 20             	push   0x20(%ebx)
80103fda:	57                   	push   %edi
      p->state = RUNNING;
80103fdb:	c7 43 10 04 00 00 00 	movl   $0x4,0x10(%ebx)
      swtch(&(c->scheduler), p->context);
80103fe2:	e8 34 0c 00 00       	call   80104c1b <swtch>
      switchkvm();
80103fe7:	e8 d4 2d 00 00       	call   80106dc0 <switchkvm>
      c->proc = 0;
80103fec:	83 c4 10             	add    $0x10,%esp
80103fef:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103ff6:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ff9:	83 eb 80             	sub    $0xffffff80,%ebx
80103ffc:	81 fb 94 4d 11 80    	cmp    $0x80114d94,%ebx
80104002:	75 bc                	jne    80103fc0 <scheduler+0x40>
    release(&ptable.lock);
80104004:	83 ec 0c             	sub    $0xc,%esp
80104007:	68 60 2d 11 80       	push   $0x80112d60
8010400c:	e8 cf 08 00 00       	call   801048e0 <release>
    sti();
80104011:	83 c4 10             	add    $0x10,%esp
80104014:	eb 8a                	jmp    80103fa0 <scheduler+0x20>
80104016:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010401d:	8d 76 00             	lea    0x0(%esi),%esi

80104020 <sched>:
{
80104020:	55                   	push   %ebp
80104021:	89 e5                	mov    %esp,%ebp
80104023:	56                   	push   %esi
80104024:	53                   	push   %ebx
  pushcli();
80104025:	e8 c6 07 00 00       	call   801047f0 <pushcli>
  c = mycpu();
8010402a:	e8 a1 fb ff ff       	call   80103bd0 <mycpu>
  p = c->proc;
8010402f:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104035:	e8 06 08 00 00       	call   80104840 <popcli>
  if(!holding(&ptable.lock))
8010403a:	83 ec 0c             	sub    $0xc,%esp
8010403d:	68 60 2d 11 80       	push   $0x80112d60
80104042:	e8 59 08 00 00       	call   801048a0 <holding>
80104047:	83 c4 10             	add    $0x10,%esp
8010404a:	85 c0                	test   %eax,%eax
8010404c:	74 4f                	je     8010409d <sched+0x7d>
  if(mycpu()->ncli != 1)
8010404e:	e8 7d fb ff ff       	call   80103bd0 <mycpu>
80104053:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010405a:	75 68                	jne    801040c4 <sched+0xa4>
  if(p->state == RUNNING)
8010405c:	83 7b 10 04          	cmpl   $0x4,0x10(%ebx)
80104060:	74 55                	je     801040b7 <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104062:	9c                   	pushf  
80104063:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104064:	f6 c4 02             	test   $0x2,%ah
80104067:	75 41                	jne    801040aa <sched+0x8a>
  intena = mycpu()->intena;
80104069:	e8 62 fb ff ff       	call   80103bd0 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
8010406e:	83 c3 20             	add    $0x20,%ebx
  intena = mycpu()->intena;
80104071:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80104077:	e8 54 fb ff ff       	call   80103bd0 <mycpu>
8010407c:	83 ec 08             	sub    $0x8,%esp
8010407f:	ff 70 04             	push   0x4(%eax)
80104082:	53                   	push   %ebx
80104083:	e8 93 0b 00 00       	call   80104c1b <swtch>
  mycpu()->intena = intena;
80104088:	e8 43 fb ff ff       	call   80103bd0 <mycpu>
}
8010408d:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104090:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80104096:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104099:	5b                   	pop    %ebx
8010409a:	5e                   	pop    %esi
8010409b:	5d                   	pop    %ebp
8010409c:	c3                   	ret    
    panic("sched ptable.lock");
8010409d:	83 ec 0c             	sub    $0xc,%esp
801040a0:	68 08 7f 10 80       	push   $0x80107f08
801040a5:	e8 06 c4 ff ff       	call   801004b0 <panic>
    panic("sched interruptible");
801040aa:	83 ec 0c             	sub    $0xc,%esp
801040ad:	68 34 7f 10 80       	push   $0x80107f34
801040b2:	e8 f9 c3 ff ff       	call   801004b0 <panic>
    panic("sched running");
801040b7:	83 ec 0c             	sub    $0xc,%esp
801040ba:	68 26 7f 10 80       	push   $0x80107f26
801040bf:	e8 ec c3 ff ff       	call   801004b0 <panic>
    panic("sched locks");
801040c4:	83 ec 0c             	sub    $0xc,%esp
801040c7:	68 1a 7f 10 80       	push   $0x80107f1a
801040cc:	e8 df c3 ff ff       	call   801004b0 <panic>
801040d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801040d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801040df:	90                   	nop

801040e0 <exit>:
{
801040e0:	55                   	push   %ebp
801040e1:	89 e5                	mov    %esp,%ebp
801040e3:	57                   	push   %edi
801040e4:	56                   	push   %esi
801040e5:	53                   	push   %ebx
801040e6:	83 ec 0c             	sub    $0xc,%esp
  struct proc *curproc = myproc();
801040e9:	e8 62 fb ff ff       	call   80103c50 <myproc>
  if(curproc == initproc)
801040ee:	39 05 94 4d 11 80    	cmp    %eax,0x80114d94
801040f4:	0f 84 fd 00 00 00    	je     801041f7 <exit+0x117>
801040fa:	89 c3                	mov    %eax,%ebx
801040fc:	8d 70 2c             	lea    0x2c(%eax),%esi
801040ff:	8d 78 6c             	lea    0x6c(%eax),%edi
80104102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[fd]){
80104108:	8b 06                	mov    (%esi),%eax
8010410a:	85 c0                	test   %eax,%eax
8010410c:	74 12                	je     80104120 <exit+0x40>
      fileclose(curproc->ofile[fd]);
8010410e:	83 ec 0c             	sub    $0xc,%esp
80104111:	50                   	push   %eax
80104112:	e8 09 cf ff ff       	call   80101020 <fileclose>
      curproc->ofile[fd] = 0;
80104117:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010411d:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80104120:	83 c6 04             	add    $0x4,%esi
80104123:	39 f7                	cmp    %esi,%edi
80104125:	75 e1                	jne    80104108 <exit+0x28>
  begin_op();
80104127:	e8 f4 ee ff ff       	call   80103020 <begin_op>
  iput(curproc->cwd);
8010412c:	83 ec 0c             	sub    $0xc,%esp
8010412f:	ff 73 6c             	push   0x6c(%ebx)
80104132:	e8 d9 d9 ff ff       	call   80101b10 <iput>
  end_op();
80104137:	e8 54 ef ff ff       	call   80103090 <end_op>
  curproc->cwd = 0;
8010413c:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)
  acquire(&ptable.lock);
80104143:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
8010414a:	e8 f1 07 00 00       	call   80104940 <acquire>
  wakeup1(curproc->parent);
8010414f:	8b 53 18             	mov    0x18(%ebx),%edx
80104152:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104155:	b8 94 2d 11 80       	mov    $0x80112d94,%eax
8010415a:	eb 0e                	jmp    8010416a <exit+0x8a>
8010415c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104160:	83 e8 80             	sub    $0xffffff80,%eax
80104163:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
80104168:	74 1c                	je     80104186 <exit+0xa6>
    if(p->state == SLEEPING && p->chan == chan)
8010416a:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
8010416e:	75 f0                	jne    80104160 <exit+0x80>
80104170:	3b 50 24             	cmp    0x24(%eax),%edx
80104173:	75 eb                	jne    80104160 <exit+0x80>
      p->state = RUNNABLE;
80104175:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010417c:	83 e8 80             	sub    $0xffffff80,%eax
8010417f:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
80104184:	75 e4                	jne    8010416a <exit+0x8a>
      p->parent = initproc;
80104186:	8b 0d 94 4d 11 80    	mov    0x80114d94,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010418c:	ba 94 2d 11 80       	mov    $0x80112d94,%edx
80104191:	eb 10                	jmp    801041a3 <exit+0xc3>
80104193:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104197:	90                   	nop
80104198:	83 ea 80             	sub    $0xffffff80,%edx
8010419b:	81 fa 94 4d 11 80    	cmp    $0x80114d94,%edx
801041a1:	74 3b                	je     801041de <exit+0xfe>
    if(p->parent == curproc){
801041a3:	39 5a 18             	cmp    %ebx,0x18(%edx)
801041a6:	75 f0                	jne    80104198 <exit+0xb8>
      if(p->state == ZOMBIE)
801041a8:	83 7a 10 05          	cmpl   $0x5,0x10(%edx)
      p->parent = initproc;
801041ac:	89 4a 18             	mov    %ecx,0x18(%edx)
      if(p->state == ZOMBIE)
801041af:	75 e7                	jne    80104198 <exit+0xb8>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801041b1:	b8 94 2d 11 80       	mov    $0x80112d94,%eax
801041b6:	eb 12                	jmp    801041ca <exit+0xea>
801041b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801041bf:	90                   	nop
801041c0:	83 e8 80             	sub    $0xffffff80,%eax
801041c3:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
801041c8:	74 ce                	je     80104198 <exit+0xb8>
    if(p->state == SLEEPING && p->chan == chan)
801041ca:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
801041ce:	75 f0                	jne    801041c0 <exit+0xe0>
801041d0:	3b 48 24             	cmp    0x24(%eax),%ecx
801041d3:	75 eb                	jne    801041c0 <exit+0xe0>
      p->state = RUNNABLE;
801041d5:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
801041dc:	eb e2                	jmp    801041c0 <exit+0xe0>
  curproc->state = ZOMBIE;
801041de:	c7 43 10 05 00 00 00 	movl   $0x5,0x10(%ebx)
  sched();
801041e5:	e8 36 fe ff ff       	call   80104020 <sched>
  panic("zombie exit");
801041ea:	83 ec 0c             	sub    $0xc,%esp
801041ed:	68 55 7f 10 80       	push   $0x80107f55
801041f2:	e8 b9 c2 ff ff       	call   801004b0 <panic>
    panic("init exiting");
801041f7:	83 ec 0c             	sub    $0xc,%esp
801041fa:	68 48 7f 10 80       	push   $0x80107f48
801041ff:	e8 ac c2 ff ff       	call   801004b0 <panic>
80104204:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010420b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010420f:	90                   	nop

80104210 <wait>:
{
80104210:	55                   	push   %ebp
80104211:	89 e5                	mov    %esp,%ebp
80104213:	56                   	push   %esi
80104214:	53                   	push   %ebx
  pushcli();
80104215:	e8 d6 05 00 00       	call   801047f0 <pushcli>
  c = mycpu();
8010421a:	e8 b1 f9 ff ff       	call   80103bd0 <mycpu>
  p = c->proc;
8010421f:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80104225:	e8 16 06 00 00       	call   80104840 <popcli>
  acquire(&ptable.lock);
8010422a:	83 ec 0c             	sub    $0xc,%esp
8010422d:	68 60 2d 11 80       	push   $0x80112d60
80104232:	e8 09 07 00 00       	call   80104940 <acquire>
80104237:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010423a:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010423c:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
80104241:	eb 10                	jmp    80104253 <wait+0x43>
80104243:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104247:	90                   	nop
80104248:	83 eb 80             	sub    $0xffffff80,%ebx
8010424b:	81 fb 94 4d 11 80    	cmp    $0x80114d94,%ebx
80104251:	74 1b                	je     8010426e <wait+0x5e>
      if(p->parent != curproc)
80104253:	39 73 18             	cmp    %esi,0x18(%ebx)
80104256:	75 f0                	jne    80104248 <wait+0x38>
      if(p->state == ZOMBIE){
80104258:	83 7b 10 05          	cmpl   $0x5,0x10(%ebx)
8010425c:	74 62                	je     801042c0 <wait+0xb0>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010425e:	83 eb 80             	sub    $0xffffff80,%ebx
      havekids = 1;
80104261:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104266:	81 fb 94 4d 11 80    	cmp    $0x80114d94,%ebx
8010426c:	75 e5                	jne    80104253 <wait+0x43>
    if(!havekids || curproc->killed){
8010426e:	85 c0                	test   %eax,%eax
80104270:	0f 84 a0 00 00 00    	je     80104316 <wait+0x106>
80104276:	8b 46 28             	mov    0x28(%esi),%eax
80104279:	85 c0                	test   %eax,%eax
8010427b:	0f 85 95 00 00 00    	jne    80104316 <wait+0x106>
  pushcli();
80104281:	e8 6a 05 00 00       	call   801047f0 <pushcli>
  c = mycpu();
80104286:	e8 45 f9 ff ff       	call   80103bd0 <mycpu>
  p = c->proc;
8010428b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104291:	e8 aa 05 00 00       	call   80104840 <popcli>
  if(p == 0)
80104296:	85 db                	test   %ebx,%ebx
80104298:	0f 84 8f 00 00 00    	je     8010432d <wait+0x11d>
  p->chan = chan;
8010429e:	89 73 24             	mov    %esi,0x24(%ebx)
  p->state = SLEEPING;
801042a1:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
801042a8:	e8 73 fd ff ff       	call   80104020 <sched>
  p->chan = 0;
801042ad:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
}
801042b4:	eb 84                	jmp    8010423a <wait+0x2a>
801042b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801042bd:	8d 76 00             	lea    0x0(%esi),%esi
        kfree(p->kstack);
801042c0:	83 ec 0c             	sub    $0xc,%esp
        pid = p->pid;
801042c3:	8b 73 14             	mov    0x14(%ebx),%esi
        kfree(p->kstack);
801042c6:	ff 73 0c             	push   0xc(%ebx)
801042c9:	e8 52 e4 ff ff       	call   80102720 <kfree>
        p->kstack = 0;
801042ce:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        freevm(p->pgdir);
801042d5:	5a                   	pop    %edx
801042d6:	ff 73 08             	push   0x8(%ebx)
801042d9:	e8 d2 2e 00 00       	call   801071b0 <freevm>
        p->pid = 0;
801042de:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->parent = 0;
801042e5:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->name[0] = 0;
801042ec:	c6 43 70 00          	movb   $0x0,0x70(%ebx)
        p->killed = 0;
801042f0:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
        p->state = UNUSED;
801042f7:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        release(&ptable.lock);
801042fe:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80104305:	e8 d6 05 00 00       	call   801048e0 <release>
        return pid;
8010430a:	83 c4 10             	add    $0x10,%esp
}
8010430d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104310:	89 f0                	mov    %esi,%eax
80104312:	5b                   	pop    %ebx
80104313:	5e                   	pop    %esi
80104314:	5d                   	pop    %ebp
80104315:	c3                   	ret    
      release(&ptable.lock);
80104316:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80104319:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
8010431e:	68 60 2d 11 80       	push   $0x80112d60
80104323:	e8 b8 05 00 00       	call   801048e0 <release>
      return -1;
80104328:	83 c4 10             	add    $0x10,%esp
8010432b:	eb e0                	jmp    8010430d <wait+0xfd>
    panic("sleep");
8010432d:	83 ec 0c             	sub    $0xc,%esp
80104330:	68 61 7f 10 80       	push   $0x80107f61
80104335:	e8 76 c1 ff ff       	call   801004b0 <panic>
8010433a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104340 <yield>:
{
80104340:	55                   	push   %ebp
80104341:	89 e5                	mov    %esp,%ebp
80104343:	53                   	push   %ebx
80104344:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104347:	68 60 2d 11 80       	push   $0x80112d60
8010434c:	e8 ef 05 00 00       	call   80104940 <acquire>
  pushcli();
80104351:	e8 9a 04 00 00       	call   801047f0 <pushcli>
  c = mycpu();
80104356:	e8 75 f8 ff ff       	call   80103bd0 <mycpu>
  p = c->proc;
8010435b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104361:	e8 da 04 00 00       	call   80104840 <popcli>
  myproc()->state = RUNNABLE;
80104366:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  sched();
8010436d:	e8 ae fc ff ff       	call   80104020 <sched>
  release(&ptable.lock);
80104372:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80104379:	e8 62 05 00 00       	call   801048e0 <release>
}
8010437e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104381:	83 c4 10             	add    $0x10,%esp
80104384:	c9                   	leave  
80104385:	c3                   	ret    
80104386:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010438d:	8d 76 00             	lea    0x0(%esi),%esi

80104390 <sleep>:
{
80104390:	55                   	push   %ebp
80104391:	89 e5                	mov    %esp,%ebp
80104393:	57                   	push   %edi
80104394:	56                   	push   %esi
80104395:	53                   	push   %ebx
80104396:	83 ec 0c             	sub    $0xc,%esp
80104399:	8b 7d 08             	mov    0x8(%ebp),%edi
8010439c:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
8010439f:	e8 4c 04 00 00       	call   801047f0 <pushcli>
  c = mycpu();
801043a4:	e8 27 f8 ff ff       	call   80103bd0 <mycpu>
  p = c->proc;
801043a9:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801043af:	e8 8c 04 00 00       	call   80104840 <popcli>
  if(p == 0)
801043b4:	85 db                	test   %ebx,%ebx
801043b6:	0f 84 87 00 00 00    	je     80104443 <sleep+0xb3>
  if(lk == 0)
801043bc:	85 f6                	test   %esi,%esi
801043be:	74 76                	je     80104436 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801043c0:	81 fe 60 2d 11 80    	cmp    $0x80112d60,%esi
801043c6:	74 50                	je     80104418 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
801043c8:	83 ec 0c             	sub    $0xc,%esp
801043cb:	68 60 2d 11 80       	push   $0x80112d60
801043d0:	e8 6b 05 00 00       	call   80104940 <acquire>
    release(lk);
801043d5:	89 34 24             	mov    %esi,(%esp)
801043d8:	e8 03 05 00 00       	call   801048e0 <release>
  p->chan = chan;
801043dd:	89 7b 24             	mov    %edi,0x24(%ebx)
  p->state = SLEEPING;
801043e0:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
801043e7:	e8 34 fc ff ff       	call   80104020 <sched>
  p->chan = 0;
801043ec:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
    release(&ptable.lock);
801043f3:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
801043fa:	e8 e1 04 00 00       	call   801048e0 <release>
    acquire(lk);
801043ff:	89 75 08             	mov    %esi,0x8(%ebp)
80104402:	83 c4 10             	add    $0x10,%esp
}
80104405:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104408:	5b                   	pop    %ebx
80104409:	5e                   	pop    %esi
8010440a:	5f                   	pop    %edi
8010440b:	5d                   	pop    %ebp
    acquire(lk);
8010440c:	e9 2f 05 00 00       	jmp    80104940 <acquire>
80104411:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  p->chan = chan;
80104418:	89 7b 24             	mov    %edi,0x24(%ebx)
  p->state = SLEEPING;
8010441b:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
80104422:	e8 f9 fb ff ff       	call   80104020 <sched>
  p->chan = 0;
80104427:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
}
8010442e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104431:	5b                   	pop    %ebx
80104432:	5e                   	pop    %esi
80104433:	5f                   	pop    %edi
80104434:	5d                   	pop    %ebp
80104435:	c3                   	ret    
    panic("sleep without lk");
80104436:	83 ec 0c             	sub    $0xc,%esp
80104439:	68 67 7f 10 80       	push   $0x80107f67
8010443e:	e8 6d c0 ff ff       	call   801004b0 <panic>
    panic("sleep");
80104443:	83 ec 0c             	sub    $0xc,%esp
80104446:	68 61 7f 10 80       	push   $0x80107f61
8010444b:	e8 60 c0 ff ff       	call   801004b0 <panic>

80104450 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104450:	55                   	push   %ebp
80104451:	89 e5                	mov    %esp,%ebp
80104453:	53                   	push   %ebx
80104454:	83 ec 10             	sub    $0x10,%esp
80104457:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010445a:	68 60 2d 11 80       	push   $0x80112d60
8010445f:	e8 dc 04 00 00       	call   80104940 <acquire>
80104464:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104467:	b8 94 2d 11 80       	mov    $0x80112d94,%eax
8010446c:	eb 0c                	jmp    8010447a <wakeup+0x2a>
8010446e:	66 90                	xchg   %ax,%ax
80104470:	83 e8 80             	sub    $0xffffff80,%eax
80104473:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
80104478:	74 1c                	je     80104496 <wakeup+0x46>
    if(p->state == SLEEPING && p->chan == chan)
8010447a:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
8010447e:	75 f0                	jne    80104470 <wakeup+0x20>
80104480:	3b 58 24             	cmp    0x24(%eax),%ebx
80104483:	75 eb                	jne    80104470 <wakeup+0x20>
      p->state = RUNNABLE;
80104485:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010448c:	83 e8 80             	sub    $0xffffff80,%eax
8010448f:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
80104494:	75 e4                	jne    8010447a <wakeup+0x2a>
  wakeup1(chan);
  release(&ptable.lock);
80104496:	c7 45 08 60 2d 11 80 	movl   $0x80112d60,0x8(%ebp)
}
8010449d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044a0:	c9                   	leave  
  release(&ptable.lock);
801044a1:	e9 3a 04 00 00       	jmp    801048e0 <release>
801044a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801044ad:	8d 76 00             	lea    0x0(%esi),%esi

801044b0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801044b0:	55                   	push   %ebp
801044b1:	89 e5                	mov    %esp,%ebp
801044b3:	53                   	push   %ebx
801044b4:	83 ec 10             	sub    $0x10,%esp
801044b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801044ba:	68 60 2d 11 80       	push   $0x80112d60
801044bf:	e8 7c 04 00 00       	call   80104940 <acquire>
801044c4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044c7:	b8 94 2d 11 80       	mov    $0x80112d94,%eax
801044cc:	eb 0c                	jmp    801044da <kill+0x2a>
801044ce:	66 90                	xchg   %ax,%ax
801044d0:	83 e8 80             	sub    $0xffffff80,%eax
801044d3:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
801044d8:	74 36                	je     80104510 <kill+0x60>
    if(p->pid == pid){
801044da:	39 58 14             	cmp    %ebx,0x14(%eax)
801044dd:	75 f1                	jne    801044d0 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801044df:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
      p->killed = 1;
801044e3:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      if(p->state == SLEEPING)
801044ea:	75 07                	jne    801044f3 <kill+0x43>
        p->state = RUNNABLE;
801044ec:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
      release(&ptable.lock);
801044f3:	83 ec 0c             	sub    $0xc,%esp
801044f6:	68 60 2d 11 80       	push   $0x80112d60
801044fb:	e8 e0 03 00 00       	call   801048e0 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
80104500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0;
80104503:	83 c4 10             	add    $0x10,%esp
80104506:	31 c0                	xor    %eax,%eax
}
80104508:	c9                   	leave  
80104509:	c3                   	ret    
8010450a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
80104510:	83 ec 0c             	sub    $0xc,%esp
80104513:	68 60 2d 11 80       	push   $0x80112d60
80104518:	e8 c3 03 00 00       	call   801048e0 <release>
}
8010451d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80104520:	83 c4 10             	add    $0x10,%esp
80104523:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104528:	c9                   	leave  
80104529:	c3                   	ret    
8010452a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104530 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104530:	55                   	push   %ebp
80104531:	89 e5                	mov    %esp,%ebp
80104533:	57                   	push   %edi
80104534:	56                   	push   %esi
80104535:	8d 75 e8             	lea    -0x18(%ebp),%esi
80104538:	53                   	push   %ebx
80104539:	bb 04 2e 11 80       	mov    $0x80112e04,%ebx
8010453e:	83 ec 3c             	sub    $0x3c,%esp
80104541:	eb 24                	jmp    80104567 <procdump+0x37>
80104543:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104547:	90                   	nop
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104548:	83 ec 0c             	sub    $0xc,%esp
8010454b:	68 7b 83 10 80       	push   $0x8010837b
80104550:	e8 7b c2 ff ff       	call   801007d0 <cprintf>
80104555:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104558:	83 eb 80             	sub    $0xffffff80,%ebx
8010455b:	81 fb 04 4e 11 80    	cmp    $0x80114e04,%ebx
80104561:	0f 84 81 00 00 00    	je     801045e8 <procdump+0xb8>
    if(p->state == UNUSED)
80104567:	8b 43 a0             	mov    -0x60(%ebx),%eax
8010456a:	85 c0                	test   %eax,%eax
8010456c:	74 ea                	je     80104558 <procdump+0x28>
      state = "???";
8010456e:	ba 78 7f 10 80       	mov    $0x80107f78,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104573:	83 f8 05             	cmp    $0x5,%eax
80104576:	77 11                	ja     80104589 <procdump+0x59>
80104578:	8b 14 85 fc 7f 10 80 	mov    -0x7fef8004(,%eax,4),%edx
      state = "???";
8010457f:	b8 78 7f 10 80       	mov    $0x80107f78,%eax
80104584:	85 d2                	test   %edx,%edx
80104586:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
80104589:	53                   	push   %ebx
8010458a:	52                   	push   %edx
8010458b:	ff 73 a4             	push   -0x5c(%ebx)
8010458e:	68 7c 7f 10 80       	push   $0x80107f7c
80104593:	e8 38 c2 ff ff       	call   801007d0 <cprintf>
    if(p->state == SLEEPING){
80104598:	83 c4 10             	add    $0x10,%esp
8010459b:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
8010459f:	75 a7                	jne    80104548 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801045a1:	83 ec 08             	sub    $0x8,%esp
801045a4:	8d 45 c0             	lea    -0x40(%ebp),%eax
801045a7:	8d 7d c0             	lea    -0x40(%ebp),%edi
801045aa:	50                   	push   %eax
801045ab:	8b 43 b0             	mov    -0x50(%ebx),%eax
801045ae:	8b 40 0c             	mov    0xc(%eax),%eax
801045b1:	83 c0 08             	add    $0x8,%eax
801045b4:	50                   	push   %eax
801045b5:	e8 d6 01 00 00       	call   80104790 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801045ba:	83 c4 10             	add    $0x10,%esp
801045bd:	8d 76 00             	lea    0x0(%esi),%esi
801045c0:	8b 17                	mov    (%edi),%edx
801045c2:	85 d2                	test   %edx,%edx
801045c4:	74 82                	je     80104548 <procdump+0x18>
        cprintf(" %p", pc[i]);
801045c6:	83 ec 08             	sub    $0x8,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801045c9:	83 c7 04             	add    $0x4,%edi
        cprintf(" %p", pc[i]);
801045cc:	52                   	push   %edx
801045cd:	68 a1 79 10 80       	push   $0x801079a1
801045d2:	e8 f9 c1 ff ff       	call   801007d0 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801045d7:	83 c4 10             	add    $0x10,%esp
801045da:	39 fe                	cmp    %edi,%esi
801045dc:	75 e2                	jne    801045c0 <procdump+0x90>
801045de:	e9 65 ff ff ff       	jmp    80104548 <procdump+0x18>
801045e3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801045e7:	90                   	nop
  }
}
801045e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801045eb:	5b                   	pop    %ebx
801045ec:	5e                   	pop    %esi
801045ed:	5f                   	pop    %edi
801045ee:	5d                   	pop    %ebp
801045ef:	c3                   	ret    

801045f0 <victim_pgdir>:
// Missed the case when two processes have same rss value
pde_t* victim_pgdir(){
801045f0:	55                   	push   %ebp
  uint max_rss=0;
  struct proc *q  = ptable.proc;
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045f1:	b8 94 2d 11 80       	mov    $0x80112d94,%eax
  uint max_rss=0;
801045f6:	31 c9                	xor    %ecx,%ecx
pde_t* victim_pgdir(){
801045f8:	89 e5                	mov    %esp,%ebp
801045fa:	53                   	push   %ebx
  struct proc *q  = ptable.proc;
801045fb:	89 c3                	mov    %eax,%ebx
801045fd:	eb 16                	jmp    80104615 <victim_pgdir+0x25>
801045ff:	90                   	nop
    if(p->rss > max_rss){
      q=p;
      max_rss= p->rss;
    }
    // Added the case here
    else if(p->rss == max_rss){
80104600:	75 09                	jne    8010460b <victim_pgdir+0x1b>
      if(p->pid < q->pid){
80104602:	8b 53 14             	mov    0x14(%ebx),%edx
80104605:	39 50 14             	cmp    %edx,0x14(%eax)
80104608:	0f 4c d8             	cmovl  %eax,%ebx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010460b:	83 e8 80             	sub    $0xffffff80,%eax
8010460e:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
80104613:	74 15                	je     8010462a <victim_pgdir+0x3a>
    if(p->rss > max_rss){
80104615:	8b 50 04             	mov    0x4(%eax),%edx
80104618:	39 ca                	cmp    %ecx,%edx
8010461a:	76 e4                	jbe    80104600 <victim_pgdir+0x10>
8010461c:	89 c3                	mov    %eax,%ebx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010461e:	83 e8 80             	sub    $0xffffff80,%eax
80104621:	89 d1                	mov    %edx,%ecx
80104623:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
80104628:	75 eb                	jne    80104615 <victim_pgdir+0x25>
        q=p;
      }
    }
  }
  q->rss-=PGSIZE;
  return q->pgdir;
8010462a:	8b 43 08             	mov    0x8(%ebx),%eax
  q->rss-=PGSIZE;
8010462d:	81 6b 04 00 10 00 00 	subl   $0x1000,0x4(%ebx)
}
80104634:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104637:	c9                   	leave  
80104638:	c3                   	ret    
80104639:	66 90                	xchg   %ax,%ax
8010463b:	66 90                	xchg   %ax,%ax
8010463d:	66 90                	xchg   %ax,%ax
8010463f:	90                   	nop

80104640 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104640:	55                   	push   %ebp
80104641:	89 e5                	mov    %esp,%ebp
80104643:	53                   	push   %ebx
80104644:	83 ec 0c             	sub    $0xc,%esp
80104647:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010464a:	68 14 80 10 80       	push   $0x80108014
8010464f:	8d 43 04             	lea    0x4(%ebx),%eax
80104652:	50                   	push   %eax
80104653:	e8 18 01 00 00       	call   80104770 <initlock>
  lk->name = name;
80104658:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
8010465b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
80104661:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
80104664:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
8010466b:	89 43 38             	mov    %eax,0x38(%ebx)
}
8010466e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104671:	c9                   	leave  
80104672:	c3                   	ret    
80104673:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010467a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104680 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104680:	55                   	push   %ebp
80104681:	89 e5                	mov    %esp,%ebp
80104683:	56                   	push   %esi
80104684:	53                   	push   %ebx
80104685:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104688:	8d 73 04             	lea    0x4(%ebx),%esi
8010468b:	83 ec 0c             	sub    $0xc,%esp
8010468e:	56                   	push   %esi
8010468f:	e8 ac 02 00 00       	call   80104940 <acquire>
  while (lk->locked) {
80104694:	8b 13                	mov    (%ebx),%edx
80104696:	83 c4 10             	add    $0x10,%esp
80104699:	85 d2                	test   %edx,%edx
8010469b:	74 16                	je     801046b3 <acquiresleep+0x33>
8010469d:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
801046a0:	83 ec 08             	sub    $0x8,%esp
801046a3:	56                   	push   %esi
801046a4:	53                   	push   %ebx
801046a5:	e8 e6 fc ff ff       	call   80104390 <sleep>
  while (lk->locked) {
801046aa:	8b 03                	mov    (%ebx),%eax
801046ac:	83 c4 10             	add    $0x10,%esp
801046af:	85 c0                	test   %eax,%eax
801046b1:	75 ed                	jne    801046a0 <acquiresleep+0x20>
  }
  lk->locked = 1;
801046b3:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
801046b9:	e8 92 f5 ff ff       	call   80103c50 <myproc>
801046be:	8b 40 14             	mov    0x14(%eax),%eax
801046c1:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
801046c4:	89 75 08             	mov    %esi,0x8(%ebp)
}
801046c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801046ca:	5b                   	pop    %ebx
801046cb:	5e                   	pop    %esi
801046cc:	5d                   	pop    %ebp
  release(&lk->lk);
801046cd:	e9 0e 02 00 00       	jmp    801048e0 <release>
801046d2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801046d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801046e0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801046e0:	55                   	push   %ebp
801046e1:	89 e5                	mov    %esp,%ebp
801046e3:	56                   	push   %esi
801046e4:	53                   	push   %ebx
801046e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801046e8:	8d 73 04             	lea    0x4(%ebx),%esi
801046eb:	83 ec 0c             	sub    $0xc,%esp
801046ee:	56                   	push   %esi
801046ef:	e8 4c 02 00 00       	call   80104940 <acquire>
  lk->locked = 0;
801046f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801046fa:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104701:	89 1c 24             	mov    %ebx,(%esp)
80104704:	e8 47 fd ff ff       	call   80104450 <wakeup>
  release(&lk->lk);
80104709:	89 75 08             	mov    %esi,0x8(%ebp)
8010470c:	83 c4 10             	add    $0x10,%esp
}
8010470f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104712:	5b                   	pop    %ebx
80104713:	5e                   	pop    %esi
80104714:	5d                   	pop    %ebp
  release(&lk->lk);
80104715:	e9 c6 01 00 00       	jmp    801048e0 <release>
8010471a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104720 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104720:	55                   	push   %ebp
80104721:	89 e5                	mov    %esp,%ebp
80104723:	57                   	push   %edi
80104724:	31 ff                	xor    %edi,%edi
80104726:	56                   	push   %esi
80104727:	53                   	push   %ebx
80104728:	83 ec 18             	sub    $0x18,%esp
8010472b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
8010472e:	8d 73 04             	lea    0x4(%ebx),%esi
80104731:	56                   	push   %esi
80104732:	e8 09 02 00 00       	call   80104940 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80104737:	8b 03                	mov    (%ebx),%eax
80104739:	83 c4 10             	add    $0x10,%esp
8010473c:	85 c0                	test   %eax,%eax
8010473e:	75 18                	jne    80104758 <holdingsleep+0x38>
  release(&lk->lk);
80104740:	83 ec 0c             	sub    $0xc,%esp
80104743:	56                   	push   %esi
80104744:	e8 97 01 00 00       	call   801048e0 <release>
  return r;
}
80104749:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010474c:	89 f8                	mov    %edi,%eax
8010474e:	5b                   	pop    %ebx
8010474f:	5e                   	pop    %esi
80104750:	5f                   	pop    %edi
80104751:	5d                   	pop    %ebp
80104752:	c3                   	ret    
80104753:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104757:	90                   	nop
  r = lk->locked && (lk->pid == myproc()->pid);
80104758:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
8010475b:	e8 f0 f4 ff ff       	call   80103c50 <myproc>
80104760:	39 58 14             	cmp    %ebx,0x14(%eax)
80104763:	0f 94 c0             	sete   %al
80104766:	0f b6 c0             	movzbl %al,%eax
80104769:	89 c7                	mov    %eax,%edi
8010476b:	eb d3                	jmp    80104740 <holdingsleep+0x20>
8010476d:	66 90                	xchg   %ax,%ax
8010476f:	90                   	nop

80104770 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104770:	55                   	push   %ebp
80104771:	89 e5                	mov    %esp,%ebp
80104773:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104776:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
80104779:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
8010477f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
80104782:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104789:	5d                   	pop    %ebp
8010478a:	c3                   	ret    
8010478b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010478f:	90                   	nop

80104790 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104790:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104791:	31 d2                	xor    %edx,%edx
{
80104793:	89 e5                	mov    %esp,%ebp
80104795:	53                   	push   %ebx
  ebp = (uint*)v - 2;
80104796:	8b 45 08             	mov    0x8(%ebp),%eax
{
80104799:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
8010479c:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
8010479f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801047a0:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
801047a6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801047ac:	77 1a                	ja     801047c8 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
801047ae:	8b 58 04             	mov    0x4(%eax),%ebx
801047b1:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
801047b4:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
801047b7:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
801047b9:	83 fa 0a             	cmp    $0xa,%edx
801047bc:	75 e2                	jne    801047a0 <getcallerpcs+0x10>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
801047be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801047c1:	c9                   	leave  
801047c2:	c3                   	ret    
801047c3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801047c7:	90                   	nop
  for(; i < 10; i++)
801047c8:	8d 04 91             	lea    (%ecx,%edx,4),%eax
801047cb:	8d 51 28             	lea    0x28(%ecx),%edx
801047ce:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
801047d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801047d6:	83 c0 04             	add    $0x4,%eax
801047d9:	39 d0                	cmp    %edx,%eax
801047db:	75 f3                	jne    801047d0 <getcallerpcs+0x40>
}
801047dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801047e0:	c9                   	leave  
801047e1:	c3                   	ret    
801047e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801047e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801047f0 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801047f0:	55                   	push   %ebp
801047f1:	89 e5                	mov    %esp,%ebp
801047f3:	53                   	push   %ebx
801047f4:	83 ec 04             	sub    $0x4,%esp
801047f7:	9c                   	pushf  
801047f8:	5b                   	pop    %ebx
  asm volatile("cli");
801047f9:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
801047fa:	e8 d1 f3 ff ff       	call   80103bd0 <mycpu>
801047ff:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104805:	85 c0                	test   %eax,%eax
80104807:	74 17                	je     80104820 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80104809:	e8 c2 f3 ff ff       	call   80103bd0 <mycpu>
8010480e:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80104815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104818:	c9                   	leave  
80104819:	c3                   	ret    
8010481a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    mycpu()->intena = eflags & FL_IF;
80104820:	e8 ab f3 ff ff       	call   80103bd0 <mycpu>
80104825:	81 e3 00 02 00 00    	and    $0x200,%ebx
8010482b:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80104831:	eb d6                	jmp    80104809 <pushcli+0x19>
80104833:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010483a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104840 <popcli>:

void
popcli(void)
{
80104840:	55                   	push   %ebp
80104841:	89 e5                	mov    %esp,%ebp
80104843:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104846:	9c                   	pushf  
80104847:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104848:	f6 c4 02             	test   $0x2,%ah
8010484b:	75 35                	jne    80104882 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
8010484d:	e8 7e f3 ff ff       	call   80103bd0 <mycpu>
80104852:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
80104859:	78 34                	js     8010488f <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010485b:	e8 70 f3 ff ff       	call   80103bd0 <mycpu>
80104860:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104866:	85 d2                	test   %edx,%edx
80104868:	74 06                	je     80104870 <popcli+0x30>
    sti();
}
8010486a:	c9                   	leave  
8010486b:	c3                   	ret    
8010486c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104870:	e8 5b f3 ff ff       	call   80103bd0 <mycpu>
80104875:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010487b:	85 c0                	test   %eax,%eax
8010487d:	74 eb                	je     8010486a <popcli+0x2a>
  asm volatile("sti");
8010487f:	fb                   	sti    
}
80104880:	c9                   	leave  
80104881:	c3                   	ret    
    panic("popcli - interruptible");
80104882:	83 ec 0c             	sub    $0xc,%esp
80104885:	68 1f 80 10 80       	push   $0x8010801f
8010488a:	e8 21 bc ff ff       	call   801004b0 <panic>
    panic("popcli");
8010488f:	83 ec 0c             	sub    $0xc,%esp
80104892:	68 36 80 10 80       	push   $0x80108036
80104897:	e8 14 bc ff ff       	call   801004b0 <panic>
8010489c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801048a0 <holding>:
{
801048a0:	55                   	push   %ebp
801048a1:	89 e5                	mov    %esp,%ebp
801048a3:	56                   	push   %esi
801048a4:	53                   	push   %ebx
801048a5:	8b 75 08             	mov    0x8(%ebp),%esi
801048a8:	31 db                	xor    %ebx,%ebx
  pushcli();
801048aa:	e8 41 ff ff ff       	call   801047f0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801048af:	8b 06                	mov    (%esi),%eax
801048b1:	85 c0                	test   %eax,%eax
801048b3:	75 0b                	jne    801048c0 <holding+0x20>
  popcli();
801048b5:	e8 86 ff ff ff       	call   80104840 <popcli>
}
801048ba:	89 d8                	mov    %ebx,%eax
801048bc:	5b                   	pop    %ebx
801048bd:	5e                   	pop    %esi
801048be:	5d                   	pop    %ebp
801048bf:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
801048c0:	8b 5e 08             	mov    0x8(%esi),%ebx
801048c3:	e8 08 f3 ff ff       	call   80103bd0 <mycpu>
801048c8:	39 c3                	cmp    %eax,%ebx
801048ca:	0f 94 c3             	sete   %bl
  popcli();
801048cd:	e8 6e ff ff ff       	call   80104840 <popcli>
  r = lock->locked && lock->cpu == mycpu();
801048d2:	0f b6 db             	movzbl %bl,%ebx
}
801048d5:	89 d8                	mov    %ebx,%eax
801048d7:	5b                   	pop    %ebx
801048d8:	5e                   	pop    %esi
801048d9:	5d                   	pop    %ebp
801048da:	c3                   	ret    
801048db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801048df:	90                   	nop

801048e0 <release>:
{
801048e0:	55                   	push   %ebp
801048e1:	89 e5                	mov    %esp,%ebp
801048e3:	56                   	push   %esi
801048e4:	53                   	push   %ebx
801048e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
801048e8:	e8 03 ff ff ff       	call   801047f0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801048ed:	8b 03                	mov    (%ebx),%eax
801048ef:	85 c0                	test   %eax,%eax
801048f1:	75 15                	jne    80104908 <release+0x28>
  popcli();
801048f3:	e8 48 ff ff ff       	call   80104840 <popcli>
    panic("release");
801048f8:	83 ec 0c             	sub    $0xc,%esp
801048fb:	68 3d 80 10 80       	push   $0x8010803d
80104900:	e8 ab bb ff ff       	call   801004b0 <panic>
80104905:	8d 76 00             	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80104908:	8b 73 08             	mov    0x8(%ebx),%esi
8010490b:	e8 c0 f2 ff ff       	call   80103bd0 <mycpu>
80104910:	39 c6                	cmp    %eax,%esi
80104912:	75 df                	jne    801048f3 <release+0x13>
  popcli();
80104914:	e8 27 ff ff ff       	call   80104840 <popcli>
  lk->pcs[0] = 0;
80104919:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104920:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80104927:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010492c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
80104932:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104935:	5b                   	pop    %ebx
80104936:	5e                   	pop    %esi
80104937:	5d                   	pop    %ebp
  popcli();
80104938:	e9 03 ff ff ff       	jmp    80104840 <popcli>
8010493d:	8d 76 00             	lea    0x0(%esi),%esi

80104940 <acquire>:
{
80104940:	55                   	push   %ebp
80104941:	89 e5                	mov    %esp,%ebp
80104943:	53                   	push   %ebx
80104944:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104947:	e8 a4 fe ff ff       	call   801047f0 <pushcli>
  if(holding(lk))
8010494c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
8010494f:	e8 9c fe ff ff       	call   801047f0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104954:	8b 03                	mov    (%ebx),%eax
80104956:	85 c0                	test   %eax,%eax
80104958:	75 7e                	jne    801049d8 <acquire+0x98>
  popcli();
8010495a:	e8 e1 fe ff ff       	call   80104840 <popcli>
  asm volatile("lock; xchgl %0, %1" :
8010495f:	b9 01 00 00 00       	mov    $0x1,%ecx
80104964:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(xchg(&lk->locked, 1) != 0)
80104968:	8b 55 08             	mov    0x8(%ebp),%edx
8010496b:	89 c8                	mov    %ecx,%eax
8010496d:	f0 87 02             	lock xchg %eax,(%edx)
80104970:	85 c0                	test   %eax,%eax
80104972:	75 f4                	jne    80104968 <acquire+0x28>
  __sync_synchronize();
80104974:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104979:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010497c:	e8 4f f2 ff ff       	call   80103bd0 <mycpu>
  getcallerpcs(&lk, lk->pcs);
80104981:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ebp = (uint*)v - 2;
80104984:	89 ea                	mov    %ebp,%edx
  lk->cpu = mycpu();
80104986:	89 43 08             	mov    %eax,0x8(%ebx)
  for(i = 0; i < 10; i++){
80104989:	31 c0                	xor    %eax,%eax
8010498b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010498f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104990:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80104996:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
8010499c:	77 1a                	ja     801049b8 <acquire+0x78>
    pcs[i] = ebp[1];     // saved %eip
8010499e:	8b 5a 04             	mov    0x4(%edx),%ebx
801049a1:	89 5c 81 0c          	mov    %ebx,0xc(%ecx,%eax,4)
  for(i = 0; i < 10; i++){
801049a5:	83 c0 01             	add    $0x1,%eax
    ebp = (uint*)ebp[0]; // saved %ebp
801049a8:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
801049aa:	83 f8 0a             	cmp    $0xa,%eax
801049ad:	75 e1                	jne    80104990 <acquire+0x50>
}
801049af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049b2:	c9                   	leave  
801049b3:	c3                   	ret    
801049b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(; i < 10; i++)
801049b8:	8d 44 81 0c          	lea    0xc(%ecx,%eax,4),%eax
801049bc:	8d 51 34             	lea    0x34(%ecx),%edx
801049bf:	90                   	nop
    pcs[i] = 0;
801049c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801049c6:	83 c0 04             	add    $0x4,%eax
801049c9:	39 c2                	cmp    %eax,%edx
801049cb:	75 f3                	jne    801049c0 <acquire+0x80>
}
801049cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049d0:	c9                   	leave  
801049d1:	c3                   	ret    
801049d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
801049d8:	8b 5b 08             	mov    0x8(%ebx),%ebx
801049db:	e8 f0 f1 ff ff       	call   80103bd0 <mycpu>
801049e0:	39 c3                	cmp    %eax,%ebx
801049e2:	0f 85 72 ff ff ff    	jne    8010495a <acquire+0x1a>
  popcli();
801049e8:	e8 53 fe ff ff       	call   80104840 <popcli>
    panic("acquire");
801049ed:	83 ec 0c             	sub    $0xc,%esp
801049f0:	68 45 80 10 80       	push   $0x80108045
801049f5:	e8 b6 ba ff ff       	call   801004b0 <panic>
801049fa:	66 90                	xchg   %ax,%ax
801049fc:	66 90                	xchg   %ax,%ax
801049fe:	66 90                	xchg   %ax,%ax

80104a00 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104a00:	55                   	push   %ebp
80104a01:	89 e5                	mov    %esp,%ebp
80104a03:	57                   	push   %edi
80104a04:	8b 55 08             	mov    0x8(%ebp),%edx
80104a07:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104a0a:	53                   	push   %ebx
80104a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
80104a0e:	89 d7                	mov    %edx,%edi
80104a10:	09 cf                	or     %ecx,%edi
80104a12:	83 e7 03             	and    $0x3,%edi
80104a15:	75 29                	jne    80104a40 <memset+0x40>
    c &= 0xFF;
80104a17:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104a1a:	c1 e0 18             	shl    $0x18,%eax
80104a1d:	89 fb                	mov    %edi,%ebx
80104a1f:	c1 e9 02             	shr    $0x2,%ecx
80104a22:	c1 e3 10             	shl    $0x10,%ebx
80104a25:	09 d8                	or     %ebx,%eax
80104a27:	09 f8                	or     %edi,%eax
80104a29:	c1 e7 08             	shl    $0x8,%edi
80104a2c:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104a2e:	89 d7                	mov    %edx,%edi
80104a30:	fc                   	cld    
80104a31:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80104a33:	5b                   	pop    %ebx
80104a34:	89 d0                	mov    %edx,%eax
80104a36:	5f                   	pop    %edi
80104a37:	5d                   	pop    %ebp
80104a38:	c3                   	ret    
80104a39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("cld; rep stosb" :
80104a40:	89 d7                	mov    %edx,%edi
80104a42:	fc                   	cld    
80104a43:	f3 aa                	rep stos %al,%es:(%edi)
80104a45:	5b                   	pop    %ebx
80104a46:	89 d0                	mov    %edx,%eax
80104a48:	5f                   	pop    %edi
80104a49:	5d                   	pop    %ebp
80104a4a:	c3                   	ret    
80104a4b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a4f:	90                   	nop

80104a50 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104a50:	55                   	push   %ebp
80104a51:	89 e5                	mov    %esp,%ebp
80104a53:	56                   	push   %esi
80104a54:	8b 75 10             	mov    0x10(%ebp),%esi
80104a57:	8b 55 08             	mov    0x8(%ebp),%edx
80104a5a:	53                   	push   %ebx
80104a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104a5e:	85 f6                	test   %esi,%esi
80104a60:	74 2e                	je     80104a90 <memcmp+0x40>
80104a62:	01 c6                	add    %eax,%esi
80104a64:	eb 14                	jmp    80104a7a <memcmp+0x2a>
80104a66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a6d:	8d 76 00             	lea    0x0(%esi),%esi
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104a70:	83 c0 01             	add    $0x1,%eax
80104a73:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104a76:	39 f0                	cmp    %esi,%eax
80104a78:	74 16                	je     80104a90 <memcmp+0x40>
    if(*s1 != *s2)
80104a7a:	0f b6 0a             	movzbl (%edx),%ecx
80104a7d:	0f b6 18             	movzbl (%eax),%ebx
80104a80:	38 d9                	cmp    %bl,%cl
80104a82:	74 ec                	je     80104a70 <memcmp+0x20>
      return *s1 - *s2;
80104a84:	0f b6 c1             	movzbl %cl,%eax
80104a87:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104a89:	5b                   	pop    %ebx
80104a8a:	5e                   	pop    %esi
80104a8b:	5d                   	pop    %ebp
80104a8c:	c3                   	ret    
80104a8d:	8d 76 00             	lea    0x0(%esi),%esi
80104a90:	5b                   	pop    %ebx
  return 0;
80104a91:	31 c0                	xor    %eax,%eax
}
80104a93:	5e                   	pop    %esi
80104a94:	5d                   	pop    %ebp
80104a95:	c3                   	ret    
80104a96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a9d:	8d 76 00             	lea    0x0(%esi),%esi

80104aa0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104aa0:	55                   	push   %ebp
80104aa1:	89 e5                	mov    %esp,%ebp
80104aa3:	57                   	push   %edi
80104aa4:	8b 55 08             	mov    0x8(%ebp),%edx
80104aa7:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104aaa:	56                   	push   %esi
80104aab:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104aae:	39 d6                	cmp    %edx,%esi
80104ab0:	73 26                	jae    80104ad8 <memmove+0x38>
80104ab2:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
80104ab5:	39 fa                	cmp    %edi,%edx
80104ab7:	73 1f                	jae    80104ad8 <memmove+0x38>
80104ab9:	8d 41 ff             	lea    -0x1(%ecx),%eax
    s += n;
    d += n;
    while(n-- > 0)
80104abc:	85 c9                	test   %ecx,%ecx
80104abe:	74 0c                	je     80104acc <memmove+0x2c>
      *--d = *--s;
80104ac0:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
80104ac4:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
80104ac7:	83 e8 01             	sub    $0x1,%eax
80104aca:	73 f4                	jae    80104ac0 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104acc:	5e                   	pop    %esi
80104acd:	89 d0                	mov    %edx,%eax
80104acf:	5f                   	pop    %edi
80104ad0:	5d                   	pop    %ebp
80104ad1:	c3                   	ret    
80104ad2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(n-- > 0)
80104ad8:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
80104adb:	89 d7                	mov    %edx,%edi
80104add:	85 c9                	test   %ecx,%ecx
80104adf:	74 eb                	je     80104acc <memmove+0x2c>
80104ae1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
80104ae8:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
80104ae9:	39 c6                	cmp    %eax,%esi
80104aeb:	75 fb                	jne    80104ae8 <memmove+0x48>
}
80104aed:	5e                   	pop    %esi
80104aee:	89 d0                	mov    %edx,%eax
80104af0:	5f                   	pop    %edi
80104af1:	5d                   	pop    %ebp
80104af2:	c3                   	ret    
80104af3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104afa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104b00 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80104b00:	eb 9e                	jmp    80104aa0 <memmove>
80104b02:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104b10 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104b10:	55                   	push   %ebp
80104b11:	89 e5                	mov    %esp,%ebp
80104b13:	56                   	push   %esi
80104b14:	8b 75 10             	mov    0x10(%ebp),%esi
80104b17:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b1a:	53                   	push   %ebx
80104b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(n > 0 && *p && *p == *q)
80104b1e:	85 f6                	test   %esi,%esi
80104b20:	74 2e                	je     80104b50 <strncmp+0x40>
80104b22:	01 d6                	add    %edx,%esi
80104b24:	eb 18                	jmp    80104b3e <strncmp+0x2e>
80104b26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b2d:	8d 76 00             	lea    0x0(%esi),%esi
80104b30:	38 d8                	cmp    %bl,%al
80104b32:	75 14                	jne    80104b48 <strncmp+0x38>
    n--, p++, q++;
80104b34:	83 c2 01             	add    $0x1,%edx
80104b37:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104b3a:	39 f2                	cmp    %esi,%edx
80104b3c:	74 12                	je     80104b50 <strncmp+0x40>
80104b3e:	0f b6 01             	movzbl (%ecx),%eax
80104b41:	0f b6 1a             	movzbl (%edx),%ebx
80104b44:	84 c0                	test   %al,%al
80104b46:	75 e8                	jne    80104b30 <strncmp+0x20>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
80104b48:	29 d8                	sub    %ebx,%eax
}
80104b4a:	5b                   	pop    %ebx
80104b4b:	5e                   	pop    %esi
80104b4c:	5d                   	pop    %ebp
80104b4d:	c3                   	ret    
80104b4e:	66 90                	xchg   %ax,%ax
80104b50:	5b                   	pop    %ebx
    return 0;
80104b51:	31 c0                	xor    %eax,%eax
}
80104b53:	5e                   	pop    %esi
80104b54:	5d                   	pop    %ebp
80104b55:	c3                   	ret    
80104b56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b5d:	8d 76 00             	lea    0x0(%esi),%esi

80104b60 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104b60:	55                   	push   %ebp
80104b61:	89 e5                	mov    %esp,%ebp
80104b63:	57                   	push   %edi
80104b64:	56                   	push   %esi
80104b65:	8b 75 08             	mov    0x8(%ebp),%esi
80104b68:	53                   	push   %ebx
80104b69:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104b6c:	89 f0                	mov    %esi,%eax
80104b6e:	eb 15                	jmp    80104b85 <strncpy+0x25>
80104b70:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104b74:	8b 7d 0c             	mov    0xc(%ebp),%edi
80104b77:	83 c0 01             	add    $0x1,%eax
80104b7a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
80104b7e:	88 50 ff             	mov    %dl,-0x1(%eax)
80104b81:	84 d2                	test   %dl,%dl
80104b83:	74 09                	je     80104b8e <strncpy+0x2e>
80104b85:	89 cb                	mov    %ecx,%ebx
80104b87:	83 e9 01             	sub    $0x1,%ecx
80104b8a:	85 db                	test   %ebx,%ebx
80104b8c:	7f e2                	jg     80104b70 <strncpy+0x10>
    ;
  while(n-- > 0)
80104b8e:	89 c2                	mov    %eax,%edx
80104b90:	85 c9                	test   %ecx,%ecx
80104b92:	7e 17                	jle    80104bab <strncpy+0x4b>
80104b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104b98:	83 c2 01             	add    $0x1,%edx
80104b9b:	89 c1                	mov    %eax,%ecx
80104b9d:	c6 42 ff 00          	movb   $0x0,-0x1(%edx)
  while(n-- > 0)
80104ba1:	29 d1                	sub    %edx,%ecx
80104ba3:	8d 4c 0b ff          	lea    -0x1(%ebx,%ecx,1),%ecx
80104ba7:	85 c9                	test   %ecx,%ecx
80104ba9:	7f ed                	jg     80104b98 <strncpy+0x38>
  return os;
}
80104bab:	5b                   	pop    %ebx
80104bac:	89 f0                	mov    %esi,%eax
80104bae:	5e                   	pop    %esi
80104baf:	5f                   	pop    %edi
80104bb0:	5d                   	pop    %ebp
80104bb1:	c3                   	ret    
80104bb2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104bc0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104bc0:	55                   	push   %ebp
80104bc1:	89 e5                	mov    %esp,%ebp
80104bc3:	56                   	push   %esi
80104bc4:	8b 55 10             	mov    0x10(%ebp),%edx
80104bc7:	8b 75 08             	mov    0x8(%ebp),%esi
80104bca:	53                   	push   %ebx
80104bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80104bce:	85 d2                	test   %edx,%edx
80104bd0:	7e 25                	jle    80104bf7 <safestrcpy+0x37>
80104bd2:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
80104bd6:	89 f2                	mov    %esi,%edx
80104bd8:	eb 16                	jmp    80104bf0 <safestrcpy+0x30>
80104bda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104be0:	0f b6 08             	movzbl (%eax),%ecx
80104be3:	83 c0 01             	add    $0x1,%eax
80104be6:	83 c2 01             	add    $0x1,%edx
80104be9:	88 4a ff             	mov    %cl,-0x1(%edx)
80104bec:	84 c9                	test   %cl,%cl
80104bee:	74 04                	je     80104bf4 <safestrcpy+0x34>
80104bf0:	39 d8                	cmp    %ebx,%eax
80104bf2:	75 ec                	jne    80104be0 <safestrcpy+0x20>
    ;
  *s = 0;
80104bf4:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80104bf7:	89 f0                	mov    %esi,%eax
80104bf9:	5b                   	pop    %ebx
80104bfa:	5e                   	pop    %esi
80104bfb:	5d                   	pop    %ebp
80104bfc:	c3                   	ret    
80104bfd:	8d 76 00             	lea    0x0(%esi),%esi

80104c00 <strlen>:

int
strlen(const char *s)
{
80104c00:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104c01:	31 c0                	xor    %eax,%eax
{
80104c03:	89 e5                	mov    %esp,%ebp
80104c05:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104c08:	80 3a 00             	cmpb   $0x0,(%edx)
80104c0b:	74 0c                	je     80104c19 <strlen+0x19>
80104c0d:	8d 76 00             	lea    0x0(%esi),%esi
80104c10:	83 c0 01             	add    $0x1,%eax
80104c13:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104c17:	75 f7                	jne    80104c10 <strlen+0x10>
    ;
  return n;
}
80104c19:	5d                   	pop    %ebp
80104c1a:	c3                   	ret    

80104c1b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104c1b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104c1f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104c23:	55                   	push   %ebp
  pushl %ebx
80104c24:	53                   	push   %ebx
  pushl %esi
80104c25:	56                   	push   %esi
  pushl %edi
80104c26:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104c27:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104c29:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80104c2b:	5f                   	pop    %edi
  popl %esi
80104c2c:	5e                   	pop    %esi
  popl %ebx
80104c2d:	5b                   	pop    %ebx
  popl %ebp
80104c2e:	5d                   	pop    %ebp
  ret
80104c2f:	c3                   	ret    

80104c30 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104c30:	55                   	push   %ebp
80104c31:	89 e5                	mov    %esp,%ebp
80104c33:	53                   	push   %ebx
80104c34:	83 ec 04             	sub    $0x4,%esp
80104c37:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80104c3a:	e8 11 f0 ff ff       	call   80103c50 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104c3f:	8b 00                	mov    (%eax),%eax
80104c41:	39 d8                	cmp    %ebx,%eax
80104c43:	76 1b                	jbe    80104c60 <fetchint+0x30>
80104c45:	8d 53 04             	lea    0x4(%ebx),%edx
80104c48:	39 d0                	cmp    %edx,%eax
80104c4a:	72 14                	jb     80104c60 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
80104c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c4f:	8b 13                	mov    (%ebx),%edx
80104c51:	89 10                	mov    %edx,(%eax)
  return 0;
80104c53:	31 c0                	xor    %eax,%eax
}
80104c55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c58:	c9                   	leave  
80104c59:	c3                   	ret    
80104c5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80104c60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c65:	eb ee                	jmp    80104c55 <fetchint+0x25>
80104c67:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c6e:	66 90                	xchg   %ax,%ax

80104c70 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104c70:	55                   	push   %ebp
80104c71:	89 e5                	mov    %esp,%ebp
80104c73:	53                   	push   %ebx
80104c74:	83 ec 04             	sub    $0x4,%esp
80104c77:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104c7a:	e8 d1 ef ff ff       	call   80103c50 <myproc>

  if(addr >= curproc->sz)
80104c7f:	39 18                	cmp    %ebx,(%eax)
80104c81:	76 2d                	jbe    80104cb0 <fetchstr+0x40>
    return -1;
  *pp = (char*)addr;
80104c83:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c86:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104c88:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104c8a:	39 d3                	cmp    %edx,%ebx
80104c8c:	73 22                	jae    80104cb0 <fetchstr+0x40>
80104c8e:	89 d8                	mov    %ebx,%eax
80104c90:	eb 0d                	jmp    80104c9f <fetchstr+0x2f>
80104c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104c98:	83 c0 01             	add    $0x1,%eax
80104c9b:	39 c2                	cmp    %eax,%edx
80104c9d:	76 11                	jbe    80104cb0 <fetchstr+0x40>
    if(*s == 0)
80104c9f:	80 38 00             	cmpb   $0x0,(%eax)
80104ca2:	75 f4                	jne    80104c98 <fetchstr+0x28>
      return s - *pp;
80104ca4:	29 d8                	sub    %ebx,%eax
  }
  return -1;
}
80104ca6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ca9:	c9                   	leave  
80104caa:	c3                   	ret    
80104cab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104caf:	90                   	nop
80104cb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return -1;
80104cb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cb8:	c9                   	leave  
80104cb9:	c3                   	ret    
80104cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104cc0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104cc0:	55                   	push   %ebp
80104cc1:	89 e5                	mov    %esp,%ebp
80104cc3:	56                   	push   %esi
80104cc4:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104cc5:	e8 86 ef ff ff       	call   80103c50 <myproc>
80104cca:	8b 55 08             	mov    0x8(%ebp),%edx
80104ccd:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cd0:	8b 40 44             	mov    0x44(%eax),%eax
80104cd3:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104cd6:	e8 75 ef ff ff       	call   80103c50 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104cdb:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104cde:	8b 00                	mov    (%eax),%eax
80104ce0:	39 c6                	cmp    %eax,%esi
80104ce2:	73 1c                	jae    80104d00 <argint+0x40>
80104ce4:	8d 53 08             	lea    0x8(%ebx),%edx
80104ce7:	39 d0                	cmp    %edx,%eax
80104ce9:	72 15                	jb     80104d00 <argint+0x40>
  *ip = *(int*)(addr);
80104ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cee:	8b 53 04             	mov    0x4(%ebx),%edx
80104cf1:	89 10                	mov    %edx,(%eax)
  return 0;
80104cf3:	31 c0                	xor    %eax,%eax
}
80104cf5:	5b                   	pop    %ebx
80104cf6:	5e                   	pop    %esi
80104cf7:	5d                   	pop    %ebp
80104cf8:	c3                   	ret    
80104cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104d00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104d05:	eb ee                	jmp    80104cf5 <argint+0x35>
80104d07:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d0e:	66 90                	xchg   %ax,%ax

80104d10 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104d10:	55                   	push   %ebp
80104d11:	89 e5                	mov    %esp,%ebp
80104d13:	57                   	push   %edi
80104d14:	56                   	push   %esi
80104d15:	53                   	push   %ebx
80104d16:	83 ec 0c             	sub    $0xc,%esp
  int i;
  struct proc *curproc = myproc();
80104d19:	e8 32 ef ff ff       	call   80103c50 <myproc>
80104d1e:	89 c6                	mov    %eax,%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104d20:	e8 2b ef ff ff       	call   80103c50 <myproc>
80104d25:	8b 55 08             	mov    0x8(%ebp),%edx
80104d28:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d2b:	8b 40 44             	mov    0x44(%eax),%eax
80104d2e:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104d31:	e8 1a ef ff ff       	call   80103c50 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104d36:	8d 7b 04             	lea    0x4(%ebx),%edi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104d39:	8b 00                	mov    (%eax),%eax
80104d3b:	39 c7                	cmp    %eax,%edi
80104d3d:	73 31                	jae    80104d70 <argptr+0x60>
80104d3f:	8d 4b 08             	lea    0x8(%ebx),%ecx
80104d42:	39 c8                	cmp    %ecx,%eax
80104d44:	72 2a                	jb     80104d70 <argptr+0x60>
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d46:	8b 55 10             	mov    0x10(%ebp),%edx
  *ip = *(int*)(addr);
80104d49:	8b 43 04             	mov    0x4(%ebx),%eax
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d4c:	85 d2                	test   %edx,%edx
80104d4e:	78 20                	js     80104d70 <argptr+0x60>
80104d50:	8b 16                	mov    (%esi),%edx
80104d52:	39 c2                	cmp    %eax,%edx
80104d54:	76 1a                	jbe    80104d70 <argptr+0x60>
80104d56:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104d59:	01 c3                	add    %eax,%ebx
80104d5b:	39 da                	cmp    %ebx,%edx
80104d5d:	72 11                	jb     80104d70 <argptr+0x60>
    return -1;
  *pp = (char*)i;
80104d5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d62:	89 02                	mov    %eax,(%edx)
  return 0;
80104d64:	31 c0                	xor    %eax,%eax
}
80104d66:	83 c4 0c             	add    $0xc,%esp
80104d69:	5b                   	pop    %ebx
80104d6a:	5e                   	pop    %esi
80104d6b:	5f                   	pop    %edi
80104d6c:	5d                   	pop    %ebp
80104d6d:	c3                   	ret    
80104d6e:	66 90                	xchg   %ax,%ax
    return -1;
80104d70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d75:	eb ef                	jmp    80104d66 <argptr+0x56>
80104d77:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d7e:	66 90                	xchg   %ax,%ax

80104d80 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104d80:	55                   	push   %ebp
80104d81:	89 e5                	mov    %esp,%ebp
80104d83:	56                   	push   %esi
80104d84:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104d85:	e8 c6 ee ff ff       	call   80103c50 <myproc>
80104d8a:	8b 55 08             	mov    0x8(%ebp),%edx
80104d8d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d90:	8b 40 44             	mov    0x44(%eax),%eax
80104d93:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104d96:	e8 b5 ee ff ff       	call   80103c50 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104d9b:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104d9e:	8b 00                	mov    (%eax),%eax
80104da0:	39 c6                	cmp    %eax,%esi
80104da2:	73 44                	jae    80104de8 <argstr+0x68>
80104da4:	8d 53 08             	lea    0x8(%ebx),%edx
80104da7:	39 d0                	cmp    %edx,%eax
80104da9:	72 3d                	jb     80104de8 <argstr+0x68>
  *ip = *(int*)(addr);
80104dab:	8b 5b 04             	mov    0x4(%ebx),%ebx
  struct proc *curproc = myproc();
80104dae:	e8 9d ee ff ff       	call   80103c50 <myproc>
  if(addr >= curproc->sz)
80104db3:	3b 18                	cmp    (%eax),%ebx
80104db5:	73 31                	jae    80104de8 <argstr+0x68>
  *pp = (char*)addr;
80104db7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104dba:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104dbc:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104dbe:	39 d3                	cmp    %edx,%ebx
80104dc0:	73 26                	jae    80104de8 <argstr+0x68>
80104dc2:	89 d8                	mov    %ebx,%eax
80104dc4:	eb 11                	jmp    80104dd7 <argstr+0x57>
80104dc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104dcd:	8d 76 00             	lea    0x0(%esi),%esi
80104dd0:	83 c0 01             	add    $0x1,%eax
80104dd3:	39 c2                	cmp    %eax,%edx
80104dd5:	76 11                	jbe    80104de8 <argstr+0x68>
    if(*s == 0)
80104dd7:	80 38 00             	cmpb   $0x0,(%eax)
80104dda:	75 f4                	jne    80104dd0 <argstr+0x50>
      return s - *pp;
80104ddc:	29 d8                	sub    %ebx,%eax
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}
80104dde:	5b                   	pop    %ebx
80104ddf:	5e                   	pop    %esi
80104de0:	5d                   	pop    %ebp
80104de1:	c3                   	ret    
80104de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104de8:	5b                   	pop    %ebx
    return -1;
80104de9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dee:	5e                   	pop    %esi
80104def:	5d                   	pop    %ebp
80104df0:	c3                   	ret    
80104df1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104df8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104dff:	90                   	nop

80104e00 <syscall>:
[SYS_getNumFreePages]   sys_getNumFreePages,
};

void
syscall(void)
{
80104e00:	55                   	push   %ebp
80104e01:	89 e5                	mov    %esp,%ebp
80104e03:	53                   	push   %ebx
80104e04:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104e07:	e8 44 ee ff ff       	call   80103c50 <myproc>
80104e0c:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104e0e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e11:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104e14:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e17:	83 fa 16             	cmp    $0x16,%edx
80104e1a:	77 24                	ja     80104e40 <syscall+0x40>
80104e1c:	8b 14 85 80 80 10 80 	mov    -0x7fef7f80(,%eax,4),%edx
80104e23:	85 d2                	test   %edx,%edx
80104e25:	74 19                	je     80104e40 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
80104e27:	ff d2                	call   *%edx
80104e29:	89 c2                	mov    %eax,%edx
80104e2b:	8b 43 1c             	mov    0x1c(%ebx),%eax
80104e2e:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104e31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e34:	c9                   	leave  
80104e35:	c3                   	ret    
80104e36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104e3d:	8d 76 00             	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
80104e40:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80104e41:	8d 43 70             	lea    0x70(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80104e44:	50                   	push   %eax
80104e45:	ff 73 14             	push   0x14(%ebx)
80104e48:	68 4d 80 10 80       	push   $0x8010804d
80104e4d:	e8 7e b9 ff ff       	call   801007d0 <cprintf>
    curproc->tf->eax = -1;
80104e52:	8b 43 1c             	mov    0x1c(%ebx),%eax
80104e55:	83 c4 10             	add    $0x10,%esp
80104e58:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
80104e5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e62:	c9                   	leave  
80104e63:	c3                   	ret    
80104e64:	66 90                	xchg   %ax,%ax
80104e66:	66 90                	xchg   %ax,%ax
80104e68:	66 90                	xchg   %ax,%ax
80104e6a:	66 90                	xchg   %ax,%ax
80104e6c:	66 90                	xchg   %ax,%ax
80104e6e:	66 90                	xchg   %ax,%ax

80104e70 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104e70:	55                   	push   %ebp
80104e71:	89 e5                	mov    %esp,%ebp
80104e73:	57                   	push   %edi
80104e74:	56                   	push   %esi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104e75:	8d 7d da             	lea    -0x26(%ebp),%edi
{
80104e78:	53                   	push   %ebx
80104e79:	83 ec 34             	sub    $0x34,%esp
80104e7c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104e7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
80104e82:	57                   	push   %edi
80104e83:	50                   	push   %eax
{
80104e84:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104e87:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  if((dp = nameiparent(path, name)) == 0)
80104e8a:	e8 91 d4 ff ff       	call   80102320 <nameiparent>
80104e8f:	83 c4 10             	add    $0x10,%esp
80104e92:	85 c0                	test   %eax,%eax
80104e94:	0f 84 46 01 00 00    	je     80104fe0 <create+0x170>
    return 0;
  ilock(dp);
80104e9a:	83 ec 0c             	sub    $0xc,%esp
80104e9d:	89 c3                	mov    %eax,%ebx
80104e9f:	50                   	push   %eax
80104ea0:	e8 3b cb ff ff       	call   801019e0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104ea5:	83 c4 0c             	add    $0xc,%esp
80104ea8:	6a 00                	push   $0x0
80104eaa:	57                   	push   %edi
80104eab:	53                   	push   %ebx
80104eac:	e8 8f d0 ff ff       	call   80101f40 <dirlookup>
80104eb1:	83 c4 10             	add    $0x10,%esp
80104eb4:	89 c6                	mov    %eax,%esi
80104eb6:	85 c0                	test   %eax,%eax
80104eb8:	74 56                	je     80104f10 <create+0xa0>
    iunlockput(dp);
80104eba:	83 ec 0c             	sub    $0xc,%esp
80104ebd:	53                   	push   %ebx
80104ebe:	e8 ad cd ff ff       	call   80101c70 <iunlockput>
    ilock(ip);
80104ec3:	89 34 24             	mov    %esi,(%esp)
80104ec6:	e8 15 cb ff ff       	call   801019e0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104ecb:	83 c4 10             	add    $0x10,%esp
80104ece:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104ed3:	75 1b                	jne    80104ef0 <create+0x80>
80104ed5:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
80104eda:	75 14                	jne    80104ef0 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104edc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104edf:	89 f0                	mov    %esi,%eax
80104ee1:	5b                   	pop    %ebx
80104ee2:	5e                   	pop    %esi
80104ee3:	5f                   	pop    %edi
80104ee4:	5d                   	pop    %ebp
80104ee5:	c3                   	ret    
80104ee6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104eed:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80104ef0:	83 ec 0c             	sub    $0xc,%esp
80104ef3:	56                   	push   %esi
    return 0;
80104ef4:	31 f6                	xor    %esi,%esi
    iunlockput(ip);
80104ef6:	e8 75 cd ff ff       	call   80101c70 <iunlockput>
    return 0;
80104efb:	83 c4 10             	add    $0x10,%esp
}
80104efe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f01:	89 f0                	mov    %esi,%eax
80104f03:	5b                   	pop    %ebx
80104f04:	5e                   	pop    %esi
80104f05:	5f                   	pop    %edi
80104f06:	5d                   	pop    %ebp
80104f07:	c3                   	ret    
80104f08:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f0f:	90                   	nop
  if((ip = ialloc(dp->dev, type)) == 0)
80104f10:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80104f14:	83 ec 08             	sub    $0x8,%esp
80104f17:	50                   	push   %eax
80104f18:	ff 33                	push   (%ebx)
80104f1a:	e8 51 c9 ff ff       	call   80101870 <ialloc>
80104f1f:	83 c4 10             	add    $0x10,%esp
80104f22:	89 c6                	mov    %eax,%esi
80104f24:	85 c0                	test   %eax,%eax
80104f26:	0f 84 cd 00 00 00    	je     80104ff9 <create+0x189>
  ilock(ip);
80104f2c:	83 ec 0c             	sub    $0xc,%esp
80104f2f:	50                   	push   %eax
80104f30:	e8 ab ca ff ff       	call   801019e0 <ilock>
  ip->major = major;
80104f35:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104f39:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
80104f3d:	0f b7 45 cc          	movzwl -0x34(%ebp),%eax
80104f41:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80104f45:	b8 01 00 00 00       	mov    $0x1,%eax
80104f4a:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
80104f4e:	89 34 24             	mov    %esi,(%esp)
80104f51:	e8 da c9 ff ff       	call   80101930 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104f56:	83 c4 10             	add    $0x10,%esp
80104f59:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104f5e:	74 30                	je     80104f90 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80104f60:	83 ec 04             	sub    $0x4,%esp
80104f63:	ff 76 04             	push   0x4(%esi)
80104f66:	57                   	push   %edi
80104f67:	53                   	push   %ebx
80104f68:	e8 d3 d2 ff ff       	call   80102240 <dirlink>
80104f6d:	83 c4 10             	add    $0x10,%esp
80104f70:	85 c0                	test   %eax,%eax
80104f72:	78 78                	js     80104fec <create+0x17c>
  iunlockput(dp);
80104f74:	83 ec 0c             	sub    $0xc,%esp
80104f77:	53                   	push   %ebx
80104f78:	e8 f3 cc ff ff       	call   80101c70 <iunlockput>
  return ip;
80104f7d:	83 c4 10             	add    $0x10,%esp
}
80104f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f83:	89 f0                	mov    %esi,%eax
80104f85:	5b                   	pop    %ebx
80104f86:	5e                   	pop    %esi
80104f87:	5f                   	pop    %edi
80104f88:	5d                   	pop    %ebp
80104f89:	c3                   	ret    
80104f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
80104f90:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
80104f93:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
80104f98:	53                   	push   %ebx
80104f99:	e8 92 c9 ff ff       	call   80101930 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104f9e:	83 c4 0c             	add    $0xc,%esp
80104fa1:	ff 76 04             	push   0x4(%esi)
80104fa4:	68 fc 80 10 80       	push   $0x801080fc
80104fa9:	56                   	push   %esi
80104faa:	e8 91 d2 ff ff       	call   80102240 <dirlink>
80104faf:	83 c4 10             	add    $0x10,%esp
80104fb2:	85 c0                	test   %eax,%eax
80104fb4:	78 18                	js     80104fce <create+0x15e>
80104fb6:	83 ec 04             	sub    $0x4,%esp
80104fb9:	ff 73 04             	push   0x4(%ebx)
80104fbc:	68 fb 80 10 80       	push   $0x801080fb
80104fc1:	56                   	push   %esi
80104fc2:	e8 79 d2 ff ff       	call   80102240 <dirlink>
80104fc7:	83 c4 10             	add    $0x10,%esp
80104fca:	85 c0                	test   %eax,%eax
80104fcc:	79 92                	jns    80104f60 <create+0xf0>
      panic("create dots");
80104fce:	83 ec 0c             	sub    $0xc,%esp
80104fd1:	68 ef 80 10 80       	push   $0x801080ef
80104fd6:	e8 d5 b4 ff ff       	call   801004b0 <panic>
80104fdb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104fdf:	90                   	nop
}
80104fe0:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80104fe3:	31 f6                	xor    %esi,%esi
}
80104fe5:	5b                   	pop    %ebx
80104fe6:	89 f0                	mov    %esi,%eax
80104fe8:	5e                   	pop    %esi
80104fe9:	5f                   	pop    %edi
80104fea:	5d                   	pop    %ebp
80104feb:	c3                   	ret    
    panic("create: dirlink");
80104fec:	83 ec 0c             	sub    $0xc,%esp
80104fef:	68 fe 80 10 80       	push   $0x801080fe
80104ff4:	e8 b7 b4 ff ff       	call   801004b0 <panic>
    panic("create: ialloc");
80104ff9:	83 ec 0c             	sub    $0xc,%esp
80104ffc:	68 e0 80 10 80       	push   $0x801080e0
80105001:	e8 aa b4 ff ff       	call   801004b0 <panic>
80105006:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010500d:	8d 76 00             	lea    0x0(%esi),%esi

80105010 <sys_dup>:
{
80105010:	55                   	push   %ebp
80105011:	89 e5                	mov    %esp,%ebp
80105013:	56                   	push   %esi
80105014:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105015:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105018:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010501b:	50                   	push   %eax
8010501c:	6a 00                	push   $0x0
8010501e:	e8 9d fc ff ff       	call   80104cc0 <argint>
80105023:	83 c4 10             	add    $0x10,%esp
80105026:	85 c0                	test   %eax,%eax
80105028:	78 36                	js     80105060 <sys_dup+0x50>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010502a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010502e:	77 30                	ja     80105060 <sys_dup+0x50>
80105030:	e8 1b ec ff ff       	call   80103c50 <myproc>
80105035:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105038:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
8010503c:	85 f6                	test   %esi,%esi
8010503e:	74 20                	je     80105060 <sys_dup+0x50>
  struct proc *curproc = myproc();
80105040:	e8 0b ec ff ff       	call   80103c50 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105045:	31 db                	xor    %ebx,%ebx
80105047:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010504e:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80105050:	8b 54 98 2c          	mov    0x2c(%eax,%ebx,4),%edx
80105054:	85 d2                	test   %edx,%edx
80105056:	74 18                	je     80105070 <sys_dup+0x60>
  for(fd = 0; fd < NOFILE; fd++){
80105058:	83 c3 01             	add    $0x1,%ebx
8010505b:	83 fb 10             	cmp    $0x10,%ebx
8010505e:	75 f0                	jne    80105050 <sys_dup+0x40>
}
80105060:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
80105063:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80105068:	89 d8                	mov    %ebx,%eax
8010506a:	5b                   	pop    %ebx
8010506b:	5e                   	pop    %esi
8010506c:	5d                   	pop    %ebp
8010506d:	c3                   	ret    
8010506e:	66 90                	xchg   %ax,%ax
  filedup(f);
80105070:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
80105073:	89 74 98 2c          	mov    %esi,0x2c(%eax,%ebx,4)
  filedup(f);
80105077:	56                   	push   %esi
80105078:	e8 53 bf ff ff       	call   80100fd0 <filedup>
  return fd;
8010507d:	83 c4 10             	add    $0x10,%esp
}
80105080:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105083:	89 d8                	mov    %ebx,%eax
80105085:	5b                   	pop    %ebx
80105086:	5e                   	pop    %esi
80105087:	5d                   	pop    %ebp
80105088:	c3                   	ret    
80105089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105090 <sys_read>:
{
80105090:	55                   	push   %ebp
80105091:	89 e5                	mov    %esp,%ebp
80105093:	56                   	push   %esi
80105094:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105095:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105098:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010509b:	53                   	push   %ebx
8010509c:	6a 00                	push   $0x0
8010509e:	e8 1d fc ff ff       	call   80104cc0 <argint>
801050a3:	83 c4 10             	add    $0x10,%esp
801050a6:	85 c0                	test   %eax,%eax
801050a8:	78 5e                	js     80105108 <sys_read+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801050aa:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801050ae:	77 58                	ja     80105108 <sys_read+0x78>
801050b0:	e8 9b eb ff ff       	call   80103c50 <myproc>
801050b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050b8:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
801050bc:	85 f6                	test   %esi,%esi
801050be:	74 48                	je     80105108 <sys_read+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801050c0:	83 ec 08             	sub    $0x8,%esp
801050c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050c6:	50                   	push   %eax
801050c7:	6a 02                	push   $0x2
801050c9:	e8 f2 fb ff ff       	call   80104cc0 <argint>
801050ce:	83 c4 10             	add    $0x10,%esp
801050d1:	85 c0                	test   %eax,%eax
801050d3:	78 33                	js     80105108 <sys_read+0x78>
801050d5:	83 ec 04             	sub    $0x4,%esp
801050d8:	ff 75 f0             	push   -0x10(%ebp)
801050db:	53                   	push   %ebx
801050dc:	6a 01                	push   $0x1
801050de:	e8 2d fc ff ff       	call   80104d10 <argptr>
801050e3:	83 c4 10             	add    $0x10,%esp
801050e6:	85 c0                	test   %eax,%eax
801050e8:	78 1e                	js     80105108 <sys_read+0x78>
  return fileread(f, p, n);
801050ea:	83 ec 04             	sub    $0x4,%esp
801050ed:	ff 75 f0             	push   -0x10(%ebp)
801050f0:	ff 75 f4             	push   -0xc(%ebp)
801050f3:	56                   	push   %esi
801050f4:	e8 57 c0 ff ff       	call   80101150 <fileread>
801050f9:	83 c4 10             	add    $0x10,%esp
}
801050fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801050ff:	5b                   	pop    %ebx
80105100:	5e                   	pop    %esi
80105101:	5d                   	pop    %ebp
80105102:	c3                   	ret    
80105103:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105107:	90                   	nop
    return -1;
80105108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010510d:	eb ed                	jmp    801050fc <sys_read+0x6c>
8010510f:	90                   	nop

80105110 <sys_write>:
{
80105110:	55                   	push   %ebp
80105111:	89 e5                	mov    %esp,%ebp
80105113:	56                   	push   %esi
80105114:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105115:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105118:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010511b:	53                   	push   %ebx
8010511c:	6a 00                	push   $0x0
8010511e:	e8 9d fb ff ff       	call   80104cc0 <argint>
80105123:	83 c4 10             	add    $0x10,%esp
80105126:	85 c0                	test   %eax,%eax
80105128:	78 5e                	js     80105188 <sys_write+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010512a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010512e:	77 58                	ja     80105188 <sys_write+0x78>
80105130:	e8 1b eb ff ff       	call   80103c50 <myproc>
80105135:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105138:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
8010513c:	85 f6                	test   %esi,%esi
8010513e:	74 48                	je     80105188 <sys_write+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105140:	83 ec 08             	sub    $0x8,%esp
80105143:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105146:	50                   	push   %eax
80105147:	6a 02                	push   $0x2
80105149:	e8 72 fb ff ff       	call   80104cc0 <argint>
8010514e:	83 c4 10             	add    $0x10,%esp
80105151:	85 c0                	test   %eax,%eax
80105153:	78 33                	js     80105188 <sys_write+0x78>
80105155:	83 ec 04             	sub    $0x4,%esp
80105158:	ff 75 f0             	push   -0x10(%ebp)
8010515b:	53                   	push   %ebx
8010515c:	6a 01                	push   $0x1
8010515e:	e8 ad fb ff ff       	call   80104d10 <argptr>
80105163:	83 c4 10             	add    $0x10,%esp
80105166:	85 c0                	test   %eax,%eax
80105168:	78 1e                	js     80105188 <sys_write+0x78>
  return filewrite(f, p, n);
8010516a:	83 ec 04             	sub    $0x4,%esp
8010516d:	ff 75 f0             	push   -0x10(%ebp)
80105170:	ff 75 f4             	push   -0xc(%ebp)
80105173:	56                   	push   %esi
80105174:	e8 67 c0 ff ff       	call   801011e0 <filewrite>
80105179:	83 c4 10             	add    $0x10,%esp
}
8010517c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010517f:	5b                   	pop    %ebx
80105180:	5e                   	pop    %esi
80105181:	5d                   	pop    %ebp
80105182:	c3                   	ret    
80105183:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105187:	90                   	nop
    return -1;
80105188:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010518d:	eb ed                	jmp    8010517c <sys_write+0x6c>
8010518f:	90                   	nop

80105190 <sys_close>:
{
80105190:	55                   	push   %ebp
80105191:	89 e5                	mov    %esp,%ebp
80105193:	56                   	push   %esi
80105194:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105195:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105198:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010519b:	50                   	push   %eax
8010519c:	6a 00                	push   $0x0
8010519e:	e8 1d fb ff ff       	call   80104cc0 <argint>
801051a3:	83 c4 10             	add    $0x10,%esp
801051a6:	85 c0                	test   %eax,%eax
801051a8:	78 3e                	js     801051e8 <sys_close+0x58>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801051aa:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801051ae:	77 38                	ja     801051e8 <sys_close+0x58>
801051b0:	e8 9b ea ff ff       	call   80103c50 <myproc>
801051b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051b8:	8d 5a 08             	lea    0x8(%edx),%ebx
801051bb:	8b 74 98 0c          	mov    0xc(%eax,%ebx,4),%esi
801051bf:	85 f6                	test   %esi,%esi
801051c1:	74 25                	je     801051e8 <sys_close+0x58>
  myproc()->ofile[fd] = 0;
801051c3:	e8 88 ea ff ff       	call   80103c50 <myproc>
  fileclose(f);
801051c8:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
801051cb:	c7 44 98 0c 00 00 00 	movl   $0x0,0xc(%eax,%ebx,4)
801051d2:	00 
  fileclose(f);
801051d3:	56                   	push   %esi
801051d4:	e8 47 be ff ff       	call   80101020 <fileclose>
  return 0;
801051d9:	83 c4 10             	add    $0x10,%esp
801051dc:	31 c0                	xor    %eax,%eax
}
801051de:	8d 65 f8             	lea    -0x8(%ebp),%esp
801051e1:	5b                   	pop    %ebx
801051e2:	5e                   	pop    %esi
801051e3:	5d                   	pop    %ebp
801051e4:	c3                   	ret    
801051e5:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
801051e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ed:	eb ef                	jmp    801051de <sys_close+0x4e>
801051ef:	90                   	nop

801051f0 <sys_fstat>:
{
801051f0:	55                   	push   %ebp
801051f1:	89 e5                	mov    %esp,%ebp
801051f3:	56                   	push   %esi
801051f4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
801051f5:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
801051f8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801051fb:	53                   	push   %ebx
801051fc:	6a 00                	push   $0x0
801051fe:	e8 bd fa ff ff       	call   80104cc0 <argint>
80105203:	83 c4 10             	add    $0x10,%esp
80105206:	85 c0                	test   %eax,%eax
80105208:	78 46                	js     80105250 <sys_fstat+0x60>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010520a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010520e:	77 40                	ja     80105250 <sys_fstat+0x60>
80105210:	e8 3b ea ff ff       	call   80103c50 <myproc>
80105215:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105218:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
8010521c:	85 f6                	test   %esi,%esi
8010521e:	74 30                	je     80105250 <sys_fstat+0x60>
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105220:	83 ec 04             	sub    $0x4,%esp
80105223:	6a 14                	push   $0x14
80105225:	53                   	push   %ebx
80105226:	6a 01                	push   $0x1
80105228:	e8 e3 fa ff ff       	call   80104d10 <argptr>
8010522d:	83 c4 10             	add    $0x10,%esp
80105230:	85 c0                	test   %eax,%eax
80105232:	78 1c                	js     80105250 <sys_fstat+0x60>
  return filestat(f, st);
80105234:	83 ec 08             	sub    $0x8,%esp
80105237:	ff 75 f4             	push   -0xc(%ebp)
8010523a:	56                   	push   %esi
8010523b:	e8 c0 be ff ff       	call   80101100 <filestat>
80105240:	83 c4 10             	add    $0x10,%esp
}
80105243:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105246:	5b                   	pop    %ebx
80105247:	5e                   	pop    %esi
80105248:	5d                   	pop    %ebp
80105249:	c3                   	ret    
8010524a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105250:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105255:	eb ec                	jmp    80105243 <sys_fstat+0x53>
80105257:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010525e:	66 90                	xchg   %ax,%ax

80105260 <sys_link>:
{
80105260:	55                   	push   %ebp
80105261:	89 e5                	mov    %esp,%ebp
80105263:	57                   	push   %edi
80105264:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105265:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105268:	53                   	push   %ebx
80105269:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010526c:	50                   	push   %eax
8010526d:	6a 00                	push   $0x0
8010526f:	e8 0c fb ff ff       	call   80104d80 <argstr>
80105274:	83 c4 10             	add    $0x10,%esp
80105277:	85 c0                	test   %eax,%eax
80105279:	0f 88 fb 00 00 00    	js     8010537a <sys_link+0x11a>
8010527f:	83 ec 08             	sub    $0x8,%esp
80105282:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105285:	50                   	push   %eax
80105286:	6a 01                	push   $0x1
80105288:	e8 f3 fa ff ff       	call   80104d80 <argstr>
8010528d:	83 c4 10             	add    $0x10,%esp
80105290:	85 c0                	test   %eax,%eax
80105292:	0f 88 e2 00 00 00    	js     8010537a <sys_link+0x11a>
  begin_op();
80105298:	e8 83 dd ff ff       	call   80103020 <begin_op>
  if((ip = namei(old)) == 0){
8010529d:	83 ec 0c             	sub    $0xc,%esp
801052a0:	ff 75 d4             	push   -0x2c(%ebp)
801052a3:	e8 58 d0 ff ff       	call   80102300 <namei>
801052a8:	83 c4 10             	add    $0x10,%esp
801052ab:	89 c3                	mov    %eax,%ebx
801052ad:	85 c0                	test   %eax,%eax
801052af:	0f 84 e4 00 00 00    	je     80105399 <sys_link+0x139>
  ilock(ip);
801052b5:	83 ec 0c             	sub    $0xc,%esp
801052b8:	50                   	push   %eax
801052b9:	e8 22 c7 ff ff       	call   801019e0 <ilock>
  if(ip->type == T_DIR){
801052be:	83 c4 10             	add    $0x10,%esp
801052c1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801052c6:	0f 84 b5 00 00 00    	je     80105381 <sys_link+0x121>
  iupdate(ip);
801052cc:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
801052cf:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
801052d4:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
801052d7:	53                   	push   %ebx
801052d8:	e8 53 c6 ff ff       	call   80101930 <iupdate>
  iunlock(ip);
801052dd:	89 1c 24             	mov    %ebx,(%esp)
801052e0:	e8 db c7 ff ff       	call   80101ac0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801052e5:	58                   	pop    %eax
801052e6:	5a                   	pop    %edx
801052e7:	57                   	push   %edi
801052e8:	ff 75 d0             	push   -0x30(%ebp)
801052eb:	e8 30 d0 ff ff       	call   80102320 <nameiparent>
801052f0:	83 c4 10             	add    $0x10,%esp
801052f3:	89 c6                	mov    %eax,%esi
801052f5:	85 c0                	test   %eax,%eax
801052f7:	74 5b                	je     80105354 <sys_link+0xf4>
  ilock(dp);
801052f9:	83 ec 0c             	sub    $0xc,%esp
801052fc:	50                   	push   %eax
801052fd:	e8 de c6 ff ff       	call   801019e0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105302:	8b 03                	mov    (%ebx),%eax
80105304:	83 c4 10             	add    $0x10,%esp
80105307:	39 06                	cmp    %eax,(%esi)
80105309:	75 3d                	jne    80105348 <sys_link+0xe8>
8010530b:	83 ec 04             	sub    $0x4,%esp
8010530e:	ff 73 04             	push   0x4(%ebx)
80105311:	57                   	push   %edi
80105312:	56                   	push   %esi
80105313:	e8 28 cf ff ff       	call   80102240 <dirlink>
80105318:	83 c4 10             	add    $0x10,%esp
8010531b:	85 c0                	test   %eax,%eax
8010531d:	78 29                	js     80105348 <sys_link+0xe8>
  iunlockput(dp);
8010531f:	83 ec 0c             	sub    $0xc,%esp
80105322:	56                   	push   %esi
80105323:	e8 48 c9 ff ff       	call   80101c70 <iunlockput>
  iput(ip);
80105328:	89 1c 24             	mov    %ebx,(%esp)
8010532b:	e8 e0 c7 ff ff       	call   80101b10 <iput>
  end_op();
80105330:	e8 5b dd ff ff       	call   80103090 <end_op>
  return 0;
80105335:	83 c4 10             	add    $0x10,%esp
80105338:	31 c0                	xor    %eax,%eax
}
8010533a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010533d:	5b                   	pop    %ebx
8010533e:	5e                   	pop    %esi
8010533f:	5f                   	pop    %edi
80105340:	5d                   	pop    %ebp
80105341:	c3                   	ret    
80105342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105348:	83 ec 0c             	sub    $0xc,%esp
8010534b:	56                   	push   %esi
8010534c:	e8 1f c9 ff ff       	call   80101c70 <iunlockput>
    goto bad;
80105351:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105354:	83 ec 0c             	sub    $0xc,%esp
80105357:	53                   	push   %ebx
80105358:	e8 83 c6 ff ff       	call   801019e0 <ilock>
  ip->nlink--;
8010535d:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80105362:	89 1c 24             	mov    %ebx,(%esp)
80105365:	e8 c6 c5 ff ff       	call   80101930 <iupdate>
  iunlockput(ip);
8010536a:	89 1c 24             	mov    %ebx,(%esp)
8010536d:	e8 fe c8 ff ff       	call   80101c70 <iunlockput>
  end_op();
80105372:	e8 19 dd ff ff       	call   80103090 <end_op>
  return -1;
80105377:	83 c4 10             	add    $0x10,%esp
8010537a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010537f:	eb b9                	jmp    8010533a <sys_link+0xda>
    iunlockput(ip);
80105381:	83 ec 0c             	sub    $0xc,%esp
80105384:	53                   	push   %ebx
80105385:	e8 e6 c8 ff ff       	call   80101c70 <iunlockput>
    end_op();
8010538a:	e8 01 dd ff ff       	call   80103090 <end_op>
    return -1;
8010538f:	83 c4 10             	add    $0x10,%esp
80105392:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105397:	eb a1                	jmp    8010533a <sys_link+0xda>
    end_op();
80105399:	e8 f2 dc ff ff       	call   80103090 <end_op>
    return -1;
8010539e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a3:	eb 95                	jmp    8010533a <sys_link+0xda>
801053a5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801053ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801053b0 <sys_unlink>:
{
801053b0:	55                   	push   %ebp
801053b1:	89 e5                	mov    %esp,%ebp
801053b3:	57                   	push   %edi
801053b4:	56                   	push   %esi
  if(argstr(0, &path) < 0)
801053b5:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
801053b8:	53                   	push   %ebx
801053b9:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
801053bc:	50                   	push   %eax
801053bd:	6a 00                	push   $0x0
801053bf:	e8 bc f9 ff ff       	call   80104d80 <argstr>
801053c4:	83 c4 10             	add    $0x10,%esp
801053c7:	85 c0                	test   %eax,%eax
801053c9:	0f 88 7a 01 00 00    	js     80105549 <sys_unlink+0x199>
  begin_op();
801053cf:	e8 4c dc ff ff       	call   80103020 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801053d4:	8d 5d ca             	lea    -0x36(%ebp),%ebx
801053d7:	83 ec 08             	sub    $0x8,%esp
801053da:	53                   	push   %ebx
801053db:	ff 75 c0             	push   -0x40(%ebp)
801053de:	e8 3d cf ff ff       	call   80102320 <nameiparent>
801053e3:	83 c4 10             	add    $0x10,%esp
801053e6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
801053e9:	85 c0                	test   %eax,%eax
801053eb:	0f 84 62 01 00 00    	je     80105553 <sys_unlink+0x1a3>
  ilock(dp);
801053f1:	8b 7d b4             	mov    -0x4c(%ebp),%edi
801053f4:	83 ec 0c             	sub    $0xc,%esp
801053f7:	57                   	push   %edi
801053f8:	e8 e3 c5 ff ff       	call   801019e0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801053fd:	58                   	pop    %eax
801053fe:	5a                   	pop    %edx
801053ff:	68 fc 80 10 80       	push   $0x801080fc
80105404:	53                   	push   %ebx
80105405:	e8 16 cb ff ff       	call   80101f20 <namecmp>
8010540a:	83 c4 10             	add    $0x10,%esp
8010540d:	85 c0                	test   %eax,%eax
8010540f:	0f 84 fb 00 00 00    	je     80105510 <sys_unlink+0x160>
80105415:	83 ec 08             	sub    $0x8,%esp
80105418:	68 fb 80 10 80       	push   $0x801080fb
8010541d:	53                   	push   %ebx
8010541e:	e8 fd ca ff ff       	call   80101f20 <namecmp>
80105423:	83 c4 10             	add    $0x10,%esp
80105426:	85 c0                	test   %eax,%eax
80105428:	0f 84 e2 00 00 00    	je     80105510 <sys_unlink+0x160>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010542e:	83 ec 04             	sub    $0x4,%esp
80105431:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105434:	50                   	push   %eax
80105435:	53                   	push   %ebx
80105436:	57                   	push   %edi
80105437:	e8 04 cb ff ff       	call   80101f40 <dirlookup>
8010543c:	83 c4 10             	add    $0x10,%esp
8010543f:	89 c3                	mov    %eax,%ebx
80105441:	85 c0                	test   %eax,%eax
80105443:	0f 84 c7 00 00 00    	je     80105510 <sys_unlink+0x160>
  ilock(ip);
80105449:	83 ec 0c             	sub    $0xc,%esp
8010544c:	50                   	push   %eax
8010544d:	e8 8e c5 ff ff       	call   801019e0 <ilock>
  if(ip->nlink < 1)
80105452:	83 c4 10             	add    $0x10,%esp
80105455:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010545a:	0f 8e 1c 01 00 00    	jle    8010557c <sys_unlink+0x1cc>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105460:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105465:	8d 7d d8             	lea    -0x28(%ebp),%edi
80105468:	74 66                	je     801054d0 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
8010546a:	83 ec 04             	sub    $0x4,%esp
8010546d:	6a 10                	push   $0x10
8010546f:	6a 00                	push   $0x0
80105471:	57                   	push   %edi
80105472:	e8 89 f5 ff ff       	call   80104a00 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105477:	6a 10                	push   $0x10
80105479:	ff 75 c4             	push   -0x3c(%ebp)
8010547c:	57                   	push   %edi
8010547d:	ff 75 b4             	push   -0x4c(%ebp)
80105480:	e8 6b c9 ff ff       	call   80101df0 <writei>
80105485:	83 c4 20             	add    $0x20,%esp
80105488:	83 f8 10             	cmp    $0x10,%eax
8010548b:	0f 85 de 00 00 00    	jne    8010556f <sys_unlink+0x1bf>
  if(ip->type == T_DIR){
80105491:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105496:	0f 84 94 00 00 00    	je     80105530 <sys_unlink+0x180>
  iunlockput(dp);
8010549c:	83 ec 0c             	sub    $0xc,%esp
8010549f:	ff 75 b4             	push   -0x4c(%ebp)
801054a2:	e8 c9 c7 ff ff       	call   80101c70 <iunlockput>
  ip->nlink--;
801054a7:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
801054ac:	89 1c 24             	mov    %ebx,(%esp)
801054af:	e8 7c c4 ff ff       	call   80101930 <iupdate>
  iunlockput(ip);
801054b4:	89 1c 24             	mov    %ebx,(%esp)
801054b7:	e8 b4 c7 ff ff       	call   80101c70 <iunlockput>
  end_op();
801054bc:	e8 cf db ff ff       	call   80103090 <end_op>
  return 0;
801054c1:	83 c4 10             	add    $0x10,%esp
801054c4:	31 c0                	xor    %eax,%eax
}
801054c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801054c9:	5b                   	pop    %ebx
801054ca:	5e                   	pop    %esi
801054cb:	5f                   	pop    %edi
801054cc:	5d                   	pop    %ebp
801054cd:	c3                   	ret    
801054ce:	66 90                	xchg   %ax,%ax
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801054d0:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
801054d4:	76 94                	jbe    8010546a <sys_unlink+0xba>
801054d6:	be 20 00 00 00       	mov    $0x20,%esi
801054db:	eb 0b                	jmp    801054e8 <sys_unlink+0x138>
801054dd:	8d 76 00             	lea    0x0(%esi),%esi
801054e0:	83 c6 10             	add    $0x10,%esi
801054e3:	3b 73 58             	cmp    0x58(%ebx),%esi
801054e6:	73 82                	jae    8010546a <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801054e8:	6a 10                	push   $0x10
801054ea:	56                   	push   %esi
801054eb:	57                   	push   %edi
801054ec:	53                   	push   %ebx
801054ed:	e8 fe c7 ff ff       	call   80101cf0 <readi>
801054f2:	83 c4 10             	add    $0x10,%esp
801054f5:	83 f8 10             	cmp    $0x10,%eax
801054f8:	75 68                	jne    80105562 <sys_unlink+0x1b2>
    if(de.inum != 0)
801054fa:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801054ff:	74 df                	je     801054e0 <sys_unlink+0x130>
    iunlockput(ip);
80105501:	83 ec 0c             	sub    $0xc,%esp
80105504:	53                   	push   %ebx
80105505:	e8 66 c7 ff ff       	call   80101c70 <iunlockput>
    goto bad;
8010550a:	83 c4 10             	add    $0x10,%esp
8010550d:	8d 76 00             	lea    0x0(%esi),%esi
  iunlockput(dp);
80105510:	83 ec 0c             	sub    $0xc,%esp
80105513:	ff 75 b4             	push   -0x4c(%ebp)
80105516:	e8 55 c7 ff ff       	call   80101c70 <iunlockput>
  end_op();
8010551b:	e8 70 db ff ff       	call   80103090 <end_op>
  return -1;
80105520:	83 c4 10             	add    $0x10,%esp
80105523:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105528:	eb 9c                	jmp    801054c6 <sys_unlink+0x116>
8010552a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    dp->nlink--;
80105530:	8b 45 b4             	mov    -0x4c(%ebp),%eax
    iupdate(dp);
80105533:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
80105536:	66 83 68 56 01       	subw   $0x1,0x56(%eax)
    iupdate(dp);
8010553b:	50                   	push   %eax
8010553c:	e8 ef c3 ff ff       	call   80101930 <iupdate>
80105541:	83 c4 10             	add    $0x10,%esp
80105544:	e9 53 ff ff ff       	jmp    8010549c <sys_unlink+0xec>
    return -1;
80105549:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554e:	e9 73 ff ff ff       	jmp    801054c6 <sys_unlink+0x116>
    end_op();
80105553:	e8 38 db ff ff       	call   80103090 <end_op>
    return -1;
80105558:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010555d:	e9 64 ff ff ff       	jmp    801054c6 <sys_unlink+0x116>
      panic("isdirempty: readi");
80105562:	83 ec 0c             	sub    $0xc,%esp
80105565:	68 20 81 10 80       	push   $0x80108120
8010556a:	e8 41 af ff ff       	call   801004b0 <panic>
    panic("unlink: writei");
8010556f:	83 ec 0c             	sub    $0xc,%esp
80105572:	68 32 81 10 80       	push   $0x80108132
80105577:	e8 34 af ff ff       	call   801004b0 <panic>
    panic("unlink: nlink < 1");
8010557c:	83 ec 0c             	sub    $0xc,%esp
8010557f:	68 0e 81 10 80       	push   $0x8010810e
80105584:	e8 27 af ff ff       	call   801004b0 <panic>
80105589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105590 <sys_open>:

int
sys_open(void)
{
80105590:	55                   	push   %ebp
80105591:	89 e5                	mov    %esp,%ebp
80105593:	57                   	push   %edi
80105594:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105595:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
80105598:	53                   	push   %ebx
80105599:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010559c:	50                   	push   %eax
8010559d:	6a 00                	push   $0x0
8010559f:	e8 dc f7 ff ff       	call   80104d80 <argstr>
801055a4:	83 c4 10             	add    $0x10,%esp
801055a7:	85 c0                	test   %eax,%eax
801055a9:	0f 88 8e 00 00 00    	js     8010563d <sys_open+0xad>
801055af:	83 ec 08             	sub    $0x8,%esp
801055b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801055b5:	50                   	push   %eax
801055b6:	6a 01                	push   $0x1
801055b8:	e8 03 f7 ff ff       	call   80104cc0 <argint>
801055bd:	83 c4 10             	add    $0x10,%esp
801055c0:	85 c0                	test   %eax,%eax
801055c2:	78 79                	js     8010563d <sys_open+0xad>
    return -1;

  begin_op();
801055c4:	e8 57 da ff ff       	call   80103020 <begin_op>

  if(omode & O_CREATE){
801055c9:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
801055cd:	75 79                	jne    80105648 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
801055cf:	83 ec 0c             	sub    $0xc,%esp
801055d2:	ff 75 e0             	push   -0x20(%ebp)
801055d5:	e8 26 cd ff ff       	call   80102300 <namei>
801055da:	83 c4 10             	add    $0x10,%esp
801055dd:	89 c6                	mov    %eax,%esi
801055df:	85 c0                	test   %eax,%eax
801055e1:	0f 84 7e 00 00 00    	je     80105665 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
801055e7:	83 ec 0c             	sub    $0xc,%esp
801055ea:	50                   	push   %eax
801055eb:	e8 f0 c3 ff ff       	call   801019e0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801055f0:	83 c4 10             	add    $0x10,%esp
801055f3:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801055f8:	0f 84 c2 00 00 00    	je     801056c0 <sys_open+0x130>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801055fe:	e8 5d b9 ff ff       	call   80100f60 <filealloc>
80105603:	89 c7                	mov    %eax,%edi
80105605:	85 c0                	test   %eax,%eax
80105607:	74 23                	je     8010562c <sys_open+0x9c>
  struct proc *curproc = myproc();
80105609:	e8 42 e6 ff ff       	call   80103c50 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010560e:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
80105610:	8b 54 98 2c          	mov    0x2c(%eax,%ebx,4),%edx
80105614:	85 d2                	test   %edx,%edx
80105616:	74 60                	je     80105678 <sys_open+0xe8>
  for(fd = 0; fd < NOFILE; fd++){
80105618:	83 c3 01             	add    $0x1,%ebx
8010561b:	83 fb 10             	cmp    $0x10,%ebx
8010561e:	75 f0                	jne    80105610 <sys_open+0x80>
    if(f)
      fileclose(f);
80105620:	83 ec 0c             	sub    $0xc,%esp
80105623:	57                   	push   %edi
80105624:	e8 f7 b9 ff ff       	call   80101020 <fileclose>
80105629:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010562c:	83 ec 0c             	sub    $0xc,%esp
8010562f:	56                   	push   %esi
80105630:	e8 3b c6 ff ff       	call   80101c70 <iunlockput>
    end_op();
80105635:	e8 56 da ff ff       	call   80103090 <end_op>
    return -1;
8010563a:	83 c4 10             	add    $0x10,%esp
8010563d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105642:	eb 6d                	jmp    801056b1 <sys_open+0x121>
80105644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
80105648:	83 ec 0c             	sub    $0xc,%esp
8010564b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010564e:	31 c9                	xor    %ecx,%ecx
80105650:	ba 02 00 00 00       	mov    $0x2,%edx
80105655:	6a 00                	push   $0x0
80105657:	e8 14 f8 ff ff       	call   80104e70 <create>
    if(ip == 0){
8010565c:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
8010565f:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80105661:	85 c0                	test   %eax,%eax
80105663:	75 99                	jne    801055fe <sys_open+0x6e>
      end_op();
80105665:	e8 26 da ff ff       	call   80103090 <end_op>
      return -1;
8010566a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010566f:	eb 40                	jmp    801056b1 <sys_open+0x121>
80105671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
80105678:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
8010567b:	89 7c 98 2c          	mov    %edi,0x2c(%eax,%ebx,4)
  iunlock(ip);
8010567f:	56                   	push   %esi
80105680:	e8 3b c4 ff ff       	call   80101ac0 <iunlock>
  end_op();
80105685:	e8 06 da ff ff       	call   80103090 <end_op>

  f->type = FD_INODE;
8010568a:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
80105690:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105693:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105696:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
80105699:	89 d0                	mov    %edx,%eax
  f->off = 0;
8010569b:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
801056a2:	f7 d0                	not    %eax
801056a4:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801056a7:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
801056aa:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801056ad:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
801056b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801056b4:	89 d8                	mov    %ebx,%eax
801056b6:	5b                   	pop    %ebx
801056b7:	5e                   	pop    %esi
801056b8:	5f                   	pop    %edi
801056b9:	5d                   	pop    %ebp
801056ba:	c3                   	ret    
801056bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801056bf:	90                   	nop
    if(ip->type == T_DIR && omode != O_RDONLY){
801056c0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801056c3:	85 c9                	test   %ecx,%ecx
801056c5:	0f 84 33 ff ff ff    	je     801055fe <sys_open+0x6e>
801056cb:	e9 5c ff ff ff       	jmp    8010562c <sys_open+0x9c>

801056d0 <sys_mkdir>:

int
sys_mkdir(void)
{
801056d0:	55                   	push   %ebp
801056d1:	89 e5                	mov    %esp,%ebp
801056d3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801056d6:	e8 45 d9 ff ff       	call   80103020 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801056db:	83 ec 08             	sub    $0x8,%esp
801056de:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056e1:	50                   	push   %eax
801056e2:	6a 00                	push   $0x0
801056e4:	e8 97 f6 ff ff       	call   80104d80 <argstr>
801056e9:	83 c4 10             	add    $0x10,%esp
801056ec:	85 c0                	test   %eax,%eax
801056ee:	78 30                	js     80105720 <sys_mkdir+0x50>
801056f0:	83 ec 0c             	sub    $0xc,%esp
801056f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f6:	31 c9                	xor    %ecx,%ecx
801056f8:	ba 01 00 00 00       	mov    $0x1,%edx
801056fd:	6a 00                	push   $0x0
801056ff:	e8 6c f7 ff ff       	call   80104e70 <create>
80105704:	83 c4 10             	add    $0x10,%esp
80105707:	85 c0                	test   %eax,%eax
80105709:	74 15                	je     80105720 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010570b:	83 ec 0c             	sub    $0xc,%esp
8010570e:	50                   	push   %eax
8010570f:	e8 5c c5 ff ff       	call   80101c70 <iunlockput>
  end_op();
80105714:	e8 77 d9 ff ff       	call   80103090 <end_op>
  return 0;
80105719:	83 c4 10             	add    $0x10,%esp
8010571c:	31 c0                	xor    %eax,%eax
}
8010571e:	c9                   	leave  
8010571f:	c3                   	ret    
    end_op();
80105720:	e8 6b d9 ff ff       	call   80103090 <end_op>
    return -1;
80105725:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010572a:	c9                   	leave  
8010572b:	c3                   	ret    
8010572c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105730 <sys_mknod>:

int
sys_mknod(void)
{
80105730:	55                   	push   %ebp
80105731:	89 e5                	mov    %esp,%ebp
80105733:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105736:	e8 e5 d8 ff ff       	call   80103020 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010573b:	83 ec 08             	sub    $0x8,%esp
8010573e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105741:	50                   	push   %eax
80105742:	6a 00                	push   $0x0
80105744:	e8 37 f6 ff ff       	call   80104d80 <argstr>
80105749:	83 c4 10             	add    $0x10,%esp
8010574c:	85 c0                	test   %eax,%eax
8010574e:	78 60                	js     801057b0 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105750:	83 ec 08             	sub    $0x8,%esp
80105753:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105756:	50                   	push   %eax
80105757:	6a 01                	push   $0x1
80105759:	e8 62 f5 ff ff       	call   80104cc0 <argint>
  if((argstr(0, &path)) < 0 ||
8010575e:	83 c4 10             	add    $0x10,%esp
80105761:	85 c0                	test   %eax,%eax
80105763:	78 4b                	js     801057b0 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105765:	83 ec 08             	sub    $0x8,%esp
80105768:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010576b:	50                   	push   %eax
8010576c:	6a 02                	push   $0x2
8010576e:	e8 4d f5 ff ff       	call   80104cc0 <argint>
     argint(1, &major) < 0 ||
80105773:	83 c4 10             	add    $0x10,%esp
80105776:	85 c0                	test   %eax,%eax
80105778:	78 36                	js     801057b0 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010577a:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
8010577e:	83 ec 0c             	sub    $0xc,%esp
80105781:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80105785:	ba 03 00 00 00       	mov    $0x3,%edx
8010578a:	50                   	push   %eax
8010578b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010578e:	e8 dd f6 ff ff       	call   80104e70 <create>
     argint(2, &minor) < 0 ||
80105793:	83 c4 10             	add    $0x10,%esp
80105796:	85 c0                	test   %eax,%eax
80105798:	74 16                	je     801057b0 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010579a:	83 ec 0c             	sub    $0xc,%esp
8010579d:	50                   	push   %eax
8010579e:	e8 cd c4 ff ff       	call   80101c70 <iunlockput>
  end_op();
801057a3:	e8 e8 d8 ff ff       	call   80103090 <end_op>
  return 0;
801057a8:	83 c4 10             	add    $0x10,%esp
801057ab:	31 c0                	xor    %eax,%eax
}
801057ad:	c9                   	leave  
801057ae:	c3                   	ret    
801057af:	90                   	nop
    end_op();
801057b0:	e8 db d8 ff ff       	call   80103090 <end_op>
    return -1;
801057b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057ba:	c9                   	leave  
801057bb:	c3                   	ret    
801057bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801057c0 <sys_chdir>:

int
sys_chdir(void)
{
801057c0:	55                   	push   %ebp
801057c1:	89 e5                	mov    %esp,%ebp
801057c3:	56                   	push   %esi
801057c4:	53                   	push   %ebx
801057c5:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801057c8:	e8 83 e4 ff ff       	call   80103c50 <myproc>
801057cd:	89 c6                	mov    %eax,%esi
  
  begin_op();
801057cf:	e8 4c d8 ff ff       	call   80103020 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801057d4:	83 ec 08             	sub    $0x8,%esp
801057d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057da:	50                   	push   %eax
801057db:	6a 00                	push   $0x0
801057dd:	e8 9e f5 ff ff       	call   80104d80 <argstr>
801057e2:	83 c4 10             	add    $0x10,%esp
801057e5:	85 c0                	test   %eax,%eax
801057e7:	78 77                	js     80105860 <sys_chdir+0xa0>
801057e9:	83 ec 0c             	sub    $0xc,%esp
801057ec:	ff 75 f4             	push   -0xc(%ebp)
801057ef:	e8 0c cb ff ff       	call   80102300 <namei>
801057f4:	83 c4 10             	add    $0x10,%esp
801057f7:	89 c3                	mov    %eax,%ebx
801057f9:	85 c0                	test   %eax,%eax
801057fb:	74 63                	je     80105860 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
801057fd:	83 ec 0c             	sub    $0xc,%esp
80105800:	50                   	push   %eax
80105801:	e8 da c1 ff ff       	call   801019e0 <ilock>
  if(ip->type != T_DIR){
80105806:	83 c4 10             	add    $0x10,%esp
80105809:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010580e:	75 30                	jne    80105840 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105810:	83 ec 0c             	sub    $0xc,%esp
80105813:	53                   	push   %ebx
80105814:	e8 a7 c2 ff ff       	call   80101ac0 <iunlock>
  iput(curproc->cwd);
80105819:	58                   	pop    %eax
8010581a:	ff 76 6c             	push   0x6c(%esi)
8010581d:	e8 ee c2 ff ff       	call   80101b10 <iput>
  end_op();
80105822:	e8 69 d8 ff ff       	call   80103090 <end_op>
  curproc->cwd = ip;
80105827:	89 5e 6c             	mov    %ebx,0x6c(%esi)
  return 0;
8010582a:	83 c4 10             	add    $0x10,%esp
8010582d:	31 c0                	xor    %eax,%eax
}
8010582f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105832:	5b                   	pop    %ebx
80105833:	5e                   	pop    %esi
80105834:	5d                   	pop    %ebp
80105835:	c3                   	ret    
80105836:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010583d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80105840:	83 ec 0c             	sub    $0xc,%esp
80105843:	53                   	push   %ebx
80105844:	e8 27 c4 ff ff       	call   80101c70 <iunlockput>
    end_op();
80105849:	e8 42 d8 ff ff       	call   80103090 <end_op>
    return -1;
8010584e:	83 c4 10             	add    $0x10,%esp
80105851:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105856:	eb d7                	jmp    8010582f <sys_chdir+0x6f>
80105858:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010585f:	90                   	nop
    end_op();
80105860:	e8 2b d8 ff ff       	call   80103090 <end_op>
    return -1;
80105865:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010586a:	eb c3                	jmp    8010582f <sys_chdir+0x6f>
8010586c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105870 <sys_exec>:

int
sys_exec(void)
{
80105870:	55                   	push   %ebp
80105871:	89 e5                	mov    %esp,%ebp
80105873:	57                   	push   %edi
80105874:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105875:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
8010587b:	53                   	push   %ebx
8010587c:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105882:	50                   	push   %eax
80105883:	6a 00                	push   $0x0
80105885:	e8 f6 f4 ff ff       	call   80104d80 <argstr>
8010588a:	83 c4 10             	add    $0x10,%esp
8010588d:	85 c0                	test   %eax,%eax
8010588f:	0f 88 87 00 00 00    	js     8010591c <sys_exec+0xac>
80105895:	83 ec 08             	sub    $0x8,%esp
80105898:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
8010589e:	50                   	push   %eax
8010589f:	6a 01                	push   $0x1
801058a1:	e8 1a f4 ff ff       	call   80104cc0 <argint>
801058a6:	83 c4 10             	add    $0x10,%esp
801058a9:	85 c0                	test   %eax,%eax
801058ab:	78 6f                	js     8010591c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801058ad:	83 ec 04             	sub    $0x4,%esp
801058b0:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  for(i=0;; i++){
801058b6:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
801058b8:	68 80 00 00 00       	push   $0x80
801058bd:	6a 00                	push   $0x0
801058bf:	56                   	push   %esi
801058c0:	e8 3b f1 ff ff       	call   80104a00 <memset>
801058c5:	83 c4 10             	add    $0x10,%esp
801058c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801058cf:	90                   	nop
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801058d0:	83 ec 08             	sub    $0x8,%esp
801058d3:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
801058d9:	8d 3c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edi
801058e0:	50                   	push   %eax
801058e1:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
801058e7:	01 f8                	add    %edi,%eax
801058e9:	50                   	push   %eax
801058ea:	e8 41 f3 ff ff       	call   80104c30 <fetchint>
801058ef:	83 c4 10             	add    $0x10,%esp
801058f2:	85 c0                	test   %eax,%eax
801058f4:	78 26                	js     8010591c <sys_exec+0xac>
      return -1;
    if(uarg == 0){
801058f6:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
801058fc:	85 c0                	test   %eax,%eax
801058fe:	74 30                	je     80105930 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105900:	83 ec 08             	sub    $0x8,%esp
80105903:	8d 14 3e             	lea    (%esi,%edi,1),%edx
80105906:	52                   	push   %edx
80105907:	50                   	push   %eax
80105908:	e8 63 f3 ff ff       	call   80104c70 <fetchstr>
8010590d:	83 c4 10             	add    $0x10,%esp
80105910:	85 c0                	test   %eax,%eax
80105912:	78 08                	js     8010591c <sys_exec+0xac>
  for(i=0;; i++){
80105914:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105917:	83 fb 20             	cmp    $0x20,%ebx
8010591a:	75 b4                	jne    801058d0 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
8010591c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
8010591f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105924:	5b                   	pop    %ebx
80105925:	5e                   	pop    %esi
80105926:	5f                   	pop    %edi
80105927:	5d                   	pop    %ebp
80105928:	c3                   	ret    
80105929:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      argv[i] = 0;
80105930:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105937:	00 00 00 00 
  return exec(path, argv);
8010593b:	83 ec 08             	sub    $0x8,%esp
8010593e:	56                   	push   %esi
8010593f:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
80105945:	e8 96 b2 ff ff       	call   80100be0 <exec>
8010594a:	83 c4 10             	add    $0x10,%esp
}
8010594d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105950:	5b                   	pop    %ebx
80105951:	5e                   	pop    %esi
80105952:	5f                   	pop    %edi
80105953:	5d                   	pop    %ebp
80105954:	c3                   	ret    
80105955:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010595c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105960 <sys_pipe>:

int
sys_pipe(void)
{
80105960:	55                   	push   %ebp
80105961:	89 e5                	mov    %esp,%ebp
80105963:	57                   	push   %edi
80105964:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105965:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105968:	53                   	push   %ebx
80105969:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010596c:	6a 08                	push   $0x8
8010596e:	50                   	push   %eax
8010596f:	6a 00                	push   $0x0
80105971:	e8 9a f3 ff ff       	call   80104d10 <argptr>
80105976:	83 c4 10             	add    $0x10,%esp
80105979:	85 c0                	test   %eax,%eax
8010597b:	78 4a                	js     801059c7 <sys_pipe+0x67>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
8010597d:	83 ec 08             	sub    $0x8,%esp
80105980:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105983:	50                   	push   %eax
80105984:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105987:	50                   	push   %eax
80105988:	e8 83 dd ff ff       	call   80103710 <pipealloc>
8010598d:	83 c4 10             	add    $0x10,%esp
80105990:	85 c0                	test   %eax,%eax
80105992:	78 33                	js     801059c7 <sys_pipe+0x67>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105994:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105997:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
80105999:	e8 b2 e2 ff ff       	call   80103c50 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010599e:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
801059a0:	8b 74 98 2c          	mov    0x2c(%eax,%ebx,4),%esi
801059a4:	85 f6                	test   %esi,%esi
801059a6:	74 28                	je     801059d0 <sys_pipe+0x70>
  for(fd = 0; fd < NOFILE; fd++){
801059a8:	83 c3 01             	add    $0x1,%ebx
801059ab:	83 fb 10             	cmp    $0x10,%ebx
801059ae:	75 f0                	jne    801059a0 <sys_pipe+0x40>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
801059b0:	83 ec 0c             	sub    $0xc,%esp
801059b3:	ff 75 e0             	push   -0x20(%ebp)
801059b6:	e8 65 b6 ff ff       	call   80101020 <fileclose>
    fileclose(wf);
801059bb:	58                   	pop    %eax
801059bc:	ff 75 e4             	push   -0x1c(%ebp)
801059bf:	e8 5c b6 ff ff       	call   80101020 <fileclose>
    return -1;
801059c4:	83 c4 10             	add    $0x10,%esp
801059c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cc:	eb 53                	jmp    80105a21 <sys_pipe+0xc1>
801059ce:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
801059d0:	8d 73 08             	lea    0x8(%ebx),%esi
801059d3:	89 7c b0 0c          	mov    %edi,0xc(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801059d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
801059da:	e8 71 e2 ff ff       	call   80103c50 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801059df:	31 d2                	xor    %edx,%edx
801059e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
801059e8:	8b 4c 90 2c          	mov    0x2c(%eax,%edx,4),%ecx
801059ec:	85 c9                	test   %ecx,%ecx
801059ee:	74 20                	je     80105a10 <sys_pipe+0xb0>
  for(fd = 0; fd < NOFILE; fd++){
801059f0:	83 c2 01             	add    $0x1,%edx
801059f3:	83 fa 10             	cmp    $0x10,%edx
801059f6:	75 f0                	jne    801059e8 <sys_pipe+0x88>
      myproc()->ofile[fd0] = 0;
801059f8:	e8 53 e2 ff ff       	call   80103c50 <myproc>
801059fd:	c7 44 b0 0c 00 00 00 	movl   $0x0,0xc(%eax,%esi,4)
80105a04:	00 
80105a05:	eb a9                	jmp    801059b0 <sys_pipe+0x50>
80105a07:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a0e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105a10:	89 7c 90 2c          	mov    %edi,0x2c(%eax,%edx,4)
  }
  fd[0] = fd0;
80105a14:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a17:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80105a19:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a1c:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80105a1f:	31 c0                	xor    %eax,%eax
}
80105a21:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105a24:	5b                   	pop    %ebx
80105a25:	5e                   	pop    %esi
80105a26:	5f                   	pop    %edi
80105a27:	5d                   	pop    %ebp
80105a28:	c3                   	ret    
80105a29:	66 90                	xchg   %ax,%ax
80105a2b:	66 90                	xchg   %ax,%ax
80105a2d:	66 90                	xchg   %ax,%ax
80105a2f:	90                   	nop

80105a30 <sys_getNumFreePages>:


int
sys_getNumFreePages(void)
{
  return num_of_FreePages();  
80105a30:	e9 4b cf ff ff       	jmp    80102980 <num_of_FreePages>
80105a35:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a40 <sys_getrss>:
}

int 
sys_getrss()
{
80105a40:	55                   	push   %ebp
80105a41:	89 e5                	mov    %esp,%ebp
80105a43:	83 ec 08             	sub    $0x8,%esp
  print_rss();
80105a46:	e8 c5 e4 ff ff       	call   80103f10 <print_rss>
  return 0;
}
80105a4b:	31 c0                	xor    %eax,%eax
80105a4d:	c9                   	leave  
80105a4e:	c3                   	ret    
80105a4f:	90                   	nop

80105a50 <sys_fork>:

int
sys_fork(void)
{
  return fork();
80105a50:	e9 9b e3 ff ff       	jmp    80103df0 <fork>
80105a55:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a60 <sys_exit>:
}

int
sys_exit(void)
{
80105a60:	55                   	push   %ebp
80105a61:	89 e5                	mov    %esp,%ebp
80105a63:	83 ec 08             	sub    $0x8,%esp
  exit();
80105a66:	e8 75 e6 ff ff       	call   801040e0 <exit>
  return 0;  // not reached
}
80105a6b:	31 c0                	xor    %eax,%eax
80105a6d:	c9                   	leave  
80105a6e:	c3                   	ret    
80105a6f:	90                   	nop

80105a70 <sys_wait>:

int
sys_wait(void)
{
  return wait();
80105a70:	e9 9b e7 ff ff       	jmp    80104210 <wait>
80105a75:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a80 <sys_kill>:
}

int
sys_kill(void)
{
80105a80:	55                   	push   %ebp
80105a81:	89 e5                	mov    %esp,%ebp
80105a83:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105a86:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a89:	50                   	push   %eax
80105a8a:	6a 00                	push   $0x0
80105a8c:	e8 2f f2 ff ff       	call   80104cc0 <argint>
80105a91:	83 c4 10             	add    $0x10,%esp
80105a94:	85 c0                	test   %eax,%eax
80105a96:	78 18                	js     80105ab0 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105a98:	83 ec 0c             	sub    $0xc,%esp
80105a9b:	ff 75 f4             	push   -0xc(%ebp)
80105a9e:	e8 0d ea ff ff       	call   801044b0 <kill>
80105aa3:	83 c4 10             	add    $0x10,%esp
}
80105aa6:	c9                   	leave  
80105aa7:	c3                   	ret    
80105aa8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105aaf:	90                   	nop
80105ab0:	c9                   	leave  
    return -1;
80105ab1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ab6:	c3                   	ret    
80105ab7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105abe:	66 90                	xchg   %ax,%ax

80105ac0 <sys_getpid>:

int
sys_getpid(void)
{
80105ac0:	55                   	push   %ebp
80105ac1:	89 e5                	mov    %esp,%ebp
80105ac3:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105ac6:	e8 85 e1 ff ff       	call   80103c50 <myproc>
80105acb:	8b 40 14             	mov    0x14(%eax),%eax
}
80105ace:	c9                   	leave  
80105acf:	c3                   	ret    

80105ad0 <sys_sbrk>:

int
sys_sbrk(void)
{
80105ad0:	55                   	push   %ebp
80105ad1:	89 e5                	mov    %esp,%ebp
80105ad3:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ad4:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105ad7:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105ada:	50                   	push   %eax
80105adb:	6a 00                	push   $0x0
80105add:	e8 de f1 ff ff       	call   80104cc0 <argint>
80105ae2:	83 c4 10             	add    $0x10,%esp
80105ae5:	85 c0                	test   %eax,%eax
80105ae7:	78 27                	js     80105b10 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105ae9:	e8 62 e1 ff ff       	call   80103c50 <myproc>
  if(growproc(n) < 0)
80105aee:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80105af1:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105af3:	ff 75 f4             	push   -0xc(%ebp)
80105af6:	e8 75 e2 ff ff       	call   80103d70 <growproc>
80105afb:	83 c4 10             	add    $0x10,%esp
80105afe:	85 c0                	test   %eax,%eax
80105b00:	78 0e                	js     80105b10 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105b02:	89 d8                	mov    %ebx,%eax
80105b04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105b07:	c9                   	leave  
80105b08:	c3                   	ret    
80105b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105b10:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105b15:	eb eb                	jmp    80105b02 <sys_sbrk+0x32>
80105b17:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105b1e:	66 90                	xchg   %ax,%ax

80105b20 <sys_sleep>:

int
sys_sleep(void)
{
80105b20:	55                   	push   %ebp
80105b21:	89 e5                	mov    %esp,%ebp
80105b23:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105b24:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105b27:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105b2a:	50                   	push   %eax
80105b2b:	6a 00                	push   $0x0
80105b2d:	e8 8e f1 ff ff       	call   80104cc0 <argint>
80105b32:	83 c4 10             	add    $0x10,%esp
80105b35:	85 c0                	test   %eax,%eax
80105b37:	0f 88 8a 00 00 00    	js     80105bc7 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105b3d:	83 ec 0c             	sub    $0xc,%esp
80105b40:	68 c0 4d 11 80       	push   $0x80114dc0
80105b45:	e8 f6 ed ff ff       	call   80104940 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105b4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
80105b4d:	8b 1d a0 4d 11 80    	mov    0x80114da0,%ebx
  while(ticks - ticks0 < n){
80105b53:	83 c4 10             	add    $0x10,%esp
80105b56:	85 d2                	test   %edx,%edx
80105b58:	75 27                	jne    80105b81 <sys_sleep+0x61>
80105b5a:	eb 54                	jmp    80105bb0 <sys_sleep+0x90>
80105b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105b60:	83 ec 08             	sub    $0x8,%esp
80105b63:	68 c0 4d 11 80       	push   $0x80114dc0
80105b68:	68 a0 4d 11 80       	push   $0x80114da0
80105b6d:	e8 1e e8 ff ff       	call   80104390 <sleep>
  while(ticks - ticks0 < n){
80105b72:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80105b77:	83 c4 10             	add    $0x10,%esp
80105b7a:	29 d8                	sub    %ebx,%eax
80105b7c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105b7f:	73 2f                	jae    80105bb0 <sys_sleep+0x90>
    if(myproc()->killed){
80105b81:	e8 ca e0 ff ff       	call   80103c50 <myproc>
80105b86:	8b 40 28             	mov    0x28(%eax),%eax
80105b89:	85 c0                	test   %eax,%eax
80105b8b:	74 d3                	je     80105b60 <sys_sleep+0x40>
      release(&tickslock);
80105b8d:	83 ec 0c             	sub    $0xc,%esp
80105b90:	68 c0 4d 11 80       	push   $0x80114dc0
80105b95:	e8 46 ed ff ff       	call   801048e0 <release>
  }
  release(&tickslock);
  return 0;
}
80105b9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return -1;
80105b9d:	83 c4 10             	add    $0x10,%esp
80105ba0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ba5:	c9                   	leave  
80105ba6:	c3                   	ret    
80105ba7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105bae:	66 90                	xchg   %ax,%ax
  release(&tickslock);
80105bb0:	83 ec 0c             	sub    $0xc,%esp
80105bb3:	68 c0 4d 11 80       	push   $0x80114dc0
80105bb8:	e8 23 ed ff ff       	call   801048e0 <release>
  return 0;
80105bbd:	83 c4 10             	add    $0x10,%esp
80105bc0:	31 c0                	xor    %eax,%eax
}
80105bc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105bc5:	c9                   	leave  
80105bc6:	c3                   	ret    
    return -1;
80105bc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bcc:	eb f4                	jmp    80105bc2 <sys_sleep+0xa2>
80105bce:	66 90                	xchg   %ax,%ax

80105bd0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105bd0:	55                   	push   %ebp
80105bd1:	89 e5                	mov    %esp,%ebp
80105bd3:	53                   	push   %ebx
80105bd4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105bd7:	68 c0 4d 11 80       	push   $0x80114dc0
80105bdc:	e8 5f ed ff ff       	call   80104940 <acquire>
  xticks = ticks;
80105be1:	8b 1d a0 4d 11 80    	mov    0x80114da0,%ebx
  release(&tickslock);
80105be7:	c7 04 24 c0 4d 11 80 	movl   $0x80114dc0,(%esp)
80105bee:	e8 ed ec ff ff       	call   801048e0 <release>
  return xticks;
}
80105bf3:	89 d8                	mov    %ebx,%eax
80105bf5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105bf8:	c9                   	leave  
80105bf9:	c3                   	ret    

80105bfa <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105bfa:	1e                   	push   %ds
  pushl %es
80105bfb:	06                   	push   %es
  pushl %fs
80105bfc:	0f a0                	push   %fs
  pushl %gs
80105bfe:	0f a8                	push   %gs
  pushal
80105c00:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105c01:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105c05:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105c07:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105c09:	54                   	push   %esp
  call trap
80105c0a:	e8 c1 00 00 00       	call   80105cd0 <trap>
  addl $4, %esp
80105c0f:	83 c4 04             	add    $0x4,%esp

80105c12 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105c12:	61                   	popa   
  popl %gs
80105c13:	0f a9                	pop    %gs
  popl %fs
80105c15:	0f a1                	pop    %fs
  popl %es
80105c17:	07                   	pop    %es
  popl %ds
80105c18:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105c19:	83 c4 08             	add    $0x8,%esp
  iret
80105c1c:	cf                   	iret   
80105c1d:	66 90                	xchg   %ax,%ax
80105c1f:	90                   	nop

80105c20 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105c20:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80105c21:	31 c0                	xor    %eax,%eax
{
80105c23:	89 e5                	mov    %esp,%ebp
80105c25:	83 ec 08             	sub    $0x8,%esp
80105c28:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c2f:	90                   	nop
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105c30:	8b 14 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%edx
80105c37:	c7 04 c5 02 4e 11 80 	movl   $0x8e000008,-0x7feeb1fe(,%eax,8)
80105c3e:	08 00 00 8e 
80105c42:	66 89 14 c5 00 4e 11 	mov    %dx,-0x7feeb200(,%eax,8)
80105c49:	80 
80105c4a:	c1 ea 10             	shr    $0x10,%edx
80105c4d:	66 89 14 c5 06 4e 11 	mov    %dx,-0x7feeb1fa(,%eax,8)
80105c54:	80 
  for(i = 0; i < 256; i++)
80105c55:	83 c0 01             	add    $0x1,%eax
80105c58:	3d 00 01 00 00       	cmp    $0x100,%eax
80105c5d:	75 d1                	jne    80105c30 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
80105c5f:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105c62:	a1 08 b1 10 80       	mov    0x8010b108,%eax
80105c67:	c7 05 02 50 11 80 08 	movl   $0xef000008,0x80115002
80105c6e:	00 00 ef 
  initlock(&tickslock, "time");
80105c71:	68 41 81 10 80       	push   $0x80108141
80105c76:	68 c0 4d 11 80       	push   $0x80114dc0
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105c7b:	66 a3 00 50 11 80    	mov    %ax,0x80115000
80105c81:	c1 e8 10             	shr    $0x10,%eax
80105c84:	66 a3 06 50 11 80    	mov    %ax,0x80115006
  initlock(&tickslock, "time");
80105c8a:	e8 e1 ea ff ff       	call   80104770 <initlock>
}
80105c8f:	83 c4 10             	add    $0x10,%esp
80105c92:	c9                   	leave  
80105c93:	c3                   	ret    
80105c94:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105c9f:	90                   	nop

80105ca0 <idtinit>:

void
idtinit(void)
{
80105ca0:	55                   	push   %ebp
  pd[0] = size-1;
80105ca1:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80105ca6:	89 e5                	mov    %esp,%ebp
80105ca8:	83 ec 10             	sub    $0x10,%esp
80105cab:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105caf:	b8 00 4e 11 80       	mov    $0x80114e00,%eax
80105cb4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105cb8:	c1 e8 10             	shr    $0x10,%eax
80105cbb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105cbf:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105cc2:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105cc5:	c9                   	leave  
80105cc6:	c3                   	ret    
80105cc7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105cce:	66 90                	xchg   %ax,%ax

80105cd0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105cd0:	55                   	push   %ebp
80105cd1:	89 e5                	mov    %esp,%ebp
80105cd3:	57                   	push   %edi
80105cd4:	56                   	push   %esi
80105cd5:	53                   	push   %ebx
80105cd6:	83 ec 1c             	sub    $0x1c,%esp
80105cd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105cdc:	8b 43 30             	mov    0x30(%ebx),%eax
80105cdf:	83 f8 40             	cmp    $0x40,%eax
80105ce2:	0f 84 30 01 00 00    	je     80105e18 <trap+0x148>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105ce8:	83 e8 0e             	sub    $0xe,%eax
80105ceb:	83 f8 31             	cmp    $0x31,%eax
80105cee:	0f 87 8c 00 00 00    	ja     80105d80 <trap+0xb0>
80105cf4:	ff 24 85 fc 81 10 80 	jmp    *-0x7fef7e04(,%eax,4)
80105cfb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105cff:	90                   	nop
  case T_PGFLT:
    cprintf("Pagefault called\n");
    page_fault();
    break;
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105d00:	e8 2b df ff ff       	call   80103c30 <cpuid>
80105d05:	85 c0                	test   %eax,%eax
80105d07:	0f 84 23 02 00 00    	je     80105f30 <trap+0x260>
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
80105d0d:	e8 be ce ff ff       	call   80102bd0 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105d12:	e8 39 df ff ff       	call   80103c50 <myproc>
80105d17:	85 c0                	test   %eax,%eax
80105d19:	74 1d                	je     80105d38 <trap+0x68>
80105d1b:	e8 30 df ff ff       	call   80103c50 <myproc>
80105d20:	8b 50 28             	mov    0x28(%eax),%edx
80105d23:	85 d2                	test   %edx,%edx
80105d25:	74 11                	je     80105d38 <trap+0x68>
80105d27:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105d2b:	83 e0 03             	and    $0x3,%eax
80105d2e:	66 83 f8 03          	cmp    $0x3,%ax
80105d32:	0f 84 d8 01 00 00    	je     80105f10 <trap+0x240>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105d38:	e8 13 df ff ff       	call   80103c50 <myproc>
80105d3d:	85 c0                	test   %eax,%eax
80105d3f:	74 0f                	je     80105d50 <trap+0x80>
80105d41:	e8 0a df ff ff       	call   80103c50 <myproc>
80105d46:	83 78 10 04          	cmpl   $0x4,0x10(%eax)
80105d4a:	0f 84 b0 00 00 00    	je     80105e00 <trap+0x130>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105d50:	e8 fb de ff ff       	call   80103c50 <myproc>
80105d55:	85 c0                	test   %eax,%eax
80105d57:	74 1d                	je     80105d76 <trap+0xa6>
80105d59:	e8 f2 de ff ff       	call   80103c50 <myproc>
80105d5e:	8b 40 28             	mov    0x28(%eax),%eax
80105d61:	85 c0                	test   %eax,%eax
80105d63:	74 11                	je     80105d76 <trap+0xa6>
80105d65:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105d69:	83 e0 03             	and    $0x3,%eax
80105d6c:	66 83 f8 03          	cmp    $0x3,%ax
80105d70:	0f 84 cf 00 00 00    	je     80105e45 <trap+0x175>
    exit();
}
80105d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d79:	5b                   	pop    %ebx
80105d7a:	5e                   	pop    %esi
80105d7b:	5f                   	pop    %edi
80105d7c:	5d                   	pop    %ebp
80105d7d:	c3                   	ret    
80105d7e:	66 90                	xchg   %ax,%ax
    if(myproc() == 0 || (tf->cs&3) == 0){
80105d80:	e8 cb de ff ff       	call   80103c50 <myproc>
80105d85:	8b 7b 38             	mov    0x38(%ebx),%edi
80105d88:	85 c0                	test   %eax,%eax
80105d8a:	0f 84 d4 01 00 00    	je     80105f64 <trap+0x294>
80105d90:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105d94:	0f 84 ca 01 00 00    	je     80105f64 <trap+0x294>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105d9a:	0f 20 d1             	mov    %cr2,%ecx
80105d9d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105da0:	e8 8b de ff ff       	call   80103c30 <cpuid>
80105da5:	8b 73 30             	mov    0x30(%ebx),%esi
80105da8:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105dab:	8b 43 34             	mov    0x34(%ebx),%eax
80105dae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            myproc()->pid, myproc()->name, tf->trapno,
80105db1:	e8 9a de ff ff       	call   80103c50 <myproc>
80105db6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105db9:	e8 92 de ff ff       	call   80103c50 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105dbe:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105dc1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105dc4:	51                   	push   %ecx
80105dc5:	57                   	push   %edi
80105dc6:	52                   	push   %edx
80105dc7:	ff 75 e4             	push   -0x1c(%ebp)
80105dca:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
80105dcb:	8b 75 e0             	mov    -0x20(%ebp),%esi
80105dce:	83 c6 70             	add    $0x70,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105dd1:	56                   	push   %esi
80105dd2:	ff 70 14             	push   0x14(%eax)
80105dd5:	68 b8 81 10 80       	push   $0x801081b8
80105dda:	e8 f1 a9 ff ff       	call   801007d0 <cprintf>
    myproc()->killed = 1;
80105ddf:	83 c4 20             	add    $0x20,%esp
80105de2:	e8 69 de ff ff       	call   80103c50 <myproc>
80105de7:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105dee:	e8 5d de ff ff       	call   80103c50 <myproc>
80105df3:	85 c0                	test   %eax,%eax
80105df5:	0f 85 20 ff ff ff    	jne    80105d1b <trap+0x4b>
80105dfb:	e9 38 ff ff ff       	jmp    80105d38 <trap+0x68>
  if(myproc() && myproc()->state == RUNNING &&
80105e00:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105e04:	0f 85 46 ff ff ff    	jne    80105d50 <trap+0x80>
    yield();
80105e0a:	e8 31 e5 ff ff       	call   80104340 <yield>
80105e0f:	e9 3c ff ff ff       	jmp    80105d50 <trap+0x80>
80105e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed)
80105e18:	e8 33 de ff ff       	call   80103c50 <myproc>
80105e1d:	8b 70 28             	mov    0x28(%eax),%esi
80105e20:	85 f6                	test   %esi,%esi
80105e22:	0f 85 f8 00 00 00    	jne    80105f20 <trap+0x250>
    myproc()->tf = tf;
80105e28:	e8 23 de ff ff       	call   80103c50 <myproc>
80105e2d:	89 58 1c             	mov    %ebx,0x1c(%eax)
    syscall();
80105e30:	e8 cb ef ff ff       	call   80104e00 <syscall>
    if(myproc()->killed)
80105e35:	e8 16 de ff ff       	call   80103c50 <myproc>
80105e3a:	8b 48 28             	mov    0x28(%eax),%ecx
80105e3d:	85 c9                	test   %ecx,%ecx
80105e3f:	0f 84 31 ff ff ff    	je     80105d76 <trap+0xa6>
}
80105e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e48:	5b                   	pop    %ebx
80105e49:	5e                   	pop    %esi
80105e4a:	5f                   	pop    %edi
80105e4b:	5d                   	pop    %ebp
      exit();
80105e4c:	e9 8f e2 ff ff       	jmp    801040e0 <exit>
80105e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105e58:	8b 7b 38             	mov    0x38(%ebx),%edi
80105e5b:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80105e5f:	e8 cc dd ff ff       	call   80103c30 <cpuid>
80105e64:	57                   	push   %edi
80105e65:	56                   	push   %esi
80105e66:	50                   	push   %eax
80105e67:	68 60 81 10 80       	push   $0x80108160
80105e6c:	e8 5f a9 ff ff       	call   801007d0 <cprintf>
    lapiceoi();
80105e71:	e8 5a cd ff ff       	call   80102bd0 <lapiceoi>
    break;
80105e76:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105e79:	e8 d2 dd ff ff       	call   80103c50 <myproc>
80105e7e:	85 c0                	test   %eax,%eax
80105e80:	0f 85 95 fe ff ff    	jne    80105d1b <trap+0x4b>
80105e86:	e9 ad fe ff ff       	jmp    80105d38 <trap+0x68>
80105e8b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105e8f:	90                   	nop
    kbdintr();
80105e90:	e8 fb cb ff ff       	call   80102a90 <kbdintr>
    lapiceoi();
80105e95:	e8 36 cd ff ff       	call   80102bd0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105e9a:	e8 b1 dd ff ff       	call   80103c50 <myproc>
80105e9f:	85 c0                	test   %eax,%eax
80105ea1:	0f 85 74 fe ff ff    	jne    80105d1b <trap+0x4b>
80105ea7:	e9 8c fe ff ff       	jmp    80105d38 <trap+0x68>
80105eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    uartintr();
80105eb0:	e8 4b 02 00 00       	call   80106100 <uartintr>
    lapiceoi();
80105eb5:	e8 16 cd ff ff       	call   80102bd0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105eba:	e8 91 dd ff ff       	call   80103c50 <myproc>
80105ebf:	85 c0                	test   %eax,%eax
80105ec1:	0f 85 54 fe ff ff    	jne    80105d1b <trap+0x4b>
80105ec7:	e9 6c fe ff ff       	jmp    80105d38 <trap+0x68>
80105ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ideintr();
80105ed0:	e8 cb c5 ff ff       	call   801024a0 <ideintr>
80105ed5:	e9 33 fe ff ff       	jmp    80105d0d <trap+0x3d>
80105eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cprintf("Pagefault called\n");
80105ee0:	83 ec 0c             	sub    $0xc,%esp
80105ee3:	68 46 81 10 80       	push   $0x80108146
80105ee8:	e8 e3 a8 ff ff       	call   801007d0 <cprintf>
    page_fault();
80105eed:	e8 de 18 00 00       	call   801077d0 <page_fault>
    break;
80105ef2:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105ef5:	e8 56 dd ff ff       	call   80103c50 <myproc>
80105efa:	85 c0                	test   %eax,%eax
80105efc:	0f 85 19 fe ff ff    	jne    80105d1b <trap+0x4b>
80105f02:	e9 31 fe ff ff       	jmp    80105d38 <trap+0x68>
80105f07:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105f0e:	66 90                	xchg   %ax,%ax
    exit();
80105f10:	e8 cb e1 ff ff       	call   801040e0 <exit>
80105f15:	e9 1e fe ff ff       	jmp    80105d38 <trap+0x68>
80105f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
80105f20:	e8 bb e1 ff ff       	call   801040e0 <exit>
80105f25:	e9 fe fe ff ff       	jmp    80105e28 <trap+0x158>
80105f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      acquire(&tickslock);
80105f30:	83 ec 0c             	sub    $0xc,%esp
80105f33:	68 c0 4d 11 80       	push   $0x80114dc0
80105f38:	e8 03 ea ff ff       	call   80104940 <acquire>
      wakeup(&ticks);
80105f3d:	c7 04 24 a0 4d 11 80 	movl   $0x80114da0,(%esp)
      ticks++;
80105f44:	83 05 a0 4d 11 80 01 	addl   $0x1,0x80114da0
      wakeup(&ticks);
80105f4b:	e8 00 e5 ff ff       	call   80104450 <wakeup>
      release(&tickslock);
80105f50:	c7 04 24 c0 4d 11 80 	movl   $0x80114dc0,(%esp)
80105f57:	e8 84 e9 ff ff       	call   801048e0 <release>
80105f5c:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80105f5f:	e9 a9 fd ff ff       	jmp    80105d0d <trap+0x3d>
80105f64:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105f67:	e8 c4 dc ff ff       	call   80103c30 <cpuid>
80105f6c:	83 ec 0c             	sub    $0xc,%esp
80105f6f:	56                   	push   %esi
80105f70:	57                   	push   %edi
80105f71:	50                   	push   %eax
80105f72:	ff 73 30             	push   0x30(%ebx)
80105f75:	68 84 81 10 80       	push   $0x80108184
80105f7a:	e8 51 a8 ff ff       	call   801007d0 <cprintf>
      panic("trap");
80105f7f:	83 c4 14             	add    $0x14,%esp
80105f82:	68 58 81 10 80       	push   $0x80108158
80105f87:	e8 24 a5 ff ff       	call   801004b0 <panic>
80105f8c:	66 90                	xchg   %ax,%ax
80105f8e:	66 90                	xchg   %ax,%ax

80105f90 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105f90:	a1 00 56 11 80       	mov    0x80115600,%eax
80105f95:	85 c0                	test   %eax,%eax
80105f97:	74 17                	je     80105fb0 <uartgetc+0x20>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105f99:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105f9e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105f9f:	a8 01                	test   $0x1,%al
80105fa1:	74 0d                	je     80105fb0 <uartgetc+0x20>
80105fa3:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105fa8:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105fa9:	0f b6 c0             	movzbl %al,%eax
80105fac:	c3                   	ret    
80105fad:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105fb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105fb5:	c3                   	ret    
80105fb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105fbd:	8d 76 00             	lea    0x0(%esi),%esi

80105fc0 <uartinit>:
{
80105fc0:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105fc1:	31 c9                	xor    %ecx,%ecx
80105fc3:	89 c8                	mov    %ecx,%eax
80105fc5:	89 e5                	mov    %esp,%ebp
80105fc7:	57                   	push   %edi
80105fc8:	bf fa 03 00 00       	mov    $0x3fa,%edi
80105fcd:	56                   	push   %esi
80105fce:	89 fa                	mov    %edi,%edx
80105fd0:	53                   	push   %ebx
80105fd1:	83 ec 1c             	sub    $0x1c,%esp
80105fd4:	ee                   	out    %al,(%dx)
80105fd5:	be fb 03 00 00       	mov    $0x3fb,%esi
80105fda:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105fdf:	89 f2                	mov    %esi,%edx
80105fe1:	ee                   	out    %al,(%dx)
80105fe2:	b8 0c 00 00 00       	mov    $0xc,%eax
80105fe7:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105fec:	ee                   	out    %al,(%dx)
80105fed:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105ff2:	89 c8                	mov    %ecx,%eax
80105ff4:	89 da                	mov    %ebx,%edx
80105ff6:	ee                   	out    %al,(%dx)
80105ff7:	b8 03 00 00 00       	mov    $0x3,%eax
80105ffc:	89 f2                	mov    %esi,%edx
80105ffe:	ee                   	out    %al,(%dx)
80105fff:	ba fc 03 00 00       	mov    $0x3fc,%edx
80106004:	89 c8                	mov    %ecx,%eax
80106006:	ee                   	out    %al,(%dx)
80106007:	b8 01 00 00 00       	mov    $0x1,%eax
8010600c:	89 da                	mov    %ebx,%edx
8010600e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010600f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106014:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80106015:	3c ff                	cmp    $0xff,%al
80106017:	74 78                	je     80106091 <uartinit+0xd1>
  uart = 1;
80106019:	c7 05 00 56 11 80 01 	movl   $0x1,0x80115600
80106020:	00 00 00 
80106023:	89 fa                	mov    %edi,%edx
80106025:	ec                   	in     (%dx),%al
80106026:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010602b:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010602c:	83 ec 08             	sub    $0x8,%esp
  for(p="xv6...\n"; *p; p++)
8010602f:	bf c4 82 10 80       	mov    $0x801082c4,%edi
80106034:	be fd 03 00 00       	mov    $0x3fd,%esi
  ioapicenable(IRQ_COM1, 0);
80106039:	6a 00                	push   $0x0
8010603b:	6a 04                	push   $0x4
8010603d:	e8 9e c6 ff ff       	call   801026e0 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80106042:	c6 45 e7 78          	movb   $0x78,-0x19(%ebp)
  ioapicenable(IRQ_COM1, 0);
80106046:	83 c4 10             	add    $0x10,%esp
80106049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(!uart)
80106050:	a1 00 56 11 80       	mov    0x80115600,%eax
80106055:	bb 80 00 00 00       	mov    $0x80,%ebx
8010605a:	85 c0                	test   %eax,%eax
8010605c:	75 14                	jne    80106072 <uartinit+0xb2>
8010605e:	eb 23                	jmp    80106083 <uartinit+0xc3>
    microdelay(10);
80106060:	83 ec 0c             	sub    $0xc,%esp
80106063:	6a 0a                	push   $0xa
80106065:	e8 86 cb ff ff       	call   80102bf0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010606a:	83 c4 10             	add    $0x10,%esp
8010606d:	83 eb 01             	sub    $0x1,%ebx
80106070:	74 07                	je     80106079 <uartinit+0xb9>
80106072:	89 f2                	mov    %esi,%edx
80106074:	ec                   	in     (%dx),%al
80106075:	a8 20                	test   $0x20,%al
80106077:	74 e7                	je     80106060 <uartinit+0xa0>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106079:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
8010607d:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106082:	ee                   	out    %al,(%dx)
  for(p="xv6...\n"; *p; p++)
80106083:	0f b6 47 01          	movzbl 0x1(%edi),%eax
80106087:	83 c7 01             	add    $0x1,%edi
8010608a:	88 45 e7             	mov    %al,-0x19(%ebp)
8010608d:	84 c0                	test   %al,%al
8010608f:	75 bf                	jne    80106050 <uartinit+0x90>
}
80106091:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106094:	5b                   	pop    %ebx
80106095:	5e                   	pop    %esi
80106096:	5f                   	pop    %edi
80106097:	5d                   	pop    %ebp
80106098:	c3                   	ret    
80106099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801060a0 <uartputc>:
  if(!uart)
801060a0:	a1 00 56 11 80       	mov    0x80115600,%eax
801060a5:	85 c0                	test   %eax,%eax
801060a7:	74 47                	je     801060f0 <uartputc+0x50>
{
801060a9:	55                   	push   %ebp
801060aa:	89 e5                	mov    %esp,%ebp
801060ac:	56                   	push   %esi
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801060ad:	be fd 03 00 00       	mov    $0x3fd,%esi
801060b2:	53                   	push   %ebx
801060b3:	bb 80 00 00 00       	mov    $0x80,%ebx
801060b8:	eb 18                	jmp    801060d2 <uartputc+0x32>
801060ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    microdelay(10);
801060c0:	83 ec 0c             	sub    $0xc,%esp
801060c3:	6a 0a                	push   $0xa
801060c5:	e8 26 cb ff ff       	call   80102bf0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801060ca:	83 c4 10             	add    $0x10,%esp
801060cd:	83 eb 01             	sub    $0x1,%ebx
801060d0:	74 07                	je     801060d9 <uartputc+0x39>
801060d2:	89 f2                	mov    %esi,%edx
801060d4:	ec                   	in     (%dx),%al
801060d5:	a8 20                	test   $0x20,%al
801060d7:	74 e7                	je     801060c0 <uartputc+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801060d9:	8b 45 08             	mov    0x8(%ebp),%eax
801060dc:	ba f8 03 00 00       	mov    $0x3f8,%edx
801060e1:	ee                   	out    %al,(%dx)
}
801060e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801060e5:	5b                   	pop    %ebx
801060e6:	5e                   	pop    %esi
801060e7:	5d                   	pop    %ebp
801060e8:	c3                   	ret    
801060e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801060f0:	c3                   	ret    
801060f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801060f8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801060ff:	90                   	nop

80106100 <uartintr>:

void
uartintr(void)
{
80106100:	55                   	push   %ebp
80106101:	89 e5                	mov    %esp,%ebp
80106103:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80106106:	68 90 5f 10 80       	push   $0x80105f90
8010610b:	e8 a0 a8 ff ff       	call   801009b0 <consoleintr>
}
80106110:	83 c4 10             	add    $0x10,%esp
80106113:	c9                   	leave  
80106114:	c3                   	ret    

80106115 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106115:	6a 00                	push   $0x0
  pushl $0
80106117:	6a 00                	push   $0x0
  jmp alltraps
80106119:	e9 dc fa ff ff       	jmp    80105bfa <alltraps>

8010611e <vector1>:
.globl vector1
vector1:
  pushl $0
8010611e:	6a 00                	push   $0x0
  pushl $1
80106120:	6a 01                	push   $0x1
  jmp alltraps
80106122:	e9 d3 fa ff ff       	jmp    80105bfa <alltraps>

80106127 <vector2>:
.globl vector2
vector2:
  pushl $0
80106127:	6a 00                	push   $0x0
  pushl $2
80106129:	6a 02                	push   $0x2
  jmp alltraps
8010612b:	e9 ca fa ff ff       	jmp    80105bfa <alltraps>

80106130 <vector3>:
.globl vector3
vector3:
  pushl $0
80106130:	6a 00                	push   $0x0
  pushl $3
80106132:	6a 03                	push   $0x3
  jmp alltraps
80106134:	e9 c1 fa ff ff       	jmp    80105bfa <alltraps>

80106139 <vector4>:
.globl vector4
vector4:
  pushl $0
80106139:	6a 00                	push   $0x0
  pushl $4
8010613b:	6a 04                	push   $0x4
  jmp alltraps
8010613d:	e9 b8 fa ff ff       	jmp    80105bfa <alltraps>

80106142 <vector5>:
.globl vector5
vector5:
  pushl $0
80106142:	6a 00                	push   $0x0
  pushl $5
80106144:	6a 05                	push   $0x5
  jmp alltraps
80106146:	e9 af fa ff ff       	jmp    80105bfa <alltraps>

8010614b <vector6>:
.globl vector6
vector6:
  pushl $0
8010614b:	6a 00                	push   $0x0
  pushl $6
8010614d:	6a 06                	push   $0x6
  jmp alltraps
8010614f:	e9 a6 fa ff ff       	jmp    80105bfa <alltraps>

80106154 <vector7>:
.globl vector7
vector7:
  pushl $0
80106154:	6a 00                	push   $0x0
  pushl $7
80106156:	6a 07                	push   $0x7
  jmp alltraps
80106158:	e9 9d fa ff ff       	jmp    80105bfa <alltraps>

8010615d <vector8>:
.globl vector8
vector8:
  pushl $8
8010615d:	6a 08                	push   $0x8
  jmp alltraps
8010615f:	e9 96 fa ff ff       	jmp    80105bfa <alltraps>

80106164 <vector9>:
.globl vector9
vector9:
  pushl $0
80106164:	6a 00                	push   $0x0
  pushl $9
80106166:	6a 09                	push   $0x9
  jmp alltraps
80106168:	e9 8d fa ff ff       	jmp    80105bfa <alltraps>

8010616d <vector10>:
.globl vector10
vector10:
  pushl $10
8010616d:	6a 0a                	push   $0xa
  jmp alltraps
8010616f:	e9 86 fa ff ff       	jmp    80105bfa <alltraps>

80106174 <vector11>:
.globl vector11
vector11:
  pushl $11
80106174:	6a 0b                	push   $0xb
  jmp alltraps
80106176:	e9 7f fa ff ff       	jmp    80105bfa <alltraps>

8010617b <vector12>:
.globl vector12
vector12:
  pushl $12
8010617b:	6a 0c                	push   $0xc
  jmp alltraps
8010617d:	e9 78 fa ff ff       	jmp    80105bfa <alltraps>

80106182 <vector13>:
.globl vector13
vector13:
  pushl $13
80106182:	6a 0d                	push   $0xd
  jmp alltraps
80106184:	e9 71 fa ff ff       	jmp    80105bfa <alltraps>

80106189 <vector14>:
.globl vector14
vector14:
  pushl $14
80106189:	6a 0e                	push   $0xe
  jmp alltraps
8010618b:	e9 6a fa ff ff       	jmp    80105bfa <alltraps>

80106190 <vector15>:
.globl vector15
vector15:
  pushl $0
80106190:	6a 00                	push   $0x0
  pushl $15
80106192:	6a 0f                	push   $0xf
  jmp alltraps
80106194:	e9 61 fa ff ff       	jmp    80105bfa <alltraps>

80106199 <vector16>:
.globl vector16
vector16:
  pushl $0
80106199:	6a 00                	push   $0x0
  pushl $16
8010619b:	6a 10                	push   $0x10
  jmp alltraps
8010619d:	e9 58 fa ff ff       	jmp    80105bfa <alltraps>

801061a2 <vector17>:
.globl vector17
vector17:
  pushl $17
801061a2:	6a 11                	push   $0x11
  jmp alltraps
801061a4:	e9 51 fa ff ff       	jmp    80105bfa <alltraps>

801061a9 <vector18>:
.globl vector18
vector18:
  pushl $0
801061a9:	6a 00                	push   $0x0
  pushl $18
801061ab:	6a 12                	push   $0x12
  jmp alltraps
801061ad:	e9 48 fa ff ff       	jmp    80105bfa <alltraps>

801061b2 <vector19>:
.globl vector19
vector19:
  pushl $0
801061b2:	6a 00                	push   $0x0
  pushl $19
801061b4:	6a 13                	push   $0x13
  jmp alltraps
801061b6:	e9 3f fa ff ff       	jmp    80105bfa <alltraps>

801061bb <vector20>:
.globl vector20
vector20:
  pushl $0
801061bb:	6a 00                	push   $0x0
  pushl $20
801061bd:	6a 14                	push   $0x14
  jmp alltraps
801061bf:	e9 36 fa ff ff       	jmp    80105bfa <alltraps>

801061c4 <vector21>:
.globl vector21
vector21:
  pushl $0
801061c4:	6a 00                	push   $0x0
  pushl $21
801061c6:	6a 15                	push   $0x15
  jmp alltraps
801061c8:	e9 2d fa ff ff       	jmp    80105bfa <alltraps>

801061cd <vector22>:
.globl vector22
vector22:
  pushl $0
801061cd:	6a 00                	push   $0x0
  pushl $22
801061cf:	6a 16                	push   $0x16
  jmp alltraps
801061d1:	e9 24 fa ff ff       	jmp    80105bfa <alltraps>

801061d6 <vector23>:
.globl vector23
vector23:
  pushl $0
801061d6:	6a 00                	push   $0x0
  pushl $23
801061d8:	6a 17                	push   $0x17
  jmp alltraps
801061da:	e9 1b fa ff ff       	jmp    80105bfa <alltraps>

801061df <vector24>:
.globl vector24
vector24:
  pushl $0
801061df:	6a 00                	push   $0x0
  pushl $24
801061e1:	6a 18                	push   $0x18
  jmp alltraps
801061e3:	e9 12 fa ff ff       	jmp    80105bfa <alltraps>

801061e8 <vector25>:
.globl vector25
vector25:
  pushl $0
801061e8:	6a 00                	push   $0x0
  pushl $25
801061ea:	6a 19                	push   $0x19
  jmp alltraps
801061ec:	e9 09 fa ff ff       	jmp    80105bfa <alltraps>

801061f1 <vector26>:
.globl vector26
vector26:
  pushl $0
801061f1:	6a 00                	push   $0x0
  pushl $26
801061f3:	6a 1a                	push   $0x1a
  jmp alltraps
801061f5:	e9 00 fa ff ff       	jmp    80105bfa <alltraps>

801061fa <vector27>:
.globl vector27
vector27:
  pushl $0
801061fa:	6a 00                	push   $0x0
  pushl $27
801061fc:	6a 1b                	push   $0x1b
  jmp alltraps
801061fe:	e9 f7 f9 ff ff       	jmp    80105bfa <alltraps>

80106203 <vector28>:
.globl vector28
vector28:
  pushl $0
80106203:	6a 00                	push   $0x0
  pushl $28
80106205:	6a 1c                	push   $0x1c
  jmp alltraps
80106207:	e9 ee f9 ff ff       	jmp    80105bfa <alltraps>

8010620c <vector29>:
.globl vector29
vector29:
  pushl $0
8010620c:	6a 00                	push   $0x0
  pushl $29
8010620e:	6a 1d                	push   $0x1d
  jmp alltraps
80106210:	e9 e5 f9 ff ff       	jmp    80105bfa <alltraps>

80106215 <vector30>:
.globl vector30
vector30:
  pushl $0
80106215:	6a 00                	push   $0x0
  pushl $30
80106217:	6a 1e                	push   $0x1e
  jmp alltraps
80106219:	e9 dc f9 ff ff       	jmp    80105bfa <alltraps>

8010621e <vector31>:
.globl vector31
vector31:
  pushl $0
8010621e:	6a 00                	push   $0x0
  pushl $31
80106220:	6a 1f                	push   $0x1f
  jmp alltraps
80106222:	e9 d3 f9 ff ff       	jmp    80105bfa <alltraps>

80106227 <vector32>:
.globl vector32
vector32:
  pushl $0
80106227:	6a 00                	push   $0x0
  pushl $32
80106229:	6a 20                	push   $0x20
  jmp alltraps
8010622b:	e9 ca f9 ff ff       	jmp    80105bfa <alltraps>

80106230 <vector33>:
.globl vector33
vector33:
  pushl $0
80106230:	6a 00                	push   $0x0
  pushl $33
80106232:	6a 21                	push   $0x21
  jmp alltraps
80106234:	e9 c1 f9 ff ff       	jmp    80105bfa <alltraps>

80106239 <vector34>:
.globl vector34
vector34:
  pushl $0
80106239:	6a 00                	push   $0x0
  pushl $34
8010623b:	6a 22                	push   $0x22
  jmp alltraps
8010623d:	e9 b8 f9 ff ff       	jmp    80105bfa <alltraps>

80106242 <vector35>:
.globl vector35
vector35:
  pushl $0
80106242:	6a 00                	push   $0x0
  pushl $35
80106244:	6a 23                	push   $0x23
  jmp alltraps
80106246:	e9 af f9 ff ff       	jmp    80105bfa <alltraps>

8010624b <vector36>:
.globl vector36
vector36:
  pushl $0
8010624b:	6a 00                	push   $0x0
  pushl $36
8010624d:	6a 24                	push   $0x24
  jmp alltraps
8010624f:	e9 a6 f9 ff ff       	jmp    80105bfa <alltraps>

80106254 <vector37>:
.globl vector37
vector37:
  pushl $0
80106254:	6a 00                	push   $0x0
  pushl $37
80106256:	6a 25                	push   $0x25
  jmp alltraps
80106258:	e9 9d f9 ff ff       	jmp    80105bfa <alltraps>

8010625d <vector38>:
.globl vector38
vector38:
  pushl $0
8010625d:	6a 00                	push   $0x0
  pushl $38
8010625f:	6a 26                	push   $0x26
  jmp alltraps
80106261:	e9 94 f9 ff ff       	jmp    80105bfa <alltraps>

80106266 <vector39>:
.globl vector39
vector39:
  pushl $0
80106266:	6a 00                	push   $0x0
  pushl $39
80106268:	6a 27                	push   $0x27
  jmp alltraps
8010626a:	e9 8b f9 ff ff       	jmp    80105bfa <alltraps>

8010626f <vector40>:
.globl vector40
vector40:
  pushl $0
8010626f:	6a 00                	push   $0x0
  pushl $40
80106271:	6a 28                	push   $0x28
  jmp alltraps
80106273:	e9 82 f9 ff ff       	jmp    80105bfa <alltraps>

80106278 <vector41>:
.globl vector41
vector41:
  pushl $0
80106278:	6a 00                	push   $0x0
  pushl $41
8010627a:	6a 29                	push   $0x29
  jmp alltraps
8010627c:	e9 79 f9 ff ff       	jmp    80105bfa <alltraps>

80106281 <vector42>:
.globl vector42
vector42:
  pushl $0
80106281:	6a 00                	push   $0x0
  pushl $42
80106283:	6a 2a                	push   $0x2a
  jmp alltraps
80106285:	e9 70 f9 ff ff       	jmp    80105bfa <alltraps>

8010628a <vector43>:
.globl vector43
vector43:
  pushl $0
8010628a:	6a 00                	push   $0x0
  pushl $43
8010628c:	6a 2b                	push   $0x2b
  jmp alltraps
8010628e:	e9 67 f9 ff ff       	jmp    80105bfa <alltraps>

80106293 <vector44>:
.globl vector44
vector44:
  pushl $0
80106293:	6a 00                	push   $0x0
  pushl $44
80106295:	6a 2c                	push   $0x2c
  jmp alltraps
80106297:	e9 5e f9 ff ff       	jmp    80105bfa <alltraps>

8010629c <vector45>:
.globl vector45
vector45:
  pushl $0
8010629c:	6a 00                	push   $0x0
  pushl $45
8010629e:	6a 2d                	push   $0x2d
  jmp alltraps
801062a0:	e9 55 f9 ff ff       	jmp    80105bfa <alltraps>

801062a5 <vector46>:
.globl vector46
vector46:
  pushl $0
801062a5:	6a 00                	push   $0x0
  pushl $46
801062a7:	6a 2e                	push   $0x2e
  jmp alltraps
801062a9:	e9 4c f9 ff ff       	jmp    80105bfa <alltraps>

801062ae <vector47>:
.globl vector47
vector47:
  pushl $0
801062ae:	6a 00                	push   $0x0
  pushl $47
801062b0:	6a 2f                	push   $0x2f
  jmp alltraps
801062b2:	e9 43 f9 ff ff       	jmp    80105bfa <alltraps>

801062b7 <vector48>:
.globl vector48
vector48:
  pushl $0
801062b7:	6a 00                	push   $0x0
  pushl $48
801062b9:	6a 30                	push   $0x30
  jmp alltraps
801062bb:	e9 3a f9 ff ff       	jmp    80105bfa <alltraps>

801062c0 <vector49>:
.globl vector49
vector49:
  pushl $0
801062c0:	6a 00                	push   $0x0
  pushl $49
801062c2:	6a 31                	push   $0x31
  jmp alltraps
801062c4:	e9 31 f9 ff ff       	jmp    80105bfa <alltraps>

801062c9 <vector50>:
.globl vector50
vector50:
  pushl $0
801062c9:	6a 00                	push   $0x0
  pushl $50
801062cb:	6a 32                	push   $0x32
  jmp alltraps
801062cd:	e9 28 f9 ff ff       	jmp    80105bfa <alltraps>

801062d2 <vector51>:
.globl vector51
vector51:
  pushl $0
801062d2:	6a 00                	push   $0x0
  pushl $51
801062d4:	6a 33                	push   $0x33
  jmp alltraps
801062d6:	e9 1f f9 ff ff       	jmp    80105bfa <alltraps>

801062db <vector52>:
.globl vector52
vector52:
  pushl $0
801062db:	6a 00                	push   $0x0
  pushl $52
801062dd:	6a 34                	push   $0x34
  jmp alltraps
801062df:	e9 16 f9 ff ff       	jmp    80105bfa <alltraps>

801062e4 <vector53>:
.globl vector53
vector53:
  pushl $0
801062e4:	6a 00                	push   $0x0
  pushl $53
801062e6:	6a 35                	push   $0x35
  jmp alltraps
801062e8:	e9 0d f9 ff ff       	jmp    80105bfa <alltraps>

801062ed <vector54>:
.globl vector54
vector54:
  pushl $0
801062ed:	6a 00                	push   $0x0
  pushl $54
801062ef:	6a 36                	push   $0x36
  jmp alltraps
801062f1:	e9 04 f9 ff ff       	jmp    80105bfa <alltraps>

801062f6 <vector55>:
.globl vector55
vector55:
  pushl $0
801062f6:	6a 00                	push   $0x0
  pushl $55
801062f8:	6a 37                	push   $0x37
  jmp alltraps
801062fa:	e9 fb f8 ff ff       	jmp    80105bfa <alltraps>

801062ff <vector56>:
.globl vector56
vector56:
  pushl $0
801062ff:	6a 00                	push   $0x0
  pushl $56
80106301:	6a 38                	push   $0x38
  jmp alltraps
80106303:	e9 f2 f8 ff ff       	jmp    80105bfa <alltraps>

80106308 <vector57>:
.globl vector57
vector57:
  pushl $0
80106308:	6a 00                	push   $0x0
  pushl $57
8010630a:	6a 39                	push   $0x39
  jmp alltraps
8010630c:	e9 e9 f8 ff ff       	jmp    80105bfa <alltraps>

80106311 <vector58>:
.globl vector58
vector58:
  pushl $0
80106311:	6a 00                	push   $0x0
  pushl $58
80106313:	6a 3a                	push   $0x3a
  jmp alltraps
80106315:	e9 e0 f8 ff ff       	jmp    80105bfa <alltraps>

8010631a <vector59>:
.globl vector59
vector59:
  pushl $0
8010631a:	6a 00                	push   $0x0
  pushl $59
8010631c:	6a 3b                	push   $0x3b
  jmp alltraps
8010631e:	e9 d7 f8 ff ff       	jmp    80105bfa <alltraps>

80106323 <vector60>:
.globl vector60
vector60:
  pushl $0
80106323:	6a 00                	push   $0x0
  pushl $60
80106325:	6a 3c                	push   $0x3c
  jmp alltraps
80106327:	e9 ce f8 ff ff       	jmp    80105bfa <alltraps>

8010632c <vector61>:
.globl vector61
vector61:
  pushl $0
8010632c:	6a 00                	push   $0x0
  pushl $61
8010632e:	6a 3d                	push   $0x3d
  jmp alltraps
80106330:	e9 c5 f8 ff ff       	jmp    80105bfa <alltraps>

80106335 <vector62>:
.globl vector62
vector62:
  pushl $0
80106335:	6a 00                	push   $0x0
  pushl $62
80106337:	6a 3e                	push   $0x3e
  jmp alltraps
80106339:	e9 bc f8 ff ff       	jmp    80105bfa <alltraps>

8010633e <vector63>:
.globl vector63
vector63:
  pushl $0
8010633e:	6a 00                	push   $0x0
  pushl $63
80106340:	6a 3f                	push   $0x3f
  jmp alltraps
80106342:	e9 b3 f8 ff ff       	jmp    80105bfa <alltraps>

80106347 <vector64>:
.globl vector64
vector64:
  pushl $0
80106347:	6a 00                	push   $0x0
  pushl $64
80106349:	6a 40                	push   $0x40
  jmp alltraps
8010634b:	e9 aa f8 ff ff       	jmp    80105bfa <alltraps>

80106350 <vector65>:
.globl vector65
vector65:
  pushl $0
80106350:	6a 00                	push   $0x0
  pushl $65
80106352:	6a 41                	push   $0x41
  jmp alltraps
80106354:	e9 a1 f8 ff ff       	jmp    80105bfa <alltraps>

80106359 <vector66>:
.globl vector66
vector66:
  pushl $0
80106359:	6a 00                	push   $0x0
  pushl $66
8010635b:	6a 42                	push   $0x42
  jmp alltraps
8010635d:	e9 98 f8 ff ff       	jmp    80105bfa <alltraps>

80106362 <vector67>:
.globl vector67
vector67:
  pushl $0
80106362:	6a 00                	push   $0x0
  pushl $67
80106364:	6a 43                	push   $0x43
  jmp alltraps
80106366:	e9 8f f8 ff ff       	jmp    80105bfa <alltraps>

8010636b <vector68>:
.globl vector68
vector68:
  pushl $0
8010636b:	6a 00                	push   $0x0
  pushl $68
8010636d:	6a 44                	push   $0x44
  jmp alltraps
8010636f:	e9 86 f8 ff ff       	jmp    80105bfa <alltraps>

80106374 <vector69>:
.globl vector69
vector69:
  pushl $0
80106374:	6a 00                	push   $0x0
  pushl $69
80106376:	6a 45                	push   $0x45
  jmp alltraps
80106378:	e9 7d f8 ff ff       	jmp    80105bfa <alltraps>

8010637d <vector70>:
.globl vector70
vector70:
  pushl $0
8010637d:	6a 00                	push   $0x0
  pushl $70
8010637f:	6a 46                	push   $0x46
  jmp alltraps
80106381:	e9 74 f8 ff ff       	jmp    80105bfa <alltraps>

80106386 <vector71>:
.globl vector71
vector71:
  pushl $0
80106386:	6a 00                	push   $0x0
  pushl $71
80106388:	6a 47                	push   $0x47
  jmp alltraps
8010638a:	e9 6b f8 ff ff       	jmp    80105bfa <alltraps>

8010638f <vector72>:
.globl vector72
vector72:
  pushl $0
8010638f:	6a 00                	push   $0x0
  pushl $72
80106391:	6a 48                	push   $0x48
  jmp alltraps
80106393:	e9 62 f8 ff ff       	jmp    80105bfa <alltraps>

80106398 <vector73>:
.globl vector73
vector73:
  pushl $0
80106398:	6a 00                	push   $0x0
  pushl $73
8010639a:	6a 49                	push   $0x49
  jmp alltraps
8010639c:	e9 59 f8 ff ff       	jmp    80105bfa <alltraps>

801063a1 <vector74>:
.globl vector74
vector74:
  pushl $0
801063a1:	6a 00                	push   $0x0
  pushl $74
801063a3:	6a 4a                	push   $0x4a
  jmp alltraps
801063a5:	e9 50 f8 ff ff       	jmp    80105bfa <alltraps>

801063aa <vector75>:
.globl vector75
vector75:
  pushl $0
801063aa:	6a 00                	push   $0x0
  pushl $75
801063ac:	6a 4b                	push   $0x4b
  jmp alltraps
801063ae:	e9 47 f8 ff ff       	jmp    80105bfa <alltraps>

801063b3 <vector76>:
.globl vector76
vector76:
  pushl $0
801063b3:	6a 00                	push   $0x0
  pushl $76
801063b5:	6a 4c                	push   $0x4c
  jmp alltraps
801063b7:	e9 3e f8 ff ff       	jmp    80105bfa <alltraps>

801063bc <vector77>:
.globl vector77
vector77:
  pushl $0
801063bc:	6a 00                	push   $0x0
  pushl $77
801063be:	6a 4d                	push   $0x4d
  jmp alltraps
801063c0:	e9 35 f8 ff ff       	jmp    80105bfa <alltraps>

801063c5 <vector78>:
.globl vector78
vector78:
  pushl $0
801063c5:	6a 00                	push   $0x0
  pushl $78
801063c7:	6a 4e                	push   $0x4e
  jmp alltraps
801063c9:	e9 2c f8 ff ff       	jmp    80105bfa <alltraps>

801063ce <vector79>:
.globl vector79
vector79:
  pushl $0
801063ce:	6a 00                	push   $0x0
  pushl $79
801063d0:	6a 4f                	push   $0x4f
  jmp alltraps
801063d2:	e9 23 f8 ff ff       	jmp    80105bfa <alltraps>

801063d7 <vector80>:
.globl vector80
vector80:
  pushl $0
801063d7:	6a 00                	push   $0x0
  pushl $80
801063d9:	6a 50                	push   $0x50
  jmp alltraps
801063db:	e9 1a f8 ff ff       	jmp    80105bfa <alltraps>

801063e0 <vector81>:
.globl vector81
vector81:
  pushl $0
801063e0:	6a 00                	push   $0x0
  pushl $81
801063e2:	6a 51                	push   $0x51
  jmp alltraps
801063e4:	e9 11 f8 ff ff       	jmp    80105bfa <alltraps>

801063e9 <vector82>:
.globl vector82
vector82:
  pushl $0
801063e9:	6a 00                	push   $0x0
  pushl $82
801063eb:	6a 52                	push   $0x52
  jmp alltraps
801063ed:	e9 08 f8 ff ff       	jmp    80105bfa <alltraps>

801063f2 <vector83>:
.globl vector83
vector83:
  pushl $0
801063f2:	6a 00                	push   $0x0
  pushl $83
801063f4:	6a 53                	push   $0x53
  jmp alltraps
801063f6:	e9 ff f7 ff ff       	jmp    80105bfa <alltraps>

801063fb <vector84>:
.globl vector84
vector84:
  pushl $0
801063fb:	6a 00                	push   $0x0
  pushl $84
801063fd:	6a 54                	push   $0x54
  jmp alltraps
801063ff:	e9 f6 f7 ff ff       	jmp    80105bfa <alltraps>

80106404 <vector85>:
.globl vector85
vector85:
  pushl $0
80106404:	6a 00                	push   $0x0
  pushl $85
80106406:	6a 55                	push   $0x55
  jmp alltraps
80106408:	e9 ed f7 ff ff       	jmp    80105bfa <alltraps>

8010640d <vector86>:
.globl vector86
vector86:
  pushl $0
8010640d:	6a 00                	push   $0x0
  pushl $86
8010640f:	6a 56                	push   $0x56
  jmp alltraps
80106411:	e9 e4 f7 ff ff       	jmp    80105bfa <alltraps>

80106416 <vector87>:
.globl vector87
vector87:
  pushl $0
80106416:	6a 00                	push   $0x0
  pushl $87
80106418:	6a 57                	push   $0x57
  jmp alltraps
8010641a:	e9 db f7 ff ff       	jmp    80105bfa <alltraps>

8010641f <vector88>:
.globl vector88
vector88:
  pushl $0
8010641f:	6a 00                	push   $0x0
  pushl $88
80106421:	6a 58                	push   $0x58
  jmp alltraps
80106423:	e9 d2 f7 ff ff       	jmp    80105bfa <alltraps>

80106428 <vector89>:
.globl vector89
vector89:
  pushl $0
80106428:	6a 00                	push   $0x0
  pushl $89
8010642a:	6a 59                	push   $0x59
  jmp alltraps
8010642c:	e9 c9 f7 ff ff       	jmp    80105bfa <alltraps>

80106431 <vector90>:
.globl vector90
vector90:
  pushl $0
80106431:	6a 00                	push   $0x0
  pushl $90
80106433:	6a 5a                	push   $0x5a
  jmp alltraps
80106435:	e9 c0 f7 ff ff       	jmp    80105bfa <alltraps>

8010643a <vector91>:
.globl vector91
vector91:
  pushl $0
8010643a:	6a 00                	push   $0x0
  pushl $91
8010643c:	6a 5b                	push   $0x5b
  jmp alltraps
8010643e:	e9 b7 f7 ff ff       	jmp    80105bfa <alltraps>

80106443 <vector92>:
.globl vector92
vector92:
  pushl $0
80106443:	6a 00                	push   $0x0
  pushl $92
80106445:	6a 5c                	push   $0x5c
  jmp alltraps
80106447:	e9 ae f7 ff ff       	jmp    80105bfa <alltraps>

8010644c <vector93>:
.globl vector93
vector93:
  pushl $0
8010644c:	6a 00                	push   $0x0
  pushl $93
8010644e:	6a 5d                	push   $0x5d
  jmp alltraps
80106450:	e9 a5 f7 ff ff       	jmp    80105bfa <alltraps>

80106455 <vector94>:
.globl vector94
vector94:
  pushl $0
80106455:	6a 00                	push   $0x0
  pushl $94
80106457:	6a 5e                	push   $0x5e
  jmp alltraps
80106459:	e9 9c f7 ff ff       	jmp    80105bfa <alltraps>

8010645e <vector95>:
.globl vector95
vector95:
  pushl $0
8010645e:	6a 00                	push   $0x0
  pushl $95
80106460:	6a 5f                	push   $0x5f
  jmp alltraps
80106462:	e9 93 f7 ff ff       	jmp    80105bfa <alltraps>

80106467 <vector96>:
.globl vector96
vector96:
  pushl $0
80106467:	6a 00                	push   $0x0
  pushl $96
80106469:	6a 60                	push   $0x60
  jmp alltraps
8010646b:	e9 8a f7 ff ff       	jmp    80105bfa <alltraps>

80106470 <vector97>:
.globl vector97
vector97:
  pushl $0
80106470:	6a 00                	push   $0x0
  pushl $97
80106472:	6a 61                	push   $0x61
  jmp alltraps
80106474:	e9 81 f7 ff ff       	jmp    80105bfa <alltraps>

80106479 <vector98>:
.globl vector98
vector98:
  pushl $0
80106479:	6a 00                	push   $0x0
  pushl $98
8010647b:	6a 62                	push   $0x62
  jmp alltraps
8010647d:	e9 78 f7 ff ff       	jmp    80105bfa <alltraps>

80106482 <vector99>:
.globl vector99
vector99:
  pushl $0
80106482:	6a 00                	push   $0x0
  pushl $99
80106484:	6a 63                	push   $0x63
  jmp alltraps
80106486:	e9 6f f7 ff ff       	jmp    80105bfa <alltraps>

8010648b <vector100>:
.globl vector100
vector100:
  pushl $0
8010648b:	6a 00                	push   $0x0
  pushl $100
8010648d:	6a 64                	push   $0x64
  jmp alltraps
8010648f:	e9 66 f7 ff ff       	jmp    80105bfa <alltraps>

80106494 <vector101>:
.globl vector101
vector101:
  pushl $0
80106494:	6a 00                	push   $0x0
  pushl $101
80106496:	6a 65                	push   $0x65
  jmp alltraps
80106498:	e9 5d f7 ff ff       	jmp    80105bfa <alltraps>

8010649d <vector102>:
.globl vector102
vector102:
  pushl $0
8010649d:	6a 00                	push   $0x0
  pushl $102
8010649f:	6a 66                	push   $0x66
  jmp alltraps
801064a1:	e9 54 f7 ff ff       	jmp    80105bfa <alltraps>

801064a6 <vector103>:
.globl vector103
vector103:
  pushl $0
801064a6:	6a 00                	push   $0x0
  pushl $103
801064a8:	6a 67                	push   $0x67
  jmp alltraps
801064aa:	e9 4b f7 ff ff       	jmp    80105bfa <alltraps>

801064af <vector104>:
.globl vector104
vector104:
  pushl $0
801064af:	6a 00                	push   $0x0
  pushl $104
801064b1:	6a 68                	push   $0x68
  jmp alltraps
801064b3:	e9 42 f7 ff ff       	jmp    80105bfa <alltraps>

801064b8 <vector105>:
.globl vector105
vector105:
  pushl $0
801064b8:	6a 00                	push   $0x0
  pushl $105
801064ba:	6a 69                	push   $0x69
  jmp alltraps
801064bc:	e9 39 f7 ff ff       	jmp    80105bfa <alltraps>

801064c1 <vector106>:
.globl vector106
vector106:
  pushl $0
801064c1:	6a 00                	push   $0x0
  pushl $106
801064c3:	6a 6a                	push   $0x6a
  jmp alltraps
801064c5:	e9 30 f7 ff ff       	jmp    80105bfa <alltraps>

801064ca <vector107>:
.globl vector107
vector107:
  pushl $0
801064ca:	6a 00                	push   $0x0
  pushl $107
801064cc:	6a 6b                	push   $0x6b
  jmp alltraps
801064ce:	e9 27 f7 ff ff       	jmp    80105bfa <alltraps>

801064d3 <vector108>:
.globl vector108
vector108:
  pushl $0
801064d3:	6a 00                	push   $0x0
  pushl $108
801064d5:	6a 6c                	push   $0x6c
  jmp alltraps
801064d7:	e9 1e f7 ff ff       	jmp    80105bfa <alltraps>

801064dc <vector109>:
.globl vector109
vector109:
  pushl $0
801064dc:	6a 00                	push   $0x0
  pushl $109
801064de:	6a 6d                	push   $0x6d
  jmp alltraps
801064e0:	e9 15 f7 ff ff       	jmp    80105bfa <alltraps>

801064e5 <vector110>:
.globl vector110
vector110:
  pushl $0
801064e5:	6a 00                	push   $0x0
  pushl $110
801064e7:	6a 6e                	push   $0x6e
  jmp alltraps
801064e9:	e9 0c f7 ff ff       	jmp    80105bfa <alltraps>

801064ee <vector111>:
.globl vector111
vector111:
  pushl $0
801064ee:	6a 00                	push   $0x0
  pushl $111
801064f0:	6a 6f                	push   $0x6f
  jmp alltraps
801064f2:	e9 03 f7 ff ff       	jmp    80105bfa <alltraps>

801064f7 <vector112>:
.globl vector112
vector112:
  pushl $0
801064f7:	6a 00                	push   $0x0
  pushl $112
801064f9:	6a 70                	push   $0x70
  jmp alltraps
801064fb:	e9 fa f6 ff ff       	jmp    80105bfa <alltraps>

80106500 <vector113>:
.globl vector113
vector113:
  pushl $0
80106500:	6a 00                	push   $0x0
  pushl $113
80106502:	6a 71                	push   $0x71
  jmp alltraps
80106504:	e9 f1 f6 ff ff       	jmp    80105bfa <alltraps>

80106509 <vector114>:
.globl vector114
vector114:
  pushl $0
80106509:	6a 00                	push   $0x0
  pushl $114
8010650b:	6a 72                	push   $0x72
  jmp alltraps
8010650d:	e9 e8 f6 ff ff       	jmp    80105bfa <alltraps>

80106512 <vector115>:
.globl vector115
vector115:
  pushl $0
80106512:	6a 00                	push   $0x0
  pushl $115
80106514:	6a 73                	push   $0x73
  jmp alltraps
80106516:	e9 df f6 ff ff       	jmp    80105bfa <alltraps>

8010651b <vector116>:
.globl vector116
vector116:
  pushl $0
8010651b:	6a 00                	push   $0x0
  pushl $116
8010651d:	6a 74                	push   $0x74
  jmp alltraps
8010651f:	e9 d6 f6 ff ff       	jmp    80105bfa <alltraps>

80106524 <vector117>:
.globl vector117
vector117:
  pushl $0
80106524:	6a 00                	push   $0x0
  pushl $117
80106526:	6a 75                	push   $0x75
  jmp alltraps
80106528:	e9 cd f6 ff ff       	jmp    80105bfa <alltraps>

8010652d <vector118>:
.globl vector118
vector118:
  pushl $0
8010652d:	6a 00                	push   $0x0
  pushl $118
8010652f:	6a 76                	push   $0x76
  jmp alltraps
80106531:	e9 c4 f6 ff ff       	jmp    80105bfa <alltraps>

80106536 <vector119>:
.globl vector119
vector119:
  pushl $0
80106536:	6a 00                	push   $0x0
  pushl $119
80106538:	6a 77                	push   $0x77
  jmp alltraps
8010653a:	e9 bb f6 ff ff       	jmp    80105bfa <alltraps>

8010653f <vector120>:
.globl vector120
vector120:
  pushl $0
8010653f:	6a 00                	push   $0x0
  pushl $120
80106541:	6a 78                	push   $0x78
  jmp alltraps
80106543:	e9 b2 f6 ff ff       	jmp    80105bfa <alltraps>

80106548 <vector121>:
.globl vector121
vector121:
  pushl $0
80106548:	6a 00                	push   $0x0
  pushl $121
8010654a:	6a 79                	push   $0x79
  jmp alltraps
8010654c:	e9 a9 f6 ff ff       	jmp    80105bfa <alltraps>

80106551 <vector122>:
.globl vector122
vector122:
  pushl $0
80106551:	6a 00                	push   $0x0
  pushl $122
80106553:	6a 7a                	push   $0x7a
  jmp alltraps
80106555:	e9 a0 f6 ff ff       	jmp    80105bfa <alltraps>

8010655a <vector123>:
.globl vector123
vector123:
  pushl $0
8010655a:	6a 00                	push   $0x0
  pushl $123
8010655c:	6a 7b                	push   $0x7b
  jmp alltraps
8010655e:	e9 97 f6 ff ff       	jmp    80105bfa <alltraps>

80106563 <vector124>:
.globl vector124
vector124:
  pushl $0
80106563:	6a 00                	push   $0x0
  pushl $124
80106565:	6a 7c                	push   $0x7c
  jmp alltraps
80106567:	e9 8e f6 ff ff       	jmp    80105bfa <alltraps>

8010656c <vector125>:
.globl vector125
vector125:
  pushl $0
8010656c:	6a 00                	push   $0x0
  pushl $125
8010656e:	6a 7d                	push   $0x7d
  jmp alltraps
80106570:	e9 85 f6 ff ff       	jmp    80105bfa <alltraps>

80106575 <vector126>:
.globl vector126
vector126:
  pushl $0
80106575:	6a 00                	push   $0x0
  pushl $126
80106577:	6a 7e                	push   $0x7e
  jmp alltraps
80106579:	e9 7c f6 ff ff       	jmp    80105bfa <alltraps>

8010657e <vector127>:
.globl vector127
vector127:
  pushl $0
8010657e:	6a 00                	push   $0x0
  pushl $127
80106580:	6a 7f                	push   $0x7f
  jmp alltraps
80106582:	e9 73 f6 ff ff       	jmp    80105bfa <alltraps>

80106587 <vector128>:
.globl vector128
vector128:
  pushl $0
80106587:	6a 00                	push   $0x0
  pushl $128
80106589:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010658e:	e9 67 f6 ff ff       	jmp    80105bfa <alltraps>

80106593 <vector129>:
.globl vector129
vector129:
  pushl $0
80106593:	6a 00                	push   $0x0
  pushl $129
80106595:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010659a:	e9 5b f6 ff ff       	jmp    80105bfa <alltraps>

8010659f <vector130>:
.globl vector130
vector130:
  pushl $0
8010659f:	6a 00                	push   $0x0
  pushl $130
801065a1:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801065a6:	e9 4f f6 ff ff       	jmp    80105bfa <alltraps>

801065ab <vector131>:
.globl vector131
vector131:
  pushl $0
801065ab:	6a 00                	push   $0x0
  pushl $131
801065ad:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801065b2:	e9 43 f6 ff ff       	jmp    80105bfa <alltraps>

801065b7 <vector132>:
.globl vector132
vector132:
  pushl $0
801065b7:	6a 00                	push   $0x0
  pushl $132
801065b9:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801065be:	e9 37 f6 ff ff       	jmp    80105bfa <alltraps>

801065c3 <vector133>:
.globl vector133
vector133:
  pushl $0
801065c3:	6a 00                	push   $0x0
  pushl $133
801065c5:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801065ca:	e9 2b f6 ff ff       	jmp    80105bfa <alltraps>

801065cf <vector134>:
.globl vector134
vector134:
  pushl $0
801065cf:	6a 00                	push   $0x0
  pushl $134
801065d1:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801065d6:	e9 1f f6 ff ff       	jmp    80105bfa <alltraps>

801065db <vector135>:
.globl vector135
vector135:
  pushl $0
801065db:	6a 00                	push   $0x0
  pushl $135
801065dd:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801065e2:	e9 13 f6 ff ff       	jmp    80105bfa <alltraps>

801065e7 <vector136>:
.globl vector136
vector136:
  pushl $0
801065e7:	6a 00                	push   $0x0
  pushl $136
801065e9:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801065ee:	e9 07 f6 ff ff       	jmp    80105bfa <alltraps>

801065f3 <vector137>:
.globl vector137
vector137:
  pushl $0
801065f3:	6a 00                	push   $0x0
  pushl $137
801065f5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801065fa:	e9 fb f5 ff ff       	jmp    80105bfa <alltraps>

801065ff <vector138>:
.globl vector138
vector138:
  pushl $0
801065ff:	6a 00                	push   $0x0
  pushl $138
80106601:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106606:	e9 ef f5 ff ff       	jmp    80105bfa <alltraps>

8010660b <vector139>:
.globl vector139
vector139:
  pushl $0
8010660b:	6a 00                	push   $0x0
  pushl $139
8010660d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106612:	e9 e3 f5 ff ff       	jmp    80105bfa <alltraps>

80106617 <vector140>:
.globl vector140
vector140:
  pushl $0
80106617:	6a 00                	push   $0x0
  pushl $140
80106619:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010661e:	e9 d7 f5 ff ff       	jmp    80105bfa <alltraps>

80106623 <vector141>:
.globl vector141
vector141:
  pushl $0
80106623:	6a 00                	push   $0x0
  pushl $141
80106625:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010662a:	e9 cb f5 ff ff       	jmp    80105bfa <alltraps>

8010662f <vector142>:
.globl vector142
vector142:
  pushl $0
8010662f:	6a 00                	push   $0x0
  pushl $142
80106631:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106636:	e9 bf f5 ff ff       	jmp    80105bfa <alltraps>

8010663b <vector143>:
.globl vector143
vector143:
  pushl $0
8010663b:	6a 00                	push   $0x0
  pushl $143
8010663d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106642:	e9 b3 f5 ff ff       	jmp    80105bfa <alltraps>

80106647 <vector144>:
.globl vector144
vector144:
  pushl $0
80106647:	6a 00                	push   $0x0
  pushl $144
80106649:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010664e:	e9 a7 f5 ff ff       	jmp    80105bfa <alltraps>

80106653 <vector145>:
.globl vector145
vector145:
  pushl $0
80106653:	6a 00                	push   $0x0
  pushl $145
80106655:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010665a:	e9 9b f5 ff ff       	jmp    80105bfa <alltraps>

8010665f <vector146>:
.globl vector146
vector146:
  pushl $0
8010665f:	6a 00                	push   $0x0
  pushl $146
80106661:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106666:	e9 8f f5 ff ff       	jmp    80105bfa <alltraps>

8010666b <vector147>:
.globl vector147
vector147:
  pushl $0
8010666b:	6a 00                	push   $0x0
  pushl $147
8010666d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106672:	e9 83 f5 ff ff       	jmp    80105bfa <alltraps>

80106677 <vector148>:
.globl vector148
vector148:
  pushl $0
80106677:	6a 00                	push   $0x0
  pushl $148
80106679:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010667e:	e9 77 f5 ff ff       	jmp    80105bfa <alltraps>

80106683 <vector149>:
.globl vector149
vector149:
  pushl $0
80106683:	6a 00                	push   $0x0
  pushl $149
80106685:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010668a:	e9 6b f5 ff ff       	jmp    80105bfa <alltraps>

8010668f <vector150>:
.globl vector150
vector150:
  pushl $0
8010668f:	6a 00                	push   $0x0
  pushl $150
80106691:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106696:	e9 5f f5 ff ff       	jmp    80105bfa <alltraps>

8010669b <vector151>:
.globl vector151
vector151:
  pushl $0
8010669b:	6a 00                	push   $0x0
  pushl $151
8010669d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801066a2:	e9 53 f5 ff ff       	jmp    80105bfa <alltraps>

801066a7 <vector152>:
.globl vector152
vector152:
  pushl $0
801066a7:	6a 00                	push   $0x0
  pushl $152
801066a9:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801066ae:	e9 47 f5 ff ff       	jmp    80105bfa <alltraps>

801066b3 <vector153>:
.globl vector153
vector153:
  pushl $0
801066b3:	6a 00                	push   $0x0
  pushl $153
801066b5:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801066ba:	e9 3b f5 ff ff       	jmp    80105bfa <alltraps>

801066bf <vector154>:
.globl vector154
vector154:
  pushl $0
801066bf:	6a 00                	push   $0x0
  pushl $154
801066c1:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801066c6:	e9 2f f5 ff ff       	jmp    80105bfa <alltraps>

801066cb <vector155>:
.globl vector155
vector155:
  pushl $0
801066cb:	6a 00                	push   $0x0
  pushl $155
801066cd:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801066d2:	e9 23 f5 ff ff       	jmp    80105bfa <alltraps>

801066d7 <vector156>:
.globl vector156
vector156:
  pushl $0
801066d7:	6a 00                	push   $0x0
  pushl $156
801066d9:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801066de:	e9 17 f5 ff ff       	jmp    80105bfa <alltraps>

801066e3 <vector157>:
.globl vector157
vector157:
  pushl $0
801066e3:	6a 00                	push   $0x0
  pushl $157
801066e5:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801066ea:	e9 0b f5 ff ff       	jmp    80105bfa <alltraps>

801066ef <vector158>:
.globl vector158
vector158:
  pushl $0
801066ef:	6a 00                	push   $0x0
  pushl $158
801066f1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801066f6:	e9 ff f4 ff ff       	jmp    80105bfa <alltraps>

801066fb <vector159>:
.globl vector159
vector159:
  pushl $0
801066fb:	6a 00                	push   $0x0
  pushl $159
801066fd:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106702:	e9 f3 f4 ff ff       	jmp    80105bfa <alltraps>

80106707 <vector160>:
.globl vector160
vector160:
  pushl $0
80106707:	6a 00                	push   $0x0
  pushl $160
80106709:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010670e:	e9 e7 f4 ff ff       	jmp    80105bfa <alltraps>

80106713 <vector161>:
.globl vector161
vector161:
  pushl $0
80106713:	6a 00                	push   $0x0
  pushl $161
80106715:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010671a:	e9 db f4 ff ff       	jmp    80105bfa <alltraps>

8010671f <vector162>:
.globl vector162
vector162:
  pushl $0
8010671f:	6a 00                	push   $0x0
  pushl $162
80106721:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106726:	e9 cf f4 ff ff       	jmp    80105bfa <alltraps>

8010672b <vector163>:
.globl vector163
vector163:
  pushl $0
8010672b:	6a 00                	push   $0x0
  pushl $163
8010672d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106732:	e9 c3 f4 ff ff       	jmp    80105bfa <alltraps>

80106737 <vector164>:
.globl vector164
vector164:
  pushl $0
80106737:	6a 00                	push   $0x0
  pushl $164
80106739:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010673e:	e9 b7 f4 ff ff       	jmp    80105bfa <alltraps>

80106743 <vector165>:
.globl vector165
vector165:
  pushl $0
80106743:	6a 00                	push   $0x0
  pushl $165
80106745:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010674a:	e9 ab f4 ff ff       	jmp    80105bfa <alltraps>

8010674f <vector166>:
.globl vector166
vector166:
  pushl $0
8010674f:	6a 00                	push   $0x0
  pushl $166
80106751:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106756:	e9 9f f4 ff ff       	jmp    80105bfa <alltraps>

8010675b <vector167>:
.globl vector167
vector167:
  pushl $0
8010675b:	6a 00                	push   $0x0
  pushl $167
8010675d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106762:	e9 93 f4 ff ff       	jmp    80105bfa <alltraps>

80106767 <vector168>:
.globl vector168
vector168:
  pushl $0
80106767:	6a 00                	push   $0x0
  pushl $168
80106769:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010676e:	e9 87 f4 ff ff       	jmp    80105bfa <alltraps>

80106773 <vector169>:
.globl vector169
vector169:
  pushl $0
80106773:	6a 00                	push   $0x0
  pushl $169
80106775:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010677a:	e9 7b f4 ff ff       	jmp    80105bfa <alltraps>

8010677f <vector170>:
.globl vector170
vector170:
  pushl $0
8010677f:	6a 00                	push   $0x0
  pushl $170
80106781:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106786:	e9 6f f4 ff ff       	jmp    80105bfa <alltraps>

8010678b <vector171>:
.globl vector171
vector171:
  pushl $0
8010678b:	6a 00                	push   $0x0
  pushl $171
8010678d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106792:	e9 63 f4 ff ff       	jmp    80105bfa <alltraps>

80106797 <vector172>:
.globl vector172
vector172:
  pushl $0
80106797:	6a 00                	push   $0x0
  pushl $172
80106799:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010679e:	e9 57 f4 ff ff       	jmp    80105bfa <alltraps>

801067a3 <vector173>:
.globl vector173
vector173:
  pushl $0
801067a3:	6a 00                	push   $0x0
  pushl $173
801067a5:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801067aa:	e9 4b f4 ff ff       	jmp    80105bfa <alltraps>

801067af <vector174>:
.globl vector174
vector174:
  pushl $0
801067af:	6a 00                	push   $0x0
  pushl $174
801067b1:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801067b6:	e9 3f f4 ff ff       	jmp    80105bfa <alltraps>

801067bb <vector175>:
.globl vector175
vector175:
  pushl $0
801067bb:	6a 00                	push   $0x0
  pushl $175
801067bd:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801067c2:	e9 33 f4 ff ff       	jmp    80105bfa <alltraps>

801067c7 <vector176>:
.globl vector176
vector176:
  pushl $0
801067c7:	6a 00                	push   $0x0
  pushl $176
801067c9:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801067ce:	e9 27 f4 ff ff       	jmp    80105bfa <alltraps>

801067d3 <vector177>:
.globl vector177
vector177:
  pushl $0
801067d3:	6a 00                	push   $0x0
  pushl $177
801067d5:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801067da:	e9 1b f4 ff ff       	jmp    80105bfa <alltraps>

801067df <vector178>:
.globl vector178
vector178:
  pushl $0
801067df:	6a 00                	push   $0x0
  pushl $178
801067e1:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801067e6:	e9 0f f4 ff ff       	jmp    80105bfa <alltraps>

801067eb <vector179>:
.globl vector179
vector179:
  pushl $0
801067eb:	6a 00                	push   $0x0
  pushl $179
801067ed:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801067f2:	e9 03 f4 ff ff       	jmp    80105bfa <alltraps>

801067f7 <vector180>:
.globl vector180
vector180:
  pushl $0
801067f7:	6a 00                	push   $0x0
  pushl $180
801067f9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801067fe:	e9 f7 f3 ff ff       	jmp    80105bfa <alltraps>

80106803 <vector181>:
.globl vector181
vector181:
  pushl $0
80106803:	6a 00                	push   $0x0
  pushl $181
80106805:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010680a:	e9 eb f3 ff ff       	jmp    80105bfa <alltraps>

8010680f <vector182>:
.globl vector182
vector182:
  pushl $0
8010680f:	6a 00                	push   $0x0
  pushl $182
80106811:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106816:	e9 df f3 ff ff       	jmp    80105bfa <alltraps>

8010681b <vector183>:
.globl vector183
vector183:
  pushl $0
8010681b:	6a 00                	push   $0x0
  pushl $183
8010681d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106822:	e9 d3 f3 ff ff       	jmp    80105bfa <alltraps>

80106827 <vector184>:
.globl vector184
vector184:
  pushl $0
80106827:	6a 00                	push   $0x0
  pushl $184
80106829:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010682e:	e9 c7 f3 ff ff       	jmp    80105bfa <alltraps>

80106833 <vector185>:
.globl vector185
vector185:
  pushl $0
80106833:	6a 00                	push   $0x0
  pushl $185
80106835:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010683a:	e9 bb f3 ff ff       	jmp    80105bfa <alltraps>

8010683f <vector186>:
.globl vector186
vector186:
  pushl $0
8010683f:	6a 00                	push   $0x0
  pushl $186
80106841:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106846:	e9 af f3 ff ff       	jmp    80105bfa <alltraps>

8010684b <vector187>:
.globl vector187
vector187:
  pushl $0
8010684b:	6a 00                	push   $0x0
  pushl $187
8010684d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106852:	e9 a3 f3 ff ff       	jmp    80105bfa <alltraps>

80106857 <vector188>:
.globl vector188
vector188:
  pushl $0
80106857:	6a 00                	push   $0x0
  pushl $188
80106859:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010685e:	e9 97 f3 ff ff       	jmp    80105bfa <alltraps>

80106863 <vector189>:
.globl vector189
vector189:
  pushl $0
80106863:	6a 00                	push   $0x0
  pushl $189
80106865:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010686a:	e9 8b f3 ff ff       	jmp    80105bfa <alltraps>

8010686f <vector190>:
.globl vector190
vector190:
  pushl $0
8010686f:	6a 00                	push   $0x0
  pushl $190
80106871:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106876:	e9 7f f3 ff ff       	jmp    80105bfa <alltraps>

8010687b <vector191>:
.globl vector191
vector191:
  pushl $0
8010687b:	6a 00                	push   $0x0
  pushl $191
8010687d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106882:	e9 73 f3 ff ff       	jmp    80105bfa <alltraps>

80106887 <vector192>:
.globl vector192
vector192:
  pushl $0
80106887:	6a 00                	push   $0x0
  pushl $192
80106889:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010688e:	e9 67 f3 ff ff       	jmp    80105bfa <alltraps>

80106893 <vector193>:
.globl vector193
vector193:
  pushl $0
80106893:	6a 00                	push   $0x0
  pushl $193
80106895:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010689a:	e9 5b f3 ff ff       	jmp    80105bfa <alltraps>

8010689f <vector194>:
.globl vector194
vector194:
  pushl $0
8010689f:	6a 00                	push   $0x0
  pushl $194
801068a1:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801068a6:	e9 4f f3 ff ff       	jmp    80105bfa <alltraps>

801068ab <vector195>:
.globl vector195
vector195:
  pushl $0
801068ab:	6a 00                	push   $0x0
  pushl $195
801068ad:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801068b2:	e9 43 f3 ff ff       	jmp    80105bfa <alltraps>

801068b7 <vector196>:
.globl vector196
vector196:
  pushl $0
801068b7:	6a 00                	push   $0x0
  pushl $196
801068b9:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801068be:	e9 37 f3 ff ff       	jmp    80105bfa <alltraps>

801068c3 <vector197>:
.globl vector197
vector197:
  pushl $0
801068c3:	6a 00                	push   $0x0
  pushl $197
801068c5:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801068ca:	e9 2b f3 ff ff       	jmp    80105bfa <alltraps>

801068cf <vector198>:
.globl vector198
vector198:
  pushl $0
801068cf:	6a 00                	push   $0x0
  pushl $198
801068d1:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801068d6:	e9 1f f3 ff ff       	jmp    80105bfa <alltraps>

801068db <vector199>:
.globl vector199
vector199:
  pushl $0
801068db:	6a 00                	push   $0x0
  pushl $199
801068dd:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801068e2:	e9 13 f3 ff ff       	jmp    80105bfa <alltraps>

801068e7 <vector200>:
.globl vector200
vector200:
  pushl $0
801068e7:	6a 00                	push   $0x0
  pushl $200
801068e9:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801068ee:	e9 07 f3 ff ff       	jmp    80105bfa <alltraps>

801068f3 <vector201>:
.globl vector201
vector201:
  pushl $0
801068f3:	6a 00                	push   $0x0
  pushl $201
801068f5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801068fa:	e9 fb f2 ff ff       	jmp    80105bfa <alltraps>

801068ff <vector202>:
.globl vector202
vector202:
  pushl $0
801068ff:	6a 00                	push   $0x0
  pushl $202
80106901:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106906:	e9 ef f2 ff ff       	jmp    80105bfa <alltraps>

8010690b <vector203>:
.globl vector203
vector203:
  pushl $0
8010690b:	6a 00                	push   $0x0
  pushl $203
8010690d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106912:	e9 e3 f2 ff ff       	jmp    80105bfa <alltraps>

80106917 <vector204>:
.globl vector204
vector204:
  pushl $0
80106917:	6a 00                	push   $0x0
  pushl $204
80106919:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010691e:	e9 d7 f2 ff ff       	jmp    80105bfa <alltraps>

80106923 <vector205>:
.globl vector205
vector205:
  pushl $0
80106923:	6a 00                	push   $0x0
  pushl $205
80106925:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010692a:	e9 cb f2 ff ff       	jmp    80105bfa <alltraps>

8010692f <vector206>:
.globl vector206
vector206:
  pushl $0
8010692f:	6a 00                	push   $0x0
  pushl $206
80106931:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106936:	e9 bf f2 ff ff       	jmp    80105bfa <alltraps>

8010693b <vector207>:
.globl vector207
vector207:
  pushl $0
8010693b:	6a 00                	push   $0x0
  pushl $207
8010693d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106942:	e9 b3 f2 ff ff       	jmp    80105bfa <alltraps>

80106947 <vector208>:
.globl vector208
vector208:
  pushl $0
80106947:	6a 00                	push   $0x0
  pushl $208
80106949:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010694e:	e9 a7 f2 ff ff       	jmp    80105bfa <alltraps>

80106953 <vector209>:
.globl vector209
vector209:
  pushl $0
80106953:	6a 00                	push   $0x0
  pushl $209
80106955:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010695a:	e9 9b f2 ff ff       	jmp    80105bfa <alltraps>

8010695f <vector210>:
.globl vector210
vector210:
  pushl $0
8010695f:	6a 00                	push   $0x0
  pushl $210
80106961:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106966:	e9 8f f2 ff ff       	jmp    80105bfa <alltraps>

8010696b <vector211>:
.globl vector211
vector211:
  pushl $0
8010696b:	6a 00                	push   $0x0
  pushl $211
8010696d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106972:	e9 83 f2 ff ff       	jmp    80105bfa <alltraps>

80106977 <vector212>:
.globl vector212
vector212:
  pushl $0
80106977:	6a 00                	push   $0x0
  pushl $212
80106979:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010697e:	e9 77 f2 ff ff       	jmp    80105bfa <alltraps>

80106983 <vector213>:
.globl vector213
vector213:
  pushl $0
80106983:	6a 00                	push   $0x0
  pushl $213
80106985:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010698a:	e9 6b f2 ff ff       	jmp    80105bfa <alltraps>

8010698f <vector214>:
.globl vector214
vector214:
  pushl $0
8010698f:	6a 00                	push   $0x0
  pushl $214
80106991:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106996:	e9 5f f2 ff ff       	jmp    80105bfa <alltraps>

8010699b <vector215>:
.globl vector215
vector215:
  pushl $0
8010699b:	6a 00                	push   $0x0
  pushl $215
8010699d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801069a2:	e9 53 f2 ff ff       	jmp    80105bfa <alltraps>

801069a7 <vector216>:
.globl vector216
vector216:
  pushl $0
801069a7:	6a 00                	push   $0x0
  pushl $216
801069a9:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801069ae:	e9 47 f2 ff ff       	jmp    80105bfa <alltraps>

801069b3 <vector217>:
.globl vector217
vector217:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $217
801069b5:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801069ba:	e9 3b f2 ff ff       	jmp    80105bfa <alltraps>

801069bf <vector218>:
.globl vector218
vector218:
  pushl $0
801069bf:	6a 00                	push   $0x0
  pushl $218
801069c1:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801069c6:	e9 2f f2 ff ff       	jmp    80105bfa <alltraps>

801069cb <vector219>:
.globl vector219
vector219:
  pushl $0
801069cb:	6a 00                	push   $0x0
  pushl $219
801069cd:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801069d2:	e9 23 f2 ff ff       	jmp    80105bfa <alltraps>

801069d7 <vector220>:
.globl vector220
vector220:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $220
801069d9:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801069de:	e9 17 f2 ff ff       	jmp    80105bfa <alltraps>

801069e3 <vector221>:
.globl vector221
vector221:
  pushl $0
801069e3:	6a 00                	push   $0x0
  pushl $221
801069e5:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801069ea:	e9 0b f2 ff ff       	jmp    80105bfa <alltraps>

801069ef <vector222>:
.globl vector222
vector222:
  pushl $0
801069ef:	6a 00                	push   $0x0
  pushl $222
801069f1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801069f6:	e9 ff f1 ff ff       	jmp    80105bfa <alltraps>

801069fb <vector223>:
.globl vector223
vector223:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $223
801069fd:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106a02:	e9 f3 f1 ff ff       	jmp    80105bfa <alltraps>

80106a07 <vector224>:
.globl vector224
vector224:
  pushl $0
80106a07:	6a 00                	push   $0x0
  pushl $224
80106a09:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106a0e:	e9 e7 f1 ff ff       	jmp    80105bfa <alltraps>

80106a13 <vector225>:
.globl vector225
vector225:
  pushl $0
80106a13:	6a 00                	push   $0x0
  pushl $225
80106a15:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106a1a:	e9 db f1 ff ff       	jmp    80105bfa <alltraps>

80106a1f <vector226>:
.globl vector226
vector226:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $226
80106a21:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106a26:	e9 cf f1 ff ff       	jmp    80105bfa <alltraps>

80106a2b <vector227>:
.globl vector227
vector227:
  pushl $0
80106a2b:	6a 00                	push   $0x0
  pushl $227
80106a2d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106a32:	e9 c3 f1 ff ff       	jmp    80105bfa <alltraps>

80106a37 <vector228>:
.globl vector228
vector228:
  pushl $0
80106a37:	6a 00                	push   $0x0
  pushl $228
80106a39:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106a3e:	e9 b7 f1 ff ff       	jmp    80105bfa <alltraps>

80106a43 <vector229>:
.globl vector229
vector229:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $229
80106a45:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106a4a:	e9 ab f1 ff ff       	jmp    80105bfa <alltraps>

80106a4f <vector230>:
.globl vector230
vector230:
  pushl $0
80106a4f:	6a 00                	push   $0x0
  pushl $230
80106a51:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106a56:	e9 9f f1 ff ff       	jmp    80105bfa <alltraps>

80106a5b <vector231>:
.globl vector231
vector231:
  pushl $0
80106a5b:	6a 00                	push   $0x0
  pushl $231
80106a5d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106a62:	e9 93 f1 ff ff       	jmp    80105bfa <alltraps>

80106a67 <vector232>:
.globl vector232
vector232:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $232
80106a69:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106a6e:	e9 87 f1 ff ff       	jmp    80105bfa <alltraps>

80106a73 <vector233>:
.globl vector233
vector233:
  pushl $0
80106a73:	6a 00                	push   $0x0
  pushl $233
80106a75:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106a7a:	e9 7b f1 ff ff       	jmp    80105bfa <alltraps>

80106a7f <vector234>:
.globl vector234
vector234:
  pushl $0
80106a7f:	6a 00                	push   $0x0
  pushl $234
80106a81:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106a86:	e9 6f f1 ff ff       	jmp    80105bfa <alltraps>

80106a8b <vector235>:
.globl vector235
vector235:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $235
80106a8d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106a92:	e9 63 f1 ff ff       	jmp    80105bfa <alltraps>

80106a97 <vector236>:
.globl vector236
vector236:
  pushl $0
80106a97:	6a 00                	push   $0x0
  pushl $236
80106a99:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106a9e:	e9 57 f1 ff ff       	jmp    80105bfa <alltraps>

80106aa3 <vector237>:
.globl vector237
vector237:
  pushl $0
80106aa3:	6a 00                	push   $0x0
  pushl $237
80106aa5:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106aaa:	e9 4b f1 ff ff       	jmp    80105bfa <alltraps>

80106aaf <vector238>:
.globl vector238
vector238:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $238
80106ab1:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106ab6:	e9 3f f1 ff ff       	jmp    80105bfa <alltraps>

80106abb <vector239>:
.globl vector239
vector239:
  pushl $0
80106abb:	6a 00                	push   $0x0
  pushl $239
80106abd:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106ac2:	e9 33 f1 ff ff       	jmp    80105bfa <alltraps>

80106ac7 <vector240>:
.globl vector240
vector240:
  pushl $0
80106ac7:	6a 00                	push   $0x0
  pushl $240
80106ac9:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106ace:	e9 27 f1 ff ff       	jmp    80105bfa <alltraps>

80106ad3 <vector241>:
.globl vector241
vector241:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $241
80106ad5:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106ada:	e9 1b f1 ff ff       	jmp    80105bfa <alltraps>

80106adf <vector242>:
.globl vector242
vector242:
  pushl $0
80106adf:	6a 00                	push   $0x0
  pushl $242
80106ae1:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106ae6:	e9 0f f1 ff ff       	jmp    80105bfa <alltraps>

80106aeb <vector243>:
.globl vector243
vector243:
  pushl $0
80106aeb:	6a 00                	push   $0x0
  pushl $243
80106aed:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106af2:	e9 03 f1 ff ff       	jmp    80105bfa <alltraps>

80106af7 <vector244>:
.globl vector244
vector244:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $244
80106af9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106afe:	e9 f7 f0 ff ff       	jmp    80105bfa <alltraps>

80106b03 <vector245>:
.globl vector245
vector245:
  pushl $0
80106b03:	6a 00                	push   $0x0
  pushl $245
80106b05:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106b0a:	e9 eb f0 ff ff       	jmp    80105bfa <alltraps>

80106b0f <vector246>:
.globl vector246
vector246:
  pushl $0
80106b0f:	6a 00                	push   $0x0
  pushl $246
80106b11:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106b16:	e9 df f0 ff ff       	jmp    80105bfa <alltraps>

80106b1b <vector247>:
.globl vector247
vector247:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $247
80106b1d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106b22:	e9 d3 f0 ff ff       	jmp    80105bfa <alltraps>

80106b27 <vector248>:
.globl vector248
vector248:
  pushl $0
80106b27:	6a 00                	push   $0x0
  pushl $248
80106b29:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106b2e:	e9 c7 f0 ff ff       	jmp    80105bfa <alltraps>

80106b33 <vector249>:
.globl vector249
vector249:
  pushl $0
80106b33:	6a 00                	push   $0x0
  pushl $249
80106b35:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106b3a:	e9 bb f0 ff ff       	jmp    80105bfa <alltraps>

80106b3f <vector250>:
.globl vector250
vector250:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $250
80106b41:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106b46:	e9 af f0 ff ff       	jmp    80105bfa <alltraps>

80106b4b <vector251>:
.globl vector251
vector251:
  pushl $0
80106b4b:	6a 00                	push   $0x0
  pushl $251
80106b4d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106b52:	e9 a3 f0 ff ff       	jmp    80105bfa <alltraps>

80106b57 <vector252>:
.globl vector252
vector252:
  pushl $0
80106b57:	6a 00                	push   $0x0
  pushl $252
80106b59:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106b5e:	e9 97 f0 ff ff       	jmp    80105bfa <alltraps>

80106b63 <vector253>:
.globl vector253
vector253:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $253
80106b65:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106b6a:	e9 8b f0 ff ff       	jmp    80105bfa <alltraps>

80106b6f <vector254>:
.globl vector254
vector254:
  pushl $0
80106b6f:	6a 00                	push   $0x0
  pushl $254
80106b71:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106b76:	e9 7f f0 ff ff       	jmp    80105bfa <alltraps>

80106b7b <vector255>:
.globl vector255
vector255:
  pushl $0
80106b7b:	6a 00                	push   $0x0
  pushl $255
80106b7d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106b82:	e9 73 f0 ff ff       	jmp    80105bfa <alltraps>
80106b87:	66 90                	xchg   %ax,%ax
80106b89:	66 90                	xchg   %ax,%ax
80106b8b:	66 90                	xchg   %ax,%ax
80106b8d:	66 90                	xchg   %ax,%ax
80106b8f:	90                   	nop

80106b90 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106b90:	55                   	push   %ebp
80106b91:	89 e5                	mov    %esp,%ebp
80106b93:	57                   	push   %edi
80106b94:	56                   	push   %esi
80106b95:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80106b96:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
80106b9c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106ba2:	83 ec 1c             	sub    $0x1c,%esp
80106ba5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106ba8:	39 d3                	cmp    %edx,%ebx
80106baa:	73 49                	jae    80106bf5 <deallocuvm.part.0+0x65>
80106bac:	89 c7                	mov    %eax,%edi
80106bae:	eb 0c                	jmp    80106bbc <deallocuvm.part.0+0x2c>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106bb0:	83 c0 01             	add    $0x1,%eax
80106bb3:	c1 e0 16             	shl    $0x16,%eax
80106bb6:	89 c3                	mov    %eax,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106bb8:	39 da                	cmp    %ebx,%edx
80106bba:	76 39                	jbe    80106bf5 <deallocuvm.part.0+0x65>
  pde = &pgdir[PDX(va)];
80106bbc:	89 d8                	mov    %ebx,%eax
80106bbe:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80106bc1:	8b 0c 87             	mov    (%edi,%eax,4),%ecx
80106bc4:	f6 c1 01             	test   $0x1,%cl
80106bc7:	74 e7                	je     80106bb0 <deallocuvm.part.0+0x20>
  return &pgtab[PTX(va)];
80106bc9:	89 de                	mov    %ebx,%esi
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106bcb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
80106bd1:	c1 ee 0a             	shr    $0xa,%esi
80106bd4:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
80106bda:	8d b4 31 00 00 00 80 	lea    -0x80000000(%ecx,%esi,1),%esi
    if(!pte)
80106be1:	85 f6                	test   %esi,%esi
80106be3:	74 cb                	je     80106bb0 <deallocuvm.part.0+0x20>
    else if((*pte & PTE_P) != 0){
80106be5:	8b 06                	mov    (%esi),%eax
80106be7:	a8 01                	test   $0x1,%al
80106be9:	75 15                	jne    80106c00 <deallocuvm.part.0+0x70>
  for(; a  < oldsz; a += PGSIZE){
80106beb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106bf1:	39 da                	cmp    %ebx,%edx
80106bf3:	77 c7                	ja     80106bbc <deallocuvm.part.0+0x2c>
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
}
80106bf5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106bfb:	5b                   	pop    %ebx
80106bfc:	5e                   	pop    %esi
80106bfd:	5f                   	pop    %edi
80106bfe:	5d                   	pop    %ebp
80106bff:	c3                   	ret    
      if(pa == 0)
80106c00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106c05:	74 25                	je     80106c2c <deallocuvm.part.0+0x9c>
      kfree(v);
80106c07:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
80106c0a:	05 00 00 00 80       	add    $0x80000000,%eax
80106c0f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106c12:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      kfree(v);
80106c18:	50                   	push   %eax
80106c19:	e8 02 bb ff ff       	call   80102720 <kfree>
      *pte = 0;
80106c1e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  for(; a  < oldsz; a += PGSIZE){
80106c24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106c27:	83 c4 10             	add    $0x10,%esp
80106c2a:	eb 8c                	jmp    80106bb8 <deallocuvm.part.0+0x28>
        panic("kfree");
80106c2c:	83 ec 0c             	sub    $0xc,%esp
80106c2f:	68 d2 7b 10 80       	push   $0x80107bd2
80106c34:	e8 77 98 ff ff       	call   801004b0 <panic>
80106c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106c40 <mappages>:
{
80106c40:	55                   	push   %ebp
80106c41:	89 e5                	mov    %esp,%ebp
80106c43:	57                   	push   %edi
80106c44:	56                   	push   %esi
80106c45:	53                   	push   %ebx
  a = (char*)PGROUNDDOWN((uint)va);
80106c46:	89 d3                	mov    %edx,%ebx
80106c48:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
80106c4e:	83 ec 1c             	sub    $0x1c,%esp
80106c51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106c54:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
80106c58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106c5d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106c60:	8b 45 08             	mov    0x8(%ebp),%eax
80106c63:	29 d8                	sub    %ebx,%eax
80106c65:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106c68:	eb 3d                	jmp    80106ca7 <mappages+0x67>
80106c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80106c70:	89 da                	mov    %ebx,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106c72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80106c77:	c1 ea 0a             	shr    $0xa,%edx
80106c7a:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80106c80:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106c87:	85 c0                	test   %eax,%eax
80106c89:	74 75                	je     80106d00 <mappages+0xc0>
    if(*pte & PTE_P)
80106c8b:	f6 00 01             	testb  $0x1,(%eax)
80106c8e:	0f 85 86 00 00 00    	jne    80106d1a <mappages+0xda>
    *pte = pa | perm | PTE_P;
80106c94:	0b 75 0c             	or     0xc(%ebp),%esi
80106c97:	83 ce 01             	or     $0x1,%esi
80106c9a:	89 30                	mov    %esi,(%eax)
    if(a == last)
80106c9c:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
80106c9f:	74 6f                	je     80106d10 <mappages+0xd0>
    a += PGSIZE;
80106ca1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  for(;;){
80106ca7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  pde = &pgdir[PDX(va)];
80106caa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106cad:	8d 34 18             	lea    (%eax,%ebx,1),%esi
80106cb0:	89 d8                	mov    %ebx,%eax
80106cb2:	c1 e8 16             	shr    $0x16,%eax
80106cb5:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
  if(*pde & PTE_P){
80106cb8:	8b 07                	mov    (%edi),%eax
80106cba:	a8 01                	test   $0x1,%al
80106cbc:	75 b2                	jne    80106c70 <mappages+0x30>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106cbe:	e8 3d bc ff ff       	call   80102900 <kalloc>
80106cc3:	85 c0                	test   %eax,%eax
80106cc5:	74 39                	je     80106d00 <mappages+0xc0>
    memset(pgtab, 0, PGSIZE);
80106cc7:	83 ec 04             	sub    $0x4,%esp
80106cca:	89 45 d8             	mov    %eax,-0x28(%ebp)
80106ccd:	68 00 10 00 00       	push   $0x1000
80106cd2:	6a 00                	push   $0x0
80106cd4:	50                   	push   %eax
80106cd5:	e8 26 dd ff ff       	call   80104a00 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106cda:	8b 55 d8             	mov    -0x28(%ebp),%edx
  return &pgtab[PTX(va)];
80106cdd:	83 c4 10             	add    $0x10,%esp
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106ce0:	8d 82 00 00 00 80    	lea    -0x80000000(%edx),%eax
80106ce6:	83 c8 07             	or     $0x7,%eax
80106ce9:	89 07                	mov    %eax,(%edi)
  return &pgtab[PTX(va)];
80106ceb:	89 d8                	mov    %ebx,%eax
80106ced:	c1 e8 0a             	shr    $0xa,%eax
80106cf0:	25 fc 0f 00 00       	and    $0xffc,%eax
80106cf5:	01 d0                	add    %edx,%eax
80106cf7:	eb 92                	jmp    80106c8b <mappages+0x4b>
80106cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}
80106d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106d03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106d08:	5b                   	pop    %ebx
80106d09:	5e                   	pop    %esi
80106d0a:	5f                   	pop    %edi
80106d0b:	5d                   	pop    %ebp
80106d0c:	c3                   	ret    
80106d0d:	8d 76 00             	lea    0x0(%esi),%esi
80106d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106d13:	31 c0                	xor    %eax,%eax
}
80106d15:	5b                   	pop    %ebx
80106d16:	5e                   	pop    %esi
80106d17:	5f                   	pop    %edi
80106d18:	5d                   	pop    %ebp
80106d19:	c3                   	ret    
      panic("remap");
80106d1a:	83 ec 0c             	sub    $0xc,%esp
80106d1d:	68 cc 82 10 80       	push   $0x801082cc
80106d22:	e8 89 97 ff ff       	call   801004b0 <panic>
80106d27:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106d2e:	66 90                	xchg   %ax,%ax

80106d30 <seginit>:
{
80106d30:	55                   	push   %ebp
80106d31:	89 e5                	mov    %esp,%ebp
80106d33:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
80106d36:	e8 f5 ce ff ff       	call   80103c30 <cpuid>
  pd[0] = size-1;
80106d3b:	ba 2f 00 00 00       	mov    $0x2f,%edx
80106d40:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106d46:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106d4a:	c7 80 58 28 11 80 ff 	movl   $0xffff,-0x7feed7a8(%eax)
80106d51:	ff 00 00 
80106d54:	c7 80 5c 28 11 80 00 	movl   $0xcf9a00,-0x7feed7a4(%eax)
80106d5b:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106d5e:	c7 80 60 28 11 80 ff 	movl   $0xffff,-0x7feed7a0(%eax)
80106d65:	ff 00 00 
80106d68:	c7 80 64 28 11 80 00 	movl   $0xcf9200,-0x7feed79c(%eax)
80106d6f:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106d72:	c7 80 68 28 11 80 ff 	movl   $0xffff,-0x7feed798(%eax)
80106d79:	ff 00 00 
80106d7c:	c7 80 6c 28 11 80 00 	movl   $0xcffa00,-0x7feed794(%eax)
80106d83:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106d86:	c7 80 70 28 11 80 ff 	movl   $0xffff,-0x7feed790(%eax)
80106d8d:	ff 00 00 
80106d90:	c7 80 74 28 11 80 00 	movl   $0xcff200,-0x7feed78c(%eax)
80106d97:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
80106d9a:	05 50 28 11 80       	add    $0x80112850,%eax
  pd[1] = (uint)p;
80106d9f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106da3:	c1 e8 10             	shr    $0x10,%eax
80106da6:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106daa:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106dad:	0f 01 10             	lgdtl  (%eax)
}
80106db0:	c9                   	leave  
80106db1:	c3                   	ret    
80106db2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106dc0 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106dc0:	a1 04 56 11 80       	mov    0x80115604,%eax
80106dc5:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106dca:	0f 22 d8             	mov    %eax,%cr3
}
80106dcd:	c3                   	ret    
80106dce:	66 90                	xchg   %ax,%ax

80106dd0 <switchuvm>:
{
80106dd0:	55                   	push   %ebp
80106dd1:	89 e5                	mov    %esp,%ebp
80106dd3:	57                   	push   %edi
80106dd4:	56                   	push   %esi
80106dd5:	53                   	push   %ebx
80106dd6:	83 ec 1c             	sub    $0x1c,%esp
80106dd9:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106ddc:	85 f6                	test   %esi,%esi
80106dde:	0f 84 cb 00 00 00    	je     80106eaf <switchuvm+0xdf>
  if(p->kstack == 0)
80106de4:	8b 46 0c             	mov    0xc(%esi),%eax
80106de7:	85 c0                	test   %eax,%eax
80106de9:	0f 84 da 00 00 00    	je     80106ec9 <switchuvm+0xf9>
  if(p->pgdir == 0)
80106def:	8b 46 08             	mov    0x8(%esi),%eax
80106df2:	85 c0                	test   %eax,%eax
80106df4:	0f 84 c2 00 00 00    	je     80106ebc <switchuvm+0xec>
  pushcli();
80106dfa:	e8 f1 d9 ff ff       	call   801047f0 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106dff:	e8 cc cd ff ff       	call   80103bd0 <mycpu>
80106e04:	89 c3                	mov    %eax,%ebx
80106e06:	e8 c5 cd ff ff       	call   80103bd0 <mycpu>
80106e0b:	89 c7                	mov    %eax,%edi
80106e0d:	e8 be cd ff ff       	call   80103bd0 <mycpu>
80106e12:	83 c7 08             	add    $0x8,%edi
80106e15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106e18:	e8 b3 cd ff ff       	call   80103bd0 <mycpu>
80106e1d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106e20:	ba 67 00 00 00       	mov    $0x67,%edx
80106e25:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106e2c:	83 c0 08             	add    $0x8,%eax
80106e2f:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106e36:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106e3b:	83 c1 08             	add    $0x8,%ecx
80106e3e:	c1 e8 18             	shr    $0x18,%eax
80106e41:	c1 e9 10             	shr    $0x10,%ecx
80106e44:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
80106e4a:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106e50:	b9 99 40 00 00       	mov    $0x4099,%ecx
80106e55:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106e5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
80106e61:	e8 6a cd ff ff       	call   80103bd0 <mycpu>
80106e66:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106e6d:	e8 5e cd ff ff       	call   80103bd0 <mycpu>
80106e72:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106e76:	8b 5e 0c             	mov    0xc(%esi),%ebx
80106e79:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106e7f:	e8 4c cd ff ff       	call   80103bd0 <mycpu>
80106e84:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106e87:	e8 44 cd ff ff       	call   80103bd0 <mycpu>
80106e8c:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106e90:	b8 28 00 00 00       	mov    $0x28,%eax
80106e95:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106e98:	8b 46 08             	mov    0x8(%esi),%eax
80106e9b:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106ea0:	0f 22 d8             	mov    %eax,%cr3
}
80106ea3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ea6:	5b                   	pop    %ebx
80106ea7:	5e                   	pop    %esi
80106ea8:	5f                   	pop    %edi
80106ea9:	5d                   	pop    %ebp
  popcli();
80106eaa:	e9 91 d9 ff ff       	jmp    80104840 <popcli>
    panic("switchuvm: no process");
80106eaf:	83 ec 0c             	sub    $0xc,%esp
80106eb2:	68 d2 82 10 80       	push   $0x801082d2
80106eb7:	e8 f4 95 ff ff       	call   801004b0 <panic>
    panic("switchuvm: no pgdir");
80106ebc:	83 ec 0c             	sub    $0xc,%esp
80106ebf:	68 fd 82 10 80       	push   $0x801082fd
80106ec4:	e8 e7 95 ff ff       	call   801004b0 <panic>
    panic("switchuvm: no kstack");
80106ec9:	83 ec 0c             	sub    $0xc,%esp
80106ecc:	68 e8 82 10 80       	push   $0x801082e8
80106ed1:	e8 da 95 ff ff       	call   801004b0 <panic>
80106ed6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106edd:	8d 76 00             	lea    0x0(%esi),%esi

80106ee0 <inituvm>:
{
80106ee0:	55                   	push   %ebp
80106ee1:	89 e5                	mov    %esp,%ebp
80106ee3:	57                   	push   %edi
80106ee4:	56                   	push   %esi
80106ee5:	53                   	push   %ebx
80106ee6:	83 ec 1c             	sub    $0x1c,%esp
80106ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
80106eec:	8b 75 10             	mov    0x10(%ebp),%esi
80106eef:	8b 7d 08             	mov    0x8(%ebp),%edi
80106ef2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
80106ef5:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106efb:	77 4b                	ja     80106f48 <inituvm+0x68>
  mem = kalloc();
80106efd:	e8 fe b9 ff ff       	call   80102900 <kalloc>
  memset(mem, 0, PGSIZE);
80106f02:	83 ec 04             	sub    $0x4,%esp
80106f05:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
80106f0a:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106f0c:	6a 00                	push   $0x0
80106f0e:	50                   	push   %eax
80106f0f:	e8 ec da ff ff       	call   80104a00 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106f14:	58                   	pop    %eax
80106f15:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106f1b:	5a                   	pop    %edx
80106f1c:	6a 06                	push   $0x6
80106f1e:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106f23:	31 d2                	xor    %edx,%edx
80106f25:	50                   	push   %eax
80106f26:	89 f8                	mov    %edi,%eax
80106f28:	e8 13 fd ff ff       	call   80106c40 <mappages>
  memmove(mem, init, sz);
80106f2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f30:	89 75 10             	mov    %esi,0x10(%ebp)
80106f33:	83 c4 10             	add    $0x10,%esp
80106f36:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106f39:	89 45 0c             	mov    %eax,0xc(%ebp)
}
80106f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f3f:	5b                   	pop    %ebx
80106f40:	5e                   	pop    %esi
80106f41:	5f                   	pop    %edi
80106f42:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80106f43:	e9 58 db ff ff       	jmp    80104aa0 <memmove>
    panic("inituvm: more than a page");
80106f48:	83 ec 0c             	sub    $0xc,%esp
80106f4b:	68 11 83 10 80       	push   $0x80108311
80106f50:	e8 5b 95 ff ff       	call   801004b0 <panic>
80106f55:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106f5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106f60 <loaduvm>:
{
80106f60:	55                   	push   %ebp
80106f61:	89 e5                	mov    %esp,%ebp
80106f63:	57                   	push   %edi
80106f64:	56                   	push   %esi
80106f65:	53                   	push   %ebx
80106f66:	83 ec 1c             	sub    $0x1c,%esp
80106f69:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f6c:	8b 75 18             	mov    0x18(%ebp),%esi
  if((uint) addr % PGSIZE != 0)
80106f6f:	a9 ff 0f 00 00       	test   $0xfff,%eax
80106f74:	0f 85 bb 00 00 00    	jne    80107035 <loaduvm+0xd5>
  for(i = 0; i < sz; i += PGSIZE){
80106f7a:	01 f0                	add    %esi,%eax
80106f7c:	89 f3                	mov    %esi,%ebx
80106f7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106f81:	8b 45 14             	mov    0x14(%ebp),%eax
80106f84:	01 f0                	add    %esi,%eax
80106f86:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sz; i += PGSIZE){
80106f89:	85 f6                	test   %esi,%esi
80106f8b:	0f 84 87 00 00 00    	je     80107018 <loaduvm+0xb8>
80106f91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  pde = &pgdir[PDX(va)];
80106f98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  if(*pde & PTE_P){
80106f9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106f9e:	29 d8                	sub    %ebx,%eax
  pde = &pgdir[PDX(va)];
80106fa0:	89 c2                	mov    %eax,%edx
80106fa2:	c1 ea 16             	shr    $0x16,%edx
  if(*pde & PTE_P){
80106fa5:	8b 14 91             	mov    (%ecx,%edx,4),%edx
80106fa8:	f6 c2 01             	test   $0x1,%dl
80106fab:	75 13                	jne    80106fc0 <loaduvm+0x60>
      panic("loaduvm: address should exist");
80106fad:	83 ec 0c             	sub    $0xc,%esp
80106fb0:	68 2b 83 10 80       	push   $0x8010832b
80106fb5:	e8 f6 94 ff ff       	call   801004b0 <panic>
80106fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80106fc0:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106fc3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80106fc9:	25 fc 0f 00 00       	and    $0xffc,%eax
80106fce:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106fd5:	85 c0                	test   %eax,%eax
80106fd7:	74 d4                	je     80106fad <loaduvm+0x4d>
    pa = PTE_ADDR(*pte);
80106fd9:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106fdb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    if(sz - i < PGSIZE)
80106fde:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80106fe3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106fe8:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
80106fee:	0f 46 fb             	cmovbe %ebx,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106ff1:	29 d9                	sub    %ebx,%ecx
80106ff3:	05 00 00 00 80       	add    $0x80000000,%eax
80106ff8:	57                   	push   %edi
80106ff9:	51                   	push   %ecx
80106ffa:	50                   	push   %eax
80106ffb:	ff 75 10             	push   0x10(%ebp)
80106ffe:	e8 ed ac ff ff       	call   80101cf0 <readi>
80107003:	83 c4 10             	add    $0x10,%esp
80107006:	39 f8                	cmp    %edi,%eax
80107008:	75 1e                	jne    80107028 <loaduvm+0xc8>
  for(i = 0; i < sz; i += PGSIZE){
8010700a:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
80107010:	89 f0                	mov    %esi,%eax
80107012:	29 d8                	sub    %ebx,%eax
80107014:	39 c6                	cmp    %eax,%esi
80107016:	77 80                	ja     80106f98 <loaduvm+0x38>
}
80107018:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010701b:	31 c0                	xor    %eax,%eax
}
8010701d:	5b                   	pop    %ebx
8010701e:	5e                   	pop    %esi
8010701f:	5f                   	pop    %edi
80107020:	5d                   	pop    %ebp
80107021:	c3                   	ret    
80107022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107028:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
8010702b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107030:	5b                   	pop    %ebx
80107031:	5e                   	pop    %esi
80107032:	5f                   	pop    %edi
80107033:	5d                   	pop    %ebp
80107034:	c3                   	ret    
    panic("loaduvm: addr must be page aligned");
80107035:	83 ec 0c             	sub    $0xc,%esp
80107038:	68 38 85 10 80       	push   $0x80108538
8010703d:	e8 6e 94 ff ff       	call   801004b0 <panic>
80107042:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107050 <allocuvm>:
{
80107050:	55                   	push   %ebp
80107051:	89 e5                	mov    %esp,%ebp
80107053:	57                   	push   %edi
80107054:	56                   	push   %esi
80107055:	53                   	push   %ebx
80107056:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80107059:	8b 45 10             	mov    0x10(%ebp),%eax
{
8010705c:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
8010705f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107062:	85 c0                	test   %eax,%eax
80107064:	0f 88 b6 00 00 00    	js     80107120 <allocuvm+0xd0>
  if(newsz < oldsz)
8010706a:	3b 45 0c             	cmp    0xc(%ebp),%eax
    return oldsz;
8010706d:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(newsz < oldsz)
80107070:	0f 82 9a 00 00 00    	jb     80107110 <allocuvm+0xc0>
  a = PGROUNDUP(oldsz);
80107076:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
8010707c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80107082:	39 75 10             	cmp    %esi,0x10(%ebp)
80107085:	77 44                	ja     801070cb <allocuvm+0x7b>
80107087:	e9 87 00 00 00       	jmp    80107113 <allocuvm+0xc3>
8010708c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    memset(mem, 0, PGSIZE);
80107090:	83 ec 04             	sub    $0x4,%esp
80107093:	68 00 10 00 00       	push   $0x1000
80107098:	6a 00                	push   $0x0
8010709a:	50                   	push   %eax
8010709b:	e8 60 d9 ff ff       	call   80104a00 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801070a0:	58                   	pop    %eax
801070a1:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801070a7:	5a                   	pop    %edx
801070a8:	6a 06                	push   $0x6
801070aa:	b9 00 10 00 00       	mov    $0x1000,%ecx
801070af:	89 f2                	mov    %esi,%edx
801070b1:	50                   	push   %eax
801070b2:	89 f8                	mov    %edi,%eax
801070b4:	e8 87 fb ff ff       	call   80106c40 <mappages>
801070b9:	83 c4 10             	add    $0x10,%esp
801070bc:	85 c0                	test   %eax,%eax
801070be:	78 78                	js     80107138 <allocuvm+0xe8>
  for(; a < newsz; a += PGSIZE){
801070c0:	81 c6 00 10 00 00    	add    $0x1000,%esi
801070c6:	39 75 10             	cmp    %esi,0x10(%ebp)
801070c9:	76 48                	jbe    80107113 <allocuvm+0xc3>
    mem = kalloc();
801070cb:	e8 30 b8 ff ff       	call   80102900 <kalloc>
801070d0:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
801070d2:	85 c0                	test   %eax,%eax
801070d4:	75 ba                	jne    80107090 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
801070d6:	83 ec 0c             	sub    $0xc,%esp
801070d9:	68 49 83 10 80       	push   $0x80108349
801070de:	e8 ed 96 ff ff       	call   801007d0 <cprintf>
  if(newsz >= oldsz)
801070e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801070e6:	83 c4 10             	add    $0x10,%esp
801070e9:	39 45 10             	cmp    %eax,0x10(%ebp)
801070ec:	74 32                	je     80107120 <allocuvm+0xd0>
801070ee:	8b 55 10             	mov    0x10(%ebp),%edx
801070f1:	89 c1                	mov    %eax,%ecx
801070f3:	89 f8                	mov    %edi,%eax
801070f5:	e8 96 fa ff ff       	call   80106b90 <deallocuvm.part.0>
      return 0;
801070fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80107101:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107104:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107107:	5b                   	pop    %ebx
80107108:	5e                   	pop    %esi
80107109:	5f                   	pop    %edi
8010710a:	5d                   	pop    %ebp
8010710b:	c3                   	ret    
8010710c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return oldsz;
80107110:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}
80107113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107116:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107119:	5b                   	pop    %ebx
8010711a:	5e                   	pop    %esi
8010711b:	5f                   	pop    %edi
8010711c:	5d                   	pop    %ebp
8010711d:	c3                   	ret    
8010711e:	66 90                	xchg   %ax,%ax
    return 0;
80107120:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80107127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010712a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010712d:	5b                   	pop    %ebx
8010712e:	5e                   	pop    %esi
8010712f:	5f                   	pop    %edi
80107130:	5d                   	pop    %ebp
80107131:	c3                   	ret    
80107132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
80107138:	83 ec 0c             	sub    $0xc,%esp
8010713b:	68 61 83 10 80       	push   $0x80108361
80107140:	e8 8b 96 ff ff       	call   801007d0 <cprintf>
  if(newsz >= oldsz)
80107145:	8b 45 0c             	mov    0xc(%ebp),%eax
80107148:	83 c4 10             	add    $0x10,%esp
8010714b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010714e:	74 0c                	je     8010715c <allocuvm+0x10c>
80107150:	8b 55 10             	mov    0x10(%ebp),%edx
80107153:	89 c1                	mov    %eax,%ecx
80107155:	89 f8                	mov    %edi,%eax
80107157:	e8 34 fa ff ff       	call   80106b90 <deallocuvm.part.0>
      kfree(mem);
8010715c:	83 ec 0c             	sub    $0xc,%esp
8010715f:	53                   	push   %ebx
80107160:	e8 bb b5 ff ff       	call   80102720 <kfree>
      return 0;
80107165:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010716c:	83 c4 10             	add    $0x10,%esp
}
8010716f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107172:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107175:	5b                   	pop    %ebx
80107176:	5e                   	pop    %esi
80107177:	5f                   	pop    %edi
80107178:	5d                   	pop    %ebp
80107179:	c3                   	ret    
8010717a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107180 <deallocuvm>:
{
80107180:	55                   	push   %ebp
80107181:	89 e5                	mov    %esp,%ebp
80107183:	8b 55 0c             	mov    0xc(%ebp),%edx
80107186:	8b 4d 10             	mov    0x10(%ebp),%ecx
80107189:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
8010718c:	39 d1                	cmp    %edx,%ecx
8010718e:	73 10                	jae    801071a0 <deallocuvm+0x20>
}
80107190:	5d                   	pop    %ebp
80107191:	e9 fa f9 ff ff       	jmp    80106b90 <deallocuvm.part.0>
80107196:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010719d:	8d 76 00             	lea    0x0(%esi),%esi
801071a0:	89 d0                	mov    %edx,%eax
801071a2:	5d                   	pop    %ebp
801071a3:	c3                   	ret    
801071a4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801071ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801071af:	90                   	nop

801071b0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801071b0:	55                   	push   %ebp
801071b1:	89 e5                	mov    %esp,%ebp
801071b3:	57                   	push   %edi
801071b4:	56                   	push   %esi
801071b5:	53                   	push   %ebx
801071b6:	83 ec 0c             	sub    $0xc,%esp
801071b9:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801071bc:	85 f6                	test   %esi,%esi
801071be:	74 59                	je     80107219 <freevm+0x69>
  if(newsz >= oldsz)
801071c0:	31 c9                	xor    %ecx,%ecx
801071c2:	ba 00 00 00 80       	mov    $0x80000000,%edx
801071c7:	89 f0                	mov    %esi,%eax
801071c9:	89 f3                	mov    %esi,%ebx
801071cb:	e8 c0 f9 ff ff       	call   80106b90 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801071d0:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
801071d6:	eb 0f                	jmp    801071e7 <freevm+0x37>
801071d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801071df:	90                   	nop
801071e0:	83 c3 04             	add    $0x4,%ebx
801071e3:	39 df                	cmp    %ebx,%edi
801071e5:	74 23                	je     8010720a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
801071e7:	8b 03                	mov    (%ebx),%eax
801071e9:	a8 01                	test   $0x1,%al
801071eb:	74 f3                	je     801071e0 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801071ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
801071f2:	83 ec 0c             	sub    $0xc,%esp
  for(i = 0; i < NPDENTRIES; i++){
801071f5:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
801071f8:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801071fd:	50                   	push   %eax
801071fe:	e8 1d b5 ff ff       	call   80102720 <kfree>
80107203:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107206:	39 df                	cmp    %ebx,%edi
80107208:	75 dd                	jne    801071e7 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010720a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010720d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107210:	5b                   	pop    %ebx
80107211:	5e                   	pop    %esi
80107212:	5f                   	pop    %edi
80107213:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107214:	e9 07 b5 ff ff       	jmp    80102720 <kfree>
    panic("freevm: no pgdir");
80107219:	83 ec 0c             	sub    $0xc,%esp
8010721c:	68 7d 83 10 80       	push   $0x8010837d
80107221:	e8 8a 92 ff ff       	call   801004b0 <panic>
80107226:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010722d:	8d 76 00             	lea    0x0(%esi),%esi

80107230 <setupkvm>:
{
80107230:	55                   	push   %ebp
80107231:	89 e5                	mov    %esp,%ebp
80107233:	56                   	push   %esi
80107234:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80107235:	e8 c6 b6 ff ff       	call   80102900 <kalloc>
8010723a:	89 c6                	mov    %eax,%esi
8010723c:	85 c0                	test   %eax,%eax
8010723e:	74 42                	je     80107282 <setupkvm+0x52>
  memset(pgdir, 0, PGSIZE);
80107240:	83 ec 04             	sub    $0x4,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107243:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
80107248:	68 00 10 00 00       	push   $0x1000
8010724d:	6a 00                	push   $0x0
8010724f:	50                   	push   %eax
80107250:	e8 ab d7 ff ff       	call   80104a00 <memset>
80107255:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0) {
80107258:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010725b:	83 ec 08             	sub    $0x8,%esp
8010725e:	8b 4b 08             	mov    0x8(%ebx),%ecx
80107261:	ff 73 0c             	push   0xc(%ebx)
80107264:	8b 13                	mov    (%ebx),%edx
80107266:	50                   	push   %eax
80107267:	29 c1                	sub    %eax,%ecx
80107269:	89 f0                	mov    %esi,%eax
8010726b:	e8 d0 f9 ff ff       	call   80106c40 <mappages>
80107270:	83 c4 10             	add    $0x10,%esp
80107273:	85 c0                	test   %eax,%eax
80107275:	78 19                	js     80107290 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107277:	83 c3 10             	add    $0x10,%ebx
8010727a:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
80107280:	75 d6                	jne    80107258 <setupkvm+0x28>
}
80107282:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107285:	89 f0                	mov    %esi,%eax
80107287:	5b                   	pop    %ebx
80107288:	5e                   	pop    %esi
80107289:	5d                   	pop    %ebp
8010728a:	c3                   	ret    
8010728b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010728f:	90                   	nop
      freevm(pgdir);
80107290:	83 ec 0c             	sub    $0xc,%esp
80107293:	56                   	push   %esi
      return 0;
80107294:	31 f6                	xor    %esi,%esi
      freevm(pgdir);
80107296:	e8 15 ff ff ff       	call   801071b0 <freevm>
      return 0;
8010729b:	83 c4 10             	add    $0x10,%esp
}
8010729e:	8d 65 f8             	lea    -0x8(%ebp),%esp
801072a1:	89 f0                	mov    %esi,%eax
801072a3:	5b                   	pop    %ebx
801072a4:	5e                   	pop    %esi
801072a5:	5d                   	pop    %ebp
801072a6:	c3                   	ret    
801072a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801072ae:	66 90                	xchg   %ax,%ax

801072b0 <kvmalloc>:
{
801072b0:	55                   	push   %ebp
801072b1:	89 e5                	mov    %esp,%ebp
801072b3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801072b6:	e8 75 ff ff ff       	call   80107230 <setupkvm>
801072bb:	a3 04 56 11 80       	mov    %eax,0x80115604
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801072c0:	05 00 00 00 80       	add    $0x80000000,%eax
801072c5:	0f 22 d8             	mov    %eax,%cr3
}
801072c8:	c9                   	leave  
801072c9:	c3                   	ret    
801072ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801072d0 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801072d0:	55                   	push   %ebp
801072d1:	89 e5                	mov    %esp,%ebp
801072d3:	83 ec 08             	sub    $0x8,%esp
801072d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
801072d9:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
801072dc:	89 c1                	mov    %eax,%ecx
801072de:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
801072e1:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
801072e4:	f6 c2 01             	test   $0x1,%dl
801072e7:	75 17                	jne    80107300 <clearpteu+0x30>
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
801072e9:	83 ec 0c             	sub    $0xc,%esp
801072ec:	68 8e 83 10 80       	push   $0x8010838e
801072f1:	e8 ba 91 ff ff       	call   801004b0 <panic>
801072f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801072fd:	8d 76 00             	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107300:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107303:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80107309:	25 fc 0f 00 00       	and    $0xffc,%eax
8010730e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
  if(pte == 0)
80107315:	85 c0                	test   %eax,%eax
80107317:	74 d0                	je     801072e9 <clearpteu+0x19>
  *pte &= ~PTE_U;
80107319:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010731c:	c9                   	leave  
8010731d:	c3                   	ret    
8010731e:	66 90                	xchg   %ax,%ax

80107320 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107320:	55                   	push   %ebp
80107321:	89 e5                	mov    %esp,%ebp
80107323:	57                   	push   %edi
80107324:	56                   	push   %esi
80107325:	53                   	push   %ebx
80107326:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107329:	e8 02 ff ff ff       	call   80107230 <setupkvm>
8010732e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107331:	85 c0                	test   %eax,%eax
80107333:	0f 84 bd 00 00 00    	je     801073f6 <copyuvm+0xd6>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80107339:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010733c:	85 c9                	test   %ecx,%ecx
8010733e:	0f 84 b2 00 00 00    	je     801073f6 <copyuvm+0xd6>
80107344:	31 f6                	xor    %esi,%esi
80107346:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010734d:	8d 76 00             	lea    0x0(%esi),%esi
  if(*pde & PTE_P){
80107350:	8b 4d 08             	mov    0x8(%ebp),%ecx
  pde = &pgdir[PDX(va)];
80107353:	89 f0                	mov    %esi,%eax
80107355:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80107358:	8b 04 81             	mov    (%ecx,%eax,4),%eax
8010735b:	a8 01                	test   $0x1,%al
8010735d:	75 11                	jne    80107370 <copyuvm+0x50>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
8010735f:	83 ec 0c             	sub    $0xc,%esp
80107362:	68 98 83 10 80       	push   $0x80108398
80107367:	e8 44 91 ff ff       	call   801004b0 <panic>
8010736c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return &pgtab[PTX(va)];
80107370:	89 f2                	mov    %esi,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80107377:	c1 ea 0a             	shr    $0xa,%edx
8010737a:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107380:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107387:	85 c0                	test   %eax,%eax
80107389:	74 d4                	je     8010735f <copyuvm+0x3f>
    if(!(*pte & PTE_P))
8010738b:	8b 00                	mov    (%eax),%eax
8010738d:	a8 01                	test   $0x1,%al
8010738f:	0f 84 9f 00 00 00    	je     80107434 <copyuvm+0x114>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80107395:	89 c7                	mov    %eax,%edi
    flags = PTE_FLAGS(*pte);
80107397:	25 ff 0f 00 00       	and    $0xfff,%eax
8010739c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pa = PTE_ADDR(*pte);
8010739f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
801073a5:	e8 56 b5 ff ff       	call   80102900 <kalloc>
801073aa:	89 c3                	mov    %eax,%ebx
801073ac:	85 c0                	test   %eax,%eax
801073ae:	74 64                	je     80107414 <copyuvm+0xf4>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801073b0:	83 ec 04             	sub    $0x4,%esp
801073b3:	81 c7 00 00 00 80    	add    $0x80000000,%edi
801073b9:	68 00 10 00 00       	push   $0x1000
801073be:	57                   	push   %edi
801073bf:	50                   	push   %eax
801073c0:	e8 db d6 ff ff       	call   80104aa0 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801073c5:	58                   	pop    %eax
801073c6:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801073cc:	5a                   	pop    %edx
801073cd:	ff 75 e4             	push   -0x1c(%ebp)
801073d0:	b9 00 10 00 00       	mov    $0x1000,%ecx
801073d5:	89 f2                	mov    %esi,%edx
801073d7:	50                   	push   %eax
801073d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801073db:	e8 60 f8 ff ff       	call   80106c40 <mappages>
801073e0:	83 c4 10             	add    $0x10,%esp
801073e3:	85 c0                	test   %eax,%eax
801073e5:	78 21                	js     80107408 <copyuvm+0xe8>
  for(i = 0; i < sz; i += PGSIZE){
801073e7:	81 c6 00 10 00 00    	add    $0x1000,%esi
801073ed:	39 75 0c             	cmp    %esi,0xc(%ebp)
801073f0:	0f 87 5a ff ff ff    	ja     80107350 <copyuvm+0x30>
  return d;

bad:
  freevm(d);
  return 0;
}
801073f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801073f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801073fc:	5b                   	pop    %ebx
801073fd:	5e                   	pop    %esi
801073fe:	5f                   	pop    %edi
801073ff:	5d                   	pop    %ebp
80107400:	c3                   	ret    
80107401:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      kfree(mem);
80107408:	83 ec 0c             	sub    $0xc,%esp
8010740b:	53                   	push   %ebx
8010740c:	e8 0f b3 ff ff       	call   80102720 <kfree>
      goto bad;
80107411:	83 c4 10             	add    $0x10,%esp
  freevm(d);
80107414:	83 ec 0c             	sub    $0xc,%esp
80107417:	ff 75 e0             	push   -0x20(%ebp)
8010741a:	e8 91 fd ff ff       	call   801071b0 <freevm>
  return 0;
8010741f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80107426:	83 c4 10             	add    $0x10,%esp
}
80107429:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010742c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010742f:	5b                   	pop    %ebx
80107430:	5e                   	pop    %esi
80107431:	5f                   	pop    %edi
80107432:	5d                   	pop    %ebp
80107433:	c3                   	ret    
      panic("copyuvm: page not present");
80107434:	83 ec 0c             	sub    $0xc,%esp
80107437:	68 b2 83 10 80       	push   $0x801083b2
8010743c:	e8 6f 90 ff ff       	call   801004b0 <panic>
80107441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107448:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010744f:	90                   	nop

80107450 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107450:	55                   	push   %ebp
80107451:	89 e5                	mov    %esp,%ebp
80107453:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
80107456:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
80107459:	89 c1                	mov    %eax,%ecx
8010745b:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
8010745e:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80107461:	f6 c2 01             	test   $0x1,%dl
80107464:	0f 84 8e 04 00 00    	je     801078f8 <uva2ka.cold>
  return &pgtab[PTX(va)];
8010746a:	c1 e8 0c             	shr    $0xc,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010746d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80107473:	5d                   	pop    %ebp
  return &pgtab[PTX(va)];
80107474:	25 ff 03 00 00       	and    $0x3ff,%eax
  if((*pte & PTE_P) == 0)
80107479:	8b 84 82 00 00 00 80 	mov    -0x80000000(%edx,%eax,4),%eax
  if((*pte & PTE_U) == 0)
80107480:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107482:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
80107487:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
8010748a:	05 00 00 00 80       	add    $0x80000000,%eax
8010748f:	83 fa 05             	cmp    $0x5,%edx
80107492:	ba 00 00 00 00       	mov    $0x0,%edx
80107497:	0f 45 c2             	cmovne %edx,%eax
}
8010749a:	c3                   	ret    
8010749b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010749f:	90                   	nop

801074a0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801074a0:	55                   	push   %ebp
801074a1:	89 e5                	mov    %esp,%ebp
801074a3:	57                   	push   %edi
801074a4:	56                   	push   %esi
801074a5:	53                   	push   %ebx
801074a6:	83 ec 0c             	sub    $0xc,%esp
801074a9:	8b 75 14             	mov    0x14(%ebp),%esi
801074ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801074af:	8b 55 10             	mov    0x10(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801074b2:	85 f6                	test   %esi,%esi
801074b4:	75 51                	jne    80107507 <copyout+0x67>
801074b6:	e9 a5 00 00 00       	jmp    80107560 <copyout+0xc0>
801074bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801074bf:	90                   	nop
  return (char*)P2V(PTE_ADDR(*pte));
801074c0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
801074c6:	8d 8b 00 00 00 80    	lea    -0x80000000(%ebx),%ecx
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
801074cc:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
801074d2:	74 75                	je     80107549 <copyout+0xa9>
      return -1;
    n = PGSIZE - (va - va0);
801074d4:	89 fb                	mov    %edi,%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801074d6:	89 55 10             	mov    %edx,0x10(%ebp)
    n = PGSIZE - (va - va0);
801074d9:	29 c3                	sub    %eax,%ebx
801074db:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801074e1:	39 f3                	cmp    %esi,%ebx
801074e3:	0f 47 de             	cmova  %esi,%ebx
    memmove(pa0 + (va - va0), buf, n);
801074e6:	29 f8                	sub    %edi,%eax
801074e8:	83 ec 04             	sub    $0x4,%esp
801074eb:	01 c1                	add    %eax,%ecx
801074ed:	53                   	push   %ebx
801074ee:	52                   	push   %edx
801074ef:	51                   	push   %ecx
801074f0:	e8 ab d5 ff ff       	call   80104aa0 <memmove>
    len -= n;
    buf += n;
801074f5:	8b 55 10             	mov    0x10(%ebp),%edx
    va = va0 + PGSIZE;
801074f8:	8d 87 00 10 00 00    	lea    0x1000(%edi),%eax
  while(len > 0){
801074fe:	83 c4 10             	add    $0x10,%esp
    buf += n;
80107501:	01 da                	add    %ebx,%edx
  while(len > 0){
80107503:	29 de                	sub    %ebx,%esi
80107505:	74 59                	je     80107560 <copyout+0xc0>
  if(*pde & PTE_P){
80107507:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pde = &pgdir[PDX(va)];
8010750a:	89 c1                	mov    %eax,%ecx
    va0 = (uint)PGROUNDDOWN(va);
8010750c:	89 c7                	mov    %eax,%edi
  pde = &pgdir[PDX(va)];
8010750e:	c1 e9 16             	shr    $0x16,%ecx
    va0 = (uint)PGROUNDDOWN(va);
80107511:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if(*pde & PTE_P){
80107517:	8b 0c 8b             	mov    (%ebx,%ecx,4),%ecx
8010751a:	f6 c1 01             	test   $0x1,%cl
8010751d:	0f 84 dc 03 00 00    	je     801078ff <copyout.cold>
  return &pgtab[PTX(va)];
80107523:	89 fb                	mov    %edi,%ebx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107525:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
8010752b:	c1 eb 0c             	shr    $0xc,%ebx
8010752e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  if((*pte & PTE_P) == 0)
80107534:	8b 9c 99 00 00 00 80 	mov    -0x80000000(%ecx,%ebx,4),%ebx
  if((*pte & PTE_U) == 0)
8010753b:	89 d9                	mov    %ebx,%ecx
8010753d:	83 e1 05             	and    $0x5,%ecx
80107540:	83 f9 05             	cmp    $0x5,%ecx
80107543:	0f 84 77 ff ff ff    	je     801074c0 <copyout+0x20>
  }
  return 0;
}
80107549:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
8010754c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107551:	5b                   	pop    %ebx
80107552:	5e                   	pop    %esi
80107553:	5f                   	pop    %edi
80107554:	5d                   	pop    %ebp
80107555:	c3                   	ret    
80107556:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010755d:	8d 76 00             	lea    0x0(%esi),%esi
80107560:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107563:	31 c0                	xor    %eax,%eax
}
80107565:	5b                   	pop    %ebx
80107566:	5e                   	pop    %esi
80107567:	5f                   	pop    %edi
80107568:	5d                   	pop    %ebp
80107569:	c3                   	ret    
8010756a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107570 <find_victim>:
  *victim_page |= (pos)<<12;  // It should be 12 instead of 3 because according to slides we are storing swap space index in base address space of pagetable entry
  cprintf("victim page is %d", *victim_page);
  return victim_page;
}

pte_t* find_victim(pde_t *pgdir){
80107570:	55                   	push   %ebp
80107571:	89 e5                	mov    %esp,%ebp
80107573:	57                   	push   %edi
80107574:	56                   	push   %esi
80107575:	53                   	push   %ebx
  uint add=0;
80107576:	31 db                	xor    %ebx,%ebx
pte_t* find_victim(pde_t *pgdir){
80107578:	83 ec 0c             	sub    $0xc,%esp
8010757b:	8b 75 08             	mov    0x8(%ebp),%esi
8010757e:	66 90                	xchg   %ax,%ax

  while(add < KERNBASE){
    cprintf("IN while\n");
80107580:	83 ec 0c             	sub    $0xc,%esp
80107583:	68 cc 83 10 80       	push   $0x801083cc
80107588:	e8 43 92 ff ff       	call   801007d0 <cprintf>
  pde = &pgdir[PDX(va)];
8010758d:	89 d8                	mov    %ebx,%eax
  if(*pde & PTE_P){
8010758f:	83 c4 10             	add    $0x10,%esp
  pde = &pgdir[PDX(va)];
80107592:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80107595:	8b 04 86             	mov    (%esi,%eax,4),%eax
80107598:	a8 01                	test   $0x1,%al
8010759a:	0f 84 66 03 00 00    	je     80107906 <find_victim.cold>
    pte_t *x= walkpgdir(pgdir,(void*)add,0);
    // cprintf(*x);
    cprintf("walkpg done\n");
801075a0:	83 ec 0c             	sub    $0xc,%esp
  return &pgtab[PTX(va)];
801075a3:	89 da                	mov    %ebx,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801075a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    cprintf("walkpg done\n");
801075aa:	68 d6 83 10 80       	push   $0x801083d6
  return &pgtab[PTX(va)];
801075af:	c1 ea 0a             	shr    $0xa,%edx
801075b2:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
801075b8:	8d bc 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%edi
    cprintf("walkpg done\n");
801075bf:	e8 0c 92 ff ff       	call   801007d0 <cprintf>
    // PTE_P is set for x (otherwise walkpgdir function will return 0)
    cprintf("Hello------------");
801075c4:	c7 04 24 e3 83 10 80 	movl   $0x801083e3,(%esp)
801075cb:	e8 00 92 ff ff       	call   801007d0 <cprintf>
    cprintf("PTE_P is %d\n",PTE_P);
801075d0:	59                   	pop    %ecx
801075d1:	58                   	pop    %eax
801075d2:	6a 01                	push   $0x1
801075d4:	68 f5 83 10 80       	push   $0x801083f5
801075d9:	e8 f2 91 ff ff       	call   801007d0 <cprintf>
    cprintf("x is %d\n",(uint)*x);
801075de:	58                   	pop    %eax
801075df:	5a                   	pop    %edx
801075e0:	ff 37                	push   (%edi)
801075e2:	68 02 84 10 80       	push   $0x80108402
801075e7:	e8 e4 91 ff ff       	call   801007d0 <cprintf>
    
    if((*x & PTE_P)){
801075ec:	83 c4 10             	add    $0x10,%esp
801075ef:	f6 07 01             	testb  $0x1,(%edi)
801075f2:	74 15                	je     80107609 <find_victim+0x99>
      // Found a process with PTE_A Flag unset
      cprintf("in if\n");
801075f4:	83 ec 0c             	sub    $0xc,%esp
801075f7:	68 16 84 10 80       	push   $0x80108416
801075fc:	e8 cf 91 ff ff       	call   801007d0 <cprintf>
      if((*x & PTE_A)==0){
80107601:	83 c4 10             	add    $0x10,%esp
80107604:	f6 07 20             	testb  $0x20,(%edi)
80107607:	74 21                	je     8010762a <find_victim+0xba>
        return x;
      }
    }
    add+=PGSIZE;
    cprintf("add is %d\n", add);
80107609:	83 ec 08             	sub    $0x8,%esp
    add+=PGSIZE;
8010760c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    cprintf("add is %d\n", add);
80107612:	53                   	push   %ebx
80107613:	68 0b 84 10 80       	push   $0x8010840b
80107618:	e8 b3 91 ff ff       	call   801007d0 <cprintf>
  while(add < KERNBASE){
8010761d:	83 c4 10             	add    $0x10,%esp
80107620:	85 db                	test   %ebx,%ebx
80107622:	0f 89 58 ff ff ff    	jns    80107580 <find_victim+0x10>
  }
  // Failed to find victim page
  return 0;
80107628:	31 ff                	xor    %edi,%edi
}
8010762a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010762d:	89 f8                	mov    %edi,%eax
8010762f:	5b                   	pop    %ebx
80107630:	5e                   	pop    %esi
80107631:	5f                   	pop    %edi
80107632:	5d                   	pop    %ebp
80107633:	c3                   	ret    
80107634:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010763b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010763f:	90                   	nop

80107640 <unset_access>:

void unset_access(pde_t *pgdir){
80107640:	55                   	push   %ebp
  uint add=0;
  int counter=0;
80107641:	31 d2                	xor    %edx,%edx
  uint add=0;
80107643:	31 c9                	xor    %ecx,%ecx
void unset_access(pde_t *pgdir){
80107645:	89 e5                	mov    %esp,%ebp
80107647:	57                   	push   %edi
    if(x!=0){
      // Unset access bit of every tenth process
      if(counter==0){
        *x &= ~ PTE_A;
      }
      counter= (counter+1)%10;
80107648:	bf cd cc cc cc       	mov    $0xcccccccd,%edi
void unset_access(pde_t *pgdir){
8010764d:	56                   	push   %esi
8010764e:	8b 75 08             	mov    0x8(%ebp),%esi
80107651:	53                   	push   %ebx
80107652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  pde = &pgdir[PDX(va)];
80107658:	89 c8                	mov    %ecx,%eax
8010765a:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
8010765d:	8b 04 86             	mov    (%esi,%eax,4),%eax
80107660:	a8 01                	test   $0x1,%al
80107662:	74 35                	je     80107699 <unset_access+0x59>
  return &pgtab[PTX(va)];
80107664:	89 cb                	mov    %ecx,%ebx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107666:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
8010766b:	c1 eb 0a             	shr    $0xa,%ebx
8010766e:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
80107674:	8d 84 18 00 00 00 80 	lea    -0x80000000(%eax,%ebx,1),%eax
    if(x!=0){
8010767b:	85 c0                	test   %eax,%eax
8010767d:	74 1a                	je     80107699 <unset_access+0x59>
      if(counter==0){
8010767f:	85 d2                	test   %edx,%edx
80107681:	75 03                	jne    80107686 <unset_access+0x46>
        *x &= ~ PTE_A;
80107683:	83 20 df             	andl   $0xffffffdf,(%eax)
      counter= (counter+1)%10;
80107686:	8d 5a 01             	lea    0x1(%edx),%ebx
80107689:	89 d8                	mov    %ebx,%eax
8010768b:	f7 e7                	mul    %edi
8010768d:	c1 ea 03             	shr    $0x3,%edx
80107690:	8d 04 92             	lea    (%edx,%edx,4),%eax
80107693:	01 c0                	add    %eax,%eax
80107695:	29 c3                	sub    %eax,%ebx
80107697:	89 da                	mov    %ebx,%edx
  while(add < KERNBASE){
80107699:	81 c1 00 10 00 00    	add    $0x1000,%ecx
8010769f:	79 b7                	jns    80107658 <unset_access+0x18>
    }
    add+=PGSIZE;
  }
  return;
}
801076a1:	5b                   	pop    %ebx
801076a2:	5e                   	pop    %esi
801076a3:	5f                   	pop    %edi
801076a4:	5d                   	pop    %ebp
801076a5:	c3                   	ret    
801076a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801076ad:	8d 76 00             	lea    0x0(%esi),%esi

801076b0 <allocate_page>:
pte_t* allocate_page(){
801076b0:	55                   	push   %ebp
801076b1:	89 e5                	mov    %esp,%ebp
801076b3:	56                   	push   %esi
801076b4:	53                   	push   %ebx
  cprintf("in allocate page1\n");
801076b5:	83 ec 0c             	sub    $0xc,%esp
801076b8:	68 1d 84 10 80       	push   $0x8010841d
801076bd:	e8 0e 91 ff ff       	call   801007d0 <cprintf>
  pde_t *victim_pde= victim_pgdir();
801076c2:	e8 29 cf ff ff       	call   801045f0 <victim_pgdir>
  cprintf("in allocate page2\n");
801076c7:	c7 04 24 30 84 10 80 	movl   $0x80108430,(%esp)
  pde_t *victim_pde= victim_pgdir();
801076ce:	89 c6                	mov    %eax,%esi
  cprintf("in allocate page2\n");
801076d0:	e8 fb 90 ff ff       	call   801007d0 <cprintf>
  victim_page= find_victim(victim_pde);
801076d5:	89 34 24             	mov    %esi,(%esp)
801076d8:	e8 93 fe ff ff       	call   80107570 <find_victim>
  cprintf("in allocate page3\n");
801076dd:	c7 04 24 43 84 10 80 	movl   $0x80108443,(%esp)
  victim_page= find_victim(victim_pde);
801076e4:	89 c3                	mov    %eax,%ebx
  cprintf("in allocate page3\n");
801076e6:	e8 e5 90 ff ff       	call   801007d0 <cprintf>
  if(victim_page==0){
801076eb:	83 c4 10             	add    $0x10,%esp
801076ee:	85 db                	test   %ebx,%ebx
801076f0:	0f 84 92 00 00 00    	je     80107788 <allocate_page+0xd8>
  cprintf("in allocate page7\n");
801076f6:	83 ec 0c             	sub    $0xc,%esp
801076f9:	68 8f 84 10 80       	push   $0x8010848f
801076fe:	e8 cd 90 ff ff       	call   801007d0 <cprintf>
  memmove(data, (char*)P2V(PTE_ADDR(victim_page)), PGSIZE);
80107703:	89 d8                	mov    %ebx,%eax
80107705:	83 c4 0c             	add    $0xc,%esp
80107708:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010770d:	68 00 10 00 00       	push   $0x1000
80107712:	05 00 00 00 80       	add    $0x80000000,%eax
80107717:	50                   	push   %eax
80107718:	6a 00                	push   $0x0
8010771a:	e8 81 d3 ff ff       	call   80104aa0 <memmove>
  cprintf("in allocate page8\n");
8010771f:	c7 04 24 a2 84 10 80 	movl   $0x801084a2,(%esp)
80107726:	e8 a5 90 ff ff       	call   801007d0 <cprintf>
  int permissions= (*victim_page) & 0x07;
8010772b:	8b 33                	mov    (%ebx),%esi
  cprintf("in allocate page9\n");
8010772d:	c7 04 24 b5 84 10 80 	movl   $0x801084b5,(%esp)
80107734:	e8 97 90 ff ff       	call   801007d0 <cprintf>
  uint pos= add_page(data,permissions);
80107739:	58                   	pop    %eax
8010773a:	5a                   	pop    %edx
  int permissions= (*victim_page) & 0x07;
8010773b:	83 e6 07             	and    $0x7,%esi
  uint pos= add_page(data,permissions);
8010773e:	56                   	push   %esi
8010773f:	6a 00                	push   $0x0
80107741:	e8 9a 9f ff ff       	call   801016e0 <add_page>
  cprintf("in allocate page10\n");
80107746:	c7 04 24 c8 84 10 80 	movl   $0x801084c8,(%esp)
  uint pos= add_page(data,permissions);
8010774d:	89 c6                	mov    %eax,%esi
  cprintf("in allocate page10\n");
8010774f:	e8 7c 90 ff ff       	call   801007d0 <cprintf>
  *victim_page &= ~PTE_P;
80107754:	83 23 fe             	andl   $0xfffffffe,(%ebx)
  cprintf("pos is %d", pos);
80107757:	59                   	pop    %ecx
80107758:	58                   	pop    %eax
80107759:	56                   	push   %esi
  *victim_page |= (pos)<<12;  // It should be 12 instead of 3 because according to slides we are storing swap space index in base address space of pagetable entry
8010775a:	c1 e6 0c             	shl    $0xc,%esi
  cprintf("pos is %d", pos);
8010775d:	68 dc 84 10 80       	push   $0x801084dc
80107762:	e8 69 90 ff ff       	call   801007d0 <cprintf>
  *victim_page |= (pos)<<12;  // It should be 12 instead of 3 because according to slides we are storing swap space index in base address space of pagetable entry
80107767:	0b 33                	or     (%ebx),%esi
80107769:	89 33                	mov    %esi,(%ebx)
  cprintf("victim page is %d", *victim_page);
8010776b:	58                   	pop    %eax
8010776c:	5a                   	pop    %edx
8010776d:	56                   	push   %esi
8010776e:	68 e6 84 10 80       	push   $0x801084e6
80107773:	e8 58 90 ff ff       	call   801007d0 <cprintf>
}
80107778:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010777b:	89 d8                	mov    %ebx,%eax
8010777d:	5b                   	pop    %ebx
8010777e:	5e                   	pop    %esi
8010777f:	5d                   	pop    %ebp
80107780:	c3                   	ret    
80107781:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cprintf("in allocate page4\n");
80107788:	83 ec 0c             	sub    $0xc,%esp
8010778b:	68 56 84 10 80       	push   $0x80108456
80107790:	e8 3b 90 ff ff       	call   801007d0 <cprintf>
    unset_access(victim_pde);
80107795:	89 34 24             	mov    %esi,(%esp)
80107798:	e8 a3 fe ff ff       	call   80107640 <unset_access>
    cprintf("in allocate page5\n");
8010779d:	c7 04 24 69 84 10 80 	movl   $0x80108469,(%esp)
801077a4:	e8 27 90 ff ff       	call   801007d0 <cprintf>
    victim_page= find_victim(victim_pde);
801077a9:	89 34 24             	mov    %esi,(%esp)
801077ac:	e8 bf fd ff ff       	call   80107570 <find_victim>
    cprintf("in allocate page6\n");
801077b1:	c7 04 24 7c 84 10 80 	movl   $0x8010847c,(%esp)
    victim_page= find_victim(victim_pde);
801077b8:	89 c3                	mov    %eax,%ebx
    cprintf("in allocate page6\n");
801077ba:	e8 11 90 ff ff       	call   801007d0 <cprintf>
801077bf:	83 c4 10             	add    $0x10,%esp
801077c2:	e9 2f ff ff ff       	jmp    801076f6 <allocate_page+0x46>
801077c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801077ce:	66 90                	xchg   %ax,%ax

801077d0 <page_fault>:

void page_fault(){
801077d0:	55                   	push   %ebp
801077d1:	89 e5                	mov    %esp,%ebp
801077d3:	57                   	push   %edi
801077d4:	56                   	push   %esi
801077d5:	53                   	push   %ebx
801077d6:	81 ec 28 02 00 00    	sub    $0x228,%esp
  cprintf("Pagefault called\n");
801077dc:	68 46 81 10 80       	push   $0x80108146
801077e1:	e8 ea 8f ff ff       	call   801007d0 <cprintf>
  asm volatile("movl %%cr2,%0" : "=r" (val));
801077e6:	0f 20 d3             	mov    %cr2,%ebx
  uint vadd= rcr2();
  pte_t *add = walkpgdir(myproc()->pgdir,(void*)vadd,0);
801077e9:	e8 62 c4 ff ff       	call   80103c50 <myproc>
  pde = &pgdir[PDX(va)];
801077ee:	89 da                	mov    %ebx,%edx
  if(*pde & PTE_P){
801077f0:	83 c4 10             	add    $0x10,%esp
801077f3:	8b 40 08             	mov    0x8(%eax),%eax
  pde = &pgdir[PDX(va)];
801077f6:	c1 ea 16             	shr    $0x16,%edx
  if(*pde & PTE_P){
801077f9:	8b 04 90             	mov    (%eax,%edx,4),%eax
801077fc:	a8 01                	test   $0x1,%al
801077fe:	0f 84 30 01 00 00    	je     80107934 <page_fault.cold>
  cprintf("walkpage done\n");
80107804:	83 ec 0c             	sub    $0xc,%esp
  return &pgtab[PTX(va)];
80107807:	c1 eb 0a             	shr    $0xa,%ebx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010780a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  cprintf("walkpage done\n");
8010780f:	68 f8 84 10 80       	push   $0x801084f8
  return &pgtab[PTX(va)];
80107814:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
8010781a:	8d 84 18 00 00 00 80 	lea    -0x80000000(%eax,%ebx,1),%eax
80107821:	89 c7                	mov    %eax,%edi
80107823:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
  cprintf("walkpage done\n");
80107829:	e8 a2 8f ff ff       	call   801007d0 <cprintf>
  // No need of taking and
  cprintf("add is %d", *add);
8010782e:	58                   	pop    %eax
8010782f:	5a                   	pop    %edx
80107830:	ff 37                	push   (%edi)
80107832:	68 07 85 10 80       	push   $0x80108507
80107837:	e8 94 8f ff ff       	call   801007d0 <cprintf>
  uint x= (*add>>12); // Instead of 3->12  and confusion in and
8010783c:	8b 07                	mov    (%edi),%eax
  cprintf("done x");
8010783e:	c7 04 24 11 85 10 80 	movl   $0x80108511,(%esp)
80107845:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
  uint x= (*add>>12); // Instead of 3->12  and confusion in and
8010784b:	c1 e8 0c             	shr    $0xc,%eax
8010784e:	89 c6                	mov    %eax,%esi
80107850:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)
  cprintf("done x");
80107856:	e8 75 8f ff ff       	call   801007d0 <cprintf>
  uint st= x*8+2;
8010785b:	8d 34 f5 02 00 00 00 	lea    0x2(,%esi,8),%esi
  // Read contents of page in mem
  char *mem= kalloc();
80107862:	e8 99 b0 ff ff       	call   80102900 <kalloc>
80107867:	83 c4 10             	add    $0x10,%esp
8010786a:	89 85 dc fd ff ff    	mov    %eax,-0x224(%ebp)
80107870:	89 c3                	mov    %eax,%ebx
80107872:	8d 80 00 10 00 00    	lea    0x1000(%eax),%eax
80107878:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
8010787e:	66 90                	xchg   %ax,%ax
  char *cur=mem;
  char buf[BSIZE];
  for(int j=0;j<8;j++){
    cprintf("calling read page from disk\n");
80107880:	83 ec 0c             	sub    $0xc,%esp
80107883:	68 18 85 10 80       	push   $0x80108518
80107888:	e8 43 8f ff ff       	call   801007d0 <cprintf>
    read_page_from_disk(ROOTDEV,buf,st+j);
8010788d:	83 c4 0c             	add    $0xc,%esp
80107890:	56                   	push   %esi
  for(int j=0;j<8;j++){
80107891:	83 c6 01             	add    $0x1,%esi
    read_page_from_disk(ROOTDEV,buf,st+j);
80107894:	57                   	push   %edi
80107895:	6a 01                	push   $0x1
80107897:	e8 94 8a ff ff       	call   80100330 <read_page_from_disk>
    memmove(cur,buf,BSIZE);
8010789c:	83 c4 0c             	add    $0xc,%esp
8010789f:	68 00 02 00 00       	push   $0x200
801078a4:	57                   	push   %edi
801078a5:	53                   	push   %ebx
    cur+=BSIZE;
801078a6:	81 c3 00 02 00 00    	add    $0x200,%ebx
    memmove(cur,buf,BSIZE);
801078ac:	e8 ef d1 ff ff       	call   80104aa0 <memmove>
  for(int j=0;j<8;j++){
801078b1:	83 c4 10             	add    $0x10,%esp
801078b4:	3b 9d e4 fd ff ff    	cmp    -0x21c(%ebp),%ebx
801078ba:	75 c4                	jne    80107880 <page_fault+0xb0>
    // st++;
  }
  uint permission = ss[x].page_perm;
  *add = *((char*)(V2P(mem)))<<12 | PTE_P | PTE_A | permission;
801078bc:	8b 85 dc fd ff ff    	mov    -0x224(%ebp),%eax
801078c2:	8b 8d e0 fd ff ff    	mov    -0x220(%ebp),%ecx
801078c8:	0f be 80 00 00 00 80 	movsbl -0x80000000(%eax),%eax
801078cf:	c1 e0 0c             	shl    $0xc,%eax
801078d2:	0b 04 cd c0 25 11 80 	or     -0x7feeda40(,%ecx,8),%eax
801078d9:	8b 8d d8 fd ff ff    	mov    -0x228(%ebp),%ecx
801078df:	83 c8 21             	or     $0x21,%eax
801078e2:	89 01                	mov    %eax,(%ecx)
  myproc()->rss+=PGSIZE;
801078e4:	e8 67 c3 ff ff       	call   80103c50 <myproc>
801078e9:	81 40 04 00 10 00 00 	addl   $0x1000,0x4(%eax)
  // Fetch permissions of page and mark swap slot free
  // uint per= remove_page(x);
  // add new page

801078f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801078f3:	5b                   	pop    %ebx
801078f4:	5e                   	pop    %esi
801078f5:	5f                   	pop    %edi
801078f6:	5d                   	pop    %ebp
801078f7:	c3                   	ret    

801078f8 <uva2ka.cold>:
  if((*pte & PTE_P) == 0)
801078f8:	a1 00 00 00 00       	mov    0x0,%eax
801078fd:	0f 0b                	ud2    

801078ff <copyout.cold>:
801078ff:	a1 00 00 00 00       	mov    0x0,%eax
80107904:	0f 0b                	ud2    

80107906 <find_victim.cold>:
    cprintf("walkpg done\n");
80107906:	83 ec 0c             	sub    $0xc,%esp
80107909:	68 d6 83 10 80       	push   $0x801083d6
8010790e:	e8 bd 8e ff ff       	call   801007d0 <cprintf>
    cprintf("Hello------------");
80107913:	c7 04 24 e3 83 10 80 	movl   $0x801083e3,(%esp)
8010791a:	e8 b1 8e ff ff       	call   801007d0 <cprintf>
    cprintf("PTE_P is %d\n",PTE_P);
8010791f:	58                   	pop    %eax
80107920:	5a                   	pop    %edx
80107921:	6a 01                	push   $0x1
80107923:	68 f5 83 10 80       	push   $0x801083f5
80107928:	e8 a3 8e ff ff       	call   801007d0 <cprintf>
    cprintf("x is %d\n",(uint)*x);
8010792d:	a1 00 00 00 00       	mov    0x0,%eax
80107932:	0f 0b                	ud2    

80107934 <page_fault.cold>:
  cprintf("walkpage done\n");
80107934:	83 ec 0c             	sub    $0xc,%esp
80107937:	68 f8 84 10 80       	push   $0x801084f8
8010793c:	e8 8f 8e ff ff       	call   801007d0 <cprintf>
  cprintf("add is %d", *add);
80107941:	a1 00 00 00 00       	mov    0x0,%eax
80107946:	0f 0b                	ud2    
