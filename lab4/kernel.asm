
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
8010002d:	b8 00 33 10 80       	mov    $0x80103300,%eax
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
80100052:	e8 c9 48 00 00       	call   80104920 <acquire>

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
801000d2:	e8 e9 47 00 00       	call   801048c0 <release>
      acquiresleep(&b->lock);
801000d7:	8d 43 0c             	lea    0xc(%ebx),%eax
801000da:	89 04 24             	mov    %eax,(%esp)
801000dd:	e8 7e 45 00 00       	call   80104660 <acquiresleep>
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
801000f2:	68 80 77 10 80       	push   $0x80107780
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
8010010c:	68 91 77 10 80       	push   $0x80107791
80100111:	68 20 b5 10 80       	push   $0x8010b520
80100116:	e8 35 46 00 00       	call   80104750 <initlock>
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
80100152:	68 98 77 10 80       	push   $0x80107798
80100157:	50                   	push   %eax
80100158:	e8 c3 44 00 00       	call   80104620 <initsleeplock>
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
801001b7:	e8 74 23 00 00       	call   80102530 <iderw>
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
801001de:	e8 1d 45 00 00       	call   80104700 <holdingsleep>
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
801001f4:	e9 37 23 00 00       	jmp    80102530 <iderw>
    panic("bwrite");
801001f9:	83 ec 0c             	sub    $0xc,%esp
801001fc:	68 9f 77 10 80       	push   $0x8010779f
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
8010021f:	e8 dc 44 00 00       	call   80104700 <holdingsleep>
80100224:	83 c4 10             	add    $0x10,%esp
80100227:	85 c0                	test   %eax,%eax
80100229:	74 66                	je     80100291 <brelse+0x81>
    panic("brelse");

  releasesleep(&b->lock);
8010022b:	83 ec 0c             	sub    $0xc,%esp
8010022e:	56                   	push   %esi
8010022f:	e8 8c 44 00 00       	call   801046c0 <releasesleep>

  acquire(&bcache.lock);
80100234:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010023b:	e8 e0 46 00 00       	call   80104920 <acquire>
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
8010028c:	e9 2f 46 00 00       	jmp    801048c0 <release>
    panic("brelse");
80100291:	83 ec 0c             	sub    $0xc,%esp
80100294:	68 a6 77 10 80       	push   $0x801077a6
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
801002d3:	e8 a8 47 00 00       	call   80104a80 <memmove>
  if(!holdingsleep(&b->lock))
801002d8:	8d 43 0c             	lea    0xc(%ebx),%eax
801002db:	89 04 24             	mov    %eax,(%esp)
801002de:	e8 1d 44 00 00       	call   80104700 <holdingsleep>
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
801002fa:	e8 31 22 00 00       	call   80102530 <iderw>
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
8010031a:	68 9f 77 10 80       	push   $0x8010779f
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
80100366:	e8 15 47 00 00       	call   80104a80 <memmove>
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
80100392:	e8 99 21 00 00       	call   80102530 <iderw>
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
801003c4:	e8 e7 16 00 00       	call   80101ab0 <iunlock>
  acquire(&cons.lock);
801003c9:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801003d0:	e8 4b 45 00 00       	call   80104920 <acquire>
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
801003fd:	e8 6e 3f 00 00       	call   80104370 <sleep>
    while(input.r == input.w){
80100402:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80100407:	83 c4 10             	add    $0x10,%esp
8010040a:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
80100410:	75 36                	jne    80100448 <consoleread+0x98>
      if(myproc()->killed){
80100412:	e8 19 38 00 00       	call   80103c30 <myproc>
80100417:	8b 48 28             	mov    0x28(%eax),%ecx
8010041a:	85 c9                	test   %ecx,%ecx
8010041c:	74 d2                	je     801003f0 <consoleread+0x40>
        release(&cons.lock);
8010041e:	83 ec 0c             	sub    $0xc,%esp
80100421:	68 20 ff 10 80       	push   $0x8010ff20
80100426:	e8 95 44 00 00       	call   801048c0 <release>
        ilock(ip);
8010042b:	5a                   	pop    %edx
8010042c:	ff 75 08             	push   0x8(%ebp)
8010042f:	e8 9c 15 00 00       	call   801019d0 <ilock>
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
8010047c:	e8 3f 44 00 00       	call   801048c0 <release>
  ilock(ip);
80100481:	58                   	pop    %eax
80100482:	ff 75 08             	push   0x8(%ebp)
80100485:	e8 46 15 00 00       	call   801019d0 <ilock>
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
801004c9:	e8 c2 26 00 00       	call   80102b90 <lapicid>
801004ce:	83 ec 08             	sub    $0x8,%esp
801004d1:	50                   	push   %eax
801004d2:	68 ad 77 10 80       	push   $0x801077ad
801004d7:	e8 f4 02 00 00       	call   801007d0 <cprintf>
  cprintf(s);
801004dc:	58                   	pop    %eax
801004dd:	ff 75 08             	push   0x8(%ebp)
801004e0:	e8 eb 02 00 00       	call   801007d0 <cprintf>
  cprintf("\n");
801004e5:	c7 04 24 67 81 10 80 	movl   $0x80108167,(%esp)
801004ec:	e8 df 02 00 00       	call   801007d0 <cprintf>
  getcallerpcs(&s, pcs);
801004f1:	8d 45 08             	lea    0x8(%ebp),%eax
801004f4:	5a                   	pop    %edx
801004f5:	59                   	pop    %ecx
801004f6:	53                   	push   %ebx
801004f7:	50                   	push   %eax
801004f8:	e8 73 42 00 00       	call   80104770 <getcallerpcs>
  for(i=0; i<10; i++)
801004fd:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
80100500:	83 ec 08             	sub    $0x8,%esp
80100503:	ff 33                	push   (%ebx)
  for(i=0; i<10; i++)
80100505:	83 c3 04             	add    $0x4,%ebx
    cprintf(" %p", pcs[i]);
80100508:	68 c1 77 10 80       	push   $0x801077c1
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
8010054a:	e8 21 5b 00 00       	call   80106070 <uartputc>
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
80100635:	e8 36 5a 00 00       	call   80106070 <uartputc>
8010063a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100641:	e8 2a 5a 00 00       	call   80106070 <uartputc>
80100646:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010064d:	e8 1e 5a 00 00       	call   80106070 <uartputc>
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
80100681:	e8 fa 43 00 00       	call   80104a80 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100686:	b8 80 07 00 00       	mov    $0x780,%eax
8010068b:	83 c4 0c             	add    $0xc,%esp
8010068e:	29 d8                	sub    %ebx,%eax
80100690:	01 c0                	add    %eax,%eax
80100692:	50                   	push   %eax
80100693:	6a 00                	push   $0x0
80100695:	56                   	push   %esi
80100696:	e8 45 43 00 00       	call   801049e0 <memset>
  outb(CRTPORT+1, pos);
8010069b:	88 5d e7             	mov    %bl,-0x19(%ebp)
8010069e:	83 c4 10             	add    $0x10,%esp
801006a1:	e9 20 ff ff ff       	jmp    801005c6 <consputc.part.0+0x96>
    panic("pos under/overflow");
801006a6:	83 ec 0c             	sub    $0xc,%esp
801006a9:	68 c5 77 10 80       	push   $0x801077c5
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
801006cf:	e8 dc 13 00 00       	call   80101ab0 <iunlock>
  acquire(&cons.lock);
801006d4:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801006db:	e8 40 42 00 00       	call   80104920 <acquire>
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
80100714:	e8 a7 41 00 00       	call   801048c0 <release>
  ilock(ip);
80100719:	58                   	pop    %eax
8010071a:	ff 75 08             	push   0x8(%ebp)
8010071d:	e8 ae 12 00 00       	call   801019d0 <ilock>

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
80100766:	0f b6 92 f0 77 10 80 	movzbl -0x7fef8810(%edx),%edx
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
80100918:	e8 03 40 00 00       	call   80104920 <acquire>
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
80100968:	bf d8 77 10 80       	mov    $0x801077d8,%edi
      for(; *s; s++)
8010096d:	b8 28 00 00 00       	mov    $0x28,%eax
80100972:	e9 19 ff ff ff       	jmp    80100890 <cprintf+0xc0>
80100977:	89 d0                	mov    %edx,%eax
80100979:	e8 b2 fb ff ff       	call   80100530 <consputc.part.0>
8010097e:	e9 c8 fe ff ff       	jmp    8010084b <cprintf+0x7b>
    release(&cons.lock);
80100983:	83 ec 0c             	sub    $0xc,%esp
80100986:	68 20 ff 10 80       	push   $0x8010ff20
8010098b:	e8 30 3f 00 00       	call   801048c0 <release>
80100990:	83 c4 10             	add    $0x10,%esp
}
80100993:	e9 c9 fe ff ff       	jmp    80100861 <cprintf+0x91>
      if((s = (char*)*argp++) == 0)
80100998:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010099b:	e9 ab fe ff ff       	jmp    8010084b <cprintf+0x7b>
    panic("null fmt");
801009a0:	83 ec 0c             	sub    $0xc,%esp
801009a3:	68 df 77 10 80       	push   $0x801077df
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
801009c3:	e8 58 3f 00 00       	call   80104920 <acquire>
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
80100b00:	e8 bb 3d 00 00       	call   801048c0 <release>
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
80100b3e:	e9 cd 39 00 00       	jmp    80104510 <procdump>
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
80100b74:	e8 b7 38 00 00       	call   80104430 <wakeup>
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
80100b96:	68 e8 77 10 80       	push   $0x801077e8
80100b9b:	68 20 ff 10 80       	push   $0x8010ff20
80100ba0:	e8 ab 3b 00 00       	call   80104750 <initlock>

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
80100bc9:	e8 02 1b 00 00       	call   801026d0 <ioapicenable>
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
80100bec:	e8 3f 30 00 00       	call   80103c30 <myproc>
80100bf1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100bf7:	e8 04 24 00 00       	call   80103000 <begin_op>

  if((ip = namei(path)) == 0){
80100bfc:	83 ec 0c             	sub    $0xc,%esp
80100bff:	ff 75 08             	push   0x8(%ebp)
80100c02:	e8 e9 16 00 00       	call   801022f0 <namei>
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
80100c18:	e8 b3 0d 00 00       	call   801019d0 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c1d:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100c23:	6a 34                	push   $0x34
80100c25:	6a 00                	push   $0x0
80100c27:	50                   	push   %eax
80100c28:	53                   	push   %ebx
80100c29:	e8 b2 10 00 00       	call   80101ce0 <readi>
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
80100c3a:	e8 21 10 00 00       	call   80101c60 <iunlockput>
    end_op();
80100c3f:	e8 2c 24 00 00       	call   80103070 <end_op>
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
80100c64:	e8 97 65 00 00       	call   80107200 <setupkvm>
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
80100cd3:	e8 48 63 00 00       	call   80107020 <allocuvm>
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
80100d09:	e8 22 62 00 00       	call   80106f30 <loaduvm>
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
80100d31:	e8 aa 0f 00 00       	call   80101ce0 <readi>
80100d36:	83 c4 10             	add    $0x10,%esp
80100d39:	83 f8 20             	cmp    $0x20,%eax
80100d3c:	0f 84 5e ff ff ff    	je     80100ca0 <exec+0xc0>
    freevm(pgdir);
80100d42:	83 ec 0c             	sub    $0xc,%esp
80100d45:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100d4b:	e8 30 64 00 00       	call   80107180 <freevm>
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
80100d7c:	e8 df 0e 00 00       	call   80101c60 <iunlockput>
  end_op();
80100d81:	e8 ea 22 00 00       	call   80103070 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d86:	83 c4 0c             	add    $0xc,%esp
80100d89:	56                   	push   %esi
80100d8a:	57                   	push   %edi
80100d8b:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100d91:	57                   	push   %edi
80100d92:	e8 89 62 00 00       	call   80107020 <allocuvm>
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
80100db3:	e8 e8 64 00 00       	call   801072a0 <clearpteu>
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
80100e03:	e8 d8 3d 00 00       	call   80104be0 <strlen>
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
80100e17:	e8 c4 3d 00 00       	call   80104be0 <strlen>
80100e1c:	83 c0 01             	add    $0x1,%eax
80100e1f:	50                   	push   %eax
80100e20:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e23:	ff 34 b8             	push   (%eax,%edi,4)
80100e26:	53                   	push   %ebx
80100e27:	56                   	push   %esi
80100e28:	e8 43 66 00 00       	call   80107470 <copyout>
80100e2d:	83 c4 20             	add    $0x20,%esp
80100e30:	85 c0                	test   %eax,%eax
80100e32:	79 ac                	jns    80100de0 <exec+0x200>
80100e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    freevm(pgdir);
80100e38:	83 ec 0c             	sub    $0xc,%esp
80100e3b:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100e41:	e8 3a 63 00 00       	call   80107180 <freevm>
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
80100e93:	e8 d8 65 00 00       	call   80107470 <copyout>
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
80100ed1:	e8 ca 3c 00 00       	call   80104ba0 <safestrcpy>
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
80100efd:	e8 9e 5e 00 00       	call   80106da0 <switchuvm>
  freevm(oldpgdir);
80100f02:	89 3c 24             	mov    %edi,(%esp)
80100f05:	e8 76 62 00 00       	call   80107180 <freevm>
  return 0;
80100f0a:	83 c4 10             	add    $0x10,%esp
80100f0d:	31 c0                	xor    %eax,%eax
80100f0f:	e9 38 fd ff ff       	jmp    80100c4c <exec+0x6c>
    end_op();
80100f14:	e8 57 21 00 00       	call   80103070 <end_op>
    cprintf("exec: fail\n");
80100f19:	83 ec 0c             	sub    $0xc,%esp
80100f1c:	68 01 78 10 80       	push   $0x80107801
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
80100f46:	68 0d 78 10 80       	push   $0x8010780d
80100f4b:	68 60 ff 10 80       	push   $0x8010ff60
80100f50:	e8 fb 37 00 00       	call   80104750 <initlock>
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
80100f71:	e8 aa 39 00 00       	call   80104920 <acquire>
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
80100fa1:	e8 1a 39 00 00       	call   801048c0 <release>
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
80100fba:	e8 01 39 00 00       	call   801048c0 <release>
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
80100fdf:	e8 3c 39 00 00       	call   80104920 <acquire>
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
80100ffc:	e8 bf 38 00 00       	call   801048c0 <release>
  return f;
}
80101001:	89 d8                	mov    %ebx,%eax
80101003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101006:	c9                   	leave  
80101007:	c3                   	ret    
    panic("filedup");
80101008:	83 ec 0c             	sub    $0xc,%esp
8010100b:	68 14 78 10 80       	push   $0x80107814
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
80101031:	e8 ea 38 00 00       	call   80104920 <acquire>
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
8010106c:	e8 4f 38 00 00       	call   801048c0 <release>

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
8010109e:	e9 1d 38 00 00       	jmp    801048c0 <release>
801010a3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801010a7:	90                   	nop
    begin_op();
801010a8:	e8 53 1f 00 00       	call   80103000 <begin_op>
    iput(ff.ip);
801010ad:	83 ec 0c             	sub    $0xc,%esp
801010b0:	ff 75 e0             	push   -0x20(%ebp)
801010b3:	e8 48 0a 00 00       	call   80101b00 <iput>
    end_op();
801010b8:	83 c4 10             	add    $0x10,%esp
}
801010bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010be:	5b                   	pop    %ebx
801010bf:	5e                   	pop    %esi
801010c0:	5f                   	pop    %edi
801010c1:	5d                   	pop    %ebp
    end_op();
801010c2:	e9 a9 1f 00 00       	jmp    80103070 <end_op>
801010c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010ce:	66 90                	xchg   %ax,%ax
    pipeclose(ff.pipe, ff.writable);
801010d0:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
801010d4:	83 ec 08             	sub    $0x8,%esp
801010d7:	53                   	push   %ebx
801010d8:	56                   	push   %esi
801010d9:	e8 12 27 00 00       	call   801037f0 <pipeclose>
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
801010ec:	68 1c 78 10 80       	push   $0x8010781c
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
80101115:	e8 b6 08 00 00       	call   801019d0 <ilock>
    stati(f->ip, st);
8010111a:	58                   	pop    %eax
8010111b:	5a                   	pop    %edx
8010111c:	ff 75 0c             	push   0xc(%ebp)
8010111f:	ff 73 10             	push   0x10(%ebx)
80101122:	e8 89 0b 00 00       	call   80101cb0 <stati>
    iunlock(f->ip);
80101127:	59                   	pop    %ecx
80101128:	ff 73 10             	push   0x10(%ebx)
8010112b:	e8 80 09 00 00       	call   80101ab0 <iunlock>
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
8010117a:	e8 51 08 00 00       	call   801019d0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010117f:	57                   	push   %edi
80101180:	ff 73 14             	push   0x14(%ebx)
80101183:	56                   	push   %esi
80101184:	ff 73 10             	push   0x10(%ebx)
80101187:	e8 54 0b 00 00       	call   80101ce0 <readi>
8010118c:	83 c4 20             	add    $0x20,%esp
8010118f:	89 c6                	mov    %eax,%esi
80101191:	85 c0                	test   %eax,%eax
80101193:	7e 03                	jle    80101198 <fileread+0x48>
      f->off += r;
80101195:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80101198:	83 ec 0c             	sub    $0xc,%esp
8010119b:	ff 73 10             	push   0x10(%ebx)
8010119e:	e8 0d 09 00 00       	call   80101ab0 <iunlock>
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
801011bd:	e9 ce 27 00 00       	jmp    80103990 <piperead>
801011c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801011c8:	be ff ff ff ff       	mov    $0xffffffff,%esi
801011cd:	eb d7                	jmp    801011a6 <fileread+0x56>
  panic("fileread");
801011cf:	83 ec 0c             	sub    $0xc,%esp
801011d2:	68 26 78 10 80       	push   $0x80107826
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
80101234:	e8 77 08 00 00       	call   80101ab0 <iunlock>
      end_op();
80101239:	e8 32 1e 00 00       	call   80103070 <end_op>

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
8010125e:	e8 9d 1d 00 00       	call   80103000 <begin_op>
      ilock(f->ip);
80101263:	83 ec 0c             	sub    $0xc,%esp
80101266:	ff 73 10             	push   0x10(%ebx)
80101269:	e8 62 07 00 00       	call   801019d0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010126e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101271:	57                   	push   %edi
80101272:	ff 73 14             	push   0x14(%ebx)
80101275:	01 f0                	add    %esi,%eax
80101277:	50                   	push   %eax
80101278:	ff 73 10             	push   0x10(%ebx)
8010127b:	e8 60 0b 00 00       	call   80101de0 <writei>
80101280:	83 c4 20             	add    $0x20,%esp
80101283:	85 c0                	test   %eax,%eax
80101285:	7f a1                	jg     80101228 <filewrite+0x48>
      iunlock(f->ip);
80101287:	83 ec 0c             	sub    $0xc,%esp
8010128a:	ff 73 10             	push   0x10(%ebx)
8010128d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101290:	e8 1b 08 00 00       	call   80101ab0 <iunlock>
      end_op();
80101295:	e8 d6 1d 00 00       	call   80103070 <end_op>
      if(r < 0)
8010129a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010129d:	83 c4 10             	add    $0x10,%esp
801012a0:	85 c0                	test   %eax,%eax
801012a2:	75 1b                	jne    801012bf <filewrite+0xdf>
        panic("short filewrite");
801012a4:	83 ec 0c             	sub    $0xc,%esp
801012a7:	68 2f 78 10 80       	push   $0x8010782f
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
801012d9:	e9 b2 25 00 00       	jmp    80103890 <pipewrite>
  panic("filewrite");
801012de:	83 ec 0c             	sub    $0xc,%esp
801012e1:	68 35 78 10 80       	push   $0x80107835
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
8010133d:	e8 9e 1e 00 00       	call   801031e0 <log_write>
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
80101357:	68 3f 78 10 80       	push   $0x8010783f
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
80101414:	68 52 78 10 80       	push   $0x80107852
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
8010142d:	e8 ae 1d 00 00       	call   801031e0 <log_write>
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
80101455:	e8 86 35 00 00       	call   801049e0 <memset>
  log_write(bp);
8010145a:	89 1c 24             	mov    %ebx,(%esp)
8010145d:	e8 7e 1d 00 00       	call   801031e0 <log_write>
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
8010149a:	e8 81 34 00 00       	call   80104920 <acquire>
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
80101507:	e8 b4 33 00 00       	call   801048c0 <release>

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
80101535:	e8 86 33 00 00       	call   801048c0 <release>
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
80101568:	68 68 78 10 80       	push   $0x80107868
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
801015f5:	e8 e6 1b 00 00       	call   801031e0 <log_write>
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
80101645:	68 78 78 10 80       	push   $0x80107878
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
8010166f:	e8 0c 34 00 00       	call   80104a80 <memmove>
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
801016f7:	75 17                	jne    80101710 <add_page+0x30>
  for(i=0; i<4; i++){
801016f9:	83 c7 01             	add    $0x1,%edi
801016fc:	83 ff 04             	cmp    $0x4,%edi
801016ff:	75 ed                	jne    801016ee <add_page+0xe>
}
80101701:	8d 65 f4             	lea    -0xc(%ebp),%esp
  if(i==4) return -1;
80101704:	bf ff ff ff ff       	mov    $0xffffffff,%edi
}
80101709:	5b                   	pop    %ebx
8010170a:	89 f8                	mov    %edi,%eax
8010170c:	5e                   	pop    %esi
8010170d:	5f                   	pop    %edi
8010170e:	5d                   	pop    %ebp
8010170f:	c3                   	ret    
  ss[i].page_perm= permissions;
80101710:	8b 55 0c             	mov    0xc(%ebp),%edx
80101713:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  ss[i].is_free=0;
80101719:	c7 04 fd c4 25 11 80 	movl   $0x0,-0x7feeda3c(,%edi,8)
80101720:	00 00 00 00 
  ss[i].page_perm= permissions;
80101724:	8d 34 fd 02 00 00 00 	lea    0x2(,%edi,8),%esi
8010172b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010172e:	89 14 fd c0 25 11 80 	mov    %edx,-0x7feeda40(,%edi,8)
  for(int j=0;j<8;j++){
80101735:	8d 76 00             	lea    0x0(%esi),%esi
    write_page_to_disk(ROOTDEV,cur,2+8*i+j);
80101738:	83 ec 04             	sub    $0x4,%esp
8010173b:	56                   	push   %esi
  for(int j=0;j<8;j++){
8010173c:	83 c6 01             	add    $0x1,%esi
    write_page_to_disk(ROOTDEV,cur,2+8*i+j);
8010173f:	53                   	push   %ebx
    cur+= BSIZE;
80101740:	81 c3 00 02 00 00    	add    $0x200,%ebx
    write_page_to_disk(ROOTDEV,cur,2+8*i+j);
80101746:	6a 01                	push   $0x1
80101748:	e8 53 eb ff ff       	call   801002a0 <write_page_to_disk>
  for(int j=0;j<8;j++){
8010174d:	83 c4 10             	add    $0x10,%esp
80101750:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
80101753:	75 e3                	jne    80101738 <add_page+0x58>
}
80101755:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101758:	89 f8                	mov    %edi,%eax
8010175a:	5b                   	pop    %ebx
8010175b:	5e                   	pop    %esi
8010175c:	5f                   	pop    %edi
8010175d:	5d                   	pop    %ebp
8010175e:	c3                   	ret    
8010175f:	90                   	nop

80101760 <iinit>:
{
80101760:	55                   	push   %ebp
80101761:	89 e5                	mov    %esp,%ebp
80101763:	56                   	push   %esi
80101764:	be c0 25 11 80       	mov    $0x801125c0,%esi
80101769:	53                   	push   %ebx
8010176a:	bb a0 09 11 80       	mov    $0x801109a0,%ebx
  initlock(&icache.lock, "icache");
8010176f:	83 ec 08             	sub    $0x8,%esp
80101772:	68 8b 78 10 80       	push   $0x8010788b
80101777:	68 60 09 11 80       	push   $0x80110960
8010177c:	e8 cf 2f 00 00       	call   80104750 <initlock>
  for(i = 0; i < NINODE; i++) {
80101781:	83 c4 10             	add    $0x10,%esp
80101784:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    initsleeplock(&icache.inode[i].lock, "inode");
80101788:	83 ec 08             	sub    $0x8,%esp
8010178b:	68 92 78 10 80       	push   $0x80107892
80101790:	53                   	push   %ebx
  for(i = 0; i < NINODE; i++) {
80101791:	81 c3 90 00 00 00    	add    $0x90,%ebx
    initsleeplock(&icache.inode[i].lock, "inode");
80101797:	e8 84 2e 00 00       	call   80104620 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
8010179c:	83 c4 10             	add    $0x10,%esp
8010179f:	39 de                	cmp    %ebx,%esi
801017a1:	75 e5                	jne    80101788 <iinit+0x28>
  bp = bread(dev, 1);
801017a3:	83 ec 08             	sub    $0x8,%esp
801017a6:	6a 01                	push   $0x1
801017a8:	ff 75 08             	push   0x8(%ebp)
801017ab:	e8 e0 e9 ff ff       	call   80100190 <bread>
  memmove(sb, bp->data, sizeof(*sb));
801017b0:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
801017b3:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801017b5:	8d 40 5c             	lea    0x5c(%eax),%eax
801017b8:	6a 24                	push   $0x24
801017ba:	50                   	push   %eax
801017bb:	68 e0 25 11 80       	push   $0x801125e0
801017c0:	e8 bb 32 00 00       	call   80104a80 <memmove>
  brelse(bp);
801017c5:	89 1c 24             	mov    %ebx,(%esp)
801017c8:	e8 43 ea ff ff       	call   80100210 <brelse>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017cd:	ff 35 fc 25 11 80    	push   0x801125fc
801017d3:	ff 35 f8 25 11 80    	push   0x801125f8
801017d9:	ff 35 f4 25 11 80    	push   0x801125f4
801017df:	ff 35 ec 25 11 80    	push   0x801125ec
801017e5:	ff 35 e8 25 11 80    	push   0x801125e8
801017eb:	ff 35 e4 25 11 80    	push   0x801125e4
801017f1:	ff 35 e0 25 11 80    	push   0x801125e0
801017f7:	68 f8 78 10 80       	push   $0x801078f8
    ss[i].page_perm=0;
801017fc:	c7 05 c0 25 11 80 00 	movl   $0x0,0x801125c0
80101803:	00 00 00 
    ss[i].is_free=1;
80101806:	c7 05 c4 25 11 80 01 	movl   $0x1,0x801125c4
8010180d:	00 00 00 
    ss[i].page_perm=0;
80101810:	c7 05 c8 25 11 80 00 	movl   $0x0,0x801125c8
80101817:	00 00 00 
    ss[i].is_free=1;
8010181a:	c7 05 cc 25 11 80 01 	movl   $0x1,0x801125cc
80101821:	00 00 00 
    ss[i].page_perm=0;
80101824:	c7 05 d0 25 11 80 00 	movl   $0x0,0x801125d0
8010182b:	00 00 00 
    ss[i].is_free=1;
8010182e:	c7 05 d4 25 11 80 01 	movl   $0x1,0x801125d4
80101835:	00 00 00 
    ss[i].page_perm=0;
80101838:	c7 05 d8 25 11 80 00 	movl   $0x0,0x801125d8
8010183f:	00 00 00 
    ss[i].is_free=1;
80101842:	c7 05 dc 25 11 80 01 	movl   $0x1,0x801125dc
80101849:	00 00 00 
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010184c:	e8 7f ef ff ff       	call   801007d0 <cprintf>
}
80101851:	83 c4 30             	add    $0x30,%esp
80101854:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101857:	5b                   	pop    %ebx
80101858:	5e                   	pop    %esi
80101859:	5d                   	pop    %ebp
8010185a:	c3                   	ret    
8010185b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010185f:	90                   	nop

80101860 <ialloc>:
{
80101860:	55                   	push   %ebp
80101861:	89 e5                	mov    %esp,%ebp
80101863:	57                   	push   %edi
80101864:	56                   	push   %esi
80101865:	53                   	push   %ebx
80101866:	83 ec 1c             	sub    $0x1c,%esp
80101869:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
8010186c:	83 3d e8 25 11 80 01 	cmpl   $0x1,0x801125e8
{
80101873:	8b 75 08             	mov    0x8(%ebp),%esi
80101876:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101879:	0f 86 91 00 00 00    	jbe    80101910 <ialloc+0xb0>
8010187f:	bf 01 00 00 00       	mov    $0x1,%edi
80101884:	eb 21                	jmp    801018a7 <ialloc+0x47>
80101886:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010188d:	8d 76 00             	lea    0x0(%esi),%esi
    brelse(bp);
80101890:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101893:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
80101896:	53                   	push   %ebx
80101897:	e8 74 e9 ff ff       	call   80100210 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010189c:	83 c4 10             	add    $0x10,%esp
8010189f:	3b 3d e8 25 11 80    	cmp    0x801125e8,%edi
801018a5:	73 69                	jae    80101910 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
801018a7:	89 f8                	mov    %edi,%eax
801018a9:	83 ec 08             	sub    $0x8,%esp
801018ac:	c1 e8 03             	shr    $0x3,%eax
801018af:	03 05 f8 25 11 80    	add    0x801125f8,%eax
801018b5:	50                   	push   %eax
801018b6:	56                   	push   %esi
801018b7:	e8 d4 e8 ff ff       	call   80100190 <bread>
    if(dip->type == 0){  // a free inode
801018bc:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
801018bf:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
801018c1:	89 f8                	mov    %edi,%eax
801018c3:	83 e0 07             	and    $0x7,%eax
801018c6:	c1 e0 06             	shl    $0x6,%eax
801018c9:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
801018cd:	66 83 39 00          	cmpw   $0x0,(%ecx)
801018d1:	75 bd                	jne    80101890 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
801018d3:	83 ec 04             	sub    $0x4,%esp
801018d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801018d9:	6a 40                	push   $0x40
801018db:	6a 00                	push   $0x0
801018dd:	51                   	push   %ecx
801018de:	e8 fd 30 00 00       	call   801049e0 <memset>
      dip->type = type;
801018e3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801018e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801018ea:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
801018ed:	89 1c 24             	mov    %ebx,(%esp)
801018f0:	e8 eb 18 00 00       	call   801031e0 <log_write>
      brelse(bp);
801018f5:	89 1c 24             	mov    %ebx,(%esp)
801018f8:	e8 13 e9 ff ff       	call   80100210 <brelse>
      return iget(dev, inum);
801018fd:	83 c4 10             	add    $0x10,%esp
}
80101900:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
80101903:	89 fa                	mov    %edi,%edx
}
80101905:	5b                   	pop    %ebx
      return iget(dev, inum);
80101906:	89 f0                	mov    %esi,%eax
}
80101908:	5e                   	pop    %esi
80101909:	5f                   	pop    %edi
8010190a:	5d                   	pop    %ebp
      return iget(dev, inum);
8010190b:	e9 70 fb ff ff       	jmp    80101480 <iget>
  panic("ialloc: no inodes");
80101910:	83 ec 0c             	sub    $0xc,%esp
80101913:	68 98 78 10 80       	push   $0x80107898
80101918:	e8 93 eb ff ff       	call   801004b0 <panic>
8010191d:	8d 76 00             	lea    0x0(%esi),%esi

80101920 <iupdate>:
{
80101920:	55                   	push   %ebp
80101921:	89 e5                	mov    %esp,%ebp
80101923:	56                   	push   %esi
80101924:	53                   	push   %ebx
80101925:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101928:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010192b:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010192e:	83 ec 08             	sub    $0x8,%esp
80101931:	c1 e8 03             	shr    $0x3,%eax
80101934:	03 05 f8 25 11 80    	add    0x801125f8,%eax
8010193a:	50                   	push   %eax
8010193b:	ff 73 a4             	push   -0x5c(%ebx)
8010193e:	e8 4d e8 ff ff       	call   80100190 <bread>
  dip->type = ip->type;
80101943:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101947:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010194a:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010194c:	8b 43 a8             	mov    -0x58(%ebx),%eax
8010194f:	83 e0 07             	and    $0x7,%eax
80101952:	c1 e0 06             	shl    $0x6,%eax
80101955:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101959:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010195c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101960:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
80101963:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
80101967:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
8010196b:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
8010196f:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
80101973:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
80101977:	8b 53 fc             	mov    -0x4(%ebx),%edx
8010197a:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010197d:	6a 34                	push   $0x34
8010197f:	53                   	push   %ebx
80101980:	50                   	push   %eax
80101981:	e8 fa 30 00 00       	call   80104a80 <memmove>
  log_write(bp);
80101986:	89 34 24             	mov    %esi,(%esp)
80101989:	e8 52 18 00 00       	call   801031e0 <log_write>
  brelse(bp);
8010198e:	89 75 08             	mov    %esi,0x8(%ebp)
80101991:	83 c4 10             	add    $0x10,%esp
}
80101994:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101997:	5b                   	pop    %ebx
80101998:	5e                   	pop    %esi
80101999:	5d                   	pop    %ebp
  brelse(bp);
8010199a:	e9 71 e8 ff ff       	jmp    80100210 <brelse>
8010199f:	90                   	nop

801019a0 <idup>:
{
801019a0:	55                   	push   %ebp
801019a1:	89 e5                	mov    %esp,%ebp
801019a3:	53                   	push   %ebx
801019a4:	83 ec 10             	sub    $0x10,%esp
801019a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801019aa:	68 60 09 11 80       	push   $0x80110960
801019af:	e8 6c 2f 00 00       	call   80104920 <acquire>
  ip->ref++;
801019b4:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
801019b8:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
801019bf:	e8 fc 2e 00 00       	call   801048c0 <release>
}
801019c4:	89 d8                	mov    %ebx,%eax
801019c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801019c9:	c9                   	leave  
801019ca:	c3                   	ret    
801019cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801019cf:	90                   	nop

801019d0 <ilock>:
{
801019d0:	55                   	push   %ebp
801019d1:	89 e5                	mov    %esp,%ebp
801019d3:	56                   	push   %esi
801019d4:	53                   	push   %ebx
801019d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
801019d8:	85 db                	test   %ebx,%ebx
801019da:	0f 84 b7 00 00 00    	je     80101a97 <ilock+0xc7>
801019e0:	8b 53 08             	mov    0x8(%ebx),%edx
801019e3:	85 d2                	test   %edx,%edx
801019e5:	0f 8e ac 00 00 00    	jle    80101a97 <ilock+0xc7>
  acquiresleep(&ip->lock);
801019eb:	83 ec 0c             	sub    $0xc,%esp
801019ee:	8d 43 0c             	lea    0xc(%ebx),%eax
801019f1:	50                   	push   %eax
801019f2:	e8 69 2c 00 00       	call   80104660 <acquiresleep>
  if(ip->valid == 0){
801019f7:	8b 43 4c             	mov    0x4c(%ebx),%eax
801019fa:	83 c4 10             	add    $0x10,%esp
801019fd:	85 c0                	test   %eax,%eax
801019ff:	74 0f                	je     80101a10 <ilock+0x40>
}
80101a01:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101a04:	5b                   	pop    %ebx
80101a05:	5e                   	pop    %esi
80101a06:	5d                   	pop    %ebp
80101a07:	c3                   	ret    
80101a08:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101a0f:	90                   	nop
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a10:	8b 43 04             	mov    0x4(%ebx),%eax
80101a13:	83 ec 08             	sub    $0x8,%esp
80101a16:	c1 e8 03             	shr    $0x3,%eax
80101a19:	03 05 f8 25 11 80    	add    0x801125f8,%eax
80101a1f:	50                   	push   %eax
80101a20:	ff 33                	push   (%ebx)
80101a22:	e8 69 e7 ff ff       	call   80100190 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a27:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a2a:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a2c:	8b 43 04             	mov    0x4(%ebx),%eax
80101a2f:	83 e0 07             	and    $0x7,%eax
80101a32:	c1 e0 06             	shl    $0x6,%eax
80101a35:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101a39:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a3c:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
80101a3f:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101a43:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
80101a47:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
80101a4b:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
80101a4f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101a53:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
80101a57:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101a5b:	8b 50 fc             	mov    -0x4(%eax),%edx
80101a5e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a61:	6a 34                	push   $0x34
80101a63:	50                   	push   %eax
80101a64:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101a67:	50                   	push   %eax
80101a68:	e8 13 30 00 00       	call   80104a80 <memmove>
    brelse(bp);
80101a6d:	89 34 24             	mov    %esi,(%esp)
80101a70:	e8 9b e7 ff ff       	call   80100210 <brelse>
    if(ip->type == 0)
80101a75:	83 c4 10             	add    $0x10,%esp
80101a78:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
80101a7d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101a84:	0f 85 77 ff ff ff    	jne    80101a01 <ilock+0x31>
      panic("ilock: no type");
80101a8a:	83 ec 0c             	sub    $0xc,%esp
80101a8d:	68 b0 78 10 80       	push   $0x801078b0
80101a92:	e8 19 ea ff ff       	call   801004b0 <panic>
    panic("ilock");
80101a97:	83 ec 0c             	sub    $0xc,%esp
80101a9a:	68 aa 78 10 80       	push   $0x801078aa
80101a9f:	e8 0c ea ff ff       	call   801004b0 <panic>
80101aa4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101aab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101aaf:	90                   	nop

80101ab0 <iunlock>:
{
80101ab0:	55                   	push   %ebp
80101ab1:	89 e5                	mov    %esp,%ebp
80101ab3:	56                   	push   %esi
80101ab4:	53                   	push   %ebx
80101ab5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101ab8:	85 db                	test   %ebx,%ebx
80101aba:	74 28                	je     80101ae4 <iunlock+0x34>
80101abc:	83 ec 0c             	sub    $0xc,%esp
80101abf:	8d 73 0c             	lea    0xc(%ebx),%esi
80101ac2:	56                   	push   %esi
80101ac3:	e8 38 2c 00 00       	call   80104700 <holdingsleep>
80101ac8:	83 c4 10             	add    $0x10,%esp
80101acb:	85 c0                	test   %eax,%eax
80101acd:	74 15                	je     80101ae4 <iunlock+0x34>
80101acf:	8b 43 08             	mov    0x8(%ebx),%eax
80101ad2:	85 c0                	test   %eax,%eax
80101ad4:	7e 0e                	jle    80101ae4 <iunlock+0x34>
  releasesleep(&ip->lock);
80101ad6:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101ad9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101adc:	5b                   	pop    %ebx
80101add:	5e                   	pop    %esi
80101ade:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
80101adf:	e9 dc 2b 00 00       	jmp    801046c0 <releasesleep>
    panic("iunlock");
80101ae4:	83 ec 0c             	sub    $0xc,%esp
80101ae7:	68 bf 78 10 80       	push   $0x801078bf
80101aec:	e8 bf e9 ff ff       	call   801004b0 <panic>
80101af1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101af8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101aff:	90                   	nop

80101b00 <iput>:
{
80101b00:	55                   	push   %ebp
80101b01:	89 e5                	mov    %esp,%ebp
80101b03:	57                   	push   %edi
80101b04:	56                   	push   %esi
80101b05:	53                   	push   %ebx
80101b06:	83 ec 28             	sub    $0x28,%esp
80101b09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101b0c:	8d 7b 0c             	lea    0xc(%ebx),%edi
80101b0f:	57                   	push   %edi
80101b10:	e8 4b 2b 00 00       	call   80104660 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101b15:	8b 53 4c             	mov    0x4c(%ebx),%edx
80101b18:	83 c4 10             	add    $0x10,%esp
80101b1b:	85 d2                	test   %edx,%edx
80101b1d:	74 07                	je     80101b26 <iput+0x26>
80101b1f:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101b24:	74 32                	je     80101b58 <iput+0x58>
  releasesleep(&ip->lock);
80101b26:	83 ec 0c             	sub    $0xc,%esp
80101b29:	57                   	push   %edi
80101b2a:	e8 91 2b 00 00       	call   801046c0 <releasesleep>
  acquire(&icache.lock);
80101b2f:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101b36:	e8 e5 2d 00 00       	call   80104920 <acquire>
  ip->ref--;
80101b3b:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101b3f:	83 c4 10             	add    $0x10,%esp
80101b42:	c7 45 08 60 09 11 80 	movl   $0x80110960,0x8(%ebp)
}
80101b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b4c:	5b                   	pop    %ebx
80101b4d:	5e                   	pop    %esi
80101b4e:	5f                   	pop    %edi
80101b4f:	5d                   	pop    %ebp
  release(&icache.lock);
80101b50:	e9 6b 2d 00 00       	jmp    801048c0 <release>
80101b55:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&icache.lock);
80101b58:	83 ec 0c             	sub    $0xc,%esp
80101b5b:	68 60 09 11 80       	push   $0x80110960
80101b60:	e8 bb 2d 00 00       	call   80104920 <acquire>
    int r = ip->ref;
80101b65:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101b68:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101b6f:	e8 4c 2d 00 00       	call   801048c0 <release>
    if(r == 1){
80101b74:	83 c4 10             	add    $0x10,%esp
80101b77:	83 fe 01             	cmp    $0x1,%esi
80101b7a:	75 aa                	jne    80101b26 <iput+0x26>
80101b7c:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101b82:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101b85:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101b88:	89 cf                	mov    %ecx,%edi
80101b8a:	eb 0b                	jmp    80101b97 <iput+0x97>
80101b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101b90:	83 c6 04             	add    $0x4,%esi
80101b93:	39 fe                	cmp    %edi,%esi
80101b95:	74 19                	je     80101bb0 <iput+0xb0>
    if(ip->addrs[i]){
80101b97:	8b 16                	mov    (%esi),%edx
80101b99:	85 d2                	test   %edx,%edx
80101b9b:	74 f3                	je     80101b90 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
80101b9d:	8b 03                	mov    (%ebx),%eax
80101b9f:	e8 4c f7 ff ff       	call   801012f0 <bfree>
      ip->addrs[i] = 0;
80101ba4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80101baa:	eb e4                	jmp    80101b90 <iput+0x90>
80101bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101bb0:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101bb6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101bb9:	85 c0                	test   %eax,%eax
80101bbb:	75 2d                	jne    80101bea <iput+0xea>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
80101bbd:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101bc0:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101bc7:	53                   	push   %ebx
80101bc8:	e8 53 fd ff ff       	call   80101920 <iupdate>
      ip->type = 0;
80101bcd:	31 c0                	xor    %eax,%eax
80101bcf:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101bd3:	89 1c 24             	mov    %ebx,(%esp)
80101bd6:	e8 45 fd ff ff       	call   80101920 <iupdate>
      ip->valid = 0;
80101bdb:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101be2:	83 c4 10             	add    $0x10,%esp
80101be5:	e9 3c ff ff ff       	jmp    80101b26 <iput+0x26>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101bea:	83 ec 08             	sub    $0x8,%esp
80101bed:	50                   	push   %eax
80101bee:	ff 33                	push   (%ebx)
80101bf0:	e8 9b e5 ff ff       	call   80100190 <bread>
80101bf5:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101bf8:	83 c4 10             	add    $0x10,%esp
80101bfb:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
80101c01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101c04:	8d 70 5c             	lea    0x5c(%eax),%esi
80101c07:	89 cf                	mov    %ecx,%edi
80101c09:	eb 0c                	jmp    80101c17 <iput+0x117>
80101c0b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101c0f:	90                   	nop
80101c10:	83 c6 04             	add    $0x4,%esi
80101c13:	39 f7                	cmp    %esi,%edi
80101c15:	74 0f                	je     80101c26 <iput+0x126>
      if(a[j])
80101c17:	8b 16                	mov    (%esi),%edx
80101c19:	85 d2                	test   %edx,%edx
80101c1b:	74 f3                	je     80101c10 <iput+0x110>
        bfree(ip->dev, a[j]);
80101c1d:	8b 03                	mov    (%ebx),%eax
80101c1f:	e8 cc f6 ff ff       	call   801012f0 <bfree>
80101c24:	eb ea                	jmp    80101c10 <iput+0x110>
    brelse(bp);
80101c26:	83 ec 0c             	sub    $0xc,%esp
80101c29:	ff 75 e4             	push   -0x1c(%ebp)
80101c2c:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101c2f:	e8 dc e5 ff ff       	call   80100210 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101c34:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101c3a:	8b 03                	mov    (%ebx),%eax
80101c3c:	e8 af f6 ff ff       	call   801012f0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101c41:	83 c4 10             	add    $0x10,%esp
80101c44:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101c4b:	00 00 00 
80101c4e:	e9 6a ff ff ff       	jmp    80101bbd <iput+0xbd>
80101c53:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101c5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101c60 <iunlockput>:
{
80101c60:	55                   	push   %ebp
80101c61:	89 e5                	mov    %esp,%ebp
80101c63:	56                   	push   %esi
80101c64:	53                   	push   %ebx
80101c65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c68:	85 db                	test   %ebx,%ebx
80101c6a:	74 34                	je     80101ca0 <iunlockput+0x40>
80101c6c:	83 ec 0c             	sub    $0xc,%esp
80101c6f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101c72:	56                   	push   %esi
80101c73:	e8 88 2a 00 00       	call   80104700 <holdingsleep>
80101c78:	83 c4 10             	add    $0x10,%esp
80101c7b:	85 c0                	test   %eax,%eax
80101c7d:	74 21                	je     80101ca0 <iunlockput+0x40>
80101c7f:	8b 43 08             	mov    0x8(%ebx),%eax
80101c82:	85 c0                	test   %eax,%eax
80101c84:	7e 1a                	jle    80101ca0 <iunlockput+0x40>
  releasesleep(&ip->lock);
80101c86:	83 ec 0c             	sub    $0xc,%esp
80101c89:	56                   	push   %esi
80101c8a:	e8 31 2a 00 00       	call   801046c0 <releasesleep>
  iput(ip);
80101c8f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101c92:	83 c4 10             	add    $0x10,%esp
}
80101c95:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101c98:	5b                   	pop    %ebx
80101c99:	5e                   	pop    %esi
80101c9a:	5d                   	pop    %ebp
  iput(ip);
80101c9b:	e9 60 fe ff ff       	jmp    80101b00 <iput>
    panic("iunlock");
80101ca0:	83 ec 0c             	sub    $0xc,%esp
80101ca3:	68 bf 78 10 80       	push   $0x801078bf
80101ca8:	e8 03 e8 ff ff       	call   801004b0 <panic>
80101cad:	8d 76 00             	lea    0x0(%esi),%esi

80101cb0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101cb0:	55                   	push   %ebp
80101cb1:	89 e5                	mov    %esp,%ebp
80101cb3:	8b 55 08             	mov    0x8(%ebp),%edx
80101cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101cb9:	8b 0a                	mov    (%edx),%ecx
80101cbb:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101cbe:	8b 4a 04             	mov    0x4(%edx),%ecx
80101cc1:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101cc4:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101cc8:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101ccb:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101ccf:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101cd3:	8b 52 58             	mov    0x58(%edx),%edx
80101cd6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101cd9:	5d                   	pop    %ebp
80101cda:	c3                   	ret    
80101cdb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101cdf:	90                   	nop

80101ce0 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ce0:	55                   	push   %ebp
80101ce1:	89 e5                	mov    %esp,%ebp
80101ce3:	57                   	push   %edi
80101ce4:	56                   	push   %esi
80101ce5:	53                   	push   %ebx
80101ce6:	83 ec 1c             	sub    $0x1c,%esp
80101ce9:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101cec:	8b 45 08             	mov    0x8(%ebp),%eax
80101cef:	8b 75 10             	mov    0x10(%ebp),%esi
80101cf2:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101cf5:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101cf8:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101cfd:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101d00:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101d03:	0f 84 a7 00 00 00    	je     80101db0 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101d09:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101d0c:	8b 40 58             	mov    0x58(%eax),%eax
80101d0f:	39 c6                	cmp    %eax,%esi
80101d11:	0f 87 ba 00 00 00    	ja     80101dd1 <readi+0xf1>
80101d17:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101d1a:	31 c9                	xor    %ecx,%ecx
80101d1c:	89 da                	mov    %ebx,%edx
80101d1e:	01 f2                	add    %esi,%edx
80101d20:	0f 92 c1             	setb   %cl
80101d23:	89 cf                	mov    %ecx,%edi
80101d25:	0f 82 a6 00 00 00    	jb     80101dd1 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101d2b:	89 c1                	mov    %eax,%ecx
80101d2d:	29 f1                	sub    %esi,%ecx
80101d2f:	39 d0                	cmp    %edx,%eax
80101d31:	0f 43 cb             	cmovae %ebx,%ecx
80101d34:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101d37:	85 c9                	test   %ecx,%ecx
80101d39:	74 67                	je     80101da2 <readi+0xc2>
80101d3b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101d3f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d40:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101d43:	89 f2                	mov    %esi,%edx
80101d45:	c1 ea 09             	shr    $0x9,%edx
80101d48:	89 d8                	mov    %ebx,%eax
80101d4a:	e8 31 f8 ff ff       	call   80101580 <bmap>
80101d4f:	83 ec 08             	sub    $0x8,%esp
80101d52:	50                   	push   %eax
80101d53:	ff 33                	push   (%ebx)
80101d55:	e8 36 e4 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101d5a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101d5d:	b9 00 02 00 00       	mov    $0x200,%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d62:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101d64:	89 f0                	mov    %esi,%eax
80101d66:	25 ff 01 00 00       	and    $0x1ff,%eax
80101d6b:	29 fb                	sub    %edi,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101d6d:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101d70:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101d72:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101d76:	39 d9                	cmp    %ebx,%ecx
80101d78:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101d7b:	83 c4 0c             	add    $0xc,%esp
80101d7e:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101d7f:	01 df                	add    %ebx,%edi
80101d81:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
80101d83:	50                   	push   %eax
80101d84:	ff 75 e0             	push   -0x20(%ebp)
80101d87:	e8 f4 2c 00 00       	call   80104a80 <memmove>
    brelse(bp);
80101d8c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101d8f:	89 14 24             	mov    %edx,(%esp)
80101d92:	e8 79 e4 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101d97:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101d9a:	83 c4 10             	add    $0x10,%esp
80101d9d:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101da0:	77 9e                	ja     80101d40 <readi+0x60>
  }
  return n;
80101da2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101da5:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101da8:	5b                   	pop    %ebx
80101da9:	5e                   	pop    %esi
80101daa:	5f                   	pop    %edi
80101dab:	5d                   	pop    %ebp
80101dac:	c3                   	ret    
80101dad:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101db0:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101db4:	66 83 f8 09          	cmp    $0x9,%ax
80101db8:	77 17                	ja     80101dd1 <readi+0xf1>
80101dba:	8b 04 c5 00 09 11 80 	mov    -0x7feef700(,%eax,8),%eax
80101dc1:	85 c0                	test   %eax,%eax
80101dc3:	74 0c                	je     80101dd1 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101dc5:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101dcb:	5b                   	pop    %ebx
80101dcc:	5e                   	pop    %esi
80101dcd:	5f                   	pop    %edi
80101dce:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101dcf:	ff e0                	jmp    *%eax
      return -1;
80101dd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dd6:	eb cd                	jmp    80101da5 <readi+0xc5>
80101dd8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101ddf:	90                   	nop

80101de0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101de0:	55                   	push   %ebp
80101de1:	89 e5                	mov    %esp,%ebp
80101de3:	57                   	push   %edi
80101de4:	56                   	push   %esi
80101de5:	53                   	push   %ebx
80101de6:	83 ec 1c             	sub    $0x1c,%esp
80101de9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dec:	8b 75 0c             	mov    0xc(%ebp),%esi
80101def:	8b 55 14             	mov    0x14(%ebp),%edx
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101df2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101df7:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101dfa:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101dfd:	8b 75 10             	mov    0x10(%ebp),%esi
80101e00:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(ip->type == T_DEV){
80101e03:	0f 84 b7 00 00 00    	je     80101ec0 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101e09:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101e0c:	3b 70 58             	cmp    0x58(%eax),%esi
80101e0f:	0f 87 e7 00 00 00    	ja     80101efc <writei+0x11c>
80101e15:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101e18:	31 d2                	xor    %edx,%edx
80101e1a:	89 f8                	mov    %edi,%eax
80101e1c:	01 f0                	add    %esi,%eax
80101e1e:	0f 92 c2             	setb   %dl
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101e21:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101e26:	0f 87 d0 00 00 00    	ja     80101efc <writei+0x11c>
80101e2c:	85 d2                	test   %edx,%edx
80101e2e:	0f 85 c8 00 00 00    	jne    80101efc <writei+0x11c>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101e34:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101e3b:	85 ff                	test   %edi,%edi
80101e3d:	74 72                	je     80101eb1 <writei+0xd1>
80101e3f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e40:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101e43:	89 f2                	mov    %esi,%edx
80101e45:	c1 ea 09             	shr    $0x9,%edx
80101e48:	89 f8                	mov    %edi,%eax
80101e4a:	e8 31 f7 ff ff       	call   80101580 <bmap>
80101e4f:	83 ec 08             	sub    $0x8,%esp
80101e52:	50                   	push   %eax
80101e53:	ff 37                	push   (%edi)
80101e55:	e8 36 e3 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101e5a:	b9 00 02 00 00       	mov    $0x200,%ecx
80101e5f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101e62:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e65:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101e67:	89 f0                	mov    %esi,%eax
80101e69:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e6e:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101e70:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101e74:	39 d9                	cmp    %ebx,%ecx
80101e76:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101e79:	83 c4 0c             	add    $0xc,%esp
80101e7c:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101e7d:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101e7f:	ff 75 dc             	push   -0x24(%ebp)
80101e82:	50                   	push   %eax
80101e83:	e8 f8 2b 00 00       	call   80104a80 <memmove>
    log_write(bp);
80101e88:	89 3c 24             	mov    %edi,(%esp)
80101e8b:	e8 50 13 00 00       	call   801031e0 <log_write>
    brelse(bp);
80101e90:	89 3c 24             	mov    %edi,(%esp)
80101e93:	e8 78 e3 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101e98:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101e9b:	83 c4 10             	add    $0x10,%esp
80101e9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101ea1:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101ea4:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101ea7:	77 97                	ja     80101e40 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101ea9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101eac:	3b 70 58             	cmp    0x58(%eax),%esi
80101eaf:	77 37                	ja     80101ee8 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101eb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101eb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101eb7:	5b                   	pop    %ebx
80101eb8:	5e                   	pop    %esi
80101eb9:	5f                   	pop    %edi
80101eba:	5d                   	pop    %ebp
80101ebb:	c3                   	ret    
80101ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101ec0:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101ec4:	66 83 f8 09          	cmp    $0x9,%ax
80101ec8:	77 32                	ja     80101efc <writei+0x11c>
80101eca:	8b 04 c5 04 09 11 80 	mov    -0x7feef6fc(,%eax,8),%eax
80101ed1:	85 c0                	test   %eax,%eax
80101ed3:	74 27                	je     80101efc <writei+0x11c>
    return devsw[ip->major].write(ip, src, n);
80101ed5:	89 55 10             	mov    %edx,0x10(%ebp)
}
80101ed8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101edb:	5b                   	pop    %ebx
80101edc:	5e                   	pop    %esi
80101edd:	5f                   	pop    %edi
80101ede:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101edf:	ff e0                	jmp    *%eax
80101ee1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101ee8:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101eeb:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101eee:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101ef1:	50                   	push   %eax
80101ef2:	e8 29 fa ff ff       	call   80101920 <iupdate>
80101ef7:	83 c4 10             	add    $0x10,%esp
80101efa:	eb b5                	jmp    80101eb1 <writei+0xd1>
      return -1;
80101efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f01:	eb b1                	jmp    80101eb4 <writei+0xd4>
80101f03:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101f0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101f10 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101f10:	55                   	push   %ebp
80101f11:	89 e5                	mov    %esp,%ebp
80101f13:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101f16:	6a 0e                	push   $0xe
80101f18:	ff 75 0c             	push   0xc(%ebp)
80101f1b:	ff 75 08             	push   0x8(%ebp)
80101f1e:	e8 cd 2b 00 00       	call   80104af0 <strncmp>
}
80101f23:	c9                   	leave  
80101f24:	c3                   	ret    
80101f25:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101f30 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101f30:	55                   	push   %ebp
80101f31:	89 e5                	mov    %esp,%ebp
80101f33:	57                   	push   %edi
80101f34:	56                   	push   %esi
80101f35:	53                   	push   %ebx
80101f36:	83 ec 1c             	sub    $0x1c,%esp
80101f39:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101f3c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101f41:	0f 85 85 00 00 00    	jne    80101fcc <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101f47:	8b 53 58             	mov    0x58(%ebx),%edx
80101f4a:	31 ff                	xor    %edi,%edi
80101f4c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101f4f:	85 d2                	test   %edx,%edx
80101f51:	74 3e                	je     80101f91 <dirlookup+0x61>
80101f53:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101f57:	90                   	nop
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101f58:	6a 10                	push   $0x10
80101f5a:	57                   	push   %edi
80101f5b:	56                   	push   %esi
80101f5c:	53                   	push   %ebx
80101f5d:	e8 7e fd ff ff       	call   80101ce0 <readi>
80101f62:	83 c4 10             	add    $0x10,%esp
80101f65:	83 f8 10             	cmp    $0x10,%eax
80101f68:	75 55                	jne    80101fbf <dirlookup+0x8f>
      panic("dirlookup read");
    if(de.inum == 0)
80101f6a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101f6f:	74 18                	je     80101f89 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101f71:	83 ec 04             	sub    $0x4,%esp
80101f74:	8d 45 da             	lea    -0x26(%ebp),%eax
80101f77:	6a 0e                	push   $0xe
80101f79:	50                   	push   %eax
80101f7a:	ff 75 0c             	push   0xc(%ebp)
80101f7d:	e8 6e 2b 00 00       	call   80104af0 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101f82:	83 c4 10             	add    $0x10,%esp
80101f85:	85 c0                	test   %eax,%eax
80101f87:	74 17                	je     80101fa0 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101f89:	83 c7 10             	add    $0x10,%edi
80101f8c:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101f8f:	72 c7                	jb     80101f58 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101f91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101f94:	31 c0                	xor    %eax,%eax
}
80101f96:	5b                   	pop    %ebx
80101f97:	5e                   	pop    %esi
80101f98:	5f                   	pop    %edi
80101f99:	5d                   	pop    %ebp
80101f9a:	c3                   	ret    
80101f9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101f9f:	90                   	nop
      if(poff)
80101fa0:	8b 45 10             	mov    0x10(%ebp),%eax
80101fa3:	85 c0                	test   %eax,%eax
80101fa5:	74 05                	je     80101fac <dirlookup+0x7c>
        *poff = off;
80101fa7:	8b 45 10             	mov    0x10(%ebp),%eax
80101faa:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101fac:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101fb0:	8b 03                	mov    (%ebx),%eax
80101fb2:	e8 c9 f4 ff ff       	call   80101480 <iget>
}
80101fb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101fba:	5b                   	pop    %ebx
80101fbb:	5e                   	pop    %esi
80101fbc:	5f                   	pop    %edi
80101fbd:	5d                   	pop    %ebp
80101fbe:	c3                   	ret    
      panic("dirlookup read");
80101fbf:	83 ec 0c             	sub    $0xc,%esp
80101fc2:	68 d9 78 10 80       	push   $0x801078d9
80101fc7:	e8 e4 e4 ff ff       	call   801004b0 <panic>
    panic("dirlookup not DIR");
80101fcc:	83 ec 0c             	sub    $0xc,%esp
80101fcf:	68 c7 78 10 80       	push   $0x801078c7
80101fd4:	e8 d7 e4 ff ff       	call   801004b0 <panic>
80101fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101fe0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101fe0:	55                   	push   %ebp
80101fe1:	89 e5                	mov    %esp,%ebp
80101fe3:	57                   	push   %edi
80101fe4:	56                   	push   %esi
80101fe5:	53                   	push   %ebx
80101fe6:	89 c3                	mov    %eax,%ebx
80101fe8:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101feb:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101fee:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ff1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80101ff4:	0f 84 64 01 00 00    	je     8010215e <namex+0x17e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101ffa:	e8 31 1c 00 00       	call   80103c30 <myproc>
  acquire(&icache.lock);
80101fff:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(myproc()->cwd);
80102002:	8b 70 6c             	mov    0x6c(%eax),%esi
  acquire(&icache.lock);
80102005:	68 60 09 11 80       	push   $0x80110960
8010200a:	e8 11 29 00 00       	call   80104920 <acquire>
  ip->ref++;
8010200f:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80102013:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
8010201a:	e8 a1 28 00 00       	call   801048c0 <release>
8010201f:	83 c4 10             	add    $0x10,%esp
80102022:	eb 07                	jmp    8010202b <namex+0x4b>
80102024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80102028:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
8010202b:	0f b6 03             	movzbl (%ebx),%eax
8010202e:	3c 2f                	cmp    $0x2f,%al
80102030:	74 f6                	je     80102028 <namex+0x48>
  if(*path == 0)
80102032:	84 c0                	test   %al,%al
80102034:	0f 84 06 01 00 00    	je     80102140 <namex+0x160>
  while(*path != '/' && *path != 0)
8010203a:	0f b6 03             	movzbl (%ebx),%eax
8010203d:	84 c0                	test   %al,%al
8010203f:	0f 84 10 01 00 00    	je     80102155 <namex+0x175>
80102045:	89 df                	mov    %ebx,%edi
80102047:	3c 2f                	cmp    $0x2f,%al
80102049:	0f 84 06 01 00 00    	je     80102155 <namex+0x175>
8010204f:	90                   	nop
80102050:	0f b6 47 01          	movzbl 0x1(%edi),%eax
    path++;
80102054:	83 c7 01             	add    $0x1,%edi
  while(*path != '/' && *path != 0)
80102057:	3c 2f                	cmp    $0x2f,%al
80102059:	74 04                	je     8010205f <namex+0x7f>
8010205b:	84 c0                	test   %al,%al
8010205d:	75 f1                	jne    80102050 <namex+0x70>
  len = path - s;
8010205f:	89 f8                	mov    %edi,%eax
80102061:	29 d8                	sub    %ebx,%eax
  if(len >= DIRSIZ)
80102063:	83 f8 0d             	cmp    $0xd,%eax
80102066:	0f 8e ac 00 00 00    	jle    80102118 <namex+0x138>
    memmove(name, s, DIRSIZ);
8010206c:	83 ec 04             	sub    $0x4,%esp
8010206f:	6a 0e                	push   $0xe
80102071:	53                   	push   %ebx
    path++;
80102072:	89 fb                	mov    %edi,%ebx
    memmove(name, s, DIRSIZ);
80102074:	ff 75 e4             	push   -0x1c(%ebp)
80102077:	e8 04 2a 00 00       	call   80104a80 <memmove>
8010207c:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
8010207f:	80 3f 2f             	cmpb   $0x2f,(%edi)
80102082:	75 0c                	jne    80102090 <namex+0xb0>
80102084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80102088:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
8010208b:	80 3b 2f             	cmpb   $0x2f,(%ebx)
8010208e:	74 f8                	je     80102088 <namex+0xa8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80102090:	83 ec 0c             	sub    $0xc,%esp
80102093:	56                   	push   %esi
80102094:	e8 37 f9 ff ff       	call   801019d0 <ilock>
    if(ip->type != T_DIR){
80102099:	83 c4 10             	add    $0x10,%esp
8010209c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801020a1:	0f 85 cd 00 00 00    	jne    80102174 <namex+0x194>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
801020a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801020aa:	85 c0                	test   %eax,%eax
801020ac:	74 09                	je     801020b7 <namex+0xd7>
801020ae:	80 3b 00             	cmpb   $0x0,(%ebx)
801020b1:	0f 84 22 01 00 00    	je     801021d9 <namex+0x1f9>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801020b7:	83 ec 04             	sub    $0x4,%esp
801020ba:	6a 00                	push   $0x0
801020bc:	ff 75 e4             	push   -0x1c(%ebp)
801020bf:	56                   	push   %esi
801020c0:	e8 6b fe ff ff       	call   80101f30 <dirlookup>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801020c5:	8d 56 0c             	lea    0xc(%esi),%edx
    if((next = dirlookup(ip, name, 0)) == 0){
801020c8:	83 c4 10             	add    $0x10,%esp
801020cb:	89 c7                	mov    %eax,%edi
801020cd:	85 c0                	test   %eax,%eax
801020cf:	0f 84 e1 00 00 00    	je     801021b6 <namex+0x1d6>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801020d5:	83 ec 0c             	sub    $0xc,%esp
801020d8:	89 55 e0             	mov    %edx,-0x20(%ebp)
801020db:	52                   	push   %edx
801020dc:	e8 1f 26 00 00       	call   80104700 <holdingsleep>
801020e1:	83 c4 10             	add    $0x10,%esp
801020e4:	85 c0                	test   %eax,%eax
801020e6:	0f 84 30 01 00 00    	je     8010221c <namex+0x23c>
801020ec:	8b 56 08             	mov    0x8(%esi),%edx
801020ef:	85 d2                	test   %edx,%edx
801020f1:	0f 8e 25 01 00 00    	jle    8010221c <namex+0x23c>
  releasesleep(&ip->lock);
801020f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801020fa:	83 ec 0c             	sub    $0xc,%esp
801020fd:	52                   	push   %edx
801020fe:	e8 bd 25 00 00       	call   801046c0 <releasesleep>
  iput(ip);
80102103:	89 34 24             	mov    %esi,(%esp)
80102106:	89 fe                	mov    %edi,%esi
80102108:	e8 f3 f9 ff ff       	call   80101b00 <iput>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	e9 16 ff ff ff       	jmp    8010202b <namex+0x4b>
80102115:	8d 76 00             	lea    0x0(%esi),%esi
    name[len] = 0;
80102118:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010211b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
    memmove(name, s, len);
8010211e:	83 ec 04             	sub    $0x4,%esp
80102121:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102124:	50                   	push   %eax
80102125:	53                   	push   %ebx
    name[len] = 0;
80102126:	89 fb                	mov    %edi,%ebx
    memmove(name, s, len);
80102128:	ff 75 e4             	push   -0x1c(%ebp)
8010212b:	e8 50 29 00 00       	call   80104a80 <memmove>
    name[len] = 0;
80102130:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102133:	83 c4 10             	add    $0x10,%esp
80102136:	c6 02 00             	movb   $0x0,(%edx)
80102139:	e9 41 ff ff ff       	jmp    8010207f <namex+0x9f>
8010213e:	66 90                	xchg   %ax,%ax
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102140:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102143:	85 c0                	test   %eax,%eax
80102145:	0f 85 be 00 00 00    	jne    80102209 <namex+0x229>
    iput(ip);
    return 0;
  }
  return ip;
}
8010214b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010214e:	89 f0                	mov    %esi,%eax
80102150:	5b                   	pop    %ebx
80102151:	5e                   	pop    %esi
80102152:	5f                   	pop    %edi
80102153:	5d                   	pop    %ebp
80102154:	c3                   	ret    
  while(*path != '/' && *path != 0)
80102155:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102158:	89 df                	mov    %ebx,%edi
8010215a:	31 c0                	xor    %eax,%eax
8010215c:	eb c0                	jmp    8010211e <namex+0x13e>
    ip = iget(ROOTDEV, ROOTINO);
8010215e:	ba 01 00 00 00       	mov    $0x1,%edx
80102163:	b8 01 00 00 00       	mov    $0x1,%eax
80102168:	e8 13 f3 ff ff       	call   80101480 <iget>
8010216d:	89 c6                	mov    %eax,%esi
8010216f:	e9 b7 fe ff ff       	jmp    8010202b <namex+0x4b>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80102174:	83 ec 0c             	sub    $0xc,%esp
80102177:	8d 5e 0c             	lea    0xc(%esi),%ebx
8010217a:	53                   	push   %ebx
8010217b:	e8 80 25 00 00       	call   80104700 <holdingsleep>
80102180:	83 c4 10             	add    $0x10,%esp
80102183:	85 c0                	test   %eax,%eax
80102185:	0f 84 91 00 00 00    	je     8010221c <namex+0x23c>
8010218b:	8b 46 08             	mov    0x8(%esi),%eax
8010218e:	85 c0                	test   %eax,%eax
80102190:	0f 8e 86 00 00 00    	jle    8010221c <namex+0x23c>
  releasesleep(&ip->lock);
80102196:	83 ec 0c             	sub    $0xc,%esp
80102199:	53                   	push   %ebx
8010219a:	e8 21 25 00 00       	call   801046c0 <releasesleep>
  iput(ip);
8010219f:	89 34 24             	mov    %esi,(%esp)
      return 0;
801021a2:	31 f6                	xor    %esi,%esi
  iput(ip);
801021a4:	e8 57 f9 ff ff       	call   80101b00 <iput>
      return 0;
801021a9:	83 c4 10             	add    $0x10,%esp
}
801021ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
801021af:	89 f0                	mov    %esi,%eax
801021b1:	5b                   	pop    %ebx
801021b2:	5e                   	pop    %esi
801021b3:	5f                   	pop    %edi
801021b4:	5d                   	pop    %ebp
801021b5:	c3                   	ret    
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801021b6:	83 ec 0c             	sub    $0xc,%esp
801021b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801021bc:	52                   	push   %edx
801021bd:	e8 3e 25 00 00       	call   80104700 <holdingsleep>
801021c2:	83 c4 10             	add    $0x10,%esp
801021c5:	85 c0                	test   %eax,%eax
801021c7:	74 53                	je     8010221c <namex+0x23c>
801021c9:	8b 4e 08             	mov    0x8(%esi),%ecx
801021cc:	85 c9                	test   %ecx,%ecx
801021ce:	7e 4c                	jle    8010221c <namex+0x23c>
  releasesleep(&ip->lock);
801021d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801021d3:	83 ec 0c             	sub    $0xc,%esp
801021d6:	52                   	push   %edx
801021d7:	eb c1                	jmp    8010219a <namex+0x1ba>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801021d9:	83 ec 0c             	sub    $0xc,%esp
801021dc:	8d 5e 0c             	lea    0xc(%esi),%ebx
801021df:	53                   	push   %ebx
801021e0:	e8 1b 25 00 00       	call   80104700 <holdingsleep>
801021e5:	83 c4 10             	add    $0x10,%esp
801021e8:	85 c0                	test   %eax,%eax
801021ea:	74 30                	je     8010221c <namex+0x23c>
801021ec:	8b 7e 08             	mov    0x8(%esi),%edi
801021ef:	85 ff                	test   %edi,%edi
801021f1:	7e 29                	jle    8010221c <namex+0x23c>
  releasesleep(&ip->lock);
801021f3:	83 ec 0c             	sub    $0xc,%esp
801021f6:	53                   	push   %ebx
801021f7:	e8 c4 24 00 00       	call   801046c0 <releasesleep>
}
801021fc:	83 c4 10             	add    $0x10,%esp
}
801021ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102202:	89 f0                	mov    %esi,%eax
80102204:	5b                   	pop    %ebx
80102205:	5e                   	pop    %esi
80102206:	5f                   	pop    %edi
80102207:	5d                   	pop    %ebp
80102208:	c3                   	ret    
    iput(ip);
80102209:	83 ec 0c             	sub    $0xc,%esp
8010220c:	56                   	push   %esi
    return 0;
8010220d:	31 f6                	xor    %esi,%esi
    iput(ip);
8010220f:	e8 ec f8 ff ff       	call   80101b00 <iput>
    return 0;
80102214:	83 c4 10             	add    $0x10,%esp
80102217:	e9 2f ff ff ff       	jmp    8010214b <namex+0x16b>
    panic("iunlock");
8010221c:	83 ec 0c             	sub    $0xc,%esp
8010221f:	68 bf 78 10 80       	push   $0x801078bf
80102224:	e8 87 e2 ff ff       	call   801004b0 <panic>
80102229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102230 <dirlink>:
{
80102230:	55                   	push   %ebp
80102231:	89 e5                	mov    %esp,%ebp
80102233:	57                   	push   %edi
80102234:	56                   	push   %esi
80102235:	53                   	push   %ebx
80102236:	83 ec 20             	sub    $0x20,%esp
80102239:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
8010223c:	6a 00                	push   $0x0
8010223e:	ff 75 0c             	push   0xc(%ebp)
80102241:	53                   	push   %ebx
80102242:	e8 e9 fc ff ff       	call   80101f30 <dirlookup>
80102247:	83 c4 10             	add    $0x10,%esp
8010224a:	85 c0                	test   %eax,%eax
8010224c:	75 67                	jne    801022b5 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010224e:	8b 7b 58             	mov    0x58(%ebx),%edi
80102251:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102254:	85 ff                	test   %edi,%edi
80102256:	74 29                	je     80102281 <dirlink+0x51>
80102258:	31 ff                	xor    %edi,%edi
8010225a:	8d 75 d8             	lea    -0x28(%ebp),%esi
8010225d:	eb 09                	jmp    80102268 <dirlink+0x38>
8010225f:	90                   	nop
80102260:	83 c7 10             	add    $0x10,%edi
80102263:	3b 7b 58             	cmp    0x58(%ebx),%edi
80102266:	73 19                	jae    80102281 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102268:	6a 10                	push   $0x10
8010226a:	57                   	push   %edi
8010226b:	56                   	push   %esi
8010226c:	53                   	push   %ebx
8010226d:	e8 6e fa ff ff       	call   80101ce0 <readi>
80102272:	83 c4 10             	add    $0x10,%esp
80102275:	83 f8 10             	cmp    $0x10,%eax
80102278:	75 4e                	jne    801022c8 <dirlink+0x98>
    if(de.inum == 0)
8010227a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010227f:	75 df                	jne    80102260 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80102281:	83 ec 04             	sub    $0x4,%esp
80102284:	8d 45 da             	lea    -0x26(%ebp),%eax
80102287:	6a 0e                	push   $0xe
80102289:	ff 75 0c             	push   0xc(%ebp)
8010228c:	50                   	push   %eax
8010228d:	e8 ae 28 00 00       	call   80104b40 <strncpy>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102292:	6a 10                	push   $0x10
  de.inum = inum;
80102294:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102297:	57                   	push   %edi
80102298:	56                   	push   %esi
80102299:	53                   	push   %ebx
  de.inum = inum;
8010229a:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010229e:	e8 3d fb ff ff       	call   80101de0 <writei>
801022a3:	83 c4 20             	add    $0x20,%esp
801022a6:	83 f8 10             	cmp    $0x10,%eax
801022a9:	75 2a                	jne    801022d5 <dirlink+0xa5>
  return 0;
801022ab:	31 c0                	xor    %eax,%eax
}
801022ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022b0:	5b                   	pop    %ebx
801022b1:	5e                   	pop    %esi
801022b2:	5f                   	pop    %edi
801022b3:	5d                   	pop    %ebp
801022b4:	c3                   	ret    
    iput(ip);
801022b5:	83 ec 0c             	sub    $0xc,%esp
801022b8:	50                   	push   %eax
801022b9:	e8 42 f8 ff ff       	call   80101b00 <iput>
    return -1;
801022be:	83 c4 10             	add    $0x10,%esp
801022c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c6:	eb e5                	jmp    801022ad <dirlink+0x7d>
      panic("dirlink read");
801022c8:	83 ec 0c             	sub    $0xc,%esp
801022cb:	68 e8 78 10 80       	push   $0x801078e8
801022d0:	e8 db e1 ff ff       	call   801004b0 <panic>
    panic("dirlink");
801022d5:	83 ec 0c             	sub    $0xc,%esp
801022d8:	68 06 7f 10 80       	push   $0x80107f06
801022dd:	e8 ce e1 ff ff       	call   801004b0 <panic>
801022e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801022f0 <namei>:

struct inode*
namei(char *path)
{
801022f0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
801022f1:	31 d2                	xor    %edx,%edx
{
801022f3:	89 e5                	mov    %esp,%ebp
801022f5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
801022f8:	8b 45 08             	mov    0x8(%ebp),%eax
801022fb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
801022fe:	e8 dd fc ff ff       	call   80101fe0 <namex>
}
80102303:	c9                   	leave  
80102304:	c3                   	ret    
80102305:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102310 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102310:	55                   	push   %ebp
  return namex(path, 1, name);
80102311:	ba 01 00 00 00       	mov    $0x1,%edx
{
80102316:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
80102318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010231b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010231e:	5d                   	pop    %ebp
  return namex(path, 1, name);
8010231f:	e9 bc fc ff ff       	jmp    80101fe0 <namex>
80102324:	66 90                	xchg   %ax,%ax
80102326:	66 90                	xchg   %ax,%ax
80102328:	66 90                	xchg   %ax,%ax
8010232a:	66 90                	xchg   %ax,%ax
8010232c:	66 90                	xchg   %ax,%ax
8010232e:	66 90                	xchg   %ax,%ax

80102330 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102330:	55                   	push   %ebp
80102331:	89 e5                	mov    %esp,%ebp
80102333:	57                   	push   %edi
80102334:	56                   	push   %esi
80102335:	53                   	push   %ebx
80102336:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
80102339:	85 c0                	test   %eax,%eax
8010233b:	0f 84 b4 00 00 00    	je     801023f5 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80102341:	8b 70 08             	mov    0x8(%eax),%esi
80102344:	89 c3                	mov    %eax,%ebx
80102346:	81 fe e7 03 00 00    	cmp    $0x3e7,%esi
8010234c:	0f 87 96 00 00 00    	ja     801023e8 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102352:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102357:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010235e:	66 90                	xchg   %ax,%ax
80102360:	89 ca                	mov    %ecx,%edx
80102362:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102363:	83 e0 c0             	and    $0xffffffc0,%eax
80102366:	3c 40                	cmp    $0x40,%al
80102368:	75 f6                	jne    80102360 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010236a:	31 ff                	xor    %edi,%edi
8010236c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102371:	89 f8                	mov    %edi,%eax
80102373:	ee                   	out    %al,(%dx)
80102374:	b8 01 00 00 00       	mov    $0x1,%eax
80102379:	ba f2 01 00 00       	mov    $0x1f2,%edx
8010237e:	ee                   	out    %al,(%dx)
8010237f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80102384:	89 f0                	mov    %esi,%eax
80102386:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80102387:	89 f0                	mov    %esi,%eax
80102389:	ba f4 01 00 00       	mov    $0x1f4,%edx
8010238e:	c1 f8 08             	sar    $0x8,%eax
80102391:	ee                   	out    %al,(%dx)
80102392:	ba f5 01 00 00       	mov    $0x1f5,%edx
80102397:	89 f8                	mov    %edi,%eax
80102399:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010239a:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
8010239e:	ba f6 01 00 00       	mov    $0x1f6,%edx
801023a3:	c1 e0 04             	shl    $0x4,%eax
801023a6:	83 e0 10             	and    $0x10,%eax
801023a9:	83 c8 e0             	or     $0xffffffe0,%eax
801023ac:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
801023ad:	f6 03 04             	testb  $0x4,(%ebx)
801023b0:	75 16                	jne    801023c8 <idestart+0x98>
801023b2:	b8 20 00 00 00       	mov    $0x20,%eax
801023b7:	89 ca                	mov    %ecx,%edx
801023b9:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
801023ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
801023bd:	5b                   	pop    %ebx
801023be:	5e                   	pop    %esi
801023bf:	5f                   	pop    %edi
801023c0:	5d                   	pop    %ebp
801023c1:	c3                   	ret    
801023c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801023c8:	b8 30 00 00 00       	mov    $0x30,%eax
801023cd:	89 ca                	mov    %ecx,%edx
801023cf:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
801023d0:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
801023d5:	8d 73 5c             	lea    0x5c(%ebx),%esi
801023d8:	ba f0 01 00 00       	mov    $0x1f0,%edx
801023dd:	fc                   	cld    
801023de:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
801023e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801023e3:	5b                   	pop    %ebx
801023e4:	5e                   	pop    %esi
801023e5:	5f                   	pop    %edi
801023e6:	5d                   	pop    %ebp
801023e7:	c3                   	ret    
    panic("incorrect blockno");
801023e8:	83 ec 0c             	sub    $0xc,%esp
801023eb:	68 54 79 10 80       	push   $0x80107954
801023f0:	e8 bb e0 ff ff       	call   801004b0 <panic>
    panic("idestart");
801023f5:	83 ec 0c             	sub    $0xc,%esp
801023f8:	68 4b 79 10 80       	push   $0x8010794b
801023fd:	e8 ae e0 ff ff       	call   801004b0 <panic>
80102402:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102410 <ideinit>:
{
80102410:	55                   	push   %ebp
80102411:	89 e5                	mov    %esp,%ebp
80102413:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80102416:	68 66 79 10 80       	push   $0x80107966
8010241b:	68 40 26 11 80       	push   $0x80112640
80102420:	e8 2b 23 00 00       	call   80104750 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102425:	58                   	pop    %eax
80102426:	a1 c4 27 11 80       	mov    0x801127c4,%eax
8010242b:	5a                   	pop    %edx
8010242c:	83 e8 01             	sub    $0x1,%eax
8010242f:	50                   	push   %eax
80102430:	6a 0e                	push   $0xe
80102432:	e8 99 02 00 00       	call   801026d0 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102437:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010243a:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010243f:	90                   	nop
80102440:	ec                   	in     (%dx),%al
80102441:	83 e0 c0             	and    $0xffffffc0,%eax
80102444:	3c 40                	cmp    $0x40,%al
80102446:	75 f8                	jne    80102440 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102448:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010244d:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102452:	ee                   	out    %al,(%dx)
80102453:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102458:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010245d:	eb 06                	jmp    80102465 <ideinit+0x55>
8010245f:	90                   	nop
  for(i=0; i<1000; i++){
80102460:	83 e9 01             	sub    $0x1,%ecx
80102463:	74 0f                	je     80102474 <ideinit+0x64>
80102465:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102466:	84 c0                	test   %al,%al
80102468:	74 f6                	je     80102460 <ideinit+0x50>
      havedisk1 = 1;
8010246a:	c7 05 20 26 11 80 01 	movl   $0x1,0x80112620
80102471:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102474:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102479:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010247e:	ee                   	out    %al,(%dx)
}
8010247f:	c9                   	leave  
80102480:	c3                   	ret    
80102481:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102488:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010248f:	90                   	nop

80102490 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102490:	55                   	push   %ebp
80102491:	89 e5                	mov    %esp,%ebp
80102493:	57                   	push   %edi
80102494:	56                   	push   %esi
80102495:	53                   	push   %ebx
80102496:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102499:	68 40 26 11 80       	push   $0x80112640
8010249e:	e8 7d 24 00 00       	call   80104920 <acquire>

  if((b = idequeue) == 0){
801024a3:	8b 1d 24 26 11 80    	mov    0x80112624,%ebx
801024a9:	83 c4 10             	add    $0x10,%esp
801024ac:	85 db                	test   %ebx,%ebx
801024ae:	74 63                	je     80102513 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
801024b0:	8b 43 58             	mov    0x58(%ebx),%eax
801024b3:	a3 24 26 11 80       	mov    %eax,0x80112624

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801024b8:	8b 33                	mov    (%ebx),%esi
801024ba:	f7 c6 04 00 00 00    	test   $0x4,%esi
801024c0:	75 2f                	jne    801024f1 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024c2:	ba f7 01 00 00       	mov    $0x1f7,%edx
801024c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801024ce:	66 90                	xchg   %ax,%ax
801024d0:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801024d1:	89 c1                	mov    %eax,%ecx
801024d3:	83 e1 c0             	and    $0xffffffc0,%ecx
801024d6:	80 f9 40             	cmp    $0x40,%cl
801024d9:	75 f5                	jne    801024d0 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801024db:	a8 21                	test   $0x21,%al
801024dd:	75 12                	jne    801024f1 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
801024df:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
801024e2:	b9 80 00 00 00       	mov    $0x80,%ecx
801024e7:	ba f0 01 00 00       	mov    $0x1f0,%edx
801024ec:	fc                   	cld    
801024ed:	f3 6d                	rep insl (%dx),%es:(%edi)

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801024ef:	8b 33                	mov    (%ebx),%esi
  b->flags &= ~B_DIRTY;
801024f1:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
801024f4:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801024f7:	83 ce 02             	or     $0x2,%esi
801024fa:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
801024fc:	53                   	push   %ebx
801024fd:	e8 2e 1f 00 00       	call   80104430 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102502:	a1 24 26 11 80       	mov    0x80112624,%eax
80102507:	83 c4 10             	add    $0x10,%esp
8010250a:	85 c0                	test   %eax,%eax
8010250c:	74 05                	je     80102513 <ideintr+0x83>
    idestart(idequeue);
8010250e:	e8 1d fe ff ff       	call   80102330 <idestart>
    release(&idelock);
80102513:	83 ec 0c             	sub    $0xc,%esp
80102516:	68 40 26 11 80       	push   $0x80112640
8010251b:	e8 a0 23 00 00       	call   801048c0 <release>

  release(&idelock);
}
80102520:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102523:	5b                   	pop    %ebx
80102524:	5e                   	pop    %esi
80102525:	5f                   	pop    %edi
80102526:	5d                   	pop    %ebp
80102527:	c3                   	ret    
80102528:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010252f:	90                   	nop

80102530 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102530:	55                   	push   %ebp
80102531:	89 e5                	mov    %esp,%ebp
80102533:	53                   	push   %ebx
80102534:	83 ec 10             	sub    $0x10,%esp
80102537:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010253a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010253d:	50                   	push   %eax
8010253e:	e8 bd 21 00 00       	call   80104700 <holdingsleep>
80102543:	83 c4 10             	add    $0x10,%esp
80102546:	85 c0                	test   %eax,%eax
80102548:	0f 84 c3 00 00 00    	je     80102611 <iderw+0xe1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010254e:	8b 03                	mov    (%ebx),%eax
80102550:	83 e0 06             	and    $0x6,%eax
80102553:	83 f8 02             	cmp    $0x2,%eax
80102556:	0f 84 a8 00 00 00    	je     80102604 <iderw+0xd4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010255c:	8b 53 04             	mov    0x4(%ebx),%edx
8010255f:	85 d2                	test   %edx,%edx
80102561:	74 0d                	je     80102570 <iderw+0x40>
80102563:	a1 20 26 11 80       	mov    0x80112620,%eax
80102568:	85 c0                	test   %eax,%eax
8010256a:	0f 84 87 00 00 00    	je     801025f7 <iderw+0xc7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102570:	83 ec 0c             	sub    $0xc,%esp
80102573:	68 40 26 11 80       	push   $0x80112640
80102578:	e8 a3 23 00 00       	call   80104920 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010257d:	a1 24 26 11 80       	mov    0x80112624,%eax
  b->qnext = 0;
80102582:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102589:	83 c4 10             	add    $0x10,%esp
8010258c:	85 c0                	test   %eax,%eax
8010258e:	74 60                	je     801025f0 <iderw+0xc0>
80102590:	89 c2                	mov    %eax,%edx
80102592:	8b 40 58             	mov    0x58(%eax),%eax
80102595:	85 c0                	test   %eax,%eax
80102597:	75 f7                	jne    80102590 <iderw+0x60>
80102599:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
8010259c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010259e:	39 1d 24 26 11 80    	cmp    %ebx,0x80112624
801025a4:	74 3a                	je     801025e0 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801025a6:	8b 03                	mov    (%ebx),%eax
801025a8:	83 e0 06             	and    $0x6,%eax
801025ab:	83 f8 02             	cmp    $0x2,%eax
801025ae:	74 1b                	je     801025cb <iderw+0x9b>
    sleep(b, &idelock);
801025b0:	83 ec 08             	sub    $0x8,%esp
801025b3:	68 40 26 11 80       	push   $0x80112640
801025b8:	53                   	push   %ebx
801025b9:	e8 b2 1d 00 00       	call   80104370 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801025be:	8b 03                	mov    (%ebx),%eax
801025c0:	83 c4 10             	add    $0x10,%esp
801025c3:	83 e0 06             	and    $0x6,%eax
801025c6:	83 f8 02             	cmp    $0x2,%eax
801025c9:	75 e5                	jne    801025b0 <iderw+0x80>
  }


  release(&idelock);
801025cb:	c7 45 08 40 26 11 80 	movl   $0x80112640,0x8(%ebp)
}
801025d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025d5:	c9                   	leave  
  release(&idelock);
801025d6:	e9 e5 22 00 00       	jmp    801048c0 <release>
801025db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801025df:	90                   	nop
    idestart(b);
801025e0:	89 d8                	mov    %ebx,%eax
801025e2:	e8 49 fd ff ff       	call   80102330 <idestart>
801025e7:	eb bd                	jmp    801025a6 <iderw+0x76>
801025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801025f0:	ba 24 26 11 80       	mov    $0x80112624,%edx
801025f5:	eb a5                	jmp    8010259c <iderw+0x6c>
    panic("iderw: ide disk 1 not present");
801025f7:	83 ec 0c             	sub    $0xc,%esp
801025fa:	68 95 79 10 80       	push   $0x80107995
801025ff:	e8 ac de ff ff       	call   801004b0 <panic>
    panic("iderw: nothing to do");
80102604:	83 ec 0c             	sub    $0xc,%esp
80102607:	68 80 79 10 80       	push   $0x80107980
8010260c:	e8 9f de ff ff       	call   801004b0 <panic>
    panic("iderw: buf not locked");
80102611:	83 ec 0c             	sub    $0xc,%esp
80102614:	68 6a 79 10 80       	push   $0x8010796a
80102619:	e8 92 de ff ff       	call   801004b0 <panic>
8010261e:	66 90                	xchg   %ax,%ax

80102620 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
80102620:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102621:	c7 05 74 26 11 80 00 	movl   $0xfec00000,0x80112674
80102628:	00 c0 fe 
{
8010262b:	89 e5                	mov    %esp,%ebp
8010262d:	56                   	push   %esi
8010262e:	53                   	push   %ebx
  ioapic->reg = reg;
8010262f:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80102636:	00 00 00 
  return ioapic->data;
80102639:	8b 15 74 26 11 80    	mov    0x80112674,%edx
8010263f:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
80102642:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
80102648:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010264e:	0f b6 15 c0 27 11 80 	movzbl 0x801127c0,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102655:	c1 ee 10             	shr    $0x10,%esi
80102658:	89 f0                	mov    %esi,%eax
8010265a:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
8010265d:	8b 41 10             	mov    0x10(%ecx),%eax
  id = ioapicread(REG_ID) >> 24;
80102660:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102663:	39 c2                	cmp    %eax,%edx
80102665:	74 16                	je     8010267d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102667:	83 ec 0c             	sub    $0xc,%esp
8010266a:	68 b4 79 10 80       	push   $0x801079b4
8010266f:	e8 5c e1 ff ff       	call   801007d0 <cprintf>
  ioapic->reg = reg;
80102674:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
8010267a:	83 c4 10             	add    $0x10,%esp
8010267d:	83 c6 21             	add    $0x21,%esi
{
80102680:	ba 10 00 00 00       	mov    $0x10,%edx
80102685:	b8 20 00 00 00       	mov    $0x20,%eax
8010268a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  ioapic->reg = reg;
80102690:	89 11                	mov    %edx,(%ecx)

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102692:	89 c3                	mov    %eax,%ebx
  ioapic->data = data;
80102694:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
  for(i = 0; i <= maxintr; i++){
8010269a:	83 c0 01             	add    $0x1,%eax
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010269d:	81 cb 00 00 01 00    	or     $0x10000,%ebx
  ioapic->data = data;
801026a3:	89 59 10             	mov    %ebx,0x10(%ecx)
  ioapic->reg = reg;
801026a6:	8d 5a 01             	lea    0x1(%edx),%ebx
  for(i = 0; i <= maxintr; i++){
801026a9:	83 c2 02             	add    $0x2,%edx
  ioapic->reg = reg;
801026ac:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
801026ae:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
801026b4:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
801026bb:	39 f0                	cmp    %esi,%eax
801026bd:	75 d1                	jne    80102690 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801026bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
801026c2:	5b                   	pop    %ebx
801026c3:	5e                   	pop    %esi
801026c4:	5d                   	pop    %ebp
801026c5:	c3                   	ret    
801026c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801026cd:	8d 76 00             	lea    0x0(%esi),%esi

801026d0 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801026d0:	55                   	push   %ebp
  ioapic->reg = reg;
801026d1:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
{
801026d7:	89 e5                	mov    %esp,%ebp
801026d9:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801026dc:	8d 50 20             	lea    0x20(%eax),%edx
801026df:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801026e3:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801026e5:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801026eb:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
801026ee:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801026f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
801026f4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801026f6:	a1 74 26 11 80       	mov    0x80112674,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801026fb:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
801026fe:	89 50 10             	mov    %edx,0x10(%eax)
}
80102701:	5d                   	pop    %ebp
80102702:	c3                   	ret    
80102703:	66 90                	xchg   %ax,%ax
80102705:	66 90                	xchg   %ax,%ax
80102707:	66 90                	xchg   %ax,%ax
80102709:	66 90                	xchg   %ax,%ax
8010270b:	66 90                	xchg   %ax,%ax
8010270d:	66 90                	xchg   %ax,%ax
8010270f:	90                   	nop

80102710 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102710:	55                   	push   %ebp
80102711:	89 e5                	mov    %esp,%ebp
80102713:	53                   	push   %ebx
80102714:	83 ec 04             	sub    $0x4,%esp
80102717:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010271a:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102720:	0f 85 82 00 00 00    	jne    801027a8 <kfree+0x98>
80102726:	81 fb 10 66 11 80    	cmp    $0x80116610,%ebx
8010272c:	72 7a                	jb     801027a8 <kfree+0x98>
8010272e:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102734:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
80102739:	77 6d                	ja     801027a8 <kfree+0x98>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010273b:	83 ec 04             	sub    $0x4,%esp
8010273e:	68 00 10 00 00       	push   $0x1000
80102743:	6a 01                	push   $0x1
80102745:	53                   	push   %ebx
80102746:	e8 95 22 00 00       	call   801049e0 <memset>

  if(kmem.use_lock)
8010274b:	8b 15 b4 26 11 80    	mov    0x801126b4,%edx
80102751:	83 c4 10             	add    $0x10,%esp
80102754:	85 d2                	test   %edx,%edx
80102756:	75 28                	jne    80102780 <kfree+0x70>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102758:	a1 bc 26 11 80       	mov    0x801126bc,%eax
8010275d:	89 03                	mov    %eax,(%ebx)
  kmem.num_free_pages+=1;
  kmem.freelist = r;
  if(kmem.use_lock)
8010275f:	a1 b4 26 11 80       	mov    0x801126b4,%eax
  kmem.num_free_pages+=1;
80102764:	83 05 b8 26 11 80 01 	addl   $0x1,0x801126b8
  kmem.freelist = r;
8010276b:	89 1d bc 26 11 80    	mov    %ebx,0x801126bc
  if(kmem.use_lock)
80102771:	85 c0                	test   %eax,%eax
80102773:	75 23                	jne    80102798 <kfree+0x88>
    release(&kmem.lock);
}
80102775:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102778:	c9                   	leave  
80102779:	c3                   	ret    
8010277a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    acquire(&kmem.lock);
80102780:	83 ec 0c             	sub    $0xc,%esp
80102783:	68 80 26 11 80       	push   $0x80112680
80102788:	e8 93 21 00 00       	call   80104920 <acquire>
8010278d:	83 c4 10             	add    $0x10,%esp
80102790:	eb c6                	jmp    80102758 <kfree+0x48>
80102792:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
80102798:	c7 45 08 80 26 11 80 	movl   $0x80112680,0x8(%ebp)
}
8010279f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027a2:	c9                   	leave  
    release(&kmem.lock);
801027a3:	e9 18 21 00 00       	jmp    801048c0 <release>
    panic("kfree");
801027a8:	83 ec 0c             	sub    $0xc,%esp
801027ab:	68 e6 79 10 80       	push   $0x801079e6
801027b0:	e8 fb dc ff ff       	call   801004b0 <panic>
801027b5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801027bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801027c0 <freerange>:
{
801027c0:	55                   	push   %ebp
801027c1:	89 e5                	mov    %esp,%ebp
801027c3:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
801027c4:	8b 45 08             	mov    0x8(%ebp),%eax
{
801027c7:	8b 75 0c             	mov    0xc(%ebp),%esi
801027ca:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801027cb:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801027d1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027d7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801027dd:	39 de                	cmp    %ebx,%esi
801027df:	72 2a                	jb     8010280b <freerange+0x4b>
801027e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801027e8:	83 ec 0c             	sub    $0xc,%esp
801027eb:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027f1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801027f7:	50                   	push   %eax
801027f8:	e8 13 ff ff ff       	call   80102710 <kfree>
    kmem.num_free_pages+=1;
801027fd:	83 05 b8 26 11 80 01 	addl   $0x1,0x801126b8
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102804:	83 c4 10             	add    $0x10,%esp
80102807:	39 f3                	cmp    %esi,%ebx
80102809:	76 dd                	jbe    801027e8 <freerange+0x28>
}
8010280b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010280e:	5b                   	pop    %ebx
8010280f:	5e                   	pop    %esi
80102810:	5d                   	pop    %ebp
80102811:	c3                   	ret    
80102812:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102820 <kinit2>:
{
80102820:	55                   	push   %ebp
80102821:	89 e5                	mov    %esp,%ebp
80102823:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
80102824:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102827:	8b 75 0c             	mov    0xc(%ebp),%esi
8010282a:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010282b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102831:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102837:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010283d:	39 de                	cmp    %ebx,%esi
8010283f:	72 2a                	jb     8010286b <kinit2+0x4b>
80102841:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102848:	83 ec 0c             	sub    $0xc,%esp
8010284b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102851:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102857:	50                   	push   %eax
80102858:	e8 b3 fe ff ff       	call   80102710 <kfree>
    kmem.num_free_pages+=1;
8010285d:	83 05 b8 26 11 80 01 	addl   $0x1,0x801126b8
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102864:	83 c4 10             	add    $0x10,%esp
80102867:	39 de                	cmp    %ebx,%esi
80102869:	73 dd                	jae    80102848 <kinit2+0x28>
  kmem.use_lock = 1;
8010286b:	c7 05 b4 26 11 80 01 	movl   $0x1,0x801126b4
80102872:	00 00 00 
}
80102875:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102878:	5b                   	pop    %ebx
80102879:	5e                   	pop    %esi
8010287a:	5d                   	pop    %ebp
8010287b:	c3                   	ret    
8010287c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102880 <kinit1>:
{
80102880:	55                   	push   %ebp
80102881:	89 e5                	mov    %esp,%ebp
80102883:	56                   	push   %esi
80102884:	53                   	push   %ebx
80102885:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102888:	83 ec 08             	sub    $0x8,%esp
8010288b:	68 ec 79 10 80       	push   $0x801079ec
80102890:	68 80 26 11 80       	push   $0x80112680
80102895:	e8 b6 1e 00 00       	call   80104750 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010289a:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010289d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801028a0:	c7 05 b4 26 11 80 00 	movl   $0x0,0x801126b4
801028a7:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
801028aa:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801028b0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801028b6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801028bc:	39 de                	cmp    %ebx,%esi
801028be:	72 23                	jb     801028e3 <kinit1+0x63>
    kfree(p);
801028c0:	83 ec 0c             	sub    $0xc,%esp
801028c3:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801028c9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801028cf:	50                   	push   %eax
801028d0:	e8 3b fe ff ff       	call   80102710 <kfree>
    kmem.num_free_pages+=1;
801028d5:	83 05 b8 26 11 80 01 	addl   $0x1,0x801126b8
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801028dc:	83 c4 10             	add    $0x10,%esp
801028df:	39 de                	cmp    %ebx,%esi
801028e1:	73 dd                	jae    801028c0 <kinit1+0x40>
}
801028e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801028e6:	5b                   	pop    %ebx
801028e7:	5e                   	pop    %esi
801028e8:	5d                   	pop    %ebp
801028e9:	c3                   	ret    
801028ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801028f0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801028f0:	55                   	push   %ebp
801028f1:	89 e5                	mov    %esp,%ebp
801028f3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801028f6:	8b 0d b4 26 11 80    	mov    0x801126b4,%ecx
801028fc:	85 c9                	test   %ecx,%ecx
801028fe:	75 40                	jne    80102940 <kalloc+0x50>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102900:	a1 bc 26 11 80       	mov    0x801126bc,%eax
  if(r)
80102905:	85 c0                	test   %eax,%eax
80102907:	74 50                	je     80102959 <kalloc+0x69>
  {
    kmem.freelist = r->next;
80102909:	8b 10                	mov    (%eax),%edx
    kmem.num_free_pages-=1;
8010290b:	83 2d b8 26 11 80 01 	subl   $0x1,0x801126b8
    kmem.freelist = r->next;
80102912:	89 15 bc 26 11 80    	mov    %edx,0x801126bc
  }
  else{
    r = (struct run *)allocate_page();
  }
  if(kmem.use_lock)
80102918:	8b 15 b4 26 11 80    	mov    0x801126b4,%edx
8010291e:	85 d2                	test   %edx,%edx
80102920:	75 06                	jne    80102928 <kalloc+0x38>
    release(&kmem.lock);
  return (char*)r;
}
80102922:	c9                   	leave  
80102923:	c3                   	ret    
80102924:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    release(&kmem.lock);
80102928:	83 ec 0c             	sub    $0xc,%esp
8010292b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010292e:	68 80 26 11 80       	push   $0x80112680
80102933:	e8 88 1f 00 00       	call   801048c0 <release>
80102938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010293b:	83 c4 10             	add    $0x10,%esp
}
8010293e:	c9                   	leave  
8010293f:	c3                   	ret    
    acquire(&kmem.lock);
80102940:	83 ec 0c             	sub    $0xc,%esp
80102943:	68 80 26 11 80       	push   $0x80112680
80102948:	e8 d3 1f 00 00       	call   80104920 <acquire>
  r = kmem.freelist;
8010294d:	a1 bc 26 11 80       	mov    0x801126bc,%eax
    acquire(&kmem.lock);
80102952:	83 c4 10             	add    $0x10,%esp
  if(r)
80102955:	85 c0                	test   %eax,%eax
80102957:	75 b0                	jne    80102909 <kalloc+0x19>
    r = (struct run *)allocate_page();
80102959:	e8 a2 4c 00 00       	call   80107600 <allocate_page>
8010295e:	eb b8                	jmp    80102918 <kalloc+0x28>

80102960 <num_of_FreePages>:
uint 
num_of_FreePages(void)
{
80102960:	55                   	push   %ebp
80102961:	89 e5                	mov    %esp,%ebp
80102963:	53                   	push   %ebx
80102964:	83 ec 10             	sub    $0x10,%esp
  acquire(&kmem.lock);
80102967:	68 80 26 11 80       	push   $0x80112680
8010296c:	e8 af 1f 00 00       	call   80104920 <acquire>

  uint num_free_pages = kmem.num_free_pages;
80102971:	8b 1d b8 26 11 80    	mov    0x801126b8,%ebx
  
  release(&kmem.lock);
80102977:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
8010297e:	e8 3d 1f 00 00       	call   801048c0 <release>
  
  return num_free_pages;
}
80102983:	89 d8                	mov    %ebx,%eax
80102985:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102988:	c9                   	leave  
80102989:	c3                   	ret    
8010298a:	66 90                	xchg   %ax,%ax
8010298c:	66 90                	xchg   %ax,%ax
8010298e:	66 90                	xchg   %ax,%ax

80102990 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102990:	ba 64 00 00 00       	mov    $0x64,%edx
80102995:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102996:	a8 01                	test   $0x1,%al
80102998:	0f 84 c2 00 00 00    	je     80102a60 <kbdgetc+0xd0>
{
8010299e:	55                   	push   %ebp
8010299f:	ba 60 00 00 00       	mov    $0x60,%edx
801029a4:	89 e5                	mov    %esp,%ebp
801029a6:	53                   	push   %ebx
801029a7:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
801029a8:	8b 1d c0 26 11 80    	mov    0x801126c0,%ebx
  data = inb(KBDATAP);
801029ae:	0f b6 c8             	movzbl %al,%ecx
  if(data == 0xE0){
801029b1:	3c e0                	cmp    $0xe0,%al
801029b3:	74 5b                	je     80102a10 <kbdgetc+0x80>
    return 0;
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801029b5:	89 da                	mov    %ebx,%edx
801029b7:	83 e2 40             	and    $0x40,%edx
  } else if(data & 0x80){
801029ba:	84 c0                	test   %al,%al
801029bc:	78 62                	js     80102a20 <kbdgetc+0x90>
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801029be:	85 d2                	test   %edx,%edx
801029c0:	74 09                	je     801029cb <kbdgetc+0x3b>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801029c2:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
801029c5:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
801029c8:	0f b6 c8             	movzbl %al,%ecx
  }

  shift |= shiftcode[data];
801029cb:	0f b6 91 20 7b 10 80 	movzbl -0x7fef84e0(%ecx),%edx
  shift ^= togglecode[data];
801029d2:	0f b6 81 20 7a 10 80 	movzbl -0x7fef85e0(%ecx),%eax
  shift |= shiftcode[data];
801029d9:	09 da                	or     %ebx,%edx
  shift ^= togglecode[data];
801029db:	31 c2                	xor    %eax,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
801029dd:	89 d0                	mov    %edx,%eax
  shift ^= togglecode[data];
801029df:	89 15 c0 26 11 80    	mov    %edx,0x801126c0
  c = charcode[shift & (CTL | SHIFT)][data];
801029e5:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
801029e8:	83 e2 08             	and    $0x8,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
801029eb:	8b 04 85 00 7a 10 80 	mov    -0x7fef8600(,%eax,4),%eax
801029f2:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
801029f6:	74 0b                	je     80102a03 <kbdgetc+0x73>
    if('a' <= c && c <= 'z')
801029f8:	8d 50 9f             	lea    -0x61(%eax),%edx
801029fb:	83 fa 19             	cmp    $0x19,%edx
801029fe:	77 48                	ja     80102a48 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102a00:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102a03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a06:	c9                   	leave  
80102a07:	c3                   	ret    
80102a08:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a0f:	90                   	nop
    shift |= E0ESC;
80102a10:	83 cb 40             	or     $0x40,%ebx
    return 0;
80102a13:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
80102a15:	89 1d c0 26 11 80    	mov    %ebx,0x801126c0
}
80102a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a1e:	c9                   	leave  
80102a1f:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102a20:	83 e0 7f             	and    $0x7f,%eax
80102a23:	85 d2                	test   %edx,%edx
80102a25:	0f 44 c8             	cmove  %eax,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
80102a28:	0f b6 81 20 7b 10 80 	movzbl -0x7fef84e0(%ecx),%eax
80102a2f:	83 c8 40             	or     $0x40,%eax
80102a32:	0f b6 c0             	movzbl %al,%eax
80102a35:	f7 d0                	not    %eax
80102a37:	21 d8                	and    %ebx,%eax
}
80102a39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    shift &= ~(shiftcode[data] | E0ESC);
80102a3c:	a3 c0 26 11 80       	mov    %eax,0x801126c0
    return 0;
80102a41:	31 c0                	xor    %eax,%eax
}
80102a43:	c9                   	leave  
80102a44:	c3                   	ret    
80102a45:	8d 76 00             	lea    0x0(%esi),%esi
    else if('A' <= c && c <= 'Z')
80102a48:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
80102a4b:	8d 50 20             	lea    0x20(%eax),%edx
}
80102a4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a51:	c9                   	leave  
      c += 'a' - 'A';
80102a52:	83 f9 1a             	cmp    $0x1a,%ecx
80102a55:	0f 42 c2             	cmovb  %edx,%eax
}
80102a58:	c3                   	ret    
80102a59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80102a60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102a65:	c3                   	ret    
80102a66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a6d:	8d 76 00             	lea    0x0(%esi),%esi

80102a70 <kbdintr>:

void
kbdintr(void)
{
80102a70:	55                   	push   %ebp
80102a71:	89 e5                	mov    %esp,%ebp
80102a73:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102a76:	68 90 29 10 80       	push   $0x80102990
80102a7b:	e8 30 df ff ff       	call   801009b0 <consoleintr>
}
80102a80:	83 c4 10             	add    $0x10,%esp
80102a83:	c9                   	leave  
80102a84:	c3                   	ret    
80102a85:	66 90                	xchg   %ax,%ax
80102a87:	66 90                	xchg   %ax,%ax
80102a89:	66 90                	xchg   %ax,%ax
80102a8b:	66 90                	xchg   %ax,%ax
80102a8d:	66 90                	xchg   %ax,%ax
80102a8f:	90                   	nop

80102a90 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
80102a90:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102a95:	85 c0                	test   %eax,%eax
80102a97:	0f 84 cb 00 00 00    	je     80102b68 <lapicinit+0xd8>
  lapic[index] = value;
80102a9d:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102aa4:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102aa7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102aaa:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102ab1:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102ab4:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102ab7:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
80102abe:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102ac1:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102ac4:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
80102acb:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
80102ace:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102ad1:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
80102ad8:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102adb:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102ade:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102ae5:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102ae8:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102aeb:	8b 50 30             	mov    0x30(%eax),%edx
80102aee:	c1 ea 10             	shr    $0x10,%edx
80102af1:	81 e2 fc 00 00 00    	and    $0xfc,%edx
80102af7:	75 77                	jne    80102b70 <lapicinit+0xe0>
  lapic[index] = value;
80102af9:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102b00:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b03:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b06:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102b0d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b10:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b13:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102b1a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b1d:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b20:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102b27:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b2a:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b2d:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102b34:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b37:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b3a:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
80102b41:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
80102b44:	8b 50 20             	mov    0x20(%eax),%edx
80102b47:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102b4e:	66 90                	xchg   %ax,%ax
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102b50:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
80102b56:	80 e6 10             	and    $0x10,%dh
80102b59:	75 f5                	jne    80102b50 <lapicinit+0xc0>
  lapic[index] = value;
80102b5b:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102b62:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b65:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102b68:	c3                   	ret    
80102b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
80102b70:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102b77:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102b7a:	8b 50 20             	mov    0x20(%eax),%edx
}
80102b7d:	e9 77 ff ff ff       	jmp    80102af9 <lapicinit+0x69>
80102b82:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102b90 <lapicid>:

int
lapicid(void)
{
  if (!lapic)
80102b90:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102b95:	85 c0                	test   %eax,%eax
80102b97:	74 07                	je     80102ba0 <lapicid+0x10>
    return 0;
  return lapic[ID] >> 24;
80102b99:	8b 40 20             	mov    0x20(%eax),%eax
80102b9c:	c1 e8 18             	shr    $0x18,%eax
80102b9f:	c3                   	ret    
    return 0;
80102ba0:	31 c0                	xor    %eax,%eax
}
80102ba2:	c3                   	ret    
80102ba3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102baa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102bb0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102bb0:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102bb5:	85 c0                	test   %eax,%eax
80102bb7:	74 0d                	je     80102bc6 <lapiceoi+0x16>
  lapic[index] = value;
80102bb9:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102bc0:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102bc3:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102bc6:	c3                   	ret    
80102bc7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102bce:	66 90                	xchg   %ax,%ax

80102bd0 <microdelay>:
// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
}
80102bd0:	c3                   	ret    
80102bd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102bd8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102bdf:	90                   	nop

80102be0 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102be0:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102be1:	b8 0f 00 00 00       	mov    $0xf,%eax
80102be6:	ba 70 00 00 00       	mov    $0x70,%edx
80102beb:	89 e5                	mov    %esp,%ebp
80102bed:	53                   	push   %ebx
80102bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102bf1:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102bf4:	ee                   	out    %al,(%dx)
80102bf5:	b8 0a 00 00 00       	mov    $0xa,%eax
80102bfa:	ba 71 00 00 00       	mov    $0x71,%edx
80102bff:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102c00:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102c02:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102c05:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
80102c0b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
80102c0d:	c1 e9 0c             	shr    $0xc,%ecx
  lapicw(ICRHI, apicid<<24);
80102c10:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
80102c12:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
80102c15:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102c18:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
80102c1e:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102c23:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102c29:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102c2c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102c33:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102c36:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102c39:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102c40:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102c43:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102c46:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102c4c:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102c4f:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102c55:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102c58:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102c5e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102c61:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102c67:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
80102c6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102c6d:	c9                   	leave  
80102c6e:	c3                   	ret    
80102c6f:	90                   	nop

80102c70 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102c70:	55                   	push   %ebp
80102c71:	b8 0b 00 00 00       	mov    $0xb,%eax
80102c76:	ba 70 00 00 00       	mov    $0x70,%edx
80102c7b:	89 e5                	mov    %esp,%ebp
80102c7d:	57                   	push   %edi
80102c7e:	56                   	push   %esi
80102c7f:	53                   	push   %ebx
80102c80:	83 ec 4c             	sub    $0x4c,%esp
80102c83:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c84:	ba 71 00 00 00       	mov    $0x71,%edx
80102c89:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
80102c8a:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c8d:	bb 70 00 00 00       	mov    $0x70,%ebx
80102c92:	88 45 b3             	mov    %al,-0x4d(%ebp)
80102c95:	8d 76 00             	lea    0x0(%esi),%esi
80102c98:	31 c0                	xor    %eax,%eax
80102c9a:	89 da                	mov    %ebx,%edx
80102c9c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c9d:	b9 71 00 00 00       	mov    $0x71,%ecx
80102ca2:	89 ca                	mov    %ecx,%edx
80102ca4:	ec                   	in     (%dx),%al
80102ca5:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ca8:	89 da                	mov    %ebx,%edx
80102caa:	b8 02 00 00 00       	mov    $0x2,%eax
80102caf:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cb0:	89 ca                	mov    %ecx,%edx
80102cb2:	ec                   	in     (%dx),%al
80102cb3:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cb6:	89 da                	mov    %ebx,%edx
80102cb8:	b8 04 00 00 00       	mov    $0x4,%eax
80102cbd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cbe:	89 ca                	mov    %ecx,%edx
80102cc0:	ec                   	in     (%dx),%al
80102cc1:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cc4:	89 da                	mov    %ebx,%edx
80102cc6:	b8 07 00 00 00       	mov    $0x7,%eax
80102ccb:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ccc:	89 ca                	mov    %ecx,%edx
80102cce:	ec                   	in     (%dx),%al
80102ccf:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cd2:	89 da                	mov    %ebx,%edx
80102cd4:	b8 08 00 00 00       	mov    $0x8,%eax
80102cd9:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cda:	89 ca                	mov    %ecx,%edx
80102cdc:	ec                   	in     (%dx),%al
80102cdd:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cdf:	89 da                	mov    %ebx,%edx
80102ce1:	b8 09 00 00 00       	mov    $0x9,%eax
80102ce6:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ce7:	89 ca                	mov    %ecx,%edx
80102ce9:	ec                   	in     (%dx),%al
80102cea:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cec:	89 da                	mov    %ebx,%edx
80102cee:	b8 0a 00 00 00       	mov    $0xa,%eax
80102cf3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cf4:	89 ca                	mov    %ecx,%edx
80102cf6:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102cf7:	84 c0                	test   %al,%al
80102cf9:	78 9d                	js     80102c98 <cmostime+0x28>
  return inb(CMOS_RETURN);
80102cfb:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102cff:	89 fa                	mov    %edi,%edx
80102d01:	0f b6 fa             	movzbl %dl,%edi
80102d04:	89 f2                	mov    %esi,%edx
80102d06:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102d09:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102d0d:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d10:	89 da                	mov    %ebx,%edx
80102d12:	89 7d c8             	mov    %edi,-0x38(%ebp)
80102d15:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102d18:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102d1c:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102d1f:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102d22:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102d26:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102d29:	31 c0                	xor    %eax,%eax
80102d2b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d2c:	89 ca                	mov    %ecx,%edx
80102d2e:	ec                   	in     (%dx),%al
80102d2f:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d32:	89 da                	mov    %ebx,%edx
80102d34:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102d37:	b8 02 00 00 00       	mov    $0x2,%eax
80102d3c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d3d:	89 ca                	mov    %ecx,%edx
80102d3f:	ec                   	in     (%dx),%al
80102d40:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d43:	89 da                	mov    %ebx,%edx
80102d45:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102d48:	b8 04 00 00 00       	mov    $0x4,%eax
80102d4d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d4e:	89 ca                	mov    %ecx,%edx
80102d50:	ec                   	in     (%dx),%al
80102d51:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d54:	89 da                	mov    %ebx,%edx
80102d56:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102d59:	b8 07 00 00 00       	mov    $0x7,%eax
80102d5e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d5f:	89 ca                	mov    %ecx,%edx
80102d61:	ec                   	in     (%dx),%al
80102d62:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d65:	89 da                	mov    %ebx,%edx
80102d67:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102d6a:	b8 08 00 00 00       	mov    $0x8,%eax
80102d6f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d70:	89 ca                	mov    %ecx,%edx
80102d72:	ec                   	in     (%dx),%al
80102d73:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d76:	89 da                	mov    %ebx,%edx
80102d78:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102d7b:	b8 09 00 00 00       	mov    $0x9,%eax
80102d80:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d81:	89 ca                	mov    %ecx,%edx
80102d83:	ec                   	in     (%dx),%al
80102d84:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d87:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102d8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d8d:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102d90:	6a 18                	push   $0x18
80102d92:	50                   	push   %eax
80102d93:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102d96:	50                   	push   %eax
80102d97:	e8 94 1c 00 00       	call   80104a30 <memcmp>
80102d9c:	83 c4 10             	add    $0x10,%esp
80102d9f:	85 c0                	test   %eax,%eax
80102da1:	0f 85 f1 fe ff ff    	jne    80102c98 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102da7:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
80102dab:	75 78                	jne    80102e25 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102dad:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102db0:	89 c2                	mov    %eax,%edx
80102db2:	83 e0 0f             	and    $0xf,%eax
80102db5:	c1 ea 04             	shr    $0x4,%edx
80102db8:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102dbb:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102dbe:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102dc1:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102dc4:	89 c2                	mov    %eax,%edx
80102dc6:	83 e0 0f             	and    $0xf,%eax
80102dc9:	c1 ea 04             	shr    $0x4,%edx
80102dcc:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102dcf:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102dd2:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102dd5:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102dd8:	89 c2                	mov    %eax,%edx
80102dda:	83 e0 0f             	and    $0xf,%eax
80102ddd:	c1 ea 04             	shr    $0x4,%edx
80102de0:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102de3:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102de6:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102de9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102dec:	89 c2                	mov    %eax,%edx
80102dee:	83 e0 0f             	and    $0xf,%eax
80102df1:	c1 ea 04             	shr    $0x4,%edx
80102df4:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102df7:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102dfa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102dfd:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102e00:	89 c2                	mov    %eax,%edx
80102e02:	83 e0 0f             	and    $0xf,%eax
80102e05:	c1 ea 04             	shr    $0x4,%edx
80102e08:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e0b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102e0e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102e11:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102e14:	89 c2                	mov    %eax,%edx
80102e16:	83 e0 0f             	and    $0xf,%eax
80102e19:	c1 ea 04             	shr    $0x4,%edx
80102e1c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e1f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102e22:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102e25:	8b 75 08             	mov    0x8(%ebp),%esi
80102e28:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102e2b:	89 06                	mov    %eax,(%esi)
80102e2d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102e30:	89 46 04             	mov    %eax,0x4(%esi)
80102e33:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102e36:	89 46 08             	mov    %eax,0x8(%esi)
80102e39:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102e3c:	89 46 0c             	mov    %eax,0xc(%esi)
80102e3f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102e42:	89 46 10             	mov    %eax,0x10(%esi)
80102e45:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102e48:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102e4b:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102e52:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e55:	5b                   	pop    %ebx
80102e56:	5e                   	pop    %esi
80102e57:	5f                   	pop    %edi
80102e58:	5d                   	pop    %ebp
80102e59:	c3                   	ret    
80102e5a:	66 90                	xchg   %ax,%ax
80102e5c:	66 90                	xchg   %ax,%ax
80102e5e:	66 90                	xchg   %ax,%ax

80102e60 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e60:	8b 0d 28 27 11 80    	mov    0x80112728,%ecx
80102e66:	85 c9                	test   %ecx,%ecx
80102e68:	0f 8e 8a 00 00 00    	jle    80102ef8 <install_trans+0x98>
{
80102e6e:	55                   	push   %ebp
80102e6f:	89 e5                	mov    %esp,%ebp
80102e71:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102e72:	31 ff                	xor    %edi,%edi
{
80102e74:	56                   	push   %esi
80102e75:	53                   	push   %ebx
80102e76:	83 ec 0c             	sub    $0xc,%esp
80102e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e80:	a1 14 27 11 80       	mov    0x80112714,%eax
80102e85:	83 ec 08             	sub    $0x8,%esp
80102e88:	01 f8                	add    %edi,%eax
80102e8a:	83 c0 01             	add    $0x1,%eax
80102e8d:	50                   	push   %eax
80102e8e:	ff 35 24 27 11 80    	push   0x80112724
80102e94:	e8 f7 d2 ff ff       	call   80100190 <bread>
80102e99:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102e9b:	58                   	pop    %eax
80102e9c:	5a                   	pop    %edx
80102e9d:	ff 34 bd 2c 27 11 80 	push   -0x7feed8d4(,%edi,4)
80102ea4:	ff 35 24 27 11 80    	push   0x80112724
  for (tail = 0; tail < log.lh.n; tail++) {
80102eaa:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ead:	e8 de d2 ff ff       	call   80100190 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102eb2:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102eb5:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102eb7:	8d 46 5c             	lea    0x5c(%esi),%eax
80102eba:	68 00 02 00 00       	push   $0x200
80102ebf:	50                   	push   %eax
80102ec0:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102ec3:	50                   	push   %eax
80102ec4:	e8 b7 1b 00 00       	call   80104a80 <memmove>
    bwrite(dbuf);  // write dst to disk
80102ec9:	89 1c 24             	mov    %ebx,(%esp)
80102ecc:	e8 ff d2 ff ff       	call   801001d0 <bwrite>
    brelse(lbuf);
80102ed1:	89 34 24             	mov    %esi,(%esp)
80102ed4:	e8 37 d3 ff ff       	call   80100210 <brelse>
    brelse(dbuf);
80102ed9:	89 1c 24             	mov    %ebx,(%esp)
80102edc:	e8 2f d3 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102ee1:	83 c4 10             	add    $0x10,%esp
80102ee4:	39 3d 28 27 11 80    	cmp    %edi,0x80112728
80102eea:	7f 94                	jg     80102e80 <install_trans+0x20>
  }
}
80102eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102eef:	5b                   	pop    %ebx
80102ef0:	5e                   	pop    %esi
80102ef1:	5f                   	pop    %edi
80102ef2:	5d                   	pop    %ebp
80102ef3:	c3                   	ret    
80102ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102ef8:	c3                   	ret    
80102ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102f00 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f00:	55                   	push   %ebp
80102f01:	89 e5                	mov    %esp,%ebp
80102f03:	53                   	push   %ebx
80102f04:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f07:	ff 35 14 27 11 80    	push   0x80112714
80102f0d:	ff 35 24 27 11 80    	push   0x80112724
80102f13:	e8 78 d2 ff ff       	call   80100190 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102f18:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f1b:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102f1d:	a1 28 27 11 80       	mov    0x80112728,%eax
80102f22:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102f25:	85 c0                	test   %eax,%eax
80102f27:	7e 19                	jle    80102f42 <write_head+0x42>
80102f29:	31 d2                	xor    %edx,%edx
80102f2b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102f2f:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102f30:	8b 0c 95 2c 27 11 80 	mov    -0x7feed8d4(,%edx,4),%ecx
80102f37:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f3b:	83 c2 01             	add    $0x1,%edx
80102f3e:	39 d0                	cmp    %edx,%eax
80102f40:	75 ee                	jne    80102f30 <write_head+0x30>
  }
  bwrite(buf);
80102f42:	83 ec 0c             	sub    $0xc,%esp
80102f45:	53                   	push   %ebx
80102f46:	e8 85 d2 ff ff       	call   801001d0 <bwrite>
  brelse(buf);
80102f4b:	89 1c 24             	mov    %ebx,(%esp)
80102f4e:	e8 bd d2 ff ff       	call   80100210 <brelse>
}
80102f53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102f56:	83 c4 10             	add    $0x10,%esp
80102f59:	c9                   	leave  
80102f5a:	c3                   	ret    
80102f5b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102f5f:	90                   	nop

80102f60 <initlog>:
{
80102f60:	55                   	push   %ebp
80102f61:	89 e5                	mov    %esp,%ebp
80102f63:	53                   	push   %ebx
80102f64:	83 ec 3c             	sub    $0x3c,%esp
80102f67:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102f6a:	68 20 7c 10 80       	push   $0x80107c20
80102f6f:	68 e0 26 11 80       	push   $0x801126e0
80102f74:	e8 d7 17 00 00       	call   80104750 <initlock>
  readsb(dev, &sb);
80102f79:	58                   	pop    %eax
80102f7a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80102f7d:	5a                   	pop    %edx
80102f7e:	50                   	push   %eax
80102f7f:	53                   	push   %ebx
80102f80:	e8 cb e6 ff ff       	call   80101650 <readsb>
  log.start = sb.logstart;
80102f85:	8b 45 e8             	mov    -0x18(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102f88:	59                   	pop    %ecx
  log.dev = dev;
80102f89:	89 1d 24 27 11 80    	mov    %ebx,0x80112724
  log.size = sb.nlog;
80102f8f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  log.start = sb.logstart;
80102f92:	a3 14 27 11 80       	mov    %eax,0x80112714
  log.size = sb.nlog;
80102f97:	89 15 18 27 11 80    	mov    %edx,0x80112718
  struct buf *buf = bread(log.dev, log.start);
80102f9d:	5a                   	pop    %edx
80102f9e:	50                   	push   %eax
80102f9f:	53                   	push   %ebx
80102fa0:	e8 eb d1 ff ff       	call   80100190 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102fa5:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102fa8:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102fab:	89 1d 28 27 11 80    	mov    %ebx,0x80112728
  for (i = 0; i < log.lh.n; i++) {
80102fb1:	85 db                	test   %ebx,%ebx
80102fb3:	7e 1d                	jle    80102fd2 <initlog+0x72>
80102fb5:	31 d2                	xor    %edx,%edx
80102fb7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102fbe:	66 90                	xchg   %ax,%ax
    log.lh.block[i] = lh->block[i];
80102fc0:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102fc4:	89 0c 95 2c 27 11 80 	mov    %ecx,-0x7feed8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fcb:	83 c2 01             	add    $0x1,%edx
80102fce:	39 d3                	cmp    %edx,%ebx
80102fd0:	75 ee                	jne    80102fc0 <initlog+0x60>
  brelse(buf);
80102fd2:	83 ec 0c             	sub    $0xc,%esp
80102fd5:	50                   	push   %eax
80102fd6:	e8 35 d2 ff ff       	call   80100210 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102fdb:	e8 80 fe ff ff       	call   80102e60 <install_trans>
  log.lh.n = 0;
80102fe0:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
80102fe7:	00 00 00 
  write_head(); // clear the log
80102fea:	e8 11 ff ff ff       	call   80102f00 <write_head>
}
80102fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102ff2:	83 c4 10             	add    $0x10,%esp
80102ff5:	c9                   	leave  
80102ff6:	c3                   	ret    
80102ff7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102ffe:	66 90                	xchg   %ax,%ax

80103000 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80103000:	55                   	push   %ebp
80103001:	89 e5                	mov    %esp,%ebp
80103003:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80103006:	68 e0 26 11 80       	push   $0x801126e0
8010300b:	e8 10 19 00 00       	call   80104920 <acquire>
80103010:	83 c4 10             	add    $0x10,%esp
80103013:	eb 18                	jmp    8010302d <begin_op+0x2d>
80103015:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80103018:	83 ec 08             	sub    $0x8,%esp
8010301b:	68 e0 26 11 80       	push   $0x801126e0
80103020:	68 e0 26 11 80       	push   $0x801126e0
80103025:	e8 46 13 00 00       	call   80104370 <sleep>
8010302a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
8010302d:	a1 20 27 11 80       	mov    0x80112720,%eax
80103032:	85 c0                	test   %eax,%eax
80103034:	75 e2                	jne    80103018 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103036:	a1 1c 27 11 80       	mov    0x8011271c,%eax
8010303b:	8b 15 28 27 11 80    	mov    0x80112728,%edx
80103041:	83 c0 01             	add    $0x1,%eax
80103044:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80103047:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
8010304a:	83 fa 1e             	cmp    $0x1e,%edx
8010304d:	7f c9                	jg     80103018 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
8010304f:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80103052:	a3 1c 27 11 80       	mov    %eax,0x8011271c
      release(&log.lock);
80103057:	68 e0 26 11 80       	push   $0x801126e0
8010305c:	e8 5f 18 00 00       	call   801048c0 <release>
      break;
    }
  }
}
80103061:	83 c4 10             	add    $0x10,%esp
80103064:	c9                   	leave  
80103065:	c3                   	ret    
80103066:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010306d:	8d 76 00             	lea    0x0(%esi),%esi

80103070 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103070:	55                   	push   %ebp
80103071:	89 e5                	mov    %esp,%ebp
80103073:	57                   	push   %edi
80103074:	56                   	push   %esi
80103075:	53                   	push   %ebx
80103076:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80103079:	68 e0 26 11 80       	push   $0x801126e0
8010307e:	e8 9d 18 00 00       	call   80104920 <acquire>
  log.outstanding -= 1;
80103083:	a1 1c 27 11 80       	mov    0x8011271c,%eax
  if(log.committing)
80103088:	8b 35 20 27 11 80    	mov    0x80112720,%esi
8010308e:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103091:	8d 58 ff             	lea    -0x1(%eax),%ebx
80103094:	89 1d 1c 27 11 80    	mov    %ebx,0x8011271c
  if(log.committing)
8010309a:	85 f6                	test   %esi,%esi
8010309c:	0f 85 22 01 00 00    	jne    801031c4 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
801030a2:	85 db                	test   %ebx,%ebx
801030a4:	0f 85 f6 00 00 00    	jne    801031a0 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
801030aa:	c7 05 20 27 11 80 01 	movl   $0x1,0x80112720
801030b1:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
801030b4:	83 ec 0c             	sub    $0xc,%esp
801030b7:	68 e0 26 11 80       	push   $0x801126e0
801030bc:	e8 ff 17 00 00       	call   801048c0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
801030c1:	8b 0d 28 27 11 80    	mov    0x80112728,%ecx
801030c7:	83 c4 10             	add    $0x10,%esp
801030ca:	85 c9                	test   %ecx,%ecx
801030cc:	7f 42                	jg     80103110 <end_op+0xa0>
    acquire(&log.lock);
801030ce:	83 ec 0c             	sub    $0xc,%esp
801030d1:	68 e0 26 11 80       	push   $0x801126e0
801030d6:	e8 45 18 00 00       	call   80104920 <acquire>
    wakeup(&log);
801030db:	c7 04 24 e0 26 11 80 	movl   $0x801126e0,(%esp)
    log.committing = 0;
801030e2:	c7 05 20 27 11 80 00 	movl   $0x0,0x80112720
801030e9:	00 00 00 
    wakeup(&log);
801030ec:	e8 3f 13 00 00       	call   80104430 <wakeup>
    release(&log.lock);
801030f1:	c7 04 24 e0 26 11 80 	movl   $0x801126e0,(%esp)
801030f8:	e8 c3 17 00 00       	call   801048c0 <release>
801030fd:	83 c4 10             	add    $0x10,%esp
}
80103100:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103103:	5b                   	pop    %ebx
80103104:	5e                   	pop    %esi
80103105:	5f                   	pop    %edi
80103106:	5d                   	pop    %ebp
80103107:	c3                   	ret    
80103108:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010310f:	90                   	nop
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103110:	a1 14 27 11 80       	mov    0x80112714,%eax
80103115:	83 ec 08             	sub    $0x8,%esp
80103118:	01 d8                	add    %ebx,%eax
8010311a:	83 c0 01             	add    $0x1,%eax
8010311d:	50                   	push   %eax
8010311e:	ff 35 24 27 11 80    	push   0x80112724
80103124:	e8 67 d0 ff ff       	call   80100190 <bread>
80103129:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010312b:	58                   	pop    %eax
8010312c:	5a                   	pop    %edx
8010312d:	ff 34 9d 2c 27 11 80 	push   -0x7feed8d4(,%ebx,4)
80103134:	ff 35 24 27 11 80    	push   0x80112724
  for (tail = 0; tail < log.lh.n; tail++) {
8010313a:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010313d:	e8 4e d0 ff ff       	call   80100190 <bread>
    memmove(to->data, from->data, BSIZE);
80103142:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103145:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80103147:	8d 40 5c             	lea    0x5c(%eax),%eax
8010314a:	68 00 02 00 00       	push   $0x200
8010314f:	50                   	push   %eax
80103150:	8d 46 5c             	lea    0x5c(%esi),%eax
80103153:	50                   	push   %eax
80103154:	e8 27 19 00 00       	call   80104a80 <memmove>
    bwrite(to);  // write the log
80103159:	89 34 24             	mov    %esi,(%esp)
8010315c:	e8 6f d0 ff ff       	call   801001d0 <bwrite>
    brelse(from);
80103161:	89 3c 24             	mov    %edi,(%esp)
80103164:	e8 a7 d0 ff ff       	call   80100210 <brelse>
    brelse(to);
80103169:	89 34 24             	mov    %esi,(%esp)
8010316c:	e8 9f d0 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80103171:	83 c4 10             	add    $0x10,%esp
80103174:	3b 1d 28 27 11 80    	cmp    0x80112728,%ebx
8010317a:	7c 94                	jl     80103110 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
8010317c:	e8 7f fd ff ff       	call   80102f00 <write_head>
    install_trans(); // Now install writes to home locations
80103181:	e8 da fc ff ff       	call   80102e60 <install_trans>
    log.lh.n = 0;
80103186:	c7 05 28 27 11 80 00 	movl   $0x0,0x80112728
8010318d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103190:	e8 6b fd ff ff       	call   80102f00 <write_head>
80103195:	e9 34 ff ff ff       	jmp    801030ce <end_op+0x5e>
8010319a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
801031a0:	83 ec 0c             	sub    $0xc,%esp
801031a3:	68 e0 26 11 80       	push   $0x801126e0
801031a8:	e8 83 12 00 00       	call   80104430 <wakeup>
  release(&log.lock);
801031ad:	c7 04 24 e0 26 11 80 	movl   $0x801126e0,(%esp)
801031b4:	e8 07 17 00 00       	call   801048c0 <release>
801031b9:	83 c4 10             	add    $0x10,%esp
}
801031bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801031bf:	5b                   	pop    %ebx
801031c0:	5e                   	pop    %esi
801031c1:	5f                   	pop    %edi
801031c2:	5d                   	pop    %ebp
801031c3:	c3                   	ret    
    panic("log.committing");
801031c4:	83 ec 0c             	sub    $0xc,%esp
801031c7:	68 24 7c 10 80       	push   $0x80107c24
801031cc:	e8 df d2 ff ff       	call   801004b0 <panic>
801031d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801031d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801031df:	90                   	nop

801031e0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801031e0:	55                   	push   %ebp
801031e1:	89 e5                	mov    %esp,%ebp
801031e3:	53                   	push   %ebx
801031e4:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801031e7:	8b 15 28 27 11 80    	mov    0x80112728,%edx
{
801031ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801031f0:	83 fa 1d             	cmp    $0x1d,%edx
801031f3:	0f 8f 85 00 00 00    	jg     8010327e <log_write+0x9e>
801031f9:	a1 18 27 11 80       	mov    0x80112718,%eax
801031fe:	83 e8 01             	sub    $0x1,%eax
80103201:	39 c2                	cmp    %eax,%edx
80103203:	7d 79                	jge    8010327e <log_write+0x9e>
    panic("too big a transaction");
  if (log.outstanding < 1)
80103205:	a1 1c 27 11 80       	mov    0x8011271c,%eax
8010320a:	85 c0                	test   %eax,%eax
8010320c:	7e 7d                	jle    8010328b <log_write+0xab>
    panic("log_write outside of trans");

  acquire(&log.lock);
8010320e:	83 ec 0c             	sub    $0xc,%esp
80103211:	68 e0 26 11 80       	push   $0x801126e0
80103216:	e8 05 17 00 00       	call   80104920 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010321b:	8b 15 28 27 11 80    	mov    0x80112728,%edx
80103221:	83 c4 10             	add    $0x10,%esp
80103224:	85 d2                	test   %edx,%edx
80103226:	7e 4a                	jle    80103272 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103228:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
8010322b:	31 c0                	xor    %eax,%eax
8010322d:	eb 08                	jmp    80103237 <log_write+0x57>
8010322f:	90                   	nop
80103230:	83 c0 01             	add    $0x1,%eax
80103233:	39 c2                	cmp    %eax,%edx
80103235:	74 29                	je     80103260 <log_write+0x80>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103237:	39 0c 85 2c 27 11 80 	cmp    %ecx,-0x7feed8d4(,%eax,4)
8010323e:	75 f0                	jne    80103230 <log_write+0x50>
      break;
  }
  log.lh.block[i] = b->blockno;
80103240:	89 0c 85 2c 27 11 80 	mov    %ecx,-0x7feed8d4(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80103247:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
8010324a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
8010324d:	c7 45 08 e0 26 11 80 	movl   $0x801126e0,0x8(%ebp)
}
80103254:	c9                   	leave  
  release(&log.lock);
80103255:	e9 66 16 00 00       	jmp    801048c0 <release>
8010325a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
80103260:	89 0c 95 2c 27 11 80 	mov    %ecx,-0x7feed8d4(,%edx,4)
    log.lh.n++;
80103267:	83 c2 01             	add    $0x1,%edx
8010326a:	89 15 28 27 11 80    	mov    %edx,0x80112728
80103270:	eb d5                	jmp    80103247 <log_write+0x67>
  log.lh.block[i] = b->blockno;
80103272:	8b 43 08             	mov    0x8(%ebx),%eax
80103275:	a3 2c 27 11 80       	mov    %eax,0x8011272c
  if (i == log.lh.n)
8010327a:	75 cb                	jne    80103247 <log_write+0x67>
8010327c:	eb e9                	jmp    80103267 <log_write+0x87>
    panic("too big a transaction");
8010327e:	83 ec 0c             	sub    $0xc,%esp
80103281:	68 33 7c 10 80       	push   $0x80107c33
80103286:	e8 25 d2 ff ff       	call   801004b0 <panic>
    panic("log_write outside of trans");
8010328b:	83 ec 0c             	sub    $0xc,%esp
8010328e:	68 49 7c 10 80       	push   $0x80107c49
80103293:	e8 18 d2 ff ff       	call   801004b0 <panic>
80103298:	66 90                	xchg   %ax,%ax
8010329a:	66 90                	xchg   %ax,%ax
8010329c:	66 90                	xchg   %ax,%ax
8010329e:	66 90                	xchg   %ax,%ax

801032a0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801032a0:	55                   	push   %ebp
801032a1:	89 e5                	mov    %esp,%ebp
801032a3:	53                   	push   %ebx
801032a4:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801032a7:	e8 64 09 00 00       	call   80103c10 <cpuid>
801032ac:	89 c3                	mov    %eax,%ebx
801032ae:	e8 5d 09 00 00       	call   80103c10 <cpuid>
801032b3:	83 ec 04             	sub    $0x4,%esp
801032b6:	53                   	push   %ebx
801032b7:	50                   	push   %eax
801032b8:	68 64 7c 10 80       	push   $0x80107c64
801032bd:	e8 0e d5 ff ff       	call   801007d0 <cprintf>
  idtinit();       // load idt register
801032c2:	e8 b9 29 00 00       	call   80105c80 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801032c7:	e8 e4 08 00 00       	call   80103bb0 <mycpu>
801032cc:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801032ce:	b8 01 00 00 00       	mov    $0x1,%eax
801032d3:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
801032da:	e8 81 0c 00 00       	call   80103f60 <scheduler>
801032df:	90                   	nop

801032e0 <mpenter>:
{
801032e0:	55                   	push   %ebp
801032e1:	89 e5                	mov    %esp,%ebp
801032e3:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801032e6:	e8 a5 3a 00 00       	call   80106d90 <switchkvm>
  seginit();
801032eb:	e8 10 3a 00 00       	call   80106d00 <seginit>
  lapicinit();
801032f0:	e8 9b f7 ff ff       	call   80102a90 <lapicinit>
  mpmain();
801032f5:	e8 a6 ff ff ff       	call   801032a0 <mpmain>
801032fa:	66 90                	xchg   %ax,%ax
801032fc:	66 90                	xchg   %ax,%ax
801032fe:	66 90                	xchg   %ax,%ax

80103300 <main>:
{
80103300:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103304:	83 e4 f0             	and    $0xfffffff0,%esp
80103307:	ff 71 fc             	push   -0x4(%ecx)
8010330a:	55                   	push   %ebp
8010330b:	89 e5                	mov    %esp,%ebp
8010330d:	53                   	push   %ebx
8010330e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010330f:	83 ec 08             	sub    $0x8,%esp
80103312:	68 00 00 40 80       	push   $0x80400000
80103317:	68 10 66 11 80       	push   $0x80116610
8010331c:	e8 5f f5 ff ff       	call   80102880 <kinit1>
  kvmalloc();      // kernel page table
80103321:	e8 5a 3f 00 00       	call   80107280 <kvmalloc>
  mpinit();        // detect other processors
80103326:	e8 a5 01 00 00       	call   801034d0 <mpinit>
  lapicinit();     // interrupt controller
8010332b:	e8 60 f7 ff ff       	call   80102a90 <lapicinit>
  seginit();       // segment descriptors
80103330:	e8 cb 39 00 00       	call   80106d00 <seginit>
  picinit();       // disable pic
80103335:	e8 96 03 00 00       	call   801036d0 <picinit>
  ioapicinit();    // another interrupt controller
8010333a:	e8 e1 f2 ff ff       	call   80102620 <ioapicinit>
  consoleinit();   // console hardware
8010333f:	e8 4c d8 ff ff       	call   80100b90 <consoleinit>
  uartinit();      // serial port
80103344:	e8 47 2c 00 00       	call   80105f90 <uartinit>
  pinit();         // process table
80103349:	e8 42 08 00 00       	call   80103b90 <pinit>
  tvinit();        // trap vectors
8010334e:	e8 ad 28 00 00       	call   80105c00 <tvinit>
  binit();         // buffer cache
80103353:	e8 a8 cd ff ff       	call   80100100 <binit>
  fileinit();      // file table
80103358:	e8 e3 db ff ff       	call   80100f40 <fileinit>
  ideinit();       // disk 
8010335d:	e8 ae f0 ff ff       	call   80102410 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103362:	83 c4 0c             	add    $0xc,%esp
80103365:	68 8a 00 00 00       	push   $0x8a
8010336a:	68 8c b4 10 80       	push   $0x8010b48c
8010336f:	68 00 70 00 80       	push   $0x80007000
80103374:	e8 07 17 00 00       	call   80104a80 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103379:	83 c4 10             	add    $0x10,%esp
8010337c:	69 05 c4 27 11 80 b0 	imul   $0xb0,0x801127c4,%eax
80103383:	00 00 00 
80103386:	05 e0 27 11 80       	add    $0x801127e0,%eax
8010338b:	3d e0 27 11 80       	cmp    $0x801127e0,%eax
80103390:	76 7e                	jbe    80103410 <main+0x110>
80103392:	bb e0 27 11 80       	mov    $0x801127e0,%ebx
80103397:	eb 20                	jmp    801033b9 <main+0xb9>
80103399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801033a0:	69 05 c4 27 11 80 b0 	imul   $0xb0,0x801127c4,%eax
801033a7:	00 00 00 
801033aa:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801033b0:	05 e0 27 11 80       	add    $0x801127e0,%eax
801033b5:	39 c3                	cmp    %eax,%ebx
801033b7:	73 57                	jae    80103410 <main+0x110>
    if(c == mycpu())  // We've started already.
801033b9:	e8 f2 07 00 00       	call   80103bb0 <mycpu>
801033be:	39 c3                	cmp    %eax,%ebx
801033c0:	74 de                	je     801033a0 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801033c2:	e8 29 f5 ff ff       	call   801028f0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
801033c7:	83 ec 08             	sub    $0x8,%esp
    *(void(**)(void))(code-8) = mpenter;
801033ca:	c7 05 f8 6f 00 80 e0 	movl   $0x801032e0,0x80006ff8
801033d1:	32 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801033d4:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
801033db:	a0 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
801033de:	05 00 10 00 00       	add    $0x1000,%eax
801033e3:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
801033e8:	0f b6 03             	movzbl (%ebx),%eax
801033eb:	68 00 70 00 00       	push   $0x7000
801033f0:	50                   	push   %eax
801033f1:	e8 ea f7 ff ff       	call   80102be0 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801033f6:	83 c4 10             	add    $0x10,%esp
801033f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103400:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103406:	85 c0                	test   %eax,%eax
80103408:	74 f6                	je     80103400 <main+0x100>
8010340a:	eb 94                	jmp    801033a0 <main+0xa0>
8010340c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103410:	83 ec 08             	sub    $0x8,%esp
80103413:	68 00 00 40 80       	push   $0x80400000
80103418:	68 00 00 40 80       	push   $0x80400000
8010341d:	e8 fe f3 ff ff       	call   80102820 <kinit2>
  cprintf("1\n");
80103422:	c7 04 24 78 7c 10 80 	movl   $0x80107c78,(%esp)
80103429:	e8 a2 d3 ff ff       	call   801007d0 <cprintf>
  userinit();      // first user process
8010342e:	e8 2d 08 00 00       	call   80103c60 <userinit>
  cprintf("3\n");
80103433:	c7 04 24 7b 7c 10 80 	movl   $0x80107c7b,(%esp)
8010343a:	e8 91 d3 ff ff       	call   801007d0 <cprintf>
  mpmain();        // finish this processor's setup
8010343f:	e8 5c fe ff ff       	call   801032a0 <mpmain>
80103444:	66 90                	xchg   %ax,%ax
80103446:	66 90                	xchg   %ax,%ax
80103448:	66 90                	xchg   %ax,%ax
8010344a:	66 90                	xchg   %ax,%ax
8010344c:	66 90                	xchg   %ax,%ax
8010344e:	66 90                	xchg   %ax,%ax

80103450 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103450:	55                   	push   %ebp
80103451:	89 e5                	mov    %esp,%ebp
80103453:	57                   	push   %edi
80103454:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80103455:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
8010345b:	53                   	push   %ebx
  e = addr+len;
8010345c:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
8010345f:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
80103462:	39 de                	cmp    %ebx,%esi
80103464:	72 10                	jb     80103476 <mpsearch1+0x26>
80103466:	eb 50                	jmp    801034b8 <mpsearch1+0x68>
80103468:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010346f:	90                   	nop
80103470:	89 fe                	mov    %edi,%esi
80103472:	39 fb                	cmp    %edi,%ebx
80103474:	76 42                	jbe    801034b8 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103476:	83 ec 04             	sub    $0x4,%esp
80103479:	8d 7e 10             	lea    0x10(%esi),%edi
8010347c:	6a 04                	push   $0x4
8010347e:	68 7e 7c 10 80       	push   $0x80107c7e
80103483:	56                   	push   %esi
80103484:	e8 a7 15 00 00       	call   80104a30 <memcmp>
80103489:	83 c4 10             	add    $0x10,%esp
8010348c:	85 c0                	test   %eax,%eax
8010348e:	75 e0                	jne    80103470 <mpsearch1+0x20>
80103490:	89 f2                	mov    %esi,%edx
80103492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
80103498:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
8010349b:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
8010349e:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801034a0:	39 fa                	cmp    %edi,%edx
801034a2:	75 f4                	jne    80103498 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801034a4:	84 c0                	test   %al,%al
801034a6:	75 c8                	jne    80103470 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801034a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801034ab:	89 f0                	mov    %esi,%eax
801034ad:	5b                   	pop    %ebx
801034ae:	5e                   	pop    %esi
801034af:	5f                   	pop    %edi
801034b0:	5d                   	pop    %ebp
801034b1:	c3                   	ret    
801034b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801034b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801034bb:	31 f6                	xor    %esi,%esi
}
801034bd:	5b                   	pop    %ebx
801034be:	89 f0                	mov    %esi,%eax
801034c0:	5e                   	pop    %esi
801034c1:	5f                   	pop    %edi
801034c2:	5d                   	pop    %ebp
801034c3:	c3                   	ret    
801034c4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801034cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801034cf:	90                   	nop

801034d0 <mpinit>:
  return conf;
}

void
mpinit(void)
{
801034d0:	55                   	push   %ebp
801034d1:	89 e5                	mov    %esp,%ebp
801034d3:	57                   	push   %edi
801034d4:	56                   	push   %esi
801034d5:	53                   	push   %ebx
801034d6:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801034d9:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
801034e0:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
801034e7:	c1 e0 08             	shl    $0x8,%eax
801034ea:	09 d0                	or     %edx,%eax
801034ec:	c1 e0 04             	shl    $0x4,%eax
801034ef:	75 1b                	jne    8010350c <mpinit+0x3c>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801034f1:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
801034f8:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
801034ff:	c1 e0 08             	shl    $0x8,%eax
80103502:	09 d0                	or     %edx,%eax
80103504:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103507:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010350c:	ba 00 04 00 00       	mov    $0x400,%edx
80103511:	e8 3a ff ff ff       	call   80103450 <mpsearch1>
80103516:	89 c3                	mov    %eax,%ebx
80103518:	85 c0                	test   %eax,%eax
8010351a:	0f 84 40 01 00 00    	je     80103660 <mpinit+0x190>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103520:	8b 73 04             	mov    0x4(%ebx),%esi
80103523:	85 f6                	test   %esi,%esi
80103525:	0f 84 25 01 00 00    	je     80103650 <mpinit+0x180>
  if(memcmp(conf, "PCMP", 4) != 0)
8010352b:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010352e:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
  if(memcmp(conf, "PCMP", 4) != 0)
80103534:	6a 04                	push   $0x4
80103536:	68 83 7c 10 80       	push   $0x80107c83
8010353b:	50                   	push   %eax
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010353c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010353f:	e8 ec 14 00 00       	call   80104a30 <memcmp>
80103544:	83 c4 10             	add    $0x10,%esp
80103547:	85 c0                	test   %eax,%eax
80103549:	0f 85 01 01 00 00    	jne    80103650 <mpinit+0x180>
  if(conf->version != 1 && conf->version != 4)
8010354f:	0f b6 86 06 00 00 80 	movzbl -0x7ffffffa(%esi),%eax
80103556:	3c 01                	cmp    $0x1,%al
80103558:	74 08                	je     80103562 <mpinit+0x92>
8010355a:	3c 04                	cmp    $0x4,%al
8010355c:	0f 85 ee 00 00 00    	jne    80103650 <mpinit+0x180>
  if(sum((uchar*)conf, conf->length) != 0)
80103562:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
  for(i=0; i<len; i++)
80103569:	66 85 d2             	test   %dx,%dx
8010356c:	74 22                	je     80103590 <mpinit+0xc0>
8010356e:	8d 3c 32             	lea    (%edx,%esi,1),%edi
80103571:	89 f0                	mov    %esi,%eax
  sum = 0;
80103573:	31 d2                	xor    %edx,%edx
80103575:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
80103578:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
  for(i=0; i<len; i++)
8010357f:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
80103582:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
80103584:	39 c7                	cmp    %eax,%edi
80103586:	75 f0                	jne    80103578 <mpinit+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
80103588:	84 d2                	test   %dl,%dl
8010358a:	0f 85 c0 00 00 00    	jne    80103650 <mpinit+0x180>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80103590:	8b 86 24 00 00 80    	mov    -0x7fffffdc(%esi),%eax
80103596:	a3 c4 26 11 80       	mov    %eax,0x801126c4
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010359b:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
801035a2:	8d 86 2c 00 00 80    	lea    -0x7fffffd4(%esi),%eax
  ismp = 1;
801035a8:	be 01 00 00 00       	mov    $0x1,%esi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801035ad:	03 55 e4             	add    -0x1c(%ebp),%edx
801035b0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801035b3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801035b7:	90                   	nop
801035b8:	39 d0                	cmp    %edx,%eax
801035ba:	73 15                	jae    801035d1 <mpinit+0x101>
    switch(*p){
801035bc:	0f b6 08             	movzbl (%eax),%ecx
801035bf:	80 f9 02             	cmp    $0x2,%cl
801035c2:	74 4c                	je     80103610 <mpinit+0x140>
801035c4:	77 3a                	ja     80103600 <mpinit+0x130>
801035c6:	84 c9                	test   %cl,%cl
801035c8:	74 56                	je     80103620 <mpinit+0x150>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801035ca:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801035cd:	39 d0                	cmp    %edx,%eax
801035cf:	72 eb                	jb     801035bc <mpinit+0xec>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
801035d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801035d4:	85 f6                	test   %esi,%esi
801035d6:	0f 84 d9 00 00 00    	je     801036b5 <mpinit+0x1e5>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
801035dc:	80 7b 0c 00          	cmpb   $0x0,0xc(%ebx)
801035e0:	74 15                	je     801035f7 <mpinit+0x127>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801035e2:	b8 70 00 00 00       	mov    $0x70,%eax
801035e7:	ba 22 00 00 00       	mov    $0x22,%edx
801035ec:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801035ed:	ba 23 00 00 00       	mov    $0x23,%edx
801035f2:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801035f3:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801035f6:	ee                   	out    %al,(%dx)
  }
}
801035f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801035fa:	5b                   	pop    %ebx
801035fb:	5e                   	pop    %esi
801035fc:	5f                   	pop    %edi
801035fd:	5d                   	pop    %ebp
801035fe:	c3                   	ret    
801035ff:	90                   	nop
    switch(*p){
80103600:	83 e9 03             	sub    $0x3,%ecx
80103603:	80 f9 01             	cmp    $0x1,%cl
80103606:	76 c2                	jbe    801035ca <mpinit+0xfa>
80103608:	31 f6                	xor    %esi,%esi
8010360a:	eb ac                	jmp    801035b8 <mpinit+0xe8>
8010360c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103610:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
80103614:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
80103617:	88 0d c0 27 11 80    	mov    %cl,0x801127c0
      continue;
8010361d:	eb 99                	jmp    801035b8 <mpinit+0xe8>
8010361f:	90                   	nop
      if(ncpu < NCPU) {
80103620:	8b 0d c4 27 11 80    	mov    0x801127c4,%ecx
80103626:	83 f9 07             	cmp    $0x7,%ecx
80103629:	7f 19                	jg     80103644 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010362b:	69 f9 b0 00 00 00    	imul   $0xb0,%ecx,%edi
80103631:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
80103635:	83 c1 01             	add    $0x1,%ecx
80103638:	89 0d c4 27 11 80    	mov    %ecx,0x801127c4
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010363e:	88 9f e0 27 11 80    	mov    %bl,-0x7feed820(%edi)
      p += sizeof(struct mpproc);
80103644:	83 c0 14             	add    $0x14,%eax
      continue;
80103647:	e9 6c ff ff ff       	jmp    801035b8 <mpinit+0xe8>
8010364c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    panic("Expect to run on an SMP");
80103650:	83 ec 0c             	sub    $0xc,%esp
80103653:	68 88 7c 10 80       	push   $0x80107c88
80103658:	e8 53 ce ff ff       	call   801004b0 <panic>
8010365d:	8d 76 00             	lea    0x0(%esi),%esi
{
80103660:	bb 00 00 0f 80       	mov    $0x800f0000,%ebx
80103665:	eb 13                	jmp    8010367a <mpinit+0x1aa>
80103667:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010366e:	66 90                	xchg   %ax,%ax
  for(p = addr; p < e; p += sizeof(struct mp))
80103670:	89 f3                	mov    %esi,%ebx
80103672:	81 fe 00 00 10 80    	cmp    $0x80100000,%esi
80103678:	74 d6                	je     80103650 <mpinit+0x180>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010367a:	83 ec 04             	sub    $0x4,%esp
8010367d:	8d 73 10             	lea    0x10(%ebx),%esi
80103680:	6a 04                	push   $0x4
80103682:	68 7e 7c 10 80       	push   $0x80107c7e
80103687:	53                   	push   %ebx
80103688:	e8 a3 13 00 00       	call   80104a30 <memcmp>
8010368d:	83 c4 10             	add    $0x10,%esp
80103690:	85 c0                	test   %eax,%eax
80103692:	75 dc                	jne    80103670 <mpinit+0x1a0>
80103694:	89 da                	mov    %ebx,%edx
80103696:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010369d:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
801036a0:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
801036a3:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
801036a6:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801036a8:	39 d6                	cmp    %edx,%esi
801036aa:	75 f4                	jne    801036a0 <mpinit+0x1d0>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801036ac:	84 c0                	test   %al,%al
801036ae:	75 c0                	jne    80103670 <mpinit+0x1a0>
801036b0:	e9 6b fe ff ff       	jmp    80103520 <mpinit+0x50>
    panic("Didn't find a suitable machine");
801036b5:	83 ec 0c             	sub    $0xc,%esp
801036b8:	68 a0 7c 10 80       	push   $0x80107ca0
801036bd:	e8 ee cd ff ff       	call   801004b0 <panic>
801036c2:	66 90                	xchg   %ax,%ax
801036c4:	66 90                	xchg   %ax,%ax
801036c6:	66 90                	xchg   %ax,%ax
801036c8:	66 90                	xchg   %ax,%ax
801036ca:	66 90                	xchg   %ax,%ax
801036cc:	66 90                	xchg   %ax,%ax
801036ce:	66 90                	xchg   %ax,%ax

801036d0 <picinit>:
801036d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801036d5:	ba 21 00 00 00       	mov    $0x21,%edx
801036da:	ee                   	out    %al,(%dx)
801036db:	ba a1 00 00 00       	mov    $0xa1,%edx
801036e0:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
801036e1:	c3                   	ret    
801036e2:	66 90                	xchg   %ax,%ax
801036e4:	66 90                	xchg   %ax,%ax
801036e6:	66 90                	xchg   %ax,%ax
801036e8:	66 90                	xchg   %ax,%ax
801036ea:	66 90                	xchg   %ax,%ax
801036ec:	66 90                	xchg   %ax,%ax
801036ee:	66 90                	xchg   %ax,%ax

801036f0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	57                   	push   %edi
801036f4:	56                   	push   %esi
801036f5:	53                   	push   %ebx
801036f6:	83 ec 0c             	sub    $0xc,%esp
801036f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801036fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
801036ff:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103705:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010370b:	e8 50 d8 ff ff       	call   80100f60 <filealloc>
80103710:	89 03                	mov    %eax,(%ebx)
80103712:	85 c0                	test   %eax,%eax
80103714:	0f 84 a8 00 00 00    	je     801037c2 <pipealloc+0xd2>
8010371a:	e8 41 d8 ff ff       	call   80100f60 <filealloc>
8010371f:	89 06                	mov    %eax,(%esi)
80103721:	85 c0                	test   %eax,%eax
80103723:	0f 84 87 00 00 00    	je     801037b0 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103729:	e8 c2 f1 ff ff       	call   801028f0 <kalloc>
8010372e:	89 c7                	mov    %eax,%edi
80103730:	85 c0                	test   %eax,%eax
80103732:	0f 84 b0 00 00 00    	je     801037e8 <pipealloc+0xf8>
    goto bad;
  p->readopen = 1;
80103738:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010373f:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
80103742:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
80103745:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010374c:	00 00 00 
  p->nwrite = 0;
8010374f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103756:	00 00 00 
  p->nread = 0;
80103759:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103760:	00 00 00 
  initlock(&p->lock, "pipe");
80103763:	68 bf 7c 10 80       	push   $0x80107cbf
80103768:	50                   	push   %eax
80103769:	e8 e2 0f 00 00       	call   80104750 <initlock>
  (*f0)->type = FD_PIPE;
8010376e:	8b 03                	mov    (%ebx),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
80103770:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103773:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103779:	8b 03                	mov    (%ebx),%eax
8010377b:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010377f:	8b 03                	mov    (%ebx),%eax
80103781:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103785:	8b 03                	mov    (%ebx),%eax
80103787:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010378a:	8b 06                	mov    (%esi),%eax
8010378c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103792:	8b 06                	mov    (%esi),%eax
80103794:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103798:	8b 06                	mov    (%esi),%eax
8010379a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010379e:	8b 06                	mov    (%esi),%eax
801037a0:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
801037a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801037a6:	31 c0                	xor    %eax,%eax
}
801037a8:	5b                   	pop    %ebx
801037a9:	5e                   	pop    %esi
801037aa:	5f                   	pop    %edi
801037ab:	5d                   	pop    %ebp
801037ac:	c3                   	ret    
801037ad:	8d 76 00             	lea    0x0(%esi),%esi
  if(*f0)
801037b0:	8b 03                	mov    (%ebx),%eax
801037b2:	85 c0                	test   %eax,%eax
801037b4:	74 1e                	je     801037d4 <pipealloc+0xe4>
    fileclose(*f0);
801037b6:	83 ec 0c             	sub    $0xc,%esp
801037b9:	50                   	push   %eax
801037ba:	e8 61 d8 ff ff       	call   80101020 <fileclose>
801037bf:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801037c2:	8b 06                	mov    (%esi),%eax
801037c4:	85 c0                	test   %eax,%eax
801037c6:	74 0c                	je     801037d4 <pipealloc+0xe4>
    fileclose(*f1);
801037c8:	83 ec 0c             	sub    $0xc,%esp
801037cb:	50                   	push   %eax
801037cc:	e8 4f d8 ff ff       	call   80101020 <fileclose>
801037d1:	83 c4 10             	add    $0x10,%esp
}
801037d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
801037d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801037dc:	5b                   	pop    %ebx
801037dd:	5e                   	pop    %esi
801037de:	5f                   	pop    %edi
801037df:	5d                   	pop    %ebp
801037e0:	c3                   	ret    
801037e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
801037e8:	8b 03                	mov    (%ebx),%eax
801037ea:	85 c0                	test   %eax,%eax
801037ec:	75 c8                	jne    801037b6 <pipealloc+0xc6>
801037ee:	eb d2                	jmp    801037c2 <pipealloc+0xd2>

801037f0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801037f0:	55                   	push   %ebp
801037f1:	89 e5                	mov    %esp,%ebp
801037f3:	56                   	push   %esi
801037f4:	53                   	push   %ebx
801037f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
801037f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
801037fb:	83 ec 0c             	sub    $0xc,%esp
801037fe:	53                   	push   %ebx
801037ff:	e8 1c 11 00 00       	call   80104920 <acquire>
  if(writable){
80103804:	83 c4 10             	add    $0x10,%esp
80103807:	85 f6                	test   %esi,%esi
80103809:	74 65                	je     80103870 <pipeclose+0x80>
    p->writeopen = 0;
    wakeup(&p->nread);
8010380b:	83 ec 0c             	sub    $0xc,%esp
8010380e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
80103814:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010381b:	00 00 00 
    wakeup(&p->nread);
8010381e:	50                   	push   %eax
8010381f:	e8 0c 0c 00 00       	call   80104430 <wakeup>
80103824:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103827:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010382d:	85 d2                	test   %edx,%edx
8010382f:	75 0a                	jne    8010383b <pipeclose+0x4b>
80103831:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103837:	85 c0                	test   %eax,%eax
80103839:	74 15                	je     80103850 <pipeclose+0x60>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010383b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010383e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103841:	5b                   	pop    %ebx
80103842:	5e                   	pop    %esi
80103843:	5d                   	pop    %ebp
    release(&p->lock);
80103844:	e9 77 10 00 00       	jmp    801048c0 <release>
80103849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    release(&p->lock);
80103850:	83 ec 0c             	sub    $0xc,%esp
80103853:	53                   	push   %ebx
80103854:	e8 67 10 00 00       	call   801048c0 <release>
    kfree((char*)p);
80103859:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010385c:	83 c4 10             	add    $0x10,%esp
}
8010385f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103862:	5b                   	pop    %ebx
80103863:	5e                   	pop    %esi
80103864:	5d                   	pop    %ebp
    kfree((char*)p);
80103865:	e9 a6 ee ff ff       	jmp    80102710 <kfree>
8010386a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&p->nwrite);
80103870:	83 ec 0c             	sub    $0xc,%esp
80103873:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
80103879:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103880:	00 00 00 
    wakeup(&p->nwrite);
80103883:	50                   	push   %eax
80103884:	e8 a7 0b 00 00       	call   80104430 <wakeup>
80103889:	83 c4 10             	add    $0x10,%esp
8010388c:	eb 99                	jmp    80103827 <pipeclose+0x37>
8010388e:	66 90                	xchg   %ax,%ax

80103890 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103890:	55                   	push   %ebp
80103891:	89 e5                	mov    %esp,%ebp
80103893:	57                   	push   %edi
80103894:	56                   	push   %esi
80103895:	53                   	push   %ebx
80103896:	83 ec 28             	sub    $0x28,%esp
80103899:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010389c:	53                   	push   %ebx
8010389d:	e8 7e 10 00 00       	call   80104920 <acquire>
  for(i = 0; i < n; i++){
801038a2:	8b 45 10             	mov    0x10(%ebp),%eax
801038a5:	83 c4 10             	add    $0x10,%esp
801038a8:	85 c0                	test   %eax,%eax
801038aa:	0f 8e c0 00 00 00    	jle    80103970 <pipewrite+0xe0>
801038b0:	8b 45 0c             	mov    0xc(%ebp),%eax
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801038b3:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801038b9:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
801038bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801038c2:	03 45 10             	add    0x10(%ebp),%eax
801038c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801038c8:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801038ce:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801038d4:	89 ca                	mov    %ecx,%edx
801038d6:	05 00 02 00 00       	add    $0x200,%eax
801038db:	39 c1                	cmp    %eax,%ecx
801038dd:	74 3f                	je     8010391e <pipewrite+0x8e>
801038df:	eb 67                	jmp    80103948 <pipewrite+0xb8>
801038e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->readopen == 0 || myproc()->killed){
801038e8:	e8 43 03 00 00       	call   80103c30 <myproc>
801038ed:	8b 48 28             	mov    0x28(%eax),%ecx
801038f0:	85 c9                	test   %ecx,%ecx
801038f2:	75 34                	jne    80103928 <pipewrite+0x98>
      wakeup(&p->nread);
801038f4:	83 ec 0c             	sub    $0xc,%esp
801038f7:	57                   	push   %edi
801038f8:	e8 33 0b 00 00       	call   80104430 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801038fd:	58                   	pop    %eax
801038fe:	5a                   	pop    %edx
801038ff:	53                   	push   %ebx
80103900:	56                   	push   %esi
80103901:	e8 6a 0a 00 00       	call   80104370 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103906:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010390c:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103912:	83 c4 10             	add    $0x10,%esp
80103915:	05 00 02 00 00       	add    $0x200,%eax
8010391a:	39 c2                	cmp    %eax,%edx
8010391c:	75 2a                	jne    80103948 <pipewrite+0xb8>
      if(p->readopen == 0 || myproc()->killed){
8010391e:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103924:	85 c0                	test   %eax,%eax
80103926:	75 c0                	jne    801038e8 <pipewrite+0x58>
        release(&p->lock);
80103928:	83 ec 0c             	sub    $0xc,%esp
8010392b:	53                   	push   %ebx
8010392c:	e8 8f 0f 00 00       	call   801048c0 <release>
        return -1;
80103931:	83 c4 10             	add    $0x10,%esp
80103934:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103939:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010393c:	5b                   	pop    %ebx
8010393d:	5e                   	pop    %esi
8010393e:	5f                   	pop    %edi
8010393f:	5d                   	pop    %ebp
80103940:	c3                   	ret    
80103941:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103948:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010394b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010394e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103954:	89 8b 38 02 00 00    	mov    %ecx,0x238(%ebx)
8010395a:	0f b6 06             	movzbl (%esi),%eax
  for(i = 0; i < n; i++){
8010395d:	83 c6 01             	add    $0x1,%esi
80103960:	89 75 e4             	mov    %esi,-0x1c(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103963:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103967:	3b 75 e0             	cmp    -0x20(%ebp),%esi
8010396a:	0f 85 58 ff ff ff    	jne    801038c8 <pipewrite+0x38>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103970:	83 ec 0c             	sub    $0xc,%esp
80103973:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103979:	50                   	push   %eax
8010397a:	e8 b1 0a 00 00       	call   80104430 <wakeup>
  release(&p->lock);
8010397f:	89 1c 24             	mov    %ebx,(%esp)
80103982:	e8 39 0f 00 00       	call   801048c0 <release>
  return n;
80103987:	8b 45 10             	mov    0x10(%ebp),%eax
8010398a:	83 c4 10             	add    $0x10,%esp
8010398d:	eb aa                	jmp    80103939 <pipewrite+0xa9>
8010398f:	90                   	nop

80103990 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103990:	55                   	push   %ebp
80103991:	89 e5                	mov    %esp,%ebp
80103993:	57                   	push   %edi
80103994:	56                   	push   %esi
80103995:	53                   	push   %ebx
80103996:	83 ec 18             	sub    $0x18,%esp
80103999:	8b 75 08             	mov    0x8(%ebp),%esi
8010399c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
8010399f:	56                   	push   %esi
801039a0:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
801039a6:	e8 75 0f 00 00       	call   80104920 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039ab:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
801039b1:	83 c4 10             	add    $0x10,%esp
801039b4:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
801039ba:	74 2f                	je     801039eb <piperead+0x5b>
801039bc:	eb 37                	jmp    801039f5 <piperead+0x65>
801039be:	66 90                	xchg   %ax,%ax
    if(myproc()->killed){
801039c0:	e8 6b 02 00 00       	call   80103c30 <myproc>
801039c5:	8b 48 28             	mov    0x28(%eax),%ecx
801039c8:	85 c9                	test   %ecx,%ecx
801039ca:	0f 85 80 00 00 00    	jne    80103a50 <piperead+0xc0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801039d0:	83 ec 08             	sub    $0x8,%esp
801039d3:	56                   	push   %esi
801039d4:	53                   	push   %ebx
801039d5:	e8 96 09 00 00       	call   80104370 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039da:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
801039e0:	83 c4 10             	add    $0x10,%esp
801039e3:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
801039e9:	75 0a                	jne    801039f5 <piperead+0x65>
801039eb:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
801039f1:	85 c0                	test   %eax,%eax
801039f3:	75 cb                	jne    801039c0 <piperead+0x30>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801039f5:	8b 55 10             	mov    0x10(%ebp),%edx
801039f8:	31 db                	xor    %ebx,%ebx
801039fa:	85 d2                	test   %edx,%edx
801039fc:	7f 20                	jg     80103a1e <piperead+0x8e>
801039fe:	eb 2c                	jmp    80103a2c <piperead+0x9c>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103a00:	8d 48 01             	lea    0x1(%eax),%ecx
80103a03:	25 ff 01 00 00       	and    $0x1ff,%eax
80103a08:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
80103a0e:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
80103a13:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a16:	83 c3 01             	add    $0x1,%ebx
80103a19:	39 5d 10             	cmp    %ebx,0x10(%ebp)
80103a1c:	74 0e                	je     80103a2c <piperead+0x9c>
    if(p->nread == p->nwrite)
80103a1e:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103a24:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
80103a2a:	75 d4                	jne    80103a00 <piperead+0x70>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103a2c:	83 ec 0c             	sub    $0xc,%esp
80103a2f:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103a35:	50                   	push   %eax
80103a36:	e8 f5 09 00 00       	call   80104430 <wakeup>
  release(&p->lock);
80103a3b:	89 34 24             	mov    %esi,(%esp)
80103a3e:	e8 7d 0e 00 00       	call   801048c0 <release>
  return i;
80103a43:	83 c4 10             	add    $0x10,%esp
}
80103a46:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103a49:	89 d8                	mov    %ebx,%eax
80103a4b:	5b                   	pop    %ebx
80103a4c:	5e                   	pop    %esi
80103a4d:	5f                   	pop    %edi
80103a4e:	5d                   	pop    %ebp
80103a4f:	c3                   	ret    
      release(&p->lock);
80103a50:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80103a53:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
80103a58:	56                   	push   %esi
80103a59:	e8 62 0e 00 00       	call   801048c0 <release>
      return -1;
80103a5e:	83 c4 10             	add    $0x10,%esp
}
80103a61:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103a64:	89 d8                	mov    %ebx,%eax
80103a66:	5b                   	pop    %ebx
80103a67:	5e                   	pop    %esi
80103a68:	5f                   	pop    %edi
80103a69:	5d                   	pop    %ebp
80103a6a:	c3                   	ret    
80103a6b:	66 90                	xchg   %ax,%ax
80103a6d:	66 90                	xchg   %ax,%ax
80103a6f:	90                   	nop

80103a70 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a70:	55                   	push   %ebp
80103a71:	89 e5                	mov    %esp,%ebp
80103a73:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a74:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
{
80103a79:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103a7c:	68 60 2d 11 80       	push   $0x80112d60
80103a81:	e8 9a 0e 00 00       	call   80104920 <acquire>
80103a86:	83 c4 10             	add    $0x10,%esp
80103a89:	eb 10                	jmp    80103a9b <allocproc+0x2b>
80103a8b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103a8f:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a90:	83 eb 80             	sub    $0xffffff80,%ebx
80103a93:	81 fb 94 4d 11 80    	cmp    $0x80114d94,%ebx
80103a99:	74 75                	je     80103b10 <allocproc+0xa0>
    if(p->state == UNUSED)
80103a9b:	8b 43 10             	mov    0x10(%ebx),%eax
80103a9e:	85 c0                	test   %eax,%eax
80103aa0:	75 ee                	jne    80103a90 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103aa2:	a1 04 b0 10 80       	mov    0x8010b004,%eax

  release(&ptable.lock);
80103aa7:	83 ec 0c             	sub    $0xc,%esp
  p->state = EMBRYO;
80103aaa:	c7 43 10 01 00 00 00 	movl   $0x1,0x10(%ebx)
  p->pid = nextpid++;
80103ab1:	89 43 14             	mov    %eax,0x14(%ebx)
80103ab4:	8d 50 01             	lea    0x1(%eax),%edx
  release(&ptable.lock);
80103ab7:	68 60 2d 11 80       	push   $0x80112d60
  p->pid = nextpid++;
80103abc:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
  release(&ptable.lock);
80103ac2:	e8 f9 0d 00 00       	call   801048c0 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ac7:	e8 24 ee ff ff       	call   801028f0 <kalloc>
80103acc:	83 c4 10             	add    $0x10,%esp
80103acf:	89 43 0c             	mov    %eax,0xc(%ebx)
80103ad2:	85 c0                	test   %eax,%eax
80103ad4:	74 53                	je     80103b29 <allocproc+0xb9>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103ad6:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
80103adc:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
80103adf:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
80103ae4:	89 53 1c             	mov    %edx,0x1c(%ebx)
  *(uint*)sp = (uint)trapret;
80103ae7:	c7 40 14 f2 5b 10 80 	movl   $0x80105bf2,0x14(%eax)
  p->context = (struct context*)sp;
80103aee:	89 43 20             	mov    %eax,0x20(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103af1:	6a 14                	push   $0x14
80103af3:	6a 00                	push   $0x0
80103af5:	50                   	push   %eax
80103af6:	e8 e5 0e 00 00       	call   801049e0 <memset>
  p->context->eip = (uint)forkret;
80103afb:	8b 43 20             	mov    0x20(%ebx),%eax

  return p;
80103afe:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b01:	c7 40 10 40 3b 10 80 	movl   $0x80103b40,0x10(%eax)
}
80103b08:	89 d8                	mov    %ebx,%eax
80103b0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b0d:	c9                   	leave  
80103b0e:	c3                   	ret    
80103b0f:	90                   	nop
  release(&ptable.lock);
80103b10:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80103b13:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
80103b15:	68 60 2d 11 80       	push   $0x80112d60
80103b1a:	e8 a1 0d 00 00       	call   801048c0 <release>
}
80103b1f:	89 d8                	mov    %ebx,%eax
  return 0;
80103b21:	83 c4 10             	add    $0x10,%esp
}
80103b24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b27:	c9                   	leave  
80103b28:	c3                   	ret    
    p->state = UNUSED;
80103b29:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return 0;
80103b30:	31 db                	xor    %ebx,%ebx
}
80103b32:	89 d8                	mov    %ebx,%eax
80103b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b37:	c9                   	leave  
80103b38:	c3                   	ret    
80103b39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103b40 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80103b40:	55                   	push   %ebp
80103b41:	89 e5                	mov    %esp,%ebp
80103b43:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80103b46:	68 60 2d 11 80       	push   $0x80112d60
80103b4b:	e8 70 0d 00 00       	call   801048c0 <release>

  if (first) {
80103b50:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80103b55:	83 c4 10             	add    $0x10,%esp
80103b58:	85 c0                	test   %eax,%eax
80103b5a:	75 04                	jne    80103b60 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
80103b5c:	c9                   	leave  
80103b5d:	c3                   	ret    
80103b5e:	66 90                	xchg   %ax,%ax
    first = 0;
80103b60:	c7 05 00 b0 10 80 00 	movl   $0x0,0x8010b000
80103b67:	00 00 00 
    iinit(ROOTDEV);
80103b6a:	83 ec 0c             	sub    $0xc,%esp
80103b6d:	6a 01                	push   $0x1
80103b6f:	e8 ec db ff ff       	call   80101760 <iinit>
    initlog(ROOTDEV);
80103b74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103b7b:	e8 e0 f3 ff ff       	call   80102f60 <initlog>
}
80103b80:	83 c4 10             	add    $0x10,%esp
80103b83:	c9                   	leave  
80103b84:	c3                   	ret    
80103b85:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103b90 <pinit>:
{
80103b90:	55                   	push   %ebp
80103b91:	89 e5                	mov    %esp,%ebp
80103b93:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103b96:	68 c4 7c 10 80       	push   $0x80107cc4
80103b9b:	68 60 2d 11 80       	push   $0x80112d60
80103ba0:	e8 ab 0b 00 00       	call   80104750 <initlock>
}
80103ba5:	83 c4 10             	add    $0x10,%esp
80103ba8:	c9                   	leave  
80103ba9:	c3                   	ret    
80103baa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103bb0 <mycpu>:
{
80103bb0:	55                   	push   %ebp
80103bb1:	89 e5                	mov    %esp,%ebp
80103bb3:	56                   	push   %esi
80103bb4:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103bb5:	9c                   	pushf  
80103bb6:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103bb7:	f6 c4 02             	test   $0x2,%ah
80103bba:	75 46                	jne    80103c02 <mycpu+0x52>
  apicid = lapicid();
80103bbc:	e8 cf ef ff ff       	call   80102b90 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103bc1:	8b 35 c4 27 11 80    	mov    0x801127c4,%esi
80103bc7:	85 f6                	test   %esi,%esi
80103bc9:	7e 2a                	jle    80103bf5 <mycpu+0x45>
80103bcb:	31 d2                	xor    %edx,%edx
80103bcd:	eb 08                	jmp    80103bd7 <mycpu+0x27>
80103bcf:	90                   	nop
80103bd0:	83 c2 01             	add    $0x1,%edx
80103bd3:	39 f2                	cmp    %esi,%edx
80103bd5:	74 1e                	je     80103bf5 <mycpu+0x45>
    if (cpus[i].apicid == apicid)
80103bd7:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103bdd:	0f b6 99 e0 27 11 80 	movzbl -0x7feed820(%ecx),%ebx
80103be4:	39 c3                	cmp    %eax,%ebx
80103be6:	75 e8                	jne    80103bd0 <mycpu+0x20>
}
80103be8:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
80103beb:	8d 81 e0 27 11 80    	lea    -0x7feed820(%ecx),%eax
}
80103bf1:	5b                   	pop    %ebx
80103bf2:	5e                   	pop    %esi
80103bf3:	5d                   	pop    %ebp
80103bf4:	c3                   	ret    
  panic("unknown apicid\n");
80103bf5:	83 ec 0c             	sub    $0xc,%esp
80103bf8:	68 cb 7c 10 80       	push   $0x80107ccb
80103bfd:	e8 ae c8 ff ff       	call   801004b0 <panic>
    panic("mycpu called with interrupts enabled\n");
80103c02:	83 ec 0c             	sub    $0xc,%esp
80103c05:	68 b4 7d 10 80       	push   $0x80107db4
80103c0a:	e8 a1 c8 ff ff       	call   801004b0 <panic>
80103c0f:	90                   	nop

80103c10 <cpuid>:
cpuid() {
80103c10:	55                   	push   %ebp
80103c11:	89 e5                	mov    %esp,%ebp
80103c13:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103c16:	e8 95 ff ff ff       	call   80103bb0 <mycpu>
}
80103c1b:	c9                   	leave  
  return mycpu()-cpus;
80103c1c:	2d e0 27 11 80       	sub    $0x801127e0,%eax
80103c21:	c1 f8 04             	sar    $0x4,%eax
80103c24:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103c2a:	c3                   	ret    
80103c2b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103c2f:	90                   	nop

80103c30 <myproc>:
myproc(void) {
80103c30:	55                   	push   %ebp
80103c31:	89 e5                	mov    %esp,%ebp
80103c33:	53                   	push   %ebx
80103c34:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103c37:	e8 94 0b 00 00       	call   801047d0 <pushcli>
  c = mycpu();
80103c3c:	e8 6f ff ff ff       	call   80103bb0 <mycpu>
  p = c->proc;
80103c41:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103c47:	e8 d4 0b 00 00       	call   80104820 <popcli>
}
80103c4c:	89 d8                	mov    %ebx,%eax
80103c4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c51:	c9                   	leave  
80103c52:	c3                   	ret    
80103c53:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103c5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103c60 <userinit>:
{
80103c60:	55                   	push   %ebp
80103c61:	89 e5                	mov    %esp,%ebp
80103c63:	53                   	push   %ebx
80103c64:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103c67:	e8 04 fe ff ff       	call   80103a70 <allocproc>
80103c6c:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103c6e:	a3 94 4d 11 80       	mov    %eax,0x80114d94
  if((p->pgdir = setupkvm()) == 0)
80103c73:	e8 88 35 00 00       	call   80107200 <setupkvm>
80103c78:	89 43 08             	mov    %eax,0x8(%ebx)
80103c7b:	85 c0                	test   %eax,%eax
80103c7d:	0f 84 bd 00 00 00    	je     80103d40 <userinit+0xe0>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103c83:	83 ec 04             	sub    $0x4,%esp
80103c86:	68 2c 00 00 00       	push   $0x2c
80103c8b:	68 60 b4 10 80       	push   $0x8010b460
80103c90:	50                   	push   %eax
80103c91:	e8 1a 32 00 00       	call   80106eb0 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103c96:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103c99:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103c9f:	6a 4c                	push   $0x4c
80103ca1:	6a 00                	push   $0x0
80103ca3:	ff 73 1c             	push   0x1c(%ebx)
80103ca6:	e8 35 0d 00 00       	call   801049e0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103cab:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103cae:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103cb3:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103cb6:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103cbb:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103cbf:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103cc2:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103cc6:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103cc9:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103ccd:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103cd1:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103cd4:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103cd8:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103cdc:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103cdf:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103ce6:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103ce9:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103cf0:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103cf3:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103cfa:	8d 43 70             	lea    0x70(%ebx),%eax
80103cfd:	6a 10                	push   $0x10
80103cff:	68 f4 7c 10 80       	push   $0x80107cf4
80103d04:	50                   	push   %eax
80103d05:	e8 96 0e 00 00       	call   80104ba0 <safestrcpy>
  p->cwd = namei("/");
80103d0a:	c7 04 24 fd 7c 10 80 	movl   $0x80107cfd,(%esp)
80103d11:	e8 da e5 ff ff       	call   801022f0 <namei>
80103d16:	89 43 6c             	mov    %eax,0x6c(%ebx)
  acquire(&ptable.lock);
80103d19:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80103d20:	e8 fb 0b 00 00       	call   80104920 <acquire>
  p->state = RUNNABLE;
80103d25:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  release(&ptable.lock);
80103d2c:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80103d33:	e8 88 0b 00 00       	call   801048c0 <release>
}
80103d38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d3b:	83 c4 10             	add    $0x10,%esp
80103d3e:	c9                   	leave  
80103d3f:	c3                   	ret    
    panic("userinit: out of memory?");
80103d40:	83 ec 0c             	sub    $0xc,%esp
80103d43:	68 db 7c 10 80       	push   $0x80107cdb
80103d48:	e8 63 c7 ff ff       	call   801004b0 <panic>
80103d4d:	8d 76 00             	lea    0x0(%esi),%esi

80103d50 <growproc>:
{
80103d50:	55                   	push   %ebp
80103d51:	89 e5                	mov    %esp,%ebp
80103d53:	56                   	push   %esi
80103d54:	53                   	push   %ebx
80103d55:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103d58:	e8 73 0a 00 00       	call   801047d0 <pushcli>
  c = mycpu();
80103d5d:	e8 4e fe ff ff       	call   80103bb0 <mycpu>
  p = c->proc;
80103d62:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103d68:	e8 b3 0a 00 00       	call   80104820 <popcli>
  sz = curproc->sz;
80103d6d:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103d6f:	85 f6                	test   %esi,%esi
80103d71:	7f 1d                	jg     80103d90 <growproc+0x40>
  } else if(n < 0){
80103d73:	75 3b                	jne    80103db0 <growproc+0x60>
  switchuvm(curproc);
80103d75:	83 ec 0c             	sub    $0xc,%esp
  curproc->sz = sz;
80103d78:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103d7a:	53                   	push   %ebx
80103d7b:	e8 20 30 00 00       	call   80106da0 <switchuvm>
  return 0;
80103d80:	83 c4 10             	add    $0x10,%esp
80103d83:	31 c0                	xor    %eax,%eax
}
80103d85:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103d88:	5b                   	pop    %ebx
80103d89:	5e                   	pop    %esi
80103d8a:	5d                   	pop    %ebp
80103d8b:	c3                   	ret    
80103d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103d90:	83 ec 04             	sub    $0x4,%esp
80103d93:	01 c6                	add    %eax,%esi
80103d95:	56                   	push   %esi
80103d96:	50                   	push   %eax
80103d97:	ff 73 08             	push   0x8(%ebx)
80103d9a:	e8 81 32 00 00       	call   80107020 <allocuvm>
80103d9f:	83 c4 10             	add    $0x10,%esp
80103da2:	85 c0                	test   %eax,%eax
80103da4:	75 cf                	jne    80103d75 <growproc+0x25>
      return -1;
80103da6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dab:	eb d8                	jmp    80103d85 <growproc+0x35>
80103dad:	8d 76 00             	lea    0x0(%esi),%esi
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103db0:	83 ec 04             	sub    $0x4,%esp
80103db3:	01 c6                	add    %eax,%esi
80103db5:	56                   	push   %esi
80103db6:	50                   	push   %eax
80103db7:	ff 73 08             	push   0x8(%ebx)
80103dba:	e8 91 33 00 00       	call   80107150 <deallocuvm>
80103dbf:	83 c4 10             	add    $0x10,%esp
80103dc2:	85 c0                	test   %eax,%eax
80103dc4:	75 af                	jne    80103d75 <growproc+0x25>
80103dc6:	eb de                	jmp    80103da6 <growproc+0x56>
80103dc8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103dcf:	90                   	nop

80103dd0 <fork>:
{
80103dd0:	55                   	push   %ebp
80103dd1:	89 e5                	mov    %esp,%ebp
80103dd3:	57                   	push   %edi
80103dd4:	56                   	push   %esi
80103dd5:	53                   	push   %ebx
80103dd6:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103dd9:	e8 f2 09 00 00       	call   801047d0 <pushcli>
  c = mycpu();
80103dde:	e8 cd fd ff ff       	call   80103bb0 <mycpu>
  p = c->proc;
80103de3:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103de9:	e8 32 0a 00 00       	call   80104820 <popcli>
  if((np = allocproc()) == 0){
80103dee:	e8 7d fc ff ff       	call   80103a70 <allocproc>
80103df3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103df6:	85 c0                	test   %eax,%eax
80103df8:	0f 84 b7 00 00 00    	je     80103eb5 <fork+0xe5>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103dfe:	83 ec 08             	sub    $0x8,%esp
80103e01:	ff 33                	push   (%ebx)
80103e03:	89 c7                	mov    %eax,%edi
80103e05:	ff 73 08             	push   0x8(%ebx)
80103e08:	e8 e3 34 00 00       	call   801072f0 <copyuvm>
80103e0d:	83 c4 10             	add    $0x10,%esp
80103e10:	89 47 08             	mov    %eax,0x8(%edi)
80103e13:	85 c0                	test   %eax,%eax
80103e15:	0f 84 a1 00 00 00    	je     80103ebc <fork+0xec>
  np->sz = curproc->sz;
80103e1b:	8b 03                	mov    (%ebx),%eax
80103e1d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e20:	89 01                	mov    %eax,(%ecx)
  *np->tf = *curproc->tf;
80103e22:	8b 79 1c             	mov    0x1c(%ecx),%edi
  np->parent = curproc;
80103e25:	89 c8                	mov    %ecx,%eax
80103e27:	89 59 18             	mov    %ebx,0x18(%ecx)
  *np->tf = *curproc->tf;
80103e2a:	b9 13 00 00 00       	mov    $0x13,%ecx
80103e2f:	8b 73 1c             	mov    0x1c(%ebx),%esi
80103e32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103e34:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103e36:	8b 40 1c             	mov    0x1c(%eax),%eax
80103e39:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    if(curproc->ofile[i])
80103e40:	8b 44 b3 2c          	mov    0x2c(%ebx,%esi,4),%eax
80103e44:	85 c0                	test   %eax,%eax
80103e46:	74 13                	je     80103e5b <fork+0x8b>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e48:	83 ec 0c             	sub    $0xc,%esp
80103e4b:	50                   	push   %eax
80103e4c:	e8 7f d1 ff ff       	call   80100fd0 <filedup>
80103e51:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e54:	83 c4 10             	add    $0x10,%esp
80103e57:	89 44 b2 2c          	mov    %eax,0x2c(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
80103e5b:	83 c6 01             	add    $0x1,%esi
80103e5e:	83 fe 10             	cmp    $0x10,%esi
80103e61:	75 dd                	jne    80103e40 <fork+0x70>
  np->cwd = idup(curproc->cwd);
80103e63:	83 ec 0c             	sub    $0xc,%esp
80103e66:	ff 73 6c             	push   0x6c(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e69:	83 c3 70             	add    $0x70,%ebx
  np->cwd = idup(curproc->cwd);
80103e6c:	e8 2f db ff ff       	call   801019a0 <idup>
80103e71:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e74:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
80103e77:	89 47 6c             	mov    %eax,0x6c(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e7a:	8d 47 70             	lea    0x70(%edi),%eax
80103e7d:	6a 10                	push   $0x10
80103e7f:	53                   	push   %ebx
80103e80:	50                   	push   %eax
80103e81:	e8 1a 0d 00 00       	call   80104ba0 <safestrcpy>
  pid = np->pid;
80103e86:	8b 5f 14             	mov    0x14(%edi),%ebx
  acquire(&ptable.lock);
80103e89:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80103e90:	e8 8b 0a 00 00       	call   80104920 <acquire>
  np->state = RUNNABLE;
80103e95:	c7 47 10 03 00 00 00 	movl   $0x3,0x10(%edi)
  release(&ptable.lock);
80103e9c:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80103ea3:	e8 18 0a 00 00       	call   801048c0 <release>
  return pid;
80103ea8:	83 c4 10             	add    $0x10,%esp
}
80103eab:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103eae:	89 d8                	mov    %ebx,%eax
80103eb0:	5b                   	pop    %ebx
80103eb1:	5e                   	pop    %esi
80103eb2:	5f                   	pop    %edi
80103eb3:	5d                   	pop    %ebp
80103eb4:	c3                   	ret    
    return -1;
80103eb5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103eba:	eb ef                	jmp    80103eab <fork+0xdb>
    kfree(np->kstack);
80103ebc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103ebf:	83 ec 0c             	sub    $0xc,%esp
80103ec2:	ff 73 0c             	push   0xc(%ebx)
80103ec5:	e8 46 e8 ff ff       	call   80102710 <kfree>
    np->kstack = 0;
80103eca:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103ed1:	83 c4 10             	add    $0x10,%esp
    np->state = UNUSED;
80103ed4:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return -1;
80103edb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103ee0:	eb c9                	jmp    80103eab <fork+0xdb>
80103ee2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103ef0 <print_rss>:
{
80103ef0:	55                   	push   %ebp
80103ef1:	89 e5                	mov    %esp,%ebp
80103ef3:	53                   	push   %ebx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ef4:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
{
80103ef9:	83 ec 10             	sub    $0x10,%esp
  cprintf("PrintingRSS\n");
80103efc:	68 ff 7c 10 80       	push   $0x80107cff
80103f01:	e8 ca c8 ff ff       	call   801007d0 <cprintf>
  acquire(&ptable.lock);
80103f06:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80103f0d:	e8 0e 0a 00 00       	call   80104920 <acquire>
80103f12:	83 c4 10             	add    $0x10,%esp
80103f15:	8d 76 00             	lea    0x0(%esi),%esi
    if((p->state == UNUSED))
80103f18:	8b 43 10             	mov    0x10(%ebx),%eax
80103f1b:	85 c0                	test   %eax,%eax
80103f1d:	74 14                	je     80103f33 <print_rss+0x43>
    cprintf("((P)) id: %d, state: %d, rss: %d\n",p->pid,p->state,p->rss);
80103f1f:	ff 73 04             	push   0x4(%ebx)
80103f22:	50                   	push   %eax
80103f23:	ff 73 14             	push   0x14(%ebx)
80103f26:	68 dc 7d 10 80       	push   $0x80107ddc
80103f2b:	e8 a0 c8 ff ff       	call   801007d0 <cprintf>
80103f30:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f33:	83 eb 80             	sub    $0xffffff80,%ebx
80103f36:	81 fb 94 4d 11 80    	cmp    $0x80114d94,%ebx
80103f3c:	75 da                	jne    80103f18 <print_rss+0x28>
  release(&ptable.lock);
80103f3e:	83 ec 0c             	sub    $0xc,%esp
80103f41:	68 60 2d 11 80       	push   $0x80112d60
80103f46:	e8 75 09 00 00       	call   801048c0 <release>
}
80103f4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f4e:	83 c4 10             	add    $0x10,%esp
80103f51:	c9                   	leave  
80103f52:	c3                   	ret    
80103f53:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103f60 <scheduler>:
{
80103f60:	55                   	push   %ebp
80103f61:	89 e5                	mov    %esp,%ebp
80103f63:	57                   	push   %edi
80103f64:	56                   	push   %esi
80103f65:	53                   	push   %ebx
80103f66:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80103f69:	e8 42 fc ff ff       	call   80103bb0 <mycpu>
  c->proc = 0;
80103f6e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103f75:	00 00 00 
  struct cpu *c = mycpu();
80103f78:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103f7a:	8d 78 04             	lea    0x4(%eax),%edi
80103f7d:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103f80:	fb                   	sti    
    acquire(&ptable.lock);
80103f81:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f84:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
    acquire(&ptable.lock);
80103f89:	68 60 2d 11 80       	push   $0x80112d60
80103f8e:	e8 8d 09 00 00       	call   80104920 <acquire>
80103f93:	83 c4 10             	add    $0x10,%esp
80103f96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103f9d:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->state != RUNNABLE)
80103fa0:	83 7b 10 03          	cmpl   $0x3,0x10(%ebx)
80103fa4:	75 33                	jne    80103fd9 <scheduler+0x79>
      switchuvm(p);
80103fa6:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80103fa9:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103faf:	53                   	push   %ebx
80103fb0:	e8 eb 2d 00 00       	call   80106da0 <switchuvm>
      swtch(&(c->scheduler), p->context);
80103fb5:	58                   	pop    %eax
80103fb6:	5a                   	pop    %edx
80103fb7:	ff 73 20             	push   0x20(%ebx)
80103fba:	57                   	push   %edi
      p->state = RUNNING;
80103fbb:	c7 43 10 04 00 00 00 	movl   $0x4,0x10(%ebx)
      swtch(&(c->scheduler), p->context);
80103fc2:	e8 34 0c 00 00       	call   80104bfb <swtch>
      switchkvm();
80103fc7:	e8 c4 2d 00 00       	call   80106d90 <switchkvm>
      c->proc = 0;
80103fcc:	83 c4 10             	add    $0x10,%esp
80103fcf:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103fd6:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fd9:	83 eb 80             	sub    $0xffffff80,%ebx
80103fdc:	81 fb 94 4d 11 80    	cmp    $0x80114d94,%ebx
80103fe2:	75 bc                	jne    80103fa0 <scheduler+0x40>
    release(&ptable.lock);
80103fe4:	83 ec 0c             	sub    $0xc,%esp
80103fe7:	68 60 2d 11 80       	push   $0x80112d60
80103fec:	e8 cf 08 00 00       	call   801048c0 <release>
    sti();
80103ff1:	83 c4 10             	add    $0x10,%esp
80103ff4:	eb 8a                	jmp    80103f80 <scheduler+0x20>
80103ff6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103ffd:	8d 76 00             	lea    0x0(%esi),%esi

80104000 <sched>:
{
80104000:	55                   	push   %ebp
80104001:	89 e5                	mov    %esp,%ebp
80104003:	56                   	push   %esi
80104004:	53                   	push   %ebx
  pushcli();
80104005:	e8 c6 07 00 00       	call   801047d0 <pushcli>
  c = mycpu();
8010400a:	e8 a1 fb ff ff       	call   80103bb0 <mycpu>
  p = c->proc;
8010400f:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104015:	e8 06 08 00 00       	call   80104820 <popcli>
  if(!holding(&ptable.lock))
8010401a:	83 ec 0c             	sub    $0xc,%esp
8010401d:	68 60 2d 11 80       	push   $0x80112d60
80104022:	e8 59 08 00 00       	call   80104880 <holding>
80104027:	83 c4 10             	add    $0x10,%esp
8010402a:	85 c0                	test   %eax,%eax
8010402c:	74 4f                	je     8010407d <sched+0x7d>
  if(mycpu()->ncli != 1)
8010402e:	e8 7d fb ff ff       	call   80103bb0 <mycpu>
80104033:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010403a:	75 68                	jne    801040a4 <sched+0xa4>
  if(p->state == RUNNING)
8010403c:	83 7b 10 04          	cmpl   $0x4,0x10(%ebx)
80104040:	74 55                	je     80104097 <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104042:	9c                   	pushf  
80104043:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104044:	f6 c4 02             	test   $0x2,%ah
80104047:	75 41                	jne    8010408a <sched+0x8a>
  intena = mycpu()->intena;
80104049:	e8 62 fb ff ff       	call   80103bb0 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
8010404e:	83 c3 20             	add    $0x20,%ebx
  intena = mycpu()->intena;
80104051:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80104057:	e8 54 fb ff ff       	call   80103bb0 <mycpu>
8010405c:	83 ec 08             	sub    $0x8,%esp
8010405f:	ff 70 04             	push   0x4(%eax)
80104062:	53                   	push   %ebx
80104063:	e8 93 0b 00 00       	call   80104bfb <swtch>
  mycpu()->intena = intena;
80104068:	e8 43 fb ff ff       	call   80103bb0 <mycpu>
}
8010406d:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104070:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80104076:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104079:	5b                   	pop    %ebx
8010407a:	5e                   	pop    %esi
8010407b:	5d                   	pop    %ebp
8010407c:	c3                   	ret    
    panic("sched ptable.lock");
8010407d:	83 ec 0c             	sub    $0xc,%esp
80104080:	68 0c 7d 10 80       	push   $0x80107d0c
80104085:	e8 26 c4 ff ff       	call   801004b0 <panic>
    panic("sched interruptible");
8010408a:	83 ec 0c             	sub    $0xc,%esp
8010408d:	68 38 7d 10 80       	push   $0x80107d38
80104092:	e8 19 c4 ff ff       	call   801004b0 <panic>
    panic("sched running");
80104097:	83 ec 0c             	sub    $0xc,%esp
8010409a:	68 2a 7d 10 80       	push   $0x80107d2a
8010409f:	e8 0c c4 ff ff       	call   801004b0 <panic>
    panic("sched locks");
801040a4:	83 ec 0c             	sub    $0xc,%esp
801040a7:	68 1e 7d 10 80       	push   $0x80107d1e
801040ac:	e8 ff c3 ff ff       	call   801004b0 <panic>
801040b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801040b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801040bf:	90                   	nop

801040c0 <exit>:
{
801040c0:	55                   	push   %ebp
801040c1:	89 e5                	mov    %esp,%ebp
801040c3:	57                   	push   %edi
801040c4:	56                   	push   %esi
801040c5:	53                   	push   %ebx
801040c6:	83 ec 0c             	sub    $0xc,%esp
  struct proc *curproc = myproc();
801040c9:	e8 62 fb ff ff       	call   80103c30 <myproc>
  if(curproc == initproc)
801040ce:	39 05 94 4d 11 80    	cmp    %eax,0x80114d94
801040d4:	0f 84 fd 00 00 00    	je     801041d7 <exit+0x117>
801040da:	89 c3                	mov    %eax,%ebx
801040dc:	8d 70 2c             	lea    0x2c(%eax),%esi
801040df:	8d 78 6c             	lea    0x6c(%eax),%edi
801040e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[fd]){
801040e8:	8b 06                	mov    (%esi),%eax
801040ea:	85 c0                	test   %eax,%eax
801040ec:	74 12                	je     80104100 <exit+0x40>
      fileclose(curproc->ofile[fd]);
801040ee:	83 ec 0c             	sub    $0xc,%esp
801040f1:	50                   	push   %eax
801040f2:	e8 29 cf ff ff       	call   80101020 <fileclose>
      curproc->ofile[fd] = 0;
801040f7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801040fd:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80104100:	83 c6 04             	add    $0x4,%esi
80104103:	39 f7                	cmp    %esi,%edi
80104105:	75 e1                	jne    801040e8 <exit+0x28>
  begin_op();
80104107:	e8 f4 ee ff ff       	call   80103000 <begin_op>
  iput(curproc->cwd);
8010410c:	83 ec 0c             	sub    $0xc,%esp
8010410f:	ff 73 6c             	push   0x6c(%ebx)
80104112:	e8 e9 d9 ff ff       	call   80101b00 <iput>
  end_op();
80104117:	e8 54 ef ff ff       	call   80103070 <end_op>
  curproc->cwd = 0;
8010411c:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)
  acquire(&ptable.lock);
80104123:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
8010412a:	e8 f1 07 00 00       	call   80104920 <acquire>
  wakeup1(curproc->parent);
8010412f:	8b 53 18             	mov    0x18(%ebx),%edx
80104132:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104135:	b8 94 2d 11 80       	mov    $0x80112d94,%eax
8010413a:	eb 0e                	jmp    8010414a <exit+0x8a>
8010413c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104140:	83 e8 80             	sub    $0xffffff80,%eax
80104143:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
80104148:	74 1c                	je     80104166 <exit+0xa6>
    if(p->state == SLEEPING && p->chan == chan)
8010414a:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
8010414e:	75 f0                	jne    80104140 <exit+0x80>
80104150:	3b 50 24             	cmp    0x24(%eax),%edx
80104153:	75 eb                	jne    80104140 <exit+0x80>
      p->state = RUNNABLE;
80104155:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010415c:	83 e8 80             	sub    $0xffffff80,%eax
8010415f:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
80104164:	75 e4                	jne    8010414a <exit+0x8a>
      p->parent = initproc;
80104166:	8b 0d 94 4d 11 80    	mov    0x80114d94,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010416c:	ba 94 2d 11 80       	mov    $0x80112d94,%edx
80104171:	eb 10                	jmp    80104183 <exit+0xc3>
80104173:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104177:	90                   	nop
80104178:	83 ea 80             	sub    $0xffffff80,%edx
8010417b:	81 fa 94 4d 11 80    	cmp    $0x80114d94,%edx
80104181:	74 3b                	je     801041be <exit+0xfe>
    if(p->parent == curproc){
80104183:	39 5a 18             	cmp    %ebx,0x18(%edx)
80104186:	75 f0                	jne    80104178 <exit+0xb8>
      if(p->state == ZOMBIE)
80104188:	83 7a 10 05          	cmpl   $0x5,0x10(%edx)
      p->parent = initproc;
8010418c:	89 4a 18             	mov    %ecx,0x18(%edx)
      if(p->state == ZOMBIE)
8010418f:	75 e7                	jne    80104178 <exit+0xb8>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104191:	b8 94 2d 11 80       	mov    $0x80112d94,%eax
80104196:	eb 12                	jmp    801041aa <exit+0xea>
80104198:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010419f:	90                   	nop
801041a0:	83 e8 80             	sub    $0xffffff80,%eax
801041a3:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
801041a8:	74 ce                	je     80104178 <exit+0xb8>
    if(p->state == SLEEPING && p->chan == chan)
801041aa:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
801041ae:	75 f0                	jne    801041a0 <exit+0xe0>
801041b0:	3b 48 24             	cmp    0x24(%eax),%ecx
801041b3:	75 eb                	jne    801041a0 <exit+0xe0>
      p->state = RUNNABLE;
801041b5:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
801041bc:	eb e2                	jmp    801041a0 <exit+0xe0>
  curproc->state = ZOMBIE;
801041be:	c7 43 10 05 00 00 00 	movl   $0x5,0x10(%ebx)
  sched();
801041c5:	e8 36 fe ff ff       	call   80104000 <sched>
  panic("zombie exit");
801041ca:	83 ec 0c             	sub    $0xc,%esp
801041cd:	68 59 7d 10 80       	push   $0x80107d59
801041d2:	e8 d9 c2 ff ff       	call   801004b0 <panic>
    panic("init exiting");
801041d7:	83 ec 0c             	sub    $0xc,%esp
801041da:	68 4c 7d 10 80       	push   $0x80107d4c
801041df:	e8 cc c2 ff ff       	call   801004b0 <panic>
801041e4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801041eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801041ef:	90                   	nop

801041f0 <wait>:
{
801041f0:	55                   	push   %ebp
801041f1:	89 e5                	mov    %esp,%ebp
801041f3:	56                   	push   %esi
801041f4:	53                   	push   %ebx
  pushcli();
801041f5:	e8 d6 05 00 00       	call   801047d0 <pushcli>
  c = mycpu();
801041fa:	e8 b1 f9 ff ff       	call   80103bb0 <mycpu>
  p = c->proc;
801041ff:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80104205:	e8 16 06 00 00       	call   80104820 <popcli>
  acquire(&ptable.lock);
8010420a:	83 ec 0c             	sub    $0xc,%esp
8010420d:	68 60 2d 11 80       	push   $0x80112d60
80104212:	e8 09 07 00 00       	call   80104920 <acquire>
80104217:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010421a:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010421c:	bb 94 2d 11 80       	mov    $0x80112d94,%ebx
80104221:	eb 10                	jmp    80104233 <wait+0x43>
80104223:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104227:	90                   	nop
80104228:	83 eb 80             	sub    $0xffffff80,%ebx
8010422b:	81 fb 94 4d 11 80    	cmp    $0x80114d94,%ebx
80104231:	74 1b                	je     8010424e <wait+0x5e>
      if(p->parent != curproc)
80104233:	39 73 18             	cmp    %esi,0x18(%ebx)
80104236:	75 f0                	jne    80104228 <wait+0x38>
      if(p->state == ZOMBIE){
80104238:	83 7b 10 05          	cmpl   $0x5,0x10(%ebx)
8010423c:	74 62                	je     801042a0 <wait+0xb0>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010423e:	83 eb 80             	sub    $0xffffff80,%ebx
      havekids = 1;
80104241:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104246:	81 fb 94 4d 11 80    	cmp    $0x80114d94,%ebx
8010424c:	75 e5                	jne    80104233 <wait+0x43>
    if(!havekids || curproc->killed){
8010424e:	85 c0                	test   %eax,%eax
80104250:	0f 84 a0 00 00 00    	je     801042f6 <wait+0x106>
80104256:	8b 46 28             	mov    0x28(%esi),%eax
80104259:	85 c0                	test   %eax,%eax
8010425b:	0f 85 95 00 00 00    	jne    801042f6 <wait+0x106>
  pushcli();
80104261:	e8 6a 05 00 00       	call   801047d0 <pushcli>
  c = mycpu();
80104266:	e8 45 f9 ff ff       	call   80103bb0 <mycpu>
  p = c->proc;
8010426b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104271:	e8 aa 05 00 00       	call   80104820 <popcli>
  if(p == 0)
80104276:	85 db                	test   %ebx,%ebx
80104278:	0f 84 8f 00 00 00    	je     8010430d <wait+0x11d>
  p->chan = chan;
8010427e:	89 73 24             	mov    %esi,0x24(%ebx)
  p->state = SLEEPING;
80104281:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
80104288:	e8 73 fd ff ff       	call   80104000 <sched>
  p->chan = 0;
8010428d:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
}
80104294:	eb 84                	jmp    8010421a <wait+0x2a>
80104296:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010429d:	8d 76 00             	lea    0x0(%esi),%esi
        kfree(p->kstack);
801042a0:	83 ec 0c             	sub    $0xc,%esp
        pid = p->pid;
801042a3:	8b 73 14             	mov    0x14(%ebx),%esi
        kfree(p->kstack);
801042a6:	ff 73 0c             	push   0xc(%ebx)
801042a9:	e8 62 e4 ff ff       	call   80102710 <kfree>
        p->kstack = 0;
801042ae:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        freevm(p->pgdir);
801042b5:	5a                   	pop    %edx
801042b6:	ff 73 08             	push   0x8(%ebx)
801042b9:	e8 c2 2e 00 00       	call   80107180 <freevm>
        p->pid = 0;
801042be:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->parent = 0;
801042c5:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->name[0] = 0;
801042cc:	c6 43 70 00          	movb   $0x0,0x70(%ebx)
        p->killed = 0;
801042d0:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
        p->state = UNUSED;
801042d7:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        release(&ptable.lock);
801042de:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
801042e5:	e8 d6 05 00 00       	call   801048c0 <release>
        return pid;
801042ea:	83 c4 10             	add    $0x10,%esp
}
801042ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
801042f0:	89 f0                	mov    %esi,%eax
801042f2:	5b                   	pop    %ebx
801042f3:	5e                   	pop    %esi
801042f4:	5d                   	pop    %ebp
801042f5:	c3                   	ret    
      release(&ptable.lock);
801042f6:	83 ec 0c             	sub    $0xc,%esp
      return -1;
801042f9:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
801042fe:	68 60 2d 11 80       	push   $0x80112d60
80104303:	e8 b8 05 00 00       	call   801048c0 <release>
      return -1;
80104308:	83 c4 10             	add    $0x10,%esp
8010430b:	eb e0                	jmp    801042ed <wait+0xfd>
    panic("sleep");
8010430d:	83 ec 0c             	sub    $0xc,%esp
80104310:	68 65 7d 10 80       	push   $0x80107d65
80104315:	e8 96 c1 ff ff       	call   801004b0 <panic>
8010431a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104320 <yield>:
{
80104320:	55                   	push   %ebp
80104321:	89 e5                	mov    %esp,%ebp
80104323:	53                   	push   %ebx
80104324:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104327:	68 60 2d 11 80       	push   $0x80112d60
8010432c:	e8 ef 05 00 00       	call   80104920 <acquire>
  pushcli();
80104331:	e8 9a 04 00 00       	call   801047d0 <pushcli>
  c = mycpu();
80104336:	e8 75 f8 ff ff       	call   80103bb0 <mycpu>
  p = c->proc;
8010433b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104341:	e8 da 04 00 00       	call   80104820 <popcli>
  myproc()->state = RUNNABLE;
80104346:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  sched();
8010434d:	e8 ae fc ff ff       	call   80104000 <sched>
  release(&ptable.lock);
80104352:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
80104359:	e8 62 05 00 00       	call   801048c0 <release>
}
8010435e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104361:	83 c4 10             	add    $0x10,%esp
80104364:	c9                   	leave  
80104365:	c3                   	ret    
80104366:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010436d:	8d 76 00             	lea    0x0(%esi),%esi

80104370 <sleep>:
{
80104370:	55                   	push   %ebp
80104371:	89 e5                	mov    %esp,%ebp
80104373:	57                   	push   %edi
80104374:	56                   	push   %esi
80104375:	53                   	push   %ebx
80104376:	83 ec 0c             	sub    $0xc,%esp
80104379:	8b 7d 08             	mov    0x8(%ebp),%edi
8010437c:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
8010437f:	e8 4c 04 00 00       	call   801047d0 <pushcli>
  c = mycpu();
80104384:	e8 27 f8 ff ff       	call   80103bb0 <mycpu>
  p = c->proc;
80104389:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010438f:	e8 8c 04 00 00       	call   80104820 <popcli>
  if(p == 0)
80104394:	85 db                	test   %ebx,%ebx
80104396:	0f 84 87 00 00 00    	je     80104423 <sleep+0xb3>
  if(lk == 0)
8010439c:	85 f6                	test   %esi,%esi
8010439e:	74 76                	je     80104416 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801043a0:	81 fe 60 2d 11 80    	cmp    $0x80112d60,%esi
801043a6:	74 50                	je     801043f8 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
801043a8:	83 ec 0c             	sub    $0xc,%esp
801043ab:	68 60 2d 11 80       	push   $0x80112d60
801043b0:	e8 6b 05 00 00       	call   80104920 <acquire>
    release(lk);
801043b5:	89 34 24             	mov    %esi,(%esp)
801043b8:	e8 03 05 00 00       	call   801048c0 <release>
  p->chan = chan;
801043bd:	89 7b 24             	mov    %edi,0x24(%ebx)
  p->state = SLEEPING;
801043c0:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
801043c7:	e8 34 fc ff ff       	call   80104000 <sched>
  p->chan = 0;
801043cc:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
    release(&ptable.lock);
801043d3:	c7 04 24 60 2d 11 80 	movl   $0x80112d60,(%esp)
801043da:	e8 e1 04 00 00       	call   801048c0 <release>
    acquire(lk);
801043df:	89 75 08             	mov    %esi,0x8(%ebp)
801043e2:	83 c4 10             	add    $0x10,%esp
}
801043e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801043e8:	5b                   	pop    %ebx
801043e9:	5e                   	pop    %esi
801043ea:	5f                   	pop    %edi
801043eb:	5d                   	pop    %ebp
    acquire(lk);
801043ec:	e9 2f 05 00 00       	jmp    80104920 <acquire>
801043f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  p->chan = chan;
801043f8:	89 7b 24             	mov    %edi,0x24(%ebx)
  p->state = SLEEPING;
801043fb:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
80104402:	e8 f9 fb ff ff       	call   80104000 <sched>
  p->chan = 0;
80104407:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
}
8010440e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104411:	5b                   	pop    %ebx
80104412:	5e                   	pop    %esi
80104413:	5f                   	pop    %edi
80104414:	5d                   	pop    %ebp
80104415:	c3                   	ret    
    panic("sleep without lk");
80104416:	83 ec 0c             	sub    $0xc,%esp
80104419:	68 6b 7d 10 80       	push   $0x80107d6b
8010441e:	e8 8d c0 ff ff       	call   801004b0 <panic>
    panic("sleep");
80104423:	83 ec 0c             	sub    $0xc,%esp
80104426:	68 65 7d 10 80       	push   $0x80107d65
8010442b:	e8 80 c0 ff ff       	call   801004b0 <panic>

80104430 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104430:	55                   	push   %ebp
80104431:	89 e5                	mov    %esp,%ebp
80104433:	53                   	push   %ebx
80104434:	83 ec 10             	sub    $0x10,%esp
80104437:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010443a:	68 60 2d 11 80       	push   $0x80112d60
8010443f:	e8 dc 04 00 00       	call   80104920 <acquire>
80104444:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104447:	b8 94 2d 11 80       	mov    $0x80112d94,%eax
8010444c:	eb 0c                	jmp    8010445a <wakeup+0x2a>
8010444e:	66 90                	xchg   %ax,%ax
80104450:	83 e8 80             	sub    $0xffffff80,%eax
80104453:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
80104458:	74 1c                	je     80104476 <wakeup+0x46>
    if(p->state == SLEEPING && p->chan == chan)
8010445a:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
8010445e:	75 f0                	jne    80104450 <wakeup+0x20>
80104460:	3b 58 24             	cmp    0x24(%eax),%ebx
80104463:	75 eb                	jne    80104450 <wakeup+0x20>
      p->state = RUNNABLE;
80104465:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010446c:	83 e8 80             	sub    $0xffffff80,%eax
8010446f:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
80104474:	75 e4                	jne    8010445a <wakeup+0x2a>
  wakeup1(chan);
  release(&ptable.lock);
80104476:	c7 45 08 60 2d 11 80 	movl   $0x80112d60,0x8(%ebp)
}
8010447d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104480:	c9                   	leave  
  release(&ptable.lock);
80104481:	e9 3a 04 00 00       	jmp    801048c0 <release>
80104486:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010448d:	8d 76 00             	lea    0x0(%esi),%esi

80104490 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104490:	55                   	push   %ebp
80104491:	89 e5                	mov    %esp,%ebp
80104493:	53                   	push   %ebx
80104494:	83 ec 10             	sub    $0x10,%esp
80104497:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010449a:	68 60 2d 11 80       	push   $0x80112d60
8010449f:	e8 7c 04 00 00       	call   80104920 <acquire>
801044a4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044a7:	b8 94 2d 11 80       	mov    $0x80112d94,%eax
801044ac:	eb 0c                	jmp    801044ba <kill+0x2a>
801044ae:	66 90                	xchg   %ax,%ax
801044b0:	83 e8 80             	sub    $0xffffff80,%eax
801044b3:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
801044b8:	74 36                	je     801044f0 <kill+0x60>
    if(p->pid == pid){
801044ba:	39 58 14             	cmp    %ebx,0x14(%eax)
801044bd:	75 f1                	jne    801044b0 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801044bf:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
      p->killed = 1;
801044c3:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      if(p->state == SLEEPING)
801044ca:	75 07                	jne    801044d3 <kill+0x43>
        p->state = RUNNABLE;
801044cc:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
      release(&ptable.lock);
801044d3:	83 ec 0c             	sub    $0xc,%esp
801044d6:	68 60 2d 11 80       	push   $0x80112d60
801044db:	e8 e0 03 00 00       	call   801048c0 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
801044e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0;
801044e3:	83 c4 10             	add    $0x10,%esp
801044e6:	31 c0                	xor    %eax,%eax
}
801044e8:	c9                   	leave  
801044e9:	c3                   	ret    
801044ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
801044f0:	83 ec 0c             	sub    $0xc,%esp
801044f3:	68 60 2d 11 80       	push   $0x80112d60
801044f8:	e8 c3 03 00 00       	call   801048c0 <release>
}
801044fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80104500:	83 c4 10             	add    $0x10,%esp
80104503:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104508:	c9                   	leave  
80104509:	c3                   	ret    
8010450a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104510 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104510:	55                   	push   %ebp
80104511:	89 e5                	mov    %esp,%ebp
80104513:	57                   	push   %edi
80104514:	56                   	push   %esi
80104515:	8d 75 e8             	lea    -0x18(%ebp),%esi
80104518:	53                   	push   %ebx
80104519:	bb 04 2e 11 80       	mov    $0x80112e04,%ebx
8010451e:	83 ec 3c             	sub    $0x3c,%esp
80104521:	eb 24                	jmp    80104547 <procdump+0x37>
80104523:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104527:	90                   	nop
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104528:	83 ec 0c             	sub    $0xc,%esp
8010452b:	68 67 81 10 80       	push   $0x80108167
80104530:	e8 9b c2 ff ff       	call   801007d0 <cprintf>
80104535:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104538:	83 eb 80             	sub    $0xffffff80,%ebx
8010453b:	81 fb 04 4e 11 80    	cmp    $0x80114e04,%ebx
80104541:	0f 84 81 00 00 00    	je     801045c8 <procdump+0xb8>
    if(p->state == UNUSED)
80104547:	8b 43 a0             	mov    -0x60(%ebx),%eax
8010454a:	85 c0                	test   %eax,%eax
8010454c:	74 ea                	je     80104538 <procdump+0x28>
      state = "???";
8010454e:	ba 7c 7d 10 80       	mov    $0x80107d7c,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104553:	83 f8 05             	cmp    $0x5,%eax
80104556:	77 11                	ja     80104569 <procdump+0x59>
80104558:	8b 14 85 00 7e 10 80 	mov    -0x7fef8200(,%eax,4),%edx
      state = "???";
8010455f:	b8 7c 7d 10 80       	mov    $0x80107d7c,%eax
80104564:	85 d2                	test   %edx,%edx
80104566:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
80104569:	53                   	push   %ebx
8010456a:	52                   	push   %edx
8010456b:	ff 73 a4             	push   -0x5c(%ebx)
8010456e:	68 80 7d 10 80       	push   $0x80107d80
80104573:	e8 58 c2 ff ff       	call   801007d0 <cprintf>
    if(p->state == SLEEPING){
80104578:	83 c4 10             	add    $0x10,%esp
8010457b:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
8010457f:	75 a7                	jne    80104528 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104581:	83 ec 08             	sub    $0x8,%esp
80104584:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104587:	8d 7d c0             	lea    -0x40(%ebp),%edi
8010458a:	50                   	push   %eax
8010458b:	8b 43 b0             	mov    -0x50(%ebx),%eax
8010458e:	8b 40 0c             	mov    0xc(%eax),%eax
80104591:	83 c0 08             	add    $0x8,%eax
80104594:	50                   	push   %eax
80104595:	e8 d6 01 00 00       	call   80104770 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010459a:	83 c4 10             	add    $0x10,%esp
8010459d:	8d 76 00             	lea    0x0(%esi),%esi
801045a0:	8b 17                	mov    (%edi),%edx
801045a2:	85 d2                	test   %edx,%edx
801045a4:	74 82                	je     80104528 <procdump+0x18>
        cprintf(" %p", pc[i]);
801045a6:	83 ec 08             	sub    $0x8,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801045a9:	83 c7 04             	add    $0x4,%edi
        cprintf(" %p", pc[i]);
801045ac:	52                   	push   %edx
801045ad:	68 c1 77 10 80       	push   $0x801077c1
801045b2:	e8 19 c2 ff ff       	call   801007d0 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801045b7:	83 c4 10             	add    $0x10,%esp
801045ba:	39 fe                	cmp    %edi,%esi
801045bc:	75 e2                	jne    801045a0 <procdump+0x90>
801045be:	e9 65 ff ff ff       	jmp    80104528 <procdump+0x18>
801045c3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801045c7:	90                   	nop
  }
}
801045c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801045cb:	5b                   	pop    %ebx
801045cc:	5e                   	pop    %esi
801045cd:	5f                   	pop    %edi
801045ce:	5d                   	pop    %ebp
801045cf:	c3                   	ret    

801045d0 <victim_pgdir>:
// Missed the case when two processes have same rss value
pde_t* victim_pgdir(){
801045d0:	55                   	push   %ebp
  uint max_rss=0;
  struct proc *q  = ptable.proc;
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045d1:	b8 94 2d 11 80       	mov    $0x80112d94,%eax
  uint max_rss=0;
801045d6:	31 c9                	xor    %ecx,%ecx
pde_t* victim_pgdir(){
801045d8:	89 e5                	mov    %esp,%ebp
801045da:	53                   	push   %ebx
  struct proc *q  = ptable.proc;
801045db:	89 c3                	mov    %eax,%ebx
801045dd:	eb 16                	jmp    801045f5 <victim_pgdir+0x25>
801045df:	90                   	nop
    if(p->rss > max_rss){
      q=p;
      max_rss= p->rss;
    }
    // Added the case here
    else if(p->rss == max_rss){
801045e0:	75 09                	jne    801045eb <victim_pgdir+0x1b>
      if(p->pid < q->pid){
801045e2:	8b 53 14             	mov    0x14(%ebx),%edx
801045e5:	39 50 14             	cmp    %edx,0x14(%eax)
801045e8:	0f 4c d8             	cmovl  %eax,%ebx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045eb:	83 e8 80             	sub    $0xffffff80,%eax
801045ee:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
801045f3:	74 15                	je     8010460a <victim_pgdir+0x3a>
    if(p->rss > max_rss){
801045f5:	8b 50 04             	mov    0x4(%eax),%edx
801045f8:	39 ca                	cmp    %ecx,%edx
801045fa:	76 e4                	jbe    801045e0 <victim_pgdir+0x10>
801045fc:	89 c3                	mov    %eax,%ebx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045fe:	83 e8 80             	sub    $0xffffff80,%eax
80104601:	89 d1                	mov    %edx,%ecx
80104603:	3d 94 4d 11 80       	cmp    $0x80114d94,%eax
80104608:	75 eb                	jne    801045f5 <victim_pgdir+0x25>
        q=p;
      }
    }
  }
  q->rss-=PGSIZE;
  return q->pgdir;
8010460a:	8b 43 08             	mov    0x8(%ebx),%eax
  q->rss-=PGSIZE;
8010460d:	81 6b 04 00 10 00 00 	subl   $0x1000,0x4(%ebx)
}
80104614:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104617:	c9                   	leave  
80104618:	c3                   	ret    
80104619:	66 90                	xchg   %ax,%ax
8010461b:	66 90                	xchg   %ax,%ax
8010461d:	66 90                	xchg   %ax,%ax
8010461f:	90                   	nop

80104620 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104620:	55                   	push   %ebp
80104621:	89 e5                	mov    %esp,%ebp
80104623:	53                   	push   %ebx
80104624:	83 ec 0c             	sub    $0xc,%esp
80104627:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010462a:	68 18 7e 10 80       	push   $0x80107e18
8010462f:	8d 43 04             	lea    0x4(%ebx),%eax
80104632:	50                   	push   %eax
80104633:	e8 18 01 00 00       	call   80104750 <initlock>
  lk->name = name;
80104638:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
8010463b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
80104641:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
80104644:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
8010464b:	89 43 38             	mov    %eax,0x38(%ebx)
}
8010464e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104651:	c9                   	leave  
80104652:	c3                   	ret    
80104653:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010465a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104660 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104660:	55                   	push   %ebp
80104661:	89 e5                	mov    %esp,%ebp
80104663:	56                   	push   %esi
80104664:	53                   	push   %ebx
80104665:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104668:	8d 73 04             	lea    0x4(%ebx),%esi
8010466b:	83 ec 0c             	sub    $0xc,%esp
8010466e:	56                   	push   %esi
8010466f:	e8 ac 02 00 00       	call   80104920 <acquire>
  while (lk->locked) {
80104674:	8b 13                	mov    (%ebx),%edx
80104676:	83 c4 10             	add    $0x10,%esp
80104679:	85 d2                	test   %edx,%edx
8010467b:	74 16                	je     80104693 <acquiresleep+0x33>
8010467d:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
80104680:	83 ec 08             	sub    $0x8,%esp
80104683:	56                   	push   %esi
80104684:	53                   	push   %ebx
80104685:	e8 e6 fc ff ff       	call   80104370 <sleep>
  while (lk->locked) {
8010468a:	8b 03                	mov    (%ebx),%eax
8010468c:	83 c4 10             	add    $0x10,%esp
8010468f:	85 c0                	test   %eax,%eax
80104691:	75 ed                	jne    80104680 <acquiresleep+0x20>
  }
  lk->locked = 1;
80104693:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104699:	e8 92 f5 ff ff       	call   80103c30 <myproc>
8010469e:	8b 40 14             	mov    0x14(%eax),%eax
801046a1:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
801046a4:	89 75 08             	mov    %esi,0x8(%ebp)
}
801046a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801046aa:	5b                   	pop    %ebx
801046ab:	5e                   	pop    %esi
801046ac:	5d                   	pop    %ebp
  release(&lk->lk);
801046ad:	e9 0e 02 00 00       	jmp    801048c0 <release>
801046b2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801046b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801046c0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801046c0:	55                   	push   %ebp
801046c1:	89 e5                	mov    %esp,%ebp
801046c3:	56                   	push   %esi
801046c4:	53                   	push   %ebx
801046c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801046c8:	8d 73 04             	lea    0x4(%ebx),%esi
801046cb:	83 ec 0c             	sub    $0xc,%esp
801046ce:	56                   	push   %esi
801046cf:	e8 4c 02 00 00       	call   80104920 <acquire>
  lk->locked = 0;
801046d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801046da:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
801046e1:	89 1c 24             	mov    %ebx,(%esp)
801046e4:	e8 47 fd ff ff       	call   80104430 <wakeup>
  release(&lk->lk);
801046e9:	89 75 08             	mov    %esi,0x8(%ebp)
801046ec:	83 c4 10             	add    $0x10,%esp
}
801046ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
801046f2:	5b                   	pop    %ebx
801046f3:	5e                   	pop    %esi
801046f4:	5d                   	pop    %ebp
  release(&lk->lk);
801046f5:	e9 c6 01 00 00       	jmp    801048c0 <release>
801046fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104700 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104700:	55                   	push   %ebp
80104701:	89 e5                	mov    %esp,%ebp
80104703:	57                   	push   %edi
80104704:	31 ff                	xor    %edi,%edi
80104706:	56                   	push   %esi
80104707:	53                   	push   %ebx
80104708:	83 ec 18             	sub    $0x18,%esp
8010470b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
8010470e:	8d 73 04             	lea    0x4(%ebx),%esi
80104711:	56                   	push   %esi
80104712:	e8 09 02 00 00       	call   80104920 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80104717:	8b 03                	mov    (%ebx),%eax
80104719:	83 c4 10             	add    $0x10,%esp
8010471c:	85 c0                	test   %eax,%eax
8010471e:	75 18                	jne    80104738 <holdingsleep+0x38>
  release(&lk->lk);
80104720:	83 ec 0c             	sub    $0xc,%esp
80104723:	56                   	push   %esi
80104724:	e8 97 01 00 00       	call   801048c0 <release>
  return r;
}
80104729:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010472c:	89 f8                	mov    %edi,%eax
8010472e:	5b                   	pop    %ebx
8010472f:	5e                   	pop    %esi
80104730:	5f                   	pop    %edi
80104731:	5d                   	pop    %ebp
80104732:	c3                   	ret    
80104733:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104737:	90                   	nop
  r = lk->locked && (lk->pid == myproc()->pid);
80104738:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
8010473b:	e8 f0 f4 ff ff       	call   80103c30 <myproc>
80104740:	39 58 14             	cmp    %ebx,0x14(%eax)
80104743:	0f 94 c0             	sete   %al
80104746:	0f b6 c0             	movzbl %al,%eax
80104749:	89 c7                	mov    %eax,%edi
8010474b:	eb d3                	jmp    80104720 <holdingsleep+0x20>
8010474d:	66 90                	xchg   %ax,%ax
8010474f:	90                   	nop

80104750 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104750:	55                   	push   %ebp
80104751:	89 e5                	mov    %esp,%ebp
80104753:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104756:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
80104759:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
8010475f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
80104762:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104769:	5d                   	pop    %ebp
8010476a:	c3                   	ret    
8010476b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010476f:	90                   	nop

80104770 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104770:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104771:	31 d2                	xor    %edx,%edx
{
80104773:	89 e5                	mov    %esp,%ebp
80104775:	53                   	push   %ebx
  ebp = (uint*)v - 2;
80104776:	8b 45 08             	mov    0x8(%ebp),%eax
{
80104779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
8010477c:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
8010477f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104780:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104786:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
8010478c:	77 1a                	ja     801047a8 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010478e:	8b 58 04             	mov    0x4(%eax),%ebx
80104791:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104794:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104797:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104799:	83 fa 0a             	cmp    $0xa,%edx
8010479c:	75 e2                	jne    80104780 <getcallerpcs+0x10>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
8010479e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801047a1:	c9                   	leave  
801047a2:	c3                   	ret    
801047a3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801047a7:	90                   	nop
  for(; i < 10; i++)
801047a8:	8d 04 91             	lea    (%ecx,%edx,4),%eax
801047ab:	8d 51 28             	lea    0x28(%ecx),%edx
801047ae:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
801047b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801047b6:	83 c0 04             	add    $0x4,%eax
801047b9:	39 d0                	cmp    %edx,%eax
801047bb:	75 f3                	jne    801047b0 <getcallerpcs+0x40>
}
801047bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801047c0:	c9                   	leave  
801047c1:	c3                   	ret    
801047c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801047c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801047d0 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801047d0:	55                   	push   %ebp
801047d1:	89 e5                	mov    %esp,%ebp
801047d3:	53                   	push   %ebx
801047d4:	83 ec 04             	sub    $0x4,%esp
801047d7:	9c                   	pushf  
801047d8:	5b                   	pop    %ebx
  asm volatile("cli");
801047d9:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
801047da:	e8 d1 f3 ff ff       	call   80103bb0 <mycpu>
801047df:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801047e5:	85 c0                	test   %eax,%eax
801047e7:	74 17                	je     80104800 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
801047e9:	e8 c2 f3 ff ff       	call   80103bb0 <mycpu>
801047ee:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
801047f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801047f8:	c9                   	leave  
801047f9:	c3                   	ret    
801047fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    mycpu()->intena = eflags & FL_IF;
80104800:	e8 ab f3 ff ff       	call   80103bb0 <mycpu>
80104805:	81 e3 00 02 00 00    	and    $0x200,%ebx
8010480b:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80104811:	eb d6                	jmp    801047e9 <pushcli+0x19>
80104813:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010481a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104820 <popcli>:

void
popcli(void)
{
80104820:	55                   	push   %ebp
80104821:	89 e5                	mov    %esp,%ebp
80104823:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104826:	9c                   	pushf  
80104827:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104828:	f6 c4 02             	test   $0x2,%ah
8010482b:	75 35                	jne    80104862 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
8010482d:	e8 7e f3 ff ff       	call   80103bb0 <mycpu>
80104832:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
80104839:	78 34                	js     8010486f <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010483b:	e8 70 f3 ff ff       	call   80103bb0 <mycpu>
80104840:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104846:	85 d2                	test   %edx,%edx
80104848:	74 06                	je     80104850 <popcli+0x30>
    sti();
}
8010484a:	c9                   	leave  
8010484b:	c3                   	ret    
8010484c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104850:	e8 5b f3 ff ff       	call   80103bb0 <mycpu>
80104855:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010485b:	85 c0                	test   %eax,%eax
8010485d:	74 eb                	je     8010484a <popcli+0x2a>
  asm volatile("sti");
8010485f:	fb                   	sti    
}
80104860:	c9                   	leave  
80104861:	c3                   	ret    
    panic("popcli - interruptible");
80104862:	83 ec 0c             	sub    $0xc,%esp
80104865:	68 23 7e 10 80       	push   $0x80107e23
8010486a:	e8 41 bc ff ff       	call   801004b0 <panic>
    panic("popcli");
8010486f:	83 ec 0c             	sub    $0xc,%esp
80104872:	68 3a 7e 10 80       	push   $0x80107e3a
80104877:	e8 34 bc ff ff       	call   801004b0 <panic>
8010487c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104880 <holding>:
{
80104880:	55                   	push   %ebp
80104881:	89 e5                	mov    %esp,%ebp
80104883:	56                   	push   %esi
80104884:	53                   	push   %ebx
80104885:	8b 75 08             	mov    0x8(%ebp),%esi
80104888:	31 db                	xor    %ebx,%ebx
  pushcli();
8010488a:	e8 41 ff ff ff       	call   801047d0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010488f:	8b 06                	mov    (%esi),%eax
80104891:	85 c0                	test   %eax,%eax
80104893:	75 0b                	jne    801048a0 <holding+0x20>
  popcli();
80104895:	e8 86 ff ff ff       	call   80104820 <popcli>
}
8010489a:	89 d8                	mov    %ebx,%eax
8010489c:	5b                   	pop    %ebx
8010489d:	5e                   	pop    %esi
8010489e:	5d                   	pop    %ebp
8010489f:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
801048a0:	8b 5e 08             	mov    0x8(%esi),%ebx
801048a3:	e8 08 f3 ff ff       	call   80103bb0 <mycpu>
801048a8:	39 c3                	cmp    %eax,%ebx
801048aa:	0f 94 c3             	sete   %bl
  popcli();
801048ad:	e8 6e ff ff ff       	call   80104820 <popcli>
  r = lock->locked && lock->cpu == mycpu();
801048b2:	0f b6 db             	movzbl %bl,%ebx
}
801048b5:	89 d8                	mov    %ebx,%eax
801048b7:	5b                   	pop    %ebx
801048b8:	5e                   	pop    %esi
801048b9:	5d                   	pop    %ebp
801048ba:	c3                   	ret    
801048bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801048bf:	90                   	nop

801048c0 <release>:
{
801048c0:	55                   	push   %ebp
801048c1:	89 e5                	mov    %esp,%ebp
801048c3:	56                   	push   %esi
801048c4:	53                   	push   %ebx
801048c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
801048c8:	e8 03 ff ff ff       	call   801047d0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801048cd:	8b 03                	mov    (%ebx),%eax
801048cf:	85 c0                	test   %eax,%eax
801048d1:	75 15                	jne    801048e8 <release+0x28>
  popcli();
801048d3:	e8 48 ff ff ff       	call   80104820 <popcli>
    panic("release");
801048d8:	83 ec 0c             	sub    $0xc,%esp
801048db:	68 41 7e 10 80       	push   $0x80107e41
801048e0:	e8 cb bb ff ff       	call   801004b0 <panic>
801048e5:	8d 76 00             	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
801048e8:	8b 73 08             	mov    0x8(%ebx),%esi
801048eb:	e8 c0 f2 ff ff       	call   80103bb0 <mycpu>
801048f0:	39 c6                	cmp    %eax,%esi
801048f2:	75 df                	jne    801048d3 <release+0x13>
  popcli();
801048f4:	e8 27 ff ff ff       	call   80104820 <popcli>
  lk->pcs[0] = 0;
801048f9:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104900:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80104907:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010490c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
80104912:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104915:	5b                   	pop    %ebx
80104916:	5e                   	pop    %esi
80104917:	5d                   	pop    %ebp
  popcli();
80104918:	e9 03 ff ff ff       	jmp    80104820 <popcli>
8010491d:	8d 76 00             	lea    0x0(%esi),%esi

80104920 <acquire>:
{
80104920:	55                   	push   %ebp
80104921:	89 e5                	mov    %esp,%ebp
80104923:	53                   	push   %ebx
80104924:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104927:	e8 a4 fe ff ff       	call   801047d0 <pushcli>
  if(holding(lk))
8010492c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
8010492f:	e8 9c fe ff ff       	call   801047d0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104934:	8b 03                	mov    (%ebx),%eax
80104936:	85 c0                	test   %eax,%eax
80104938:	75 7e                	jne    801049b8 <acquire+0x98>
  popcli();
8010493a:	e8 e1 fe ff ff       	call   80104820 <popcli>
  asm volatile("lock; xchgl %0, %1" :
8010493f:	b9 01 00 00 00       	mov    $0x1,%ecx
80104944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(xchg(&lk->locked, 1) != 0)
80104948:	8b 55 08             	mov    0x8(%ebp),%edx
8010494b:	89 c8                	mov    %ecx,%eax
8010494d:	f0 87 02             	lock xchg %eax,(%edx)
80104950:	85 c0                	test   %eax,%eax
80104952:	75 f4                	jne    80104948 <acquire+0x28>
  __sync_synchronize();
80104954:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104959:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010495c:	e8 4f f2 ff ff       	call   80103bb0 <mycpu>
  getcallerpcs(&lk, lk->pcs);
80104961:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ebp = (uint*)v - 2;
80104964:	89 ea                	mov    %ebp,%edx
  lk->cpu = mycpu();
80104966:	89 43 08             	mov    %eax,0x8(%ebx)
  for(i = 0; i < 10; i++){
80104969:	31 c0                	xor    %eax,%eax
8010496b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010496f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104970:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80104976:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
8010497c:	77 1a                	ja     80104998 <acquire+0x78>
    pcs[i] = ebp[1];     // saved %eip
8010497e:	8b 5a 04             	mov    0x4(%edx),%ebx
80104981:	89 5c 81 0c          	mov    %ebx,0xc(%ecx,%eax,4)
  for(i = 0; i < 10; i++){
80104985:	83 c0 01             	add    $0x1,%eax
    ebp = (uint*)ebp[0]; // saved %ebp
80104988:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
8010498a:	83 f8 0a             	cmp    $0xa,%eax
8010498d:	75 e1                	jne    80104970 <acquire+0x50>
}
8010498f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104992:	c9                   	leave  
80104993:	c3                   	ret    
80104994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(; i < 10; i++)
80104998:	8d 44 81 0c          	lea    0xc(%ecx,%eax,4),%eax
8010499c:	8d 51 34             	lea    0x34(%ecx),%edx
8010499f:	90                   	nop
    pcs[i] = 0;
801049a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801049a6:	83 c0 04             	add    $0x4,%eax
801049a9:	39 c2                	cmp    %eax,%edx
801049ab:	75 f3                	jne    801049a0 <acquire+0x80>
}
801049ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049b0:	c9                   	leave  
801049b1:	c3                   	ret    
801049b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
801049b8:	8b 5b 08             	mov    0x8(%ebx),%ebx
801049bb:	e8 f0 f1 ff ff       	call   80103bb0 <mycpu>
801049c0:	39 c3                	cmp    %eax,%ebx
801049c2:	0f 85 72 ff ff ff    	jne    8010493a <acquire+0x1a>
  popcli();
801049c8:	e8 53 fe ff ff       	call   80104820 <popcli>
    panic("acquire");
801049cd:	83 ec 0c             	sub    $0xc,%esp
801049d0:	68 49 7e 10 80       	push   $0x80107e49
801049d5:	e8 d6 ba ff ff       	call   801004b0 <panic>
801049da:	66 90                	xchg   %ax,%ax
801049dc:	66 90                	xchg   %ax,%ax
801049de:	66 90                	xchg   %ax,%ax

801049e0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801049e0:	55                   	push   %ebp
801049e1:	89 e5                	mov    %esp,%ebp
801049e3:	57                   	push   %edi
801049e4:	8b 55 08             	mov    0x8(%ebp),%edx
801049e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
801049ea:	53                   	push   %ebx
801049eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
801049ee:	89 d7                	mov    %edx,%edi
801049f0:	09 cf                	or     %ecx,%edi
801049f2:	83 e7 03             	and    $0x3,%edi
801049f5:	75 29                	jne    80104a20 <memset+0x40>
    c &= 0xFF;
801049f7:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801049fa:	c1 e0 18             	shl    $0x18,%eax
801049fd:	89 fb                	mov    %edi,%ebx
801049ff:	c1 e9 02             	shr    $0x2,%ecx
80104a02:	c1 e3 10             	shl    $0x10,%ebx
80104a05:	09 d8                	or     %ebx,%eax
80104a07:	09 f8                	or     %edi,%eax
80104a09:	c1 e7 08             	shl    $0x8,%edi
80104a0c:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104a0e:	89 d7                	mov    %edx,%edi
80104a10:	fc                   	cld    
80104a11:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80104a13:	5b                   	pop    %ebx
80104a14:	89 d0                	mov    %edx,%eax
80104a16:	5f                   	pop    %edi
80104a17:	5d                   	pop    %ebp
80104a18:	c3                   	ret    
80104a19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("cld; rep stosb" :
80104a20:	89 d7                	mov    %edx,%edi
80104a22:	fc                   	cld    
80104a23:	f3 aa                	rep stos %al,%es:(%edi)
80104a25:	5b                   	pop    %ebx
80104a26:	89 d0                	mov    %edx,%eax
80104a28:	5f                   	pop    %edi
80104a29:	5d                   	pop    %ebp
80104a2a:	c3                   	ret    
80104a2b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a2f:	90                   	nop

80104a30 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104a30:	55                   	push   %ebp
80104a31:	89 e5                	mov    %esp,%ebp
80104a33:	56                   	push   %esi
80104a34:	8b 75 10             	mov    0x10(%ebp),%esi
80104a37:	8b 55 08             	mov    0x8(%ebp),%edx
80104a3a:	53                   	push   %ebx
80104a3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104a3e:	85 f6                	test   %esi,%esi
80104a40:	74 2e                	je     80104a70 <memcmp+0x40>
80104a42:	01 c6                	add    %eax,%esi
80104a44:	eb 14                	jmp    80104a5a <memcmp+0x2a>
80104a46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a4d:	8d 76 00             	lea    0x0(%esi),%esi
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104a50:	83 c0 01             	add    $0x1,%eax
80104a53:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104a56:	39 f0                	cmp    %esi,%eax
80104a58:	74 16                	je     80104a70 <memcmp+0x40>
    if(*s1 != *s2)
80104a5a:	0f b6 0a             	movzbl (%edx),%ecx
80104a5d:	0f b6 18             	movzbl (%eax),%ebx
80104a60:	38 d9                	cmp    %bl,%cl
80104a62:	74 ec                	je     80104a50 <memcmp+0x20>
      return *s1 - *s2;
80104a64:	0f b6 c1             	movzbl %cl,%eax
80104a67:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104a69:	5b                   	pop    %ebx
80104a6a:	5e                   	pop    %esi
80104a6b:	5d                   	pop    %ebp
80104a6c:	c3                   	ret    
80104a6d:	8d 76 00             	lea    0x0(%esi),%esi
80104a70:	5b                   	pop    %ebx
  return 0;
80104a71:	31 c0                	xor    %eax,%eax
}
80104a73:	5e                   	pop    %esi
80104a74:	5d                   	pop    %ebp
80104a75:	c3                   	ret    
80104a76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a7d:	8d 76 00             	lea    0x0(%esi),%esi

80104a80 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104a80:	55                   	push   %ebp
80104a81:	89 e5                	mov    %esp,%ebp
80104a83:	57                   	push   %edi
80104a84:	8b 55 08             	mov    0x8(%ebp),%edx
80104a87:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104a8a:	56                   	push   %esi
80104a8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104a8e:	39 d6                	cmp    %edx,%esi
80104a90:	73 26                	jae    80104ab8 <memmove+0x38>
80104a92:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
80104a95:	39 fa                	cmp    %edi,%edx
80104a97:	73 1f                	jae    80104ab8 <memmove+0x38>
80104a99:	8d 41 ff             	lea    -0x1(%ecx),%eax
    s += n;
    d += n;
    while(n-- > 0)
80104a9c:	85 c9                	test   %ecx,%ecx
80104a9e:	74 0c                	je     80104aac <memmove+0x2c>
      *--d = *--s;
80104aa0:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
80104aa4:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
80104aa7:	83 e8 01             	sub    $0x1,%eax
80104aaa:	73 f4                	jae    80104aa0 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104aac:	5e                   	pop    %esi
80104aad:	89 d0                	mov    %edx,%eax
80104aaf:	5f                   	pop    %edi
80104ab0:	5d                   	pop    %ebp
80104ab1:	c3                   	ret    
80104ab2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(n-- > 0)
80104ab8:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
80104abb:	89 d7                	mov    %edx,%edi
80104abd:	85 c9                	test   %ecx,%ecx
80104abf:	74 eb                	je     80104aac <memmove+0x2c>
80104ac1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
80104ac8:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
80104ac9:	39 c6                	cmp    %eax,%esi
80104acb:	75 fb                	jne    80104ac8 <memmove+0x48>
}
80104acd:	5e                   	pop    %esi
80104ace:	89 d0                	mov    %edx,%eax
80104ad0:	5f                   	pop    %edi
80104ad1:	5d                   	pop    %ebp
80104ad2:	c3                   	ret    
80104ad3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ada:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104ae0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80104ae0:	eb 9e                	jmp    80104a80 <memmove>
80104ae2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ae9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104af0 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104af0:	55                   	push   %ebp
80104af1:	89 e5                	mov    %esp,%ebp
80104af3:	56                   	push   %esi
80104af4:	8b 75 10             	mov    0x10(%ebp),%esi
80104af7:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104afa:	53                   	push   %ebx
80104afb:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(n > 0 && *p && *p == *q)
80104afe:	85 f6                	test   %esi,%esi
80104b00:	74 2e                	je     80104b30 <strncmp+0x40>
80104b02:	01 d6                	add    %edx,%esi
80104b04:	eb 18                	jmp    80104b1e <strncmp+0x2e>
80104b06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b0d:	8d 76 00             	lea    0x0(%esi),%esi
80104b10:	38 d8                	cmp    %bl,%al
80104b12:	75 14                	jne    80104b28 <strncmp+0x38>
    n--, p++, q++;
80104b14:	83 c2 01             	add    $0x1,%edx
80104b17:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104b1a:	39 f2                	cmp    %esi,%edx
80104b1c:	74 12                	je     80104b30 <strncmp+0x40>
80104b1e:	0f b6 01             	movzbl (%ecx),%eax
80104b21:	0f b6 1a             	movzbl (%edx),%ebx
80104b24:	84 c0                	test   %al,%al
80104b26:	75 e8                	jne    80104b10 <strncmp+0x20>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
80104b28:	29 d8                	sub    %ebx,%eax
}
80104b2a:	5b                   	pop    %ebx
80104b2b:	5e                   	pop    %esi
80104b2c:	5d                   	pop    %ebp
80104b2d:	c3                   	ret    
80104b2e:	66 90                	xchg   %ax,%ax
80104b30:	5b                   	pop    %ebx
    return 0;
80104b31:	31 c0                	xor    %eax,%eax
}
80104b33:	5e                   	pop    %esi
80104b34:	5d                   	pop    %ebp
80104b35:	c3                   	ret    
80104b36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b3d:	8d 76 00             	lea    0x0(%esi),%esi

80104b40 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104b40:	55                   	push   %ebp
80104b41:	89 e5                	mov    %esp,%ebp
80104b43:	57                   	push   %edi
80104b44:	56                   	push   %esi
80104b45:	8b 75 08             	mov    0x8(%ebp),%esi
80104b48:	53                   	push   %ebx
80104b49:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104b4c:	89 f0                	mov    %esi,%eax
80104b4e:	eb 15                	jmp    80104b65 <strncpy+0x25>
80104b50:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104b54:	8b 7d 0c             	mov    0xc(%ebp),%edi
80104b57:	83 c0 01             	add    $0x1,%eax
80104b5a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
80104b5e:	88 50 ff             	mov    %dl,-0x1(%eax)
80104b61:	84 d2                	test   %dl,%dl
80104b63:	74 09                	je     80104b6e <strncpy+0x2e>
80104b65:	89 cb                	mov    %ecx,%ebx
80104b67:	83 e9 01             	sub    $0x1,%ecx
80104b6a:	85 db                	test   %ebx,%ebx
80104b6c:	7f e2                	jg     80104b50 <strncpy+0x10>
    ;
  while(n-- > 0)
80104b6e:	89 c2                	mov    %eax,%edx
80104b70:	85 c9                	test   %ecx,%ecx
80104b72:	7e 17                	jle    80104b8b <strncpy+0x4b>
80104b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104b78:	83 c2 01             	add    $0x1,%edx
80104b7b:	89 c1                	mov    %eax,%ecx
80104b7d:	c6 42 ff 00          	movb   $0x0,-0x1(%edx)
  while(n-- > 0)
80104b81:	29 d1                	sub    %edx,%ecx
80104b83:	8d 4c 0b ff          	lea    -0x1(%ebx,%ecx,1),%ecx
80104b87:	85 c9                	test   %ecx,%ecx
80104b89:	7f ed                	jg     80104b78 <strncpy+0x38>
  return os;
}
80104b8b:	5b                   	pop    %ebx
80104b8c:	89 f0                	mov    %esi,%eax
80104b8e:	5e                   	pop    %esi
80104b8f:	5f                   	pop    %edi
80104b90:	5d                   	pop    %ebp
80104b91:	c3                   	ret    
80104b92:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104ba0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104ba0:	55                   	push   %ebp
80104ba1:	89 e5                	mov    %esp,%ebp
80104ba3:	56                   	push   %esi
80104ba4:	8b 55 10             	mov    0x10(%ebp),%edx
80104ba7:	8b 75 08             	mov    0x8(%ebp),%esi
80104baa:	53                   	push   %ebx
80104bab:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80104bae:	85 d2                	test   %edx,%edx
80104bb0:	7e 25                	jle    80104bd7 <safestrcpy+0x37>
80104bb2:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
80104bb6:	89 f2                	mov    %esi,%edx
80104bb8:	eb 16                	jmp    80104bd0 <safestrcpy+0x30>
80104bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104bc0:	0f b6 08             	movzbl (%eax),%ecx
80104bc3:	83 c0 01             	add    $0x1,%eax
80104bc6:	83 c2 01             	add    $0x1,%edx
80104bc9:	88 4a ff             	mov    %cl,-0x1(%edx)
80104bcc:	84 c9                	test   %cl,%cl
80104bce:	74 04                	je     80104bd4 <safestrcpy+0x34>
80104bd0:	39 d8                	cmp    %ebx,%eax
80104bd2:	75 ec                	jne    80104bc0 <safestrcpy+0x20>
    ;
  *s = 0;
80104bd4:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80104bd7:	89 f0                	mov    %esi,%eax
80104bd9:	5b                   	pop    %ebx
80104bda:	5e                   	pop    %esi
80104bdb:	5d                   	pop    %ebp
80104bdc:	c3                   	ret    
80104bdd:	8d 76 00             	lea    0x0(%esi),%esi

80104be0 <strlen>:

int
strlen(const char *s)
{
80104be0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104be1:	31 c0                	xor    %eax,%eax
{
80104be3:	89 e5                	mov    %esp,%ebp
80104be5:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104be8:	80 3a 00             	cmpb   $0x0,(%edx)
80104beb:	74 0c                	je     80104bf9 <strlen+0x19>
80104bed:	8d 76 00             	lea    0x0(%esi),%esi
80104bf0:	83 c0 01             	add    $0x1,%eax
80104bf3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104bf7:	75 f7                	jne    80104bf0 <strlen+0x10>
    ;
  return n;
}
80104bf9:	5d                   	pop    %ebp
80104bfa:	c3                   	ret    

80104bfb <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104bfb:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104bff:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104c03:	55                   	push   %ebp
  pushl %ebx
80104c04:	53                   	push   %ebx
  pushl %esi
80104c05:	56                   	push   %esi
  pushl %edi
80104c06:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104c07:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104c09:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80104c0b:	5f                   	pop    %edi
  popl %esi
80104c0c:	5e                   	pop    %esi
  popl %ebx
80104c0d:	5b                   	pop    %ebx
  popl %ebp
80104c0e:	5d                   	pop    %ebp
  ret
80104c0f:	c3                   	ret    

80104c10 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104c10:	55                   	push   %ebp
80104c11:	89 e5                	mov    %esp,%ebp
80104c13:	53                   	push   %ebx
80104c14:	83 ec 04             	sub    $0x4,%esp
80104c17:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80104c1a:	e8 11 f0 ff ff       	call   80103c30 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104c1f:	8b 00                	mov    (%eax),%eax
80104c21:	39 d8                	cmp    %ebx,%eax
80104c23:	76 1b                	jbe    80104c40 <fetchint+0x30>
80104c25:	8d 53 04             	lea    0x4(%ebx),%edx
80104c28:	39 d0                	cmp    %edx,%eax
80104c2a:	72 14                	jb     80104c40 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
80104c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c2f:	8b 13                	mov    (%ebx),%edx
80104c31:	89 10                	mov    %edx,(%eax)
  return 0;
80104c33:	31 c0                	xor    %eax,%eax
}
80104c35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c38:	c9                   	leave  
80104c39:	c3                   	ret    
80104c3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80104c40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c45:	eb ee                	jmp    80104c35 <fetchint+0x25>
80104c47:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c4e:	66 90                	xchg   %ax,%ax

80104c50 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104c50:	55                   	push   %ebp
80104c51:	89 e5                	mov    %esp,%ebp
80104c53:	53                   	push   %ebx
80104c54:	83 ec 04             	sub    $0x4,%esp
80104c57:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104c5a:	e8 d1 ef ff ff       	call   80103c30 <myproc>

  if(addr >= curproc->sz)
80104c5f:	39 18                	cmp    %ebx,(%eax)
80104c61:	76 2d                	jbe    80104c90 <fetchstr+0x40>
    return -1;
  *pp = (char*)addr;
80104c63:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c66:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104c68:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104c6a:	39 d3                	cmp    %edx,%ebx
80104c6c:	73 22                	jae    80104c90 <fetchstr+0x40>
80104c6e:	89 d8                	mov    %ebx,%eax
80104c70:	eb 0d                	jmp    80104c7f <fetchstr+0x2f>
80104c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104c78:	83 c0 01             	add    $0x1,%eax
80104c7b:	39 c2                	cmp    %eax,%edx
80104c7d:	76 11                	jbe    80104c90 <fetchstr+0x40>
    if(*s == 0)
80104c7f:	80 38 00             	cmpb   $0x0,(%eax)
80104c82:	75 f4                	jne    80104c78 <fetchstr+0x28>
      return s - *pp;
80104c84:	29 d8                	sub    %ebx,%eax
  }
  return -1;
}
80104c86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c89:	c9                   	leave  
80104c8a:	c3                   	ret    
80104c8b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104c8f:	90                   	nop
80104c90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return -1;
80104c93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c98:	c9                   	leave  
80104c99:	c3                   	ret    
80104c9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104ca0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104ca0:	55                   	push   %ebp
80104ca1:	89 e5                	mov    %esp,%ebp
80104ca3:	56                   	push   %esi
80104ca4:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104ca5:	e8 86 ef ff ff       	call   80103c30 <myproc>
80104caa:	8b 55 08             	mov    0x8(%ebp),%edx
80104cad:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cb0:	8b 40 44             	mov    0x44(%eax),%eax
80104cb3:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104cb6:	e8 75 ef ff ff       	call   80103c30 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104cbb:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104cbe:	8b 00                	mov    (%eax),%eax
80104cc0:	39 c6                	cmp    %eax,%esi
80104cc2:	73 1c                	jae    80104ce0 <argint+0x40>
80104cc4:	8d 53 08             	lea    0x8(%ebx),%edx
80104cc7:	39 d0                	cmp    %edx,%eax
80104cc9:	72 15                	jb     80104ce0 <argint+0x40>
  *ip = *(int*)(addr);
80104ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cce:	8b 53 04             	mov    0x4(%ebx),%edx
80104cd1:	89 10                	mov    %edx,(%eax)
  return 0;
80104cd3:	31 c0                	xor    %eax,%eax
}
80104cd5:	5b                   	pop    %ebx
80104cd6:	5e                   	pop    %esi
80104cd7:	5d                   	pop    %ebp
80104cd8:	c3                   	ret    
80104cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104ce0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104ce5:	eb ee                	jmp    80104cd5 <argint+0x35>
80104ce7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104cee:	66 90                	xchg   %ax,%ax

80104cf0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104cf0:	55                   	push   %ebp
80104cf1:	89 e5                	mov    %esp,%ebp
80104cf3:	57                   	push   %edi
80104cf4:	56                   	push   %esi
80104cf5:	53                   	push   %ebx
80104cf6:	83 ec 0c             	sub    $0xc,%esp
  int i;
  struct proc *curproc = myproc();
80104cf9:	e8 32 ef ff ff       	call   80103c30 <myproc>
80104cfe:	89 c6                	mov    %eax,%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104d00:	e8 2b ef ff ff       	call   80103c30 <myproc>
80104d05:	8b 55 08             	mov    0x8(%ebp),%edx
80104d08:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d0b:	8b 40 44             	mov    0x44(%eax),%eax
80104d0e:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104d11:	e8 1a ef ff ff       	call   80103c30 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104d16:	8d 7b 04             	lea    0x4(%ebx),%edi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104d19:	8b 00                	mov    (%eax),%eax
80104d1b:	39 c7                	cmp    %eax,%edi
80104d1d:	73 31                	jae    80104d50 <argptr+0x60>
80104d1f:	8d 4b 08             	lea    0x8(%ebx),%ecx
80104d22:	39 c8                	cmp    %ecx,%eax
80104d24:	72 2a                	jb     80104d50 <argptr+0x60>
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d26:	8b 55 10             	mov    0x10(%ebp),%edx
  *ip = *(int*)(addr);
80104d29:	8b 43 04             	mov    0x4(%ebx),%eax
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d2c:	85 d2                	test   %edx,%edx
80104d2e:	78 20                	js     80104d50 <argptr+0x60>
80104d30:	8b 16                	mov    (%esi),%edx
80104d32:	39 c2                	cmp    %eax,%edx
80104d34:	76 1a                	jbe    80104d50 <argptr+0x60>
80104d36:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104d39:	01 c3                	add    %eax,%ebx
80104d3b:	39 da                	cmp    %ebx,%edx
80104d3d:	72 11                	jb     80104d50 <argptr+0x60>
    return -1;
  *pp = (char*)i;
80104d3f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d42:	89 02                	mov    %eax,(%edx)
  return 0;
80104d44:	31 c0                	xor    %eax,%eax
}
80104d46:	83 c4 0c             	add    $0xc,%esp
80104d49:	5b                   	pop    %ebx
80104d4a:	5e                   	pop    %esi
80104d4b:	5f                   	pop    %edi
80104d4c:	5d                   	pop    %ebp
80104d4d:	c3                   	ret    
80104d4e:	66 90                	xchg   %ax,%ax
    return -1;
80104d50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d55:	eb ef                	jmp    80104d46 <argptr+0x56>
80104d57:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d5e:	66 90                	xchg   %ax,%ax

80104d60 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104d60:	55                   	push   %ebp
80104d61:	89 e5                	mov    %esp,%ebp
80104d63:	56                   	push   %esi
80104d64:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104d65:	e8 c6 ee ff ff       	call   80103c30 <myproc>
80104d6a:	8b 55 08             	mov    0x8(%ebp),%edx
80104d6d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d70:	8b 40 44             	mov    0x44(%eax),%eax
80104d73:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104d76:	e8 b5 ee ff ff       	call   80103c30 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104d7b:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104d7e:	8b 00                	mov    (%eax),%eax
80104d80:	39 c6                	cmp    %eax,%esi
80104d82:	73 44                	jae    80104dc8 <argstr+0x68>
80104d84:	8d 53 08             	lea    0x8(%ebx),%edx
80104d87:	39 d0                	cmp    %edx,%eax
80104d89:	72 3d                	jb     80104dc8 <argstr+0x68>
  *ip = *(int*)(addr);
80104d8b:	8b 5b 04             	mov    0x4(%ebx),%ebx
  struct proc *curproc = myproc();
80104d8e:	e8 9d ee ff ff       	call   80103c30 <myproc>
  if(addr >= curproc->sz)
80104d93:	3b 18                	cmp    (%eax),%ebx
80104d95:	73 31                	jae    80104dc8 <argstr+0x68>
  *pp = (char*)addr;
80104d97:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d9a:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104d9c:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104d9e:	39 d3                	cmp    %edx,%ebx
80104da0:	73 26                	jae    80104dc8 <argstr+0x68>
80104da2:	89 d8                	mov    %ebx,%eax
80104da4:	eb 11                	jmp    80104db7 <argstr+0x57>
80104da6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104dad:	8d 76 00             	lea    0x0(%esi),%esi
80104db0:	83 c0 01             	add    $0x1,%eax
80104db3:	39 c2                	cmp    %eax,%edx
80104db5:	76 11                	jbe    80104dc8 <argstr+0x68>
    if(*s == 0)
80104db7:	80 38 00             	cmpb   $0x0,(%eax)
80104dba:	75 f4                	jne    80104db0 <argstr+0x50>
      return s - *pp;
80104dbc:	29 d8                	sub    %ebx,%eax
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}
80104dbe:	5b                   	pop    %ebx
80104dbf:	5e                   	pop    %esi
80104dc0:	5d                   	pop    %ebp
80104dc1:	c3                   	ret    
80104dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104dc8:	5b                   	pop    %ebx
    return -1;
80104dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dce:	5e                   	pop    %esi
80104dcf:	5d                   	pop    %ebp
80104dd0:	c3                   	ret    
80104dd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104dd8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ddf:	90                   	nop

80104de0 <syscall>:
[SYS_getNumFreePages]   sys_getNumFreePages,
};

void
syscall(void)
{
80104de0:	55                   	push   %ebp
80104de1:	89 e5                	mov    %esp,%ebp
80104de3:	53                   	push   %ebx
80104de4:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104de7:	e8 44 ee ff ff       	call   80103c30 <myproc>
80104dec:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104dee:	8b 40 1c             	mov    0x1c(%eax),%eax
80104df1:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104df4:	8d 50 ff             	lea    -0x1(%eax),%edx
80104df7:	83 fa 16             	cmp    $0x16,%edx
80104dfa:	77 24                	ja     80104e20 <syscall+0x40>
80104dfc:	8b 14 85 80 7e 10 80 	mov    -0x7fef8180(,%eax,4),%edx
80104e03:	85 d2                	test   %edx,%edx
80104e05:	74 19                	je     80104e20 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
80104e07:	ff d2                	call   *%edx
80104e09:	89 c2                	mov    %eax,%edx
80104e0b:	8b 43 1c             	mov    0x1c(%ebx),%eax
80104e0e:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104e11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e14:	c9                   	leave  
80104e15:	c3                   	ret    
80104e16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104e1d:	8d 76 00             	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
80104e20:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80104e21:	8d 43 70             	lea    0x70(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80104e24:	50                   	push   %eax
80104e25:	ff 73 14             	push   0x14(%ebx)
80104e28:	68 51 7e 10 80       	push   $0x80107e51
80104e2d:	e8 9e b9 ff ff       	call   801007d0 <cprintf>
    curproc->tf->eax = -1;
80104e32:	8b 43 1c             	mov    0x1c(%ebx),%eax
80104e35:	83 c4 10             	add    $0x10,%esp
80104e38:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
80104e3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e42:	c9                   	leave  
80104e43:	c3                   	ret    
80104e44:	66 90                	xchg   %ax,%ax
80104e46:	66 90                	xchg   %ax,%ax
80104e48:	66 90                	xchg   %ax,%ax
80104e4a:	66 90                	xchg   %ax,%ax
80104e4c:	66 90                	xchg   %ax,%ax
80104e4e:	66 90                	xchg   %ax,%ax

80104e50 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104e50:	55                   	push   %ebp
80104e51:	89 e5                	mov    %esp,%ebp
80104e53:	57                   	push   %edi
80104e54:	56                   	push   %esi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104e55:	8d 7d da             	lea    -0x26(%ebp),%edi
{
80104e58:	53                   	push   %ebx
80104e59:	83 ec 34             	sub    $0x34,%esp
80104e5c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104e5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
80104e62:	57                   	push   %edi
80104e63:	50                   	push   %eax
{
80104e64:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104e67:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  if((dp = nameiparent(path, name)) == 0)
80104e6a:	e8 a1 d4 ff ff       	call   80102310 <nameiparent>
80104e6f:	83 c4 10             	add    $0x10,%esp
80104e72:	85 c0                	test   %eax,%eax
80104e74:	0f 84 46 01 00 00    	je     80104fc0 <create+0x170>
    return 0;
  ilock(dp);
80104e7a:	83 ec 0c             	sub    $0xc,%esp
80104e7d:	89 c3                	mov    %eax,%ebx
80104e7f:	50                   	push   %eax
80104e80:	e8 4b cb ff ff       	call   801019d0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104e85:	83 c4 0c             	add    $0xc,%esp
80104e88:	6a 00                	push   $0x0
80104e8a:	57                   	push   %edi
80104e8b:	53                   	push   %ebx
80104e8c:	e8 9f d0 ff ff       	call   80101f30 <dirlookup>
80104e91:	83 c4 10             	add    $0x10,%esp
80104e94:	89 c6                	mov    %eax,%esi
80104e96:	85 c0                	test   %eax,%eax
80104e98:	74 56                	je     80104ef0 <create+0xa0>
    iunlockput(dp);
80104e9a:	83 ec 0c             	sub    $0xc,%esp
80104e9d:	53                   	push   %ebx
80104e9e:	e8 bd cd ff ff       	call   80101c60 <iunlockput>
    ilock(ip);
80104ea3:	89 34 24             	mov    %esi,(%esp)
80104ea6:	e8 25 cb ff ff       	call   801019d0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104eab:	83 c4 10             	add    $0x10,%esp
80104eae:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104eb3:	75 1b                	jne    80104ed0 <create+0x80>
80104eb5:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
80104eba:	75 14                	jne    80104ed0 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104ebc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104ebf:	89 f0                	mov    %esi,%eax
80104ec1:	5b                   	pop    %ebx
80104ec2:	5e                   	pop    %esi
80104ec3:	5f                   	pop    %edi
80104ec4:	5d                   	pop    %ebp
80104ec5:	c3                   	ret    
80104ec6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ecd:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80104ed0:	83 ec 0c             	sub    $0xc,%esp
80104ed3:	56                   	push   %esi
    return 0;
80104ed4:	31 f6                	xor    %esi,%esi
    iunlockput(ip);
80104ed6:	e8 85 cd ff ff       	call   80101c60 <iunlockput>
    return 0;
80104edb:	83 c4 10             	add    $0x10,%esp
}
80104ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104ee1:	89 f0                	mov    %esi,%eax
80104ee3:	5b                   	pop    %ebx
80104ee4:	5e                   	pop    %esi
80104ee5:	5f                   	pop    %edi
80104ee6:	5d                   	pop    %ebp
80104ee7:	c3                   	ret    
80104ee8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104eef:	90                   	nop
  if((ip = ialloc(dp->dev, type)) == 0)
80104ef0:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80104ef4:	83 ec 08             	sub    $0x8,%esp
80104ef7:	50                   	push   %eax
80104ef8:	ff 33                	push   (%ebx)
80104efa:	e8 61 c9 ff ff       	call   80101860 <ialloc>
80104eff:	83 c4 10             	add    $0x10,%esp
80104f02:	89 c6                	mov    %eax,%esi
80104f04:	85 c0                	test   %eax,%eax
80104f06:	0f 84 cd 00 00 00    	je     80104fd9 <create+0x189>
  ilock(ip);
80104f0c:	83 ec 0c             	sub    $0xc,%esp
80104f0f:	50                   	push   %eax
80104f10:	e8 bb ca ff ff       	call   801019d0 <ilock>
  ip->major = major;
80104f15:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104f19:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
80104f1d:	0f b7 45 cc          	movzwl -0x34(%ebp),%eax
80104f21:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80104f25:	b8 01 00 00 00       	mov    $0x1,%eax
80104f2a:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
80104f2e:	89 34 24             	mov    %esi,(%esp)
80104f31:	e8 ea c9 ff ff       	call   80101920 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104f36:	83 c4 10             	add    $0x10,%esp
80104f39:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104f3e:	74 30                	je     80104f70 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80104f40:	83 ec 04             	sub    $0x4,%esp
80104f43:	ff 76 04             	push   0x4(%esi)
80104f46:	57                   	push   %edi
80104f47:	53                   	push   %ebx
80104f48:	e8 e3 d2 ff ff       	call   80102230 <dirlink>
80104f4d:	83 c4 10             	add    $0x10,%esp
80104f50:	85 c0                	test   %eax,%eax
80104f52:	78 78                	js     80104fcc <create+0x17c>
  iunlockput(dp);
80104f54:	83 ec 0c             	sub    $0xc,%esp
80104f57:	53                   	push   %ebx
80104f58:	e8 03 cd ff ff       	call   80101c60 <iunlockput>
  return ip;
80104f5d:	83 c4 10             	add    $0x10,%esp
}
80104f60:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f63:	89 f0                	mov    %esi,%eax
80104f65:	5b                   	pop    %ebx
80104f66:	5e                   	pop    %esi
80104f67:	5f                   	pop    %edi
80104f68:	5d                   	pop    %ebp
80104f69:	c3                   	ret    
80104f6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
80104f70:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
80104f73:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
80104f78:	53                   	push   %ebx
80104f79:	e8 a2 c9 ff ff       	call   80101920 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104f7e:	83 c4 0c             	add    $0xc,%esp
80104f81:	ff 76 04             	push   0x4(%esi)
80104f84:	68 fc 7e 10 80       	push   $0x80107efc
80104f89:	56                   	push   %esi
80104f8a:	e8 a1 d2 ff ff       	call   80102230 <dirlink>
80104f8f:	83 c4 10             	add    $0x10,%esp
80104f92:	85 c0                	test   %eax,%eax
80104f94:	78 18                	js     80104fae <create+0x15e>
80104f96:	83 ec 04             	sub    $0x4,%esp
80104f99:	ff 73 04             	push   0x4(%ebx)
80104f9c:	68 fb 7e 10 80       	push   $0x80107efb
80104fa1:	56                   	push   %esi
80104fa2:	e8 89 d2 ff ff       	call   80102230 <dirlink>
80104fa7:	83 c4 10             	add    $0x10,%esp
80104faa:	85 c0                	test   %eax,%eax
80104fac:	79 92                	jns    80104f40 <create+0xf0>
      panic("create dots");
80104fae:	83 ec 0c             	sub    $0xc,%esp
80104fb1:	68 ef 7e 10 80       	push   $0x80107eef
80104fb6:	e8 f5 b4 ff ff       	call   801004b0 <panic>
80104fbb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104fbf:	90                   	nop
}
80104fc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80104fc3:	31 f6                	xor    %esi,%esi
}
80104fc5:	5b                   	pop    %ebx
80104fc6:	89 f0                	mov    %esi,%eax
80104fc8:	5e                   	pop    %esi
80104fc9:	5f                   	pop    %edi
80104fca:	5d                   	pop    %ebp
80104fcb:	c3                   	ret    
    panic("create: dirlink");
80104fcc:	83 ec 0c             	sub    $0xc,%esp
80104fcf:	68 fe 7e 10 80       	push   $0x80107efe
80104fd4:	e8 d7 b4 ff ff       	call   801004b0 <panic>
    panic("create: ialloc");
80104fd9:	83 ec 0c             	sub    $0xc,%esp
80104fdc:	68 e0 7e 10 80       	push   $0x80107ee0
80104fe1:	e8 ca b4 ff ff       	call   801004b0 <panic>
80104fe6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104fed:	8d 76 00             	lea    0x0(%esi),%esi

80104ff0 <sys_dup>:
{
80104ff0:	55                   	push   %ebp
80104ff1:	89 e5                	mov    %esp,%ebp
80104ff3:	56                   	push   %esi
80104ff4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104ff5:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80104ff8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104ffb:	50                   	push   %eax
80104ffc:	6a 00                	push   $0x0
80104ffe:	e8 9d fc ff ff       	call   80104ca0 <argint>
80105003:	83 c4 10             	add    $0x10,%esp
80105006:	85 c0                	test   %eax,%eax
80105008:	78 36                	js     80105040 <sys_dup+0x50>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010500a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010500e:	77 30                	ja     80105040 <sys_dup+0x50>
80105010:	e8 1b ec ff ff       	call   80103c30 <myproc>
80105015:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105018:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
8010501c:	85 f6                	test   %esi,%esi
8010501e:	74 20                	je     80105040 <sys_dup+0x50>
  struct proc *curproc = myproc();
80105020:	e8 0b ec ff ff       	call   80103c30 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105025:	31 db                	xor    %ebx,%ebx
80105027:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010502e:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80105030:	8b 54 98 2c          	mov    0x2c(%eax,%ebx,4),%edx
80105034:	85 d2                	test   %edx,%edx
80105036:	74 18                	je     80105050 <sys_dup+0x60>
  for(fd = 0; fd < NOFILE; fd++){
80105038:	83 c3 01             	add    $0x1,%ebx
8010503b:	83 fb 10             	cmp    $0x10,%ebx
8010503e:	75 f0                	jne    80105030 <sys_dup+0x40>
}
80105040:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
80105043:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80105048:	89 d8                	mov    %ebx,%eax
8010504a:	5b                   	pop    %ebx
8010504b:	5e                   	pop    %esi
8010504c:	5d                   	pop    %ebp
8010504d:	c3                   	ret    
8010504e:	66 90                	xchg   %ax,%ax
  filedup(f);
80105050:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
80105053:	89 74 98 2c          	mov    %esi,0x2c(%eax,%ebx,4)
  filedup(f);
80105057:	56                   	push   %esi
80105058:	e8 73 bf ff ff       	call   80100fd0 <filedup>
  return fd;
8010505d:	83 c4 10             	add    $0x10,%esp
}
80105060:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105063:	89 d8                	mov    %ebx,%eax
80105065:	5b                   	pop    %ebx
80105066:	5e                   	pop    %esi
80105067:	5d                   	pop    %ebp
80105068:	c3                   	ret    
80105069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105070 <sys_read>:
{
80105070:	55                   	push   %ebp
80105071:	89 e5                	mov    %esp,%ebp
80105073:	56                   	push   %esi
80105074:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105075:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105078:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010507b:	53                   	push   %ebx
8010507c:	6a 00                	push   $0x0
8010507e:	e8 1d fc ff ff       	call   80104ca0 <argint>
80105083:	83 c4 10             	add    $0x10,%esp
80105086:	85 c0                	test   %eax,%eax
80105088:	78 5e                	js     801050e8 <sys_read+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010508a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010508e:	77 58                	ja     801050e8 <sys_read+0x78>
80105090:	e8 9b eb ff ff       	call   80103c30 <myproc>
80105095:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105098:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
8010509c:	85 f6                	test   %esi,%esi
8010509e:	74 48                	je     801050e8 <sys_read+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801050a0:	83 ec 08             	sub    $0x8,%esp
801050a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050a6:	50                   	push   %eax
801050a7:	6a 02                	push   $0x2
801050a9:	e8 f2 fb ff ff       	call   80104ca0 <argint>
801050ae:	83 c4 10             	add    $0x10,%esp
801050b1:	85 c0                	test   %eax,%eax
801050b3:	78 33                	js     801050e8 <sys_read+0x78>
801050b5:	83 ec 04             	sub    $0x4,%esp
801050b8:	ff 75 f0             	push   -0x10(%ebp)
801050bb:	53                   	push   %ebx
801050bc:	6a 01                	push   $0x1
801050be:	e8 2d fc ff ff       	call   80104cf0 <argptr>
801050c3:	83 c4 10             	add    $0x10,%esp
801050c6:	85 c0                	test   %eax,%eax
801050c8:	78 1e                	js     801050e8 <sys_read+0x78>
  return fileread(f, p, n);
801050ca:	83 ec 04             	sub    $0x4,%esp
801050cd:	ff 75 f0             	push   -0x10(%ebp)
801050d0:	ff 75 f4             	push   -0xc(%ebp)
801050d3:	56                   	push   %esi
801050d4:	e8 77 c0 ff ff       	call   80101150 <fileread>
801050d9:	83 c4 10             	add    $0x10,%esp
}
801050dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801050df:	5b                   	pop    %ebx
801050e0:	5e                   	pop    %esi
801050e1:	5d                   	pop    %ebp
801050e2:	c3                   	ret    
801050e3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801050e7:	90                   	nop
    return -1;
801050e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ed:	eb ed                	jmp    801050dc <sys_read+0x6c>
801050ef:	90                   	nop

801050f0 <sys_write>:
{
801050f0:	55                   	push   %ebp
801050f1:	89 e5                	mov    %esp,%ebp
801050f3:	56                   	push   %esi
801050f4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
801050f5:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
801050f8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801050fb:	53                   	push   %ebx
801050fc:	6a 00                	push   $0x0
801050fe:	e8 9d fb ff ff       	call   80104ca0 <argint>
80105103:	83 c4 10             	add    $0x10,%esp
80105106:	85 c0                	test   %eax,%eax
80105108:	78 5e                	js     80105168 <sys_write+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010510a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010510e:	77 58                	ja     80105168 <sys_write+0x78>
80105110:	e8 1b eb ff ff       	call   80103c30 <myproc>
80105115:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105118:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
8010511c:	85 f6                	test   %esi,%esi
8010511e:	74 48                	je     80105168 <sys_write+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105120:	83 ec 08             	sub    $0x8,%esp
80105123:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105126:	50                   	push   %eax
80105127:	6a 02                	push   $0x2
80105129:	e8 72 fb ff ff       	call   80104ca0 <argint>
8010512e:	83 c4 10             	add    $0x10,%esp
80105131:	85 c0                	test   %eax,%eax
80105133:	78 33                	js     80105168 <sys_write+0x78>
80105135:	83 ec 04             	sub    $0x4,%esp
80105138:	ff 75 f0             	push   -0x10(%ebp)
8010513b:	53                   	push   %ebx
8010513c:	6a 01                	push   $0x1
8010513e:	e8 ad fb ff ff       	call   80104cf0 <argptr>
80105143:	83 c4 10             	add    $0x10,%esp
80105146:	85 c0                	test   %eax,%eax
80105148:	78 1e                	js     80105168 <sys_write+0x78>
  return filewrite(f, p, n);
8010514a:	83 ec 04             	sub    $0x4,%esp
8010514d:	ff 75 f0             	push   -0x10(%ebp)
80105150:	ff 75 f4             	push   -0xc(%ebp)
80105153:	56                   	push   %esi
80105154:	e8 87 c0 ff ff       	call   801011e0 <filewrite>
80105159:	83 c4 10             	add    $0x10,%esp
}
8010515c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010515f:	5b                   	pop    %ebx
80105160:	5e                   	pop    %esi
80105161:	5d                   	pop    %ebp
80105162:	c3                   	ret    
80105163:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105167:	90                   	nop
    return -1;
80105168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010516d:	eb ed                	jmp    8010515c <sys_write+0x6c>
8010516f:	90                   	nop

80105170 <sys_close>:
{
80105170:	55                   	push   %ebp
80105171:	89 e5                	mov    %esp,%ebp
80105173:	56                   	push   %esi
80105174:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105175:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105178:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010517b:	50                   	push   %eax
8010517c:	6a 00                	push   $0x0
8010517e:	e8 1d fb ff ff       	call   80104ca0 <argint>
80105183:	83 c4 10             	add    $0x10,%esp
80105186:	85 c0                	test   %eax,%eax
80105188:	78 3e                	js     801051c8 <sys_close+0x58>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010518a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010518e:	77 38                	ja     801051c8 <sys_close+0x58>
80105190:	e8 9b ea ff ff       	call   80103c30 <myproc>
80105195:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105198:	8d 5a 08             	lea    0x8(%edx),%ebx
8010519b:	8b 74 98 0c          	mov    0xc(%eax,%ebx,4),%esi
8010519f:	85 f6                	test   %esi,%esi
801051a1:	74 25                	je     801051c8 <sys_close+0x58>
  myproc()->ofile[fd] = 0;
801051a3:	e8 88 ea ff ff       	call   80103c30 <myproc>
  fileclose(f);
801051a8:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
801051ab:	c7 44 98 0c 00 00 00 	movl   $0x0,0xc(%eax,%ebx,4)
801051b2:	00 
  fileclose(f);
801051b3:	56                   	push   %esi
801051b4:	e8 67 be ff ff       	call   80101020 <fileclose>
  return 0;
801051b9:	83 c4 10             	add    $0x10,%esp
801051bc:	31 c0                	xor    %eax,%eax
}
801051be:	8d 65 f8             	lea    -0x8(%ebp),%esp
801051c1:	5b                   	pop    %ebx
801051c2:	5e                   	pop    %esi
801051c3:	5d                   	pop    %ebp
801051c4:	c3                   	ret    
801051c5:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
801051c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051cd:	eb ef                	jmp    801051be <sys_close+0x4e>
801051cf:	90                   	nop

801051d0 <sys_fstat>:
{
801051d0:	55                   	push   %ebp
801051d1:	89 e5                	mov    %esp,%ebp
801051d3:	56                   	push   %esi
801051d4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
801051d5:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
801051d8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801051db:	53                   	push   %ebx
801051dc:	6a 00                	push   $0x0
801051de:	e8 bd fa ff ff       	call   80104ca0 <argint>
801051e3:	83 c4 10             	add    $0x10,%esp
801051e6:	85 c0                	test   %eax,%eax
801051e8:	78 46                	js     80105230 <sys_fstat+0x60>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801051ea:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801051ee:	77 40                	ja     80105230 <sys_fstat+0x60>
801051f0:	e8 3b ea ff ff       	call   80103c30 <myproc>
801051f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051f8:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
801051fc:	85 f6                	test   %esi,%esi
801051fe:	74 30                	je     80105230 <sys_fstat+0x60>
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105200:	83 ec 04             	sub    $0x4,%esp
80105203:	6a 14                	push   $0x14
80105205:	53                   	push   %ebx
80105206:	6a 01                	push   $0x1
80105208:	e8 e3 fa ff ff       	call   80104cf0 <argptr>
8010520d:	83 c4 10             	add    $0x10,%esp
80105210:	85 c0                	test   %eax,%eax
80105212:	78 1c                	js     80105230 <sys_fstat+0x60>
  return filestat(f, st);
80105214:	83 ec 08             	sub    $0x8,%esp
80105217:	ff 75 f4             	push   -0xc(%ebp)
8010521a:	56                   	push   %esi
8010521b:	e8 e0 be ff ff       	call   80101100 <filestat>
80105220:	83 c4 10             	add    $0x10,%esp
}
80105223:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105226:	5b                   	pop    %ebx
80105227:	5e                   	pop    %esi
80105228:	5d                   	pop    %ebp
80105229:	c3                   	ret    
8010522a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105230:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105235:	eb ec                	jmp    80105223 <sys_fstat+0x53>
80105237:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010523e:	66 90                	xchg   %ax,%ax

80105240 <sys_link>:
{
80105240:	55                   	push   %ebp
80105241:	89 e5                	mov    %esp,%ebp
80105243:	57                   	push   %edi
80105244:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105245:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105248:	53                   	push   %ebx
80105249:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010524c:	50                   	push   %eax
8010524d:	6a 00                	push   $0x0
8010524f:	e8 0c fb ff ff       	call   80104d60 <argstr>
80105254:	83 c4 10             	add    $0x10,%esp
80105257:	85 c0                	test   %eax,%eax
80105259:	0f 88 fb 00 00 00    	js     8010535a <sys_link+0x11a>
8010525f:	83 ec 08             	sub    $0x8,%esp
80105262:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105265:	50                   	push   %eax
80105266:	6a 01                	push   $0x1
80105268:	e8 f3 fa ff ff       	call   80104d60 <argstr>
8010526d:	83 c4 10             	add    $0x10,%esp
80105270:	85 c0                	test   %eax,%eax
80105272:	0f 88 e2 00 00 00    	js     8010535a <sys_link+0x11a>
  begin_op();
80105278:	e8 83 dd ff ff       	call   80103000 <begin_op>
  if((ip = namei(old)) == 0){
8010527d:	83 ec 0c             	sub    $0xc,%esp
80105280:	ff 75 d4             	push   -0x2c(%ebp)
80105283:	e8 68 d0 ff ff       	call   801022f0 <namei>
80105288:	83 c4 10             	add    $0x10,%esp
8010528b:	89 c3                	mov    %eax,%ebx
8010528d:	85 c0                	test   %eax,%eax
8010528f:	0f 84 e4 00 00 00    	je     80105379 <sys_link+0x139>
  ilock(ip);
80105295:	83 ec 0c             	sub    $0xc,%esp
80105298:	50                   	push   %eax
80105299:	e8 32 c7 ff ff       	call   801019d0 <ilock>
  if(ip->type == T_DIR){
8010529e:	83 c4 10             	add    $0x10,%esp
801052a1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801052a6:	0f 84 b5 00 00 00    	je     80105361 <sys_link+0x121>
  iupdate(ip);
801052ac:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
801052af:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
801052b4:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
801052b7:	53                   	push   %ebx
801052b8:	e8 63 c6 ff ff       	call   80101920 <iupdate>
  iunlock(ip);
801052bd:	89 1c 24             	mov    %ebx,(%esp)
801052c0:	e8 eb c7 ff ff       	call   80101ab0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801052c5:	58                   	pop    %eax
801052c6:	5a                   	pop    %edx
801052c7:	57                   	push   %edi
801052c8:	ff 75 d0             	push   -0x30(%ebp)
801052cb:	e8 40 d0 ff ff       	call   80102310 <nameiparent>
801052d0:	83 c4 10             	add    $0x10,%esp
801052d3:	89 c6                	mov    %eax,%esi
801052d5:	85 c0                	test   %eax,%eax
801052d7:	74 5b                	je     80105334 <sys_link+0xf4>
  ilock(dp);
801052d9:	83 ec 0c             	sub    $0xc,%esp
801052dc:	50                   	push   %eax
801052dd:	e8 ee c6 ff ff       	call   801019d0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801052e2:	8b 03                	mov    (%ebx),%eax
801052e4:	83 c4 10             	add    $0x10,%esp
801052e7:	39 06                	cmp    %eax,(%esi)
801052e9:	75 3d                	jne    80105328 <sys_link+0xe8>
801052eb:	83 ec 04             	sub    $0x4,%esp
801052ee:	ff 73 04             	push   0x4(%ebx)
801052f1:	57                   	push   %edi
801052f2:	56                   	push   %esi
801052f3:	e8 38 cf ff ff       	call   80102230 <dirlink>
801052f8:	83 c4 10             	add    $0x10,%esp
801052fb:	85 c0                	test   %eax,%eax
801052fd:	78 29                	js     80105328 <sys_link+0xe8>
  iunlockput(dp);
801052ff:	83 ec 0c             	sub    $0xc,%esp
80105302:	56                   	push   %esi
80105303:	e8 58 c9 ff ff       	call   80101c60 <iunlockput>
  iput(ip);
80105308:	89 1c 24             	mov    %ebx,(%esp)
8010530b:	e8 f0 c7 ff ff       	call   80101b00 <iput>
  end_op();
80105310:	e8 5b dd ff ff       	call   80103070 <end_op>
  return 0;
80105315:	83 c4 10             	add    $0x10,%esp
80105318:	31 c0                	xor    %eax,%eax
}
8010531a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010531d:	5b                   	pop    %ebx
8010531e:	5e                   	pop    %esi
8010531f:	5f                   	pop    %edi
80105320:	5d                   	pop    %ebp
80105321:	c3                   	ret    
80105322:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105328:	83 ec 0c             	sub    $0xc,%esp
8010532b:	56                   	push   %esi
8010532c:	e8 2f c9 ff ff       	call   80101c60 <iunlockput>
    goto bad;
80105331:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105334:	83 ec 0c             	sub    $0xc,%esp
80105337:	53                   	push   %ebx
80105338:	e8 93 c6 ff ff       	call   801019d0 <ilock>
  ip->nlink--;
8010533d:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80105342:	89 1c 24             	mov    %ebx,(%esp)
80105345:	e8 d6 c5 ff ff       	call   80101920 <iupdate>
  iunlockput(ip);
8010534a:	89 1c 24             	mov    %ebx,(%esp)
8010534d:	e8 0e c9 ff ff       	call   80101c60 <iunlockput>
  end_op();
80105352:	e8 19 dd ff ff       	call   80103070 <end_op>
  return -1;
80105357:	83 c4 10             	add    $0x10,%esp
8010535a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010535f:	eb b9                	jmp    8010531a <sys_link+0xda>
    iunlockput(ip);
80105361:	83 ec 0c             	sub    $0xc,%esp
80105364:	53                   	push   %ebx
80105365:	e8 f6 c8 ff ff       	call   80101c60 <iunlockput>
    end_op();
8010536a:	e8 01 dd ff ff       	call   80103070 <end_op>
    return -1;
8010536f:	83 c4 10             	add    $0x10,%esp
80105372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105377:	eb a1                	jmp    8010531a <sys_link+0xda>
    end_op();
80105379:	e8 f2 dc ff ff       	call   80103070 <end_op>
    return -1;
8010537e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105383:	eb 95                	jmp    8010531a <sys_link+0xda>
80105385:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010538c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105390 <sys_unlink>:
{
80105390:	55                   	push   %ebp
80105391:	89 e5                	mov    %esp,%ebp
80105393:	57                   	push   %edi
80105394:	56                   	push   %esi
  if(argstr(0, &path) < 0)
80105395:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
80105398:	53                   	push   %ebx
80105399:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
8010539c:	50                   	push   %eax
8010539d:	6a 00                	push   $0x0
8010539f:	e8 bc f9 ff ff       	call   80104d60 <argstr>
801053a4:	83 c4 10             	add    $0x10,%esp
801053a7:	85 c0                	test   %eax,%eax
801053a9:	0f 88 7a 01 00 00    	js     80105529 <sys_unlink+0x199>
  begin_op();
801053af:	e8 4c dc ff ff       	call   80103000 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801053b4:	8d 5d ca             	lea    -0x36(%ebp),%ebx
801053b7:	83 ec 08             	sub    $0x8,%esp
801053ba:	53                   	push   %ebx
801053bb:	ff 75 c0             	push   -0x40(%ebp)
801053be:	e8 4d cf ff ff       	call   80102310 <nameiparent>
801053c3:	83 c4 10             	add    $0x10,%esp
801053c6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
801053c9:	85 c0                	test   %eax,%eax
801053cb:	0f 84 62 01 00 00    	je     80105533 <sys_unlink+0x1a3>
  ilock(dp);
801053d1:	8b 7d b4             	mov    -0x4c(%ebp),%edi
801053d4:	83 ec 0c             	sub    $0xc,%esp
801053d7:	57                   	push   %edi
801053d8:	e8 f3 c5 ff ff       	call   801019d0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801053dd:	58                   	pop    %eax
801053de:	5a                   	pop    %edx
801053df:	68 fc 7e 10 80       	push   $0x80107efc
801053e4:	53                   	push   %ebx
801053e5:	e8 26 cb ff ff       	call   80101f10 <namecmp>
801053ea:	83 c4 10             	add    $0x10,%esp
801053ed:	85 c0                	test   %eax,%eax
801053ef:	0f 84 fb 00 00 00    	je     801054f0 <sys_unlink+0x160>
801053f5:	83 ec 08             	sub    $0x8,%esp
801053f8:	68 fb 7e 10 80       	push   $0x80107efb
801053fd:	53                   	push   %ebx
801053fe:	e8 0d cb ff ff       	call   80101f10 <namecmp>
80105403:	83 c4 10             	add    $0x10,%esp
80105406:	85 c0                	test   %eax,%eax
80105408:	0f 84 e2 00 00 00    	je     801054f0 <sys_unlink+0x160>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010540e:	83 ec 04             	sub    $0x4,%esp
80105411:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105414:	50                   	push   %eax
80105415:	53                   	push   %ebx
80105416:	57                   	push   %edi
80105417:	e8 14 cb ff ff       	call   80101f30 <dirlookup>
8010541c:	83 c4 10             	add    $0x10,%esp
8010541f:	89 c3                	mov    %eax,%ebx
80105421:	85 c0                	test   %eax,%eax
80105423:	0f 84 c7 00 00 00    	je     801054f0 <sys_unlink+0x160>
  ilock(ip);
80105429:	83 ec 0c             	sub    $0xc,%esp
8010542c:	50                   	push   %eax
8010542d:	e8 9e c5 ff ff       	call   801019d0 <ilock>
  if(ip->nlink < 1)
80105432:	83 c4 10             	add    $0x10,%esp
80105435:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010543a:	0f 8e 1c 01 00 00    	jle    8010555c <sys_unlink+0x1cc>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105440:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105445:	8d 7d d8             	lea    -0x28(%ebp),%edi
80105448:	74 66                	je     801054b0 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
8010544a:	83 ec 04             	sub    $0x4,%esp
8010544d:	6a 10                	push   $0x10
8010544f:	6a 00                	push   $0x0
80105451:	57                   	push   %edi
80105452:	e8 89 f5 ff ff       	call   801049e0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105457:	6a 10                	push   $0x10
80105459:	ff 75 c4             	push   -0x3c(%ebp)
8010545c:	57                   	push   %edi
8010545d:	ff 75 b4             	push   -0x4c(%ebp)
80105460:	e8 7b c9 ff ff       	call   80101de0 <writei>
80105465:	83 c4 20             	add    $0x20,%esp
80105468:	83 f8 10             	cmp    $0x10,%eax
8010546b:	0f 85 de 00 00 00    	jne    8010554f <sys_unlink+0x1bf>
  if(ip->type == T_DIR){
80105471:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105476:	0f 84 94 00 00 00    	je     80105510 <sys_unlink+0x180>
  iunlockput(dp);
8010547c:	83 ec 0c             	sub    $0xc,%esp
8010547f:	ff 75 b4             	push   -0x4c(%ebp)
80105482:	e8 d9 c7 ff ff       	call   80101c60 <iunlockput>
  ip->nlink--;
80105487:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
8010548c:	89 1c 24             	mov    %ebx,(%esp)
8010548f:	e8 8c c4 ff ff       	call   80101920 <iupdate>
  iunlockput(ip);
80105494:	89 1c 24             	mov    %ebx,(%esp)
80105497:	e8 c4 c7 ff ff       	call   80101c60 <iunlockput>
  end_op();
8010549c:	e8 cf db ff ff       	call   80103070 <end_op>
  return 0;
801054a1:	83 c4 10             	add    $0x10,%esp
801054a4:	31 c0                	xor    %eax,%eax
}
801054a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801054a9:	5b                   	pop    %ebx
801054aa:	5e                   	pop    %esi
801054ab:	5f                   	pop    %edi
801054ac:	5d                   	pop    %ebp
801054ad:	c3                   	ret    
801054ae:	66 90                	xchg   %ax,%ax
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801054b0:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
801054b4:	76 94                	jbe    8010544a <sys_unlink+0xba>
801054b6:	be 20 00 00 00       	mov    $0x20,%esi
801054bb:	eb 0b                	jmp    801054c8 <sys_unlink+0x138>
801054bd:	8d 76 00             	lea    0x0(%esi),%esi
801054c0:	83 c6 10             	add    $0x10,%esi
801054c3:	3b 73 58             	cmp    0x58(%ebx),%esi
801054c6:	73 82                	jae    8010544a <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801054c8:	6a 10                	push   $0x10
801054ca:	56                   	push   %esi
801054cb:	57                   	push   %edi
801054cc:	53                   	push   %ebx
801054cd:	e8 0e c8 ff ff       	call   80101ce0 <readi>
801054d2:	83 c4 10             	add    $0x10,%esp
801054d5:	83 f8 10             	cmp    $0x10,%eax
801054d8:	75 68                	jne    80105542 <sys_unlink+0x1b2>
    if(de.inum != 0)
801054da:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801054df:	74 df                	je     801054c0 <sys_unlink+0x130>
    iunlockput(ip);
801054e1:	83 ec 0c             	sub    $0xc,%esp
801054e4:	53                   	push   %ebx
801054e5:	e8 76 c7 ff ff       	call   80101c60 <iunlockput>
    goto bad;
801054ea:	83 c4 10             	add    $0x10,%esp
801054ed:	8d 76 00             	lea    0x0(%esi),%esi
  iunlockput(dp);
801054f0:	83 ec 0c             	sub    $0xc,%esp
801054f3:	ff 75 b4             	push   -0x4c(%ebp)
801054f6:	e8 65 c7 ff ff       	call   80101c60 <iunlockput>
  end_op();
801054fb:	e8 70 db ff ff       	call   80103070 <end_op>
  return -1;
80105500:	83 c4 10             	add    $0x10,%esp
80105503:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105508:	eb 9c                	jmp    801054a6 <sys_unlink+0x116>
8010550a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    dp->nlink--;
80105510:	8b 45 b4             	mov    -0x4c(%ebp),%eax
    iupdate(dp);
80105513:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
80105516:	66 83 68 56 01       	subw   $0x1,0x56(%eax)
    iupdate(dp);
8010551b:	50                   	push   %eax
8010551c:	e8 ff c3 ff ff       	call   80101920 <iupdate>
80105521:	83 c4 10             	add    $0x10,%esp
80105524:	e9 53 ff ff ff       	jmp    8010547c <sys_unlink+0xec>
    return -1;
80105529:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010552e:	e9 73 ff ff ff       	jmp    801054a6 <sys_unlink+0x116>
    end_op();
80105533:	e8 38 db ff ff       	call   80103070 <end_op>
    return -1;
80105538:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010553d:	e9 64 ff ff ff       	jmp    801054a6 <sys_unlink+0x116>
      panic("isdirempty: readi");
80105542:	83 ec 0c             	sub    $0xc,%esp
80105545:	68 20 7f 10 80       	push   $0x80107f20
8010554a:	e8 61 af ff ff       	call   801004b0 <panic>
    panic("unlink: writei");
8010554f:	83 ec 0c             	sub    $0xc,%esp
80105552:	68 32 7f 10 80       	push   $0x80107f32
80105557:	e8 54 af ff ff       	call   801004b0 <panic>
    panic("unlink: nlink < 1");
8010555c:	83 ec 0c             	sub    $0xc,%esp
8010555f:	68 0e 7f 10 80       	push   $0x80107f0e
80105564:	e8 47 af ff ff       	call   801004b0 <panic>
80105569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105570 <sys_open>:

int
sys_open(void)
{
80105570:	55                   	push   %ebp
80105571:	89 e5                	mov    %esp,%ebp
80105573:	57                   	push   %edi
80105574:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105575:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
80105578:	53                   	push   %ebx
80105579:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010557c:	50                   	push   %eax
8010557d:	6a 00                	push   $0x0
8010557f:	e8 dc f7 ff ff       	call   80104d60 <argstr>
80105584:	83 c4 10             	add    $0x10,%esp
80105587:	85 c0                	test   %eax,%eax
80105589:	0f 88 8e 00 00 00    	js     8010561d <sys_open+0xad>
8010558f:	83 ec 08             	sub    $0x8,%esp
80105592:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105595:	50                   	push   %eax
80105596:	6a 01                	push   $0x1
80105598:	e8 03 f7 ff ff       	call   80104ca0 <argint>
8010559d:	83 c4 10             	add    $0x10,%esp
801055a0:	85 c0                	test   %eax,%eax
801055a2:	78 79                	js     8010561d <sys_open+0xad>
    return -1;

  begin_op();
801055a4:	e8 57 da ff ff       	call   80103000 <begin_op>

  if(omode & O_CREATE){
801055a9:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
801055ad:	75 79                	jne    80105628 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
801055af:	83 ec 0c             	sub    $0xc,%esp
801055b2:	ff 75 e0             	push   -0x20(%ebp)
801055b5:	e8 36 cd ff ff       	call   801022f0 <namei>
801055ba:	83 c4 10             	add    $0x10,%esp
801055bd:	89 c6                	mov    %eax,%esi
801055bf:	85 c0                	test   %eax,%eax
801055c1:	0f 84 7e 00 00 00    	je     80105645 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
801055c7:	83 ec 0c             	sub    $0xc,%esp
801055ca:	50                   	push   %eax
801055cb:	e8 00 c4 ff ff       	call   801019d0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801055d0:	83 c4 10             	add    $0x10,%esp
801055d3:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801055d8:	0f 84 c2 00 00 00    	je     801056a0 <sys_open+0x130>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801055de:	e8 7d b9 ff ff       	call   80100f60 <filealloc>
801055e3:	89 c7                	mov    %eax,%edi
801055e5:	85 c0                	test   %eax,%eax
801055e7:	74 23                	je     8010560c <sys_open+0x9c>
  struct proc *curproc = myproc();
801055e9:	e8 42 e6 ff ff       	call   80103c30 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801055ee:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
801055f0:	8b 54 98 2c          	mov    0x2c(%eax,%ebx,4),%edx
801055f4:	85 d2                	test   %edx,%edx
801055f6:	74 60                	je     80105658 <sys_open+0xe8>
  for(fd = 0; fd < NOFILE; fd++){
801055f8:	83 c3 01             	add    $0x1,%ebx
801055fb:	83 fb 10             	cmp    $0x10,%ebx
801055fe:	75 f0                	jne    801055f0 <sys_open+0x80>
    if(f)
      fileclose(f);
80105600:	83 ec 0c             	sub    $0xc,%esp
80105603:	57                   	push   %edi
80105604:	e8 17 ba ff ff       	call   80101020 <fileclose>
80105609:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010560c:	83 ec 0c             	sub    $0xc,%esp
8010560f:	56                   	push   %esi
80105610:	e8 4b c6 ff ff       	call   80101c60 <iunlockput>
    end_op();
80105615:	e8 56 da ff ff       	call   80103070 <end_op>
    return -1;
8010561a:	83 c4 10             	add    $0x10,%esp
8010561d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105622:	eb 6d                	jmp    80105691 <sys_open+0x121>
80105624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
80105628:	83 ec 0c             	sub    $0xc,%esp
8010562b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010562e:	31 c9                	xor    %ecx,%ecx
80105630:	ba 02 00 00 00       	mov    $0x2,%edx
80105635:	6a 00                	push   $0x0
80105637:	e8 14 f8 ff ff       	call   80104e50 <create>
    if(ip == 0){
8010563c:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
8010563f:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80105641:	85 c0                	test   %eax,%eax
80105643:	75 99                	jne    801055de <sys_open+0x6e>
      end_op();
80105645:	e8 26 da ff ff       	call   80103070 <end_op>
      return -1;
8010564a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010564f:	eb 40                	jmp    80105691 <sys_open+0x121>
80105651:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
80105658:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
8010565b:	89 7c 98 2c          	mov    %edi,0x2c(%eax,%ebx,4)
  iunlock(ip);
8010565f:	56                   	push   %esi
80105660:	e8 4b c4 ff ff       	call   80101ab0 <iunlock>
  end_op();
80105665:	e8 06 da ff ff       	call   80103070 <end_op>

  f->type = FD_INODE;
8010566a:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
80105670:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105673:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105676:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
80105679:	89 d0                	mov    %edx,%eax
  f->off = 0;
8010567b:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
80105682:	f7 d0                	not    %eax
80105684:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105687:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
8010568a:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010568d:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
80105691:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105694:	89 d8                	mov    %ebx,%eax
80105696:	5b                   	pop    %ebx
80105697:	5e                   	pop    %esi
80105698:	5f                   	pop    %edi
80105699:	5d                   	pop    %ebp
8010569a:	c3                   	ret    
8010569b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010569f:	90                   	nop
    if(ip->type == T_DIR && omode != O_RDONLY){
801056a0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801056a3:	85 c9                	test   %ecx,%ecx
801056a5:	0f 84 33 ff ff ff    	je     801055de <sys_open+0x6e>
801056ab:	e9 5c ff ff ff       	jmp    8010560c <sys_open+0x9c>

801056b0 <sys_mkdir>:

int
sys_mkdir(void)
{
801056b0:	55                   	push   %ebp
801056b1:	89 e5                	mov    %esp,%ebp
801056b3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801056b6:	e8 45 d9 ff ff       	call   80103000 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801056bb:	83 ec 08             	sub    $0x8,%esp
801056be:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056c1:	50                   	push   %eax
801056c2:	6a 00                	push   $0x0
801056c4:	e8 97 f6 ff ff       	call   80104d60 <argstr>
801056c9:	83 c4 10             	add    $0x10,%esp
801056cc:	85 c0                	test   %eax,%eax
801056ce:	78 30                	js     80105700 <sys_mkdir+0x50>
801056d0:	83 ec 0c             	sub    $0xc,%esp
801056d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d6:	31 c9                	xor    %ecx,%ecx
801056d8:	ba 01 00 00 00       	mov    $0x1,%edx
801056dd:	6a 00                	push   $0x0
801056df:	e8 6c f7 ff ff       	call   80104e50 <create>
801056e4:	83 c4 10             	add    $0x10,%esp
801056e7:	85 c0                	test   %eax,%eax
801056e9:	74 15                	je     80105700 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
801056eb:	83 ec 0c             	sub    $0xc,%esp
801056ee:	50                   	push   %eax
801056ef:	e8 6c c5 ff ff       	call   80101c60 <iunlockput>
  end_op();
801056f4:	e8 77 d9 ff ff       	call   80103070 <end_op>
  return 0;
801056f9:	83 c4 10             	add    $0x10,%esp
801056fc:	31 c0                	xor    %eax,%eax
}
801056fe:	c9                   	leave  
801056ff:	c3                   	ret    
    end_op();
80105700:	e8 6b d9 ff ff       	call   80103070 <end_op>
    return -1;
80105705:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010570a:	c9                   	leave  
8010570b:	c3                   	ret    
8010570c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105710 <sys_mknod>:

int
sys_mknod(void)
{
80105710:	55                   	push   %ebp
80105711:	89 e5                	mov    %esp,%ebp
80105713:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105716:	e8 e5 d8 ff ff       	call   80103000 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010571b:	83 ec 08             	sub    $0x8,%esp
8010571e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105721:	50                   	push   %eax
80105722:	6a 00                	push   $0x0
80105724:	e8 37 f6 ff ff       	call   80104d60 <argstr>
80105729:	83 c4 10             	add    $0x10,%esp
8010572c:	85 c0                	test   %eax,%eax
8010572e:	78 60                	js     80105790 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105730:	83 ec 08             	sub    $0x8,%esp
80105733:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105736:	50                   	push   %eax
80105737:	6a 01                	push   $0x1
80105739:	e8 62 f5 ff ff       	call   80104ca0 <argint>
  if((argstr(0, &path)) < 0 ||
8010573e:	83 c4 10             	add    $0x10,%esp
80105741:	85 c0                	test   %eax,%eax
80105743:	78 4b                	js     80105790 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105745:	83 ec 08             	sub    $0x8,%esp
80105748:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010574b:	50                   	push   %eax
8010574c:	6a 02                	push   $0x2
8010574e:	e8 4d f5 ff ff       	call   80104ca0 <argint>
     argint(1, &major) < 0 ||
80105753:	83 c4 10             	add    $0x10,%esp
80105756:	85 c0                	test   %eax,%eax
80105758:	78 36                	js     80105790 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010575a:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
8010575e:	83 ec 0c             	sub    $0xc,%esp
80105761:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80105765:	ba 03 00 00 00       	mov    $0x3,%edx
8010576a:	50                   	push   %eax
8010576b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010576e:	e8 dd f6 ff ff       	call   80104e50 <create>
     argint(2, &minor) < 0 ||
80105773:	83 c4 10             	add    $0x10,%esp
80105776:	85 c0                	test   %eax,%eax
80105778:	74 16                	je     80105790 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010577a:	83 ec 0c             	sub    $0xc,%esp
8010577d:	50                   	push   %eax
8010577e:	e8 dd c4 ff ff       	call   80101c60 <iunlockput>
  end_op();
80105783:	e8 e8 d8 ff ff       	call   80103070 <end_op>
  return 0;
80105788:	83 c4 10             	add    $0x10,%esp
8010578b:	31 c0                	xor    %eax,%eax
}
8010578d:	c9                   	leave  
8010578e:	c3                   	ret    
8010578f:	90                   	nop
    end_op();
80105790:	e8 db d8 ff ff       	call   80103070 <end_op>
    return -1;
80105795:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010579a:	c9                   	leave  
8010579b:	c3                   	ret    
8010579c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801057a0 <sys_chdir>:

int
sys_chdir(void)
{
801057a0:	55                   	push   %ebp
801057a1:	89 e5                	mov    %esp,%ebp
801057a3:	56                   	push   %esi
801057a4:	53                   	push   %ebx
801057a5:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801057a8:	e8 83 e4 ff ff       	call   80103c30 <myproc>
801057ad:	89 c6                	mov    %eax,%esi
  
  begin_op();
801057af:	e8 4c d8 ff ff       	call   80103000 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801057b4:	83 ec 08             	sub    $0x8,%esp
801057b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057ba:	50                   	push   %eax
801057bb:	6a 00                	push   $0x0
801057bd:	e8 9e f5 ff ff       	call   80104d60 <argstr>
801057c2:	83 c4 10             	add    $0x10,%esp
801057c5:	85 c0                	test   %eax,%eax
801057c7:	78 77                	js     80105840 <sys_chdir+0xa0>
801057c9:	83 ec 0c             	sub    $0xc,%esp
801057cc:	ff 75 f4             	push   -0xc(%ebp)
801057cf:	e8 1c cb ff ff       	call   801022f0 <namei>
801057d4:	83 c4 10             	add    $0x10,%esp
801057d7:	89 c3                	mov    %eax,%ebx
801057d9:	85 c0                	test   %eax,%eax
801057db:	74 63                	je     80105840 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
801057dd:	83 ec 0c             	sub    $0xc,%esp
801057e0:	50                   	push   %eax
801057e1:	e8 ea c1 ff ff       	call   801019d0 <ilock>
  if(ip->type != T_DIR){
801057e6:	83 c4 10             	add    $0x10,%esp
801057e9:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801057ee:	75 30                	jne    80105820 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801057f0:	83 ec 0c             	sub    $0xc,%esp
801057f3:	53                   	push   %ebx
801057f4:	e8 b7 c2 ff ff       	call   80101ab0 <iunlock>
  iput(curproc->cwd);
801057f9:	58                   	pop    %eax
801057fa:	ff 76 6c             	push   0x6c(%esi)
801057fd:	e8 fe c2 ff ff       	call   80101b00 <iput>
  end_op();
80105802:	e8 69 d8 ff ff       	call   80103070 <end_op>
  curproc->cwd = ip;
80105807:	89 5e 6c             	mov    %ebx,0x6c(%esi)
  return 0;
8010580a:	83 c4 10             	add    $0x10,%esp
8010580d:	31 c0                	xor    %eax,%eax
}
8010580f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105812:	5b                   	pop    %ebx
80105813:	5e                   	pop    %esi
80105814:	5d                   	pop    %ebp
80105815:	c3                   	ret    
80105816:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010581d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80105820:	83 ec 0c             	sub    $0xc,%esp
80105823:	53                   	push   %ebx
80105824:	e8 37 c4 ff ff       	call   80101c60 <iunlockput>
    end_op();
80105829:	e8 42 d8 ff ff       	call   80103070 <end_op>
    return -1;
8010582e:	83 c4 10             	add    $0x10,%esp
80105831:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105836:	eb d7                	jmp    8010580f <sys_chdir+0x6f>
80105838:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010583f:	90                   	nop
    end_op();
80105840:	e8 2b d8 ff ff       	call   80103070 <end_op>
    return -1;
80105845:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010584a:	eb c3                	jmp    8010580f <sys_chdir+0x6f>
8010584c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105850 <sys_exec>:

int
sys_exec(void)
{
80105850:	55                   	push   %ebp
80105851:	89 e5                	mov    %esp,%ebp
80105853:	57                   	push   %edi
80105854:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105855:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
8010585b:	53                   	push   %ebx
8010585c:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105862:	50                   	push   %eax
80105863:	6a 00                	push   $0x0
80105865:	e8 f6 f4 ff ff       	call   80104d60 <argstr>
8010586a:	83 c4 10             	add    $0x10,%esp
8010586d:	85 c0                	test   %eax,%eax
8010586f:	0f 88 87 00 00 00    	js     801058fc <sys_exec+0xac>
80105875:	83 ec 08             	sub    $0x8,%esp
80105878:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
8010587e:	50                   	push   %eax
8010587f:	6a 01                	push   $0x1
80105881:	e8 1a f4 ff ff       	call   80104ca0 <argint>
80105886:	83 c4 10             	add    $0x10,%esp
80105889:	85 c0                	test   %eax,%eax
8010588b:	78 6f                	js     801058fc <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
8010588d:	83 ec 04             	sub    $0x4,%esp
80105890:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  for(i=0;; i++){
80105896:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105898:	68 80 00 00 00       	push   $0x80
8010589d:	6a 00                	push   $0x0
8010589f:	56                   	push   %esi
801058a0:	e8 3b f1 ff ff       	call   801049e0 <memset>
801058a5:	83 c4 10             	add    $0x10,%esp
801058a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801058af:	90                   	nop
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801058b0:	83 ec 08             	sub    $0x8,%esp
801058b3:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
801058b9:	8d 3c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edi
801058c0:	50                   	push   %eax
801058c1:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
801058c7:	01 f8                	add    %edi,%eax
801058c9:	50                   	push   %eax
801058ca:	e8 41 f3 ff ff       	call   80104c10 <fetchint>
801058cf:	83 c4 10             	add    $0x10,%esp
801058d2:	85 c0                	test   %eax,%eax
801058d4:	78 26                	js     801058fc <sys_exec+0xac>
      return -1;
    if(uarg == 0){
801058d6:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
801058dc:	85 c0                	test   %eax,%eax
801058de:	74 30                	je     80105910 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801058e0:	83 ec 08             	sub    $0x8,%esp
801058e3:	8d 14 3e             	lea    (%esi,%edi,1),%edx
801058e6:	52                   	push   %edx
801058e7:	50                   	push   %eax
801058e8:	e8 63 f3 ff ff       	call   80104c50 <fetchstr>
801058ed:	83 c4 10             	add    $0x10,%esp
801058f0:	85 c0                	test   %eax,%eax
801058f2:	78 08                	js     801058fc <sys_exec+0xac>
  for(i=0;; i++){
801058f4:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
801058f7:	83 fb 20             	cmp    $0x20,%ebx
801058fa:	75 b4                	jne    801058b0 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
801058fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
801058ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105904:	5b                   	pop    %ebx
80105905:	5e                   	pop    %esi
80105906:	5f                   	pop    %edi
80105907:	5d                   	pop    %ebp
80105908:	c3                   	ret    
80105909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      argv[i] = 0;
80105910:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105917:	00 00 00 00 
  return exec(path, argv);
8010591b:	83 ec 08             	sub    $0x8,%esp
8010591e:	56                   	push   %esi
8010591f:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
80105925:	e8 b6 b2 ff ff       	call   80100be0 <exec>
8010592a:	83 c4 10             	add    $0x10,%esp
}
8010592d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105930:	5b                   	pop    %ebx
80105931:	5e                   	pop    %esi
80105932:	5f                   	pop    %edi
80105933:	5d                   	pop    %ebp
80105934:	c3                   	ret    
80105935:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010593c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105940 <sys_pipe>:

int
sys_pipe(void)
{
80105940:	55                   	push   %ebp
80105941:	89 e5                	mov    %esp,%ebp
80105943:	57                   	push   %edi
80105944:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105945:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105948:	53                   	push   %ebx
80105949:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010594c:	6a 08                	push   $0x8
8010594e:	50                   	push   %eax
8010594f:	6a 00                	push   $0x0
80105951:	e8 9a f3 ff ff       	call   80104cf0 <argptr>
80105956:	83 c4 10             	add    $0x10,%esp
80105959:	85 c0                	test   %eax,%eax
8010595b:	78 4a                	js     801059a7 <sys_pipe+0x67>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
8010595d:	83 ec 08             	sub    $0x8,%esp
80105960:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105963:	50                   	push   %eax
80105964:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105967:	50                   	push   %eax
80105968:	e8 83 dd ff ff       	call   801036f0 <pipealloc>
8010596d:	83 c4 10             	add    $0x10,%esp
80105970:	85 c0                	test   %eax,%eax
80105972:	78 33                	js     801059a7 <sys_pipe+0x67>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105974:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105977:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
80105979:	e8 b2 e2 ff ff       	call   80103c30 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010597e:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80105980:	8b 74 98 2c          	mov    0x2c(%eax,%ebx,4),%esi
80105984:	85 f6                	test   %esi,%esi
80105986:	74 28                	je     801059b0 <sys_pipe+0x70>
  for(fd = 0; fd < NOFILE; fd++){
80105988:	83 c3 01             	add    $0x1,%ebx
8010598b:	83 fb 10             	cmp    $0x10,%ebx
8010598e:	75 f0                	jne    80105980 <sys_pipe+0x40>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
80105990:	83 ec 0c             	sub    $0xc,%esp
80105993:	ff 75 e0             	push   -0x20(%ebp)
80105996:	e8 85 b6 ff ff       	call   80101020 <fileclose>
    fileclose(wf);
8010599b:	58                   	pop    %eax
8010599c:	ff 75 e4             	push   -0x1c(%ebp)
8010599f:	e8 7c b6 ff ff       	call   80101020 <fileclose>
    return -1;
801059a4:	83 c4 10             	add    $0x10,%esp
801059a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ac:	eb 53                	jmp    80105a01 <sys_pipe+0xc1>
801059ae:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
801059b0:	8d 73 08             	lea    0x8(%ebx),%esi
801059b3:	89 7c b0 0c          	mov    %edi,0xc(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801059b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
801059ba:	e8 71 e2 ff ff       	call   80103c30 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801059bf:	31 d2                	xor    %edx,%edx
801059c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
801059c8:	8b 4c 90 2c          	mov    0x2c(%eax,%edx,4),%ecx
801059cc:	85 c9                	test   %ecx,%ecx
801059ce:	74 20                	je     801059f0 <sys_pipe+0xb0>
  for(fd = 0; fd < NOFILE; fd++){
801059d0:	83 c2 01             	add    $0x1,%edx
801059d3:	83 fa 10             	cmp    $0x10,%edx
801059d6:	75 f0                	jne    801059c8 <sys_pipe+0x88>
      myproc()->ofile[fd0] = 0;
801059d8:	e8 53 e2 ff ff       	call   80103c30 <myproc>
801059dd:	c7 44 b0 0c 00 00 00 	movl   $0x0,0xc(%eax,%esi,4)
801059e4:	00 
801059e5:	eb a9                	jmp    80105990 <sys_pipe+0x50>
801059e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801059ee:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
801059f0:	89 7c 90 2c          	mov    %edi,0x2c(%eax,%edx,4)
  }
  fd[0] = fd0;
801059f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801059f7:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
801059f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801059fc:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
801059ff:	31 c0                	xor    %eax,%eax
}
80105a01:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105a04:	5b                   	pop    %ebx
80105a05:	5e                   	pop    %esi
80105a06:	5f                   	pop    %edi
80105a07:	5d                   	pop    %ebp
80105a08:	c3                   	ret    
80105a09:	66 90                	xchg   %ax,%ax
80105a0b:	66 90                	xchg   %ax,%ax
80105a0d:	66 90                	xchg   %ax,%ax
80105a0f:	90                   	nop

80105a10 <sys_getNumFreePages>:


int
sys_getNumFreePages(void)
{
  return num_of_FreePages();  
80105a10:	e9 4b cf ff ff       	jmp    80102960 <num_of_FreePages>
80105a15:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a20 <sys_getrss>:
}

int 
sys_getrss()
{
80105a20:	55                   	push   %ebp
80105a21:	89 e5                	mov    %esp,%ebp
80105a23:	83 ec 08             	sub    $0x8,%esp
  print_rss();
80105a26:	e8 c5 e4 ff ff       	call   80103ef0 <print_rss>
  return 0;
}
80105a2b:	31 c0                	xor    %eax,%eax
80105a2d:	c9                   	leave  
80105a2e:	c3                   	ret    
80105a2f:	90                   	nop

80105a30 <sys_fork>:

int
sys_fork(void)
{
  return fork();
80105a30:	e9 9b e3 ff ff       	jmp    80103dd0 <fork>
80105a35:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a40 <sys_exit>:
}

int
sys_exit(void)
{
80105a40:	55                   	push   %ebp
80105a41:	89 e5                	mov    %esp,%ebp
80105a43:	83 ec 08             	sub    $0x8,%esp
  exit();
80105a46:	e8 75 e6 ff ff       	call   801040c0 <exit>
  return 0;  // not reached
}
80105a4b:	31 c0                	xor    %eax,%eax
80105a4d:	c9                   	leave  
80105a4e:	c3                   	ret    
80105a4f:	90                   	nop

80105a50 <sys_wait>:

int
sys_wait(void)
{
  return wait();
80105a50:	e9 9b e7 ff ff       	jmp    801041f0 <wait>
80105a55:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a60 <sys_kill>:
}

int
sys_kill(void)
{
80105a60:	55                   	push   %ebp
80105a61:	89 e5                	mov    %esp,%ebp
80105a63:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105a66:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a69:	50                   	push   %eax
80105a6a:	6a 00                	push   $0x0
80105a6c:	e8 2f f2 ff ff       	call   80104ca0 <argint>
80105a71:	83 c4 10             	add    $0x10,%esp
80105a74:	85 c0                	test   %eax,%eax
80105a76:	78 18                	js     80105a90 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105a78:	83 ec 0c             	sub    $0xc,%esp
80105a7b:	ff 75 f4             	push   -0xc(%ebp)
80105a7e:	e8 0d ea ff ff       	call   80104490 <kill>
80105a83:	83 c4 10             	add    $0x10,%esp
}
80105a86:	c9                   	leave  
80105a87:	c3                   	ret    
80105a88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a8f:	90                   	nop
80105a90:	c9                   	leave  
    return -1;
80105a91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a96:	c3                   	ret    
80105a97:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a9e:	66 90                	xchg   %ax,%ax

80105aa0 <sys_getpid>:

int
sys_getpid(void)
{
80105aa0:	55                   	push   %ebp
80105aa1:	89 e5                	mov    %esp,%ebp
80105aa3:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105aa6:	e8 85 e1 ff ff       	call   80103c30 <myproc>
80105aab:	8b 40 14             	mov    0x14(%eax),%eax
}
80105aae:	c9                   	leave  
80105aaf:	c3                   	ret    

80105ab0 <sys_sbrk>:

int
sys_sbrk(void)
{
80105ab0:	55                   	push   %ebp
80105ab1:	89 e5                	mov    %esp,%ebp
80105ab3:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105ab7:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105aba:	50                   	push   %eax
80105abb:	6a 00                	push   $0x0
80105abd:	e8 de f1 ff ff       	call   80104ca0 <argint>
80105ac2:	83 c4 10             	add    $0x10,%esp
80105ac5:	85 c0                	test   %eax,%eax
80105ac7:	78 27                	js     80105af0 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105ac9:	e8 62 e1 ff ff       	call   80103c30 <myproc>
  if(growproc(n) < 0)
80105ace:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80105ad1:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105ad3:	ff 75 f4             	push   -0xc(%ebp)
80105ad6:	e8 75 e2 ff ff       	call   80103d50 <growproc>
80105adb:	83 c4 10             	add    $0x10,%esp
80105ade:	85 c0                	test   %eax,%eax
80105ae0:	78 0e                	js     80105af0 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105ae2:	89 d8                	mov    %ebx,%eax
80105ae4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105ae7:	c9                   	leave  
80105ae8:	c3                   	ret    
80105ae9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105af0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105af5:	eb eb                	jmp    80105ae2 <sys_sbrk+0x32>
80105af7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105afe:	66 90                	xchg   %ax,%ax

80105b00 <sys_sleep>:

int
sys_sleep(void)
{
80105b00:	55                   	push   %ebp
80105b01:	89 e5                	mov    %esp,%ebp
80105b03:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105b04:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105b07:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105b0a:	50                   	push   %eax
80105b0b:	6a 00                	push   $0x0
80105b0d:	e8 8e f1 ff ff       	call   80104ca0 <argint>
80105b12:	83 c4 10             	add    $0x10,%esp
80105b15:	85 c0                	test   %eax,%eax
80105b17:	0f 88 8a 00 00 00    	js     80105ba7 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105b1d:	83 ec 0c             	sub    $0xc,%esp
80105b20:	68 c0 4d 11 80       	push   $0x80114dc0
80105b25:	e8 f6 ed ff ff       	call   80104920 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105b2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
80105b2d:	8b 1d a0 4d 11 80    	mov    0x80114da0,%ebx
  while(ticks - ticks0 < n){
80105b33:	83 c4 10             	add    $0x10,%esp
80105b36:	85 d2                	test   %edx,%edx
80105b38:	75 27                	jne    80105b61 <sys_sleep+0x61>
80105b3a:	eb 54                	jmp    80105b90 <sys_sleep+0x90>
80105b3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105b40:	83 ec 08             	sub    $0x8,%esp
80105b43:	68 c0 4d 11 80       	push   $0x80114dc0
80105b48:	68 a0 4d 11 80       	push   $0x80114da0
80105b4d:	e8 1e e8 ff ff       	call   80104370 <sleep>
  while(ticks - ticks0 < n){
80105b52:	a1 a0 4d 11 80       	mov    0x80114da0,%eax
80105b57:	83 c4 10             	add    $0x10,%esp
80105b5a:	29 d8                	sub    %ebx,%eax
80105b5c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105b5f:	73 2f                	jae    80105b90 <sys_sleep+0x90>
    if(myproc()->killed){
80105b61:	e8 ca e0 ff ff       	call   80103c30 <myproc>
80105b66:	8b 40 28             	mov    0x28(%eax),%eax
80105b69:	85 c0                	test   %eax,%eax
80105b6b:	74 d3                	je     80105b40 <sys_sleep+0x40>
      release(&tickslock);
80105b6d:	83 ec 0c             	sub    $0xc,%esp
80105b70:	68 c0 4d 11 80       	push   $0x80114dc0
80105b75:	e8 46 ed ff ff       	call   801048c0 <release>
  }
  release(&tickslock);
  return 0;
}
80105b7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return -1;
80105b7d:	83 c4 10             	add    $0x10,%esp
80105b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b85:	c9                   	leave  
80105b86:	c3                   	ret    
80105b87:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105b8e:	66 90                	xchg   %ax,%ax
  release(&tickslock);
80105b90:	83 ec 0c             	sub    $0xc,%esp
80105b93:	68 c0 4d 11 80       	push   $0x80114dc0
80105b98:	e8 23 ed ff ff       	call   801048c0 <release>
  return 0;
80105b9d:	83 c4 10             	add    $0x10,%esp
80105ba0:	31 c0                	xor    %eax,%eax
}
80105ba2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105ba5:	c9                   	leave  
80105ba6:	c3                   	ret    
    return -1;
80105ba7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bac:	eb f4                	jmp    80105ba2 <sys_sleep+0xa2>
80105bae:	66 90                	xchg   %ax,%ax

80105bb0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105bb0:	55                   	push   %ebp
80105bb1:	89 e5                	mov    %esp,%ebp
80105bb3:	53                   	push   %ebx
80105bb4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105bb7:	68 c0 4d 11 80       	push   $0x80114dc0
80105bbc:	e8 5f ed ff ff       	call   80104920 <acquire>
  xticks = ticks;
80105bc1:	8b 1d a0 4d 11 80    	mov    0x80114da0,%ebx
  release(&tickslock);
80105bc7:	c7 04 24 c0 4d 11 80 	movl   $0x80114dc0,(%esp)
80105bce:	e8 ed ec ff ff       	call   801048c0 <release>
  return xticks;
}
80105bd3:	89 d8                	mov    %ebx,%eax
80105bd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105bd8:	c9                   	leave  
80105bd9:	c3                   	ret    

80105bda <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105bda:	1e                   	push   %ds
  pushl %es
80105bdb:	06                   	push   %es
  pushl %fs
80105bdc:	0f a0                	push   %fs
  pushl %gs
80105bde:	0f a8                	push   %gs
  pushal
80105be0:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105be1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105be5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105be7:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105be9:	54                   	push   %esp
  call trap
80105bea:	e8 c1 00 00 00       	call   80105cb0 <trap>
  addl $4, %esp
80105bef:	83 c4 04             	add    $0x4,%esp

80105bf2 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105bf2:	61                   	popa   
  popl %gs
80105bf3:	0f a9                	pop    %gs
  popl %fs
80105bf5:	0f a1                	pop    %fs
  popl %es
80105bf7:	07                   	pop    %es
  popl %ds
80105bf8:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105bf9:	83 c4 08             	add    $0x8,%esp
  iret
80105bfc:	cf                   	iret   
80105bfd:	66 90                	xchg   %ax,%ax
80105bff:	90                   	nop

80105c00 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105c00:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80105c01:	31 c0                	xor    %eax,%eax
{
80105c03:	89 e5                	mov    %esp,%ebp
80105c05:	83 ec 08             	sub    $0x8,%esp
80105c08:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c0f:	90                   	nop
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105c10:	8b 14 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%edx
80105c17:	c7 04 c5 02 4e 11 80 	movl   $0x8e000008,-0x7feeb1fe(,%eax,8)
80105c1e:	08 00 00 8e 
80105c22:	66 89 14 c5 00 4e 11 	mov    %dx,-0x7feeb200(,%eax,8)
80105c29:	80 
80105c2a:	c1 ea 10             	shr    $0x10,%edx
80105c2d:	66 89 14 c5 06 4e 11 	mov    %dx,-0x7feeb1fa(,%eax,8)
80105c34:	80 
  for(i = 0; i < 256; i++)
80105c35:	83 c0 01             	add    $0x1,%eax
80105c38:	3d 00 01 00 00       	cmp    $0x100,%eax
80105c3d:	75 d1                	jne    80105c10 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
80105c3f:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105c42:	a1 08 b1 10 80       	mov    0x8010b108,%eax
80105c47:	c7 05 02 50 11 80 08 	movl   $0xef000008,0x80115002
80105c4e:	00 00 ef 
  initlock(&tickslock, "time");
80105c51:	68 41 7f 10 80       	push   $0x80107f41
80105c56:	68 c0 4d 11 80       	push   $0x80114dc0
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105c5b:	66 a3 00 50 11 80    	mov    %ax,0x80115000
80105c61:	c1 e8 10             	shr    $0x10,%eax
80105c64:	66 a3 06 50 11 80    	mov    %ax,0x80115006
  initlock(&tickslock, "time");
80105c6a:	e8 e1 ea ff ff       	call   80104750 <initlock>
}
80105c6f:	83 c4 10             	add    $0x10,%esp
80105c72:	c9                   	leave  
80105c73:	c3                   	ret    
80105c74:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c7b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105c7f:	90                   	nop

80105c80 <idtinit>:

void
idtinit(void)
{
80105c80:	55                   	push   %ebp
  pd[0] = size-1;
80105c81:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80105c86:	89 e5                	mov    %esp,%ebp
80105c88:	83 ec 10             	sub    $0x10,%esp
80105c8b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105c8f:	b8 00 4e 11 80       	mov    $0x80114e00,%eax
80105c94:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105c98:	c1 e8 10             	shr    $0x10,%eax
80105c9b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105c9f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105ca2:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105ca5:	c9                   	leave  
80105ca6:	c3                   	ret    
80105ca7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105cae:	66 90                	xchg   %ax,%ax

80105cb0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105cb0:	55                   	push   %ebp
80105cb1:	89 e5                	mov    %esp,%ebp
80105cb3:	57                   	push   %edi
80105cb4:	56                   	push   %esi
80105cb5:	53                   	push   %ebx
80105cb6:	83 ec 1c             	sub    $0x1c,%esp
80105cb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105cbc:	8b 43 30             	mov    0x30(%ebx),%eax
80105cbf:	83 f8 40             	cmp    $0x40,%eax
80105cc2:	0f 84 30 01 00 00    	je     80105df8 <trap+0x148>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105cc8:	83 e8 0e             	sub    $0xe,%eax
80105ccb:	83 f8 31             	cmp    $0x31,%eax
80105cce:	0f 87 8c 00 00 00    	ja     80105d60 <trap+0xb0>
80105cd4:	ff 24 85 e8 7f 10 80 	jmp    *-0x7fef8018(,%eax,4)
80105cdb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105cdf:	90                   	nop
  case T_PGFLT:
    page_fault();
    break;
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105ce0:	e8 2b df ff ff       	call   80103c10 <cpuid>
80105ce5:	85 c0                	test   %eax,%eax
80105ce7:	0f 84 13 02 00 00    	je     80105f00 <trap+0x250>
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
80105ced:	e8 be ce ff ff       	call   80102bb0 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105cf2:	e8 39 df ff ff       	call   80103c30 <myproc>
80105cf7:	85 c0                	test   %eax,%eax
80105cf9:	74 1d                	je     80105d18 <trap+0x68>
80105cfb:	e8 30 df ff ff       	call   80103c30 <myproc>
80105d00:	8b 50 28             	mov    0x28(%eax),%edx
80105d03:	85 d2                	test   %edx,%edx
80105d05:	74 11                	je     80105d18 <trap+0x68>
80105d07:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105d0b:	83 e0 03             	and    $0x3,%eax
80105d0e:	66 83 f8 03          	cmp    $0x3,%ax
80105d12:	0f 84 c8 01 00 00    	je     80105ee0 <trap+0x230>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105d18:	e8 13 df ff ff       	call   80103c30 <myproc>
80105d1d:	85 c0                	test   %eax,%eax
80105d1f:	74 0f                	je     80105d30 <trap+0x80>
80105d21:	e8 0a df ff ff       	call   80103c30 <myproc>
80105d26:	83 78 10 04          	cmpl   $0x4,0x10(%eax)
80105d2a:	0f 84 b0 00 00 00    	je     80105de0 <trap+0x130>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105d30:	e8 fb de ff ff       	call   80103c30 <myproc>
80105d35:	85 c0                	test   %eax,%eax
80105d37:	74 1d                	je     80105d56 <trap+0xa6>
80105d39:	e8 f2 de ff ff       	call   80103c30 <myproc>
80105d3e:	8b 40 28             	mov    0x28(%eax),%eax
80105d41:	85 c0                	test   %eax,%eax
80105d43:	74 11                	je     80105d56 <trap+0xa6>
80105d45:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105d49:	83 e0 03             	and    $0x3,%eax
80105d4c:	66 83 f8 03          	cmp    $0x3,%ax
80105d50:	0f 84 cf 00 00 00    	je     80105e25 <trap+0x175>
    exit();
}
80105d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d59:	5b                   	pop    %ebx
80105d5a:	5e                   	pop    %esi
80105d5b:	5f                   	pop    %edi
80105d5c:	5d                   	pop    %ebp
80105d5d:	c3                   	ret    
80105d5e:	66 90                	xchg   %ax,%ax
    if(myproc() == 0 || (tf->cs&3) == 0){
80105d60:	e8 cb de ff ff       	call   80103c30 <myproc>
80105d65:	8b 7b 38             	mov    0x38(%ebx),%edi
80105d68:	85 c0                	test   %eax,%eax
80105d6a:	0f 84 c4 01 00 00    	je     80105f34 <trap+0x284>
80105d70:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105d74:	0f 84 ba 01 00 00    	je     80105f34 <trap+0x284>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105d7a:	0f 20 d1             	mov    %cr2,%ecx
80105d7d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105d80:	e8 8b de ff ff       	call   80103c10 <cpuid>
80105d85:	8b 73 30             	mov    0x30(%ebx),%esi
80105d88:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105d8b:	8b 43 34             	mov    0x34(%ebx),%eax
80105d8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            myproc()->pid, myproc()->name, tf->trapno,
80105d91:	e8 9a de ff ff       	call   80103c30 <myproc>
80105d96:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105d99:	e8 92 de ff ff       	call   80103c30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105d9e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105da1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105da4:	51                   	push   %ecx
80105da5:	57                   	push   %edi
80105da6:	52                   	push   %edx
80105da7:	ff 75 e4             	push   -0x1c(%ebp)
80105daa:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
80105dab:	8b 75 e0             	mov    -0x20(%ebp),%esi
80105dae:	83 c6 70             	add    $0x70,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105db1:	56                   	push   %esi
80105db2:	ff 70 14             	push   0x14(%eax)
80105db5:	68 a4 7f 10 80       	push   $0x80107fa4
80105dba:	e8 11 aa ff ff       	call   801007d0 <cprintf>
    myproc()->killed = 1;
80105dbf:	83 c4 20             	add    $0x20,%esp
80105dc2:	e8 69 de ff ff       	call   80103c30 <myproc>
80105dc7:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105dce:	e8 5d de ff ff       	call   80103c30 <myproc>
80105dd3:	85 c0                	test   %eax,%eax
80105dd5:	0f 85 20 ff ff ff    	jne    80105cfb <trap+0x4b>
80105ddb:	e9 38 ff ff ff       	jmp    80105d18 <trap+0x68>
  if(myproc() && myproc()->state == RUNNING &&
80105de0:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105de4:	0f 85 46 ff ff ff    	jne    80105d30 <trap+0x80>
    yield();
80105dea:	e8 31 e5 ff ff       	call   80104320 <yield>
80105def:	e9 3c ff ff ff       	jmp    80105d30 <trap+0x80>
80105df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed)
80105df8:	e8 33 de ff ff       	call   80103c30 <myproc>
80105dfd:	8b 70 28             	mov    0x28(%eax),%esi
80105e00:	85 f6                	test   %esi,%esi
80105e02:	0f 85 e8 00 00 00    	jne    80105ef0 <trap+0x240>
    myproc()->tf = tf;
80105e08:	e8 23 de ff ff       	call   80103c30 <myproc>
80105e0d:	89 58 1c             	mov    %ebx,0x1c(%eax)
    syscall();
80105e10:	e8 cb ef ff ff       	call   80104de0 <syscall>
    if(myproc()->killed)
80105e15:	e8 16 de ff ff       	call   80103c30 <myproc>
80105e1a:	8b 48 28             	mov    0x28(%eax),%ecx
80105e1d:	85 c9                	test   %ecx,%ecx
80105e1f:	0f 84 31 ff ff ff    	je     80105d56 <trap+0xa6>
}
80105e25:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e28:	5b                   	pop    %ebx
80105e29:	5e                   	pop    %esi
80105e2a:	5f                   	pop    %edi
80105e2b:	5d                   	pop    %ebp
      exit();
80105e2c:	e9 8f e2 ff ff       	jmp    801040c0 <exit>
80105e31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105e38:	8b 7b 38             	mov    0x38(%ebx),%edi
80105e3b:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80105e3f:	e8 cc dd ff ff       	call   80103c10 <cpuid>
80105e44:	57                   	push   %edi
80105e45:	56                   	push   %esi
80105e46:	50                   	push   %eax
80105e47:	68 4c 7f 10 80       	push   $0x80107f4c
80105e4c:	e8 7f a9 ff ff       	call   801007d0 <cprintf>
    lapiceoi();
80105e51:	e8 5a cd ff ff       	call   80102bb0 <lapiceoi>
    break;
80105e56:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105e59:	e8 d2 dd ff ff       	call   80103c30 <myproc>
80105e5e:	85 c0                	test   %eax,%eax
80105e60:	0f 85 95 fe ff ff    	jne    80105cfb <trap+0x4b>
80105e66:	e9 ad fe ff ff       	jmp    80105d18 <trap+0x68>
80105e6b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105e6f:	90                   	nop
    kbdintr();
80105e70:	e8 fb cb ff ff       	call   80102a70 <kbdintr>
    lapiceoi();
80105e75:	e8 36 cd ff ff       	call   80102bb0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105e7a:	e8 b1 dd ff ff       	call   80103c30 <myproc>
80105e7f:	85 c0                	test   %eax,%eax
80105e81:	0f 85 74 fe ff ff    	jne    80105cfb <trap+0x4b>
80105e87:	e9 8c fe ff ff       	jmp    80105d18 <trap+0x68>
80105e8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    uartintr();
80105e90:	e8 3b 02 00 00       	call   801060d0 <uartintr>
    lapiceoi();
80105e95:	e8 16 cd ff ff       	call   80102bb0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105e9a:	e8 91 dd ff ff       	call   80103c30 <myproc>
80105e9f:	85 c0                	test   %eax,%eax
80105ea1:	0f 85 54 fe ff ff    	jne    80105cfb <trap+0x4b>
80105ea7:	e9 6c fe ff ff       	jmp    80105d18 <trap+0x68>
80105eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ideintr();
80105eb0:	e8 db c5 ff ff       	call   80102490 <ideintr>
80105eb5:	e9 33 fe ff ff       	jmp    80105ced <trap+0x3d>
80105eba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    page_fault();
80105ec0:	e8 bb 17 00 00       	call   80107680 <page_fault>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105ec5:	e8 66 dd ff ff       	call   80103c30 <myproc>
80105eca:	85 c0                	test   %eax,%eax
80105ecc:	0f 85 29 fe ff ff    	jne    80105cfb <trap+0x4b>
80105ed2:	e9 41 fe ff ff       	jmp    80105d18 <trap+0x68>
80105ed7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105ede:	66 90                	xchg   %ax,%ax
    exit();
80105ee0:	e8 db e1 ff ff       	call   801040c0 <exit>
80105ee5:	e9 2e fe ff ff       	jmp    80105d18 <trap+0x68>
80105eea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
80105ef0:	e8 cb e1 ff ff       	call   801040c0 <exit>
80105ef5:	e9 0e ff ff ff       	jmp    80105e08 <trap+0x158>
80105efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      acquire(&tickslock);
80105f00:	83 ec 0c             	sub    $0xc,%esp
80105f03:	68 c0 4d 11 80       	push   $0x80114dc0
80105f08:	e8 13 ea ff ff       	call   80104920 <acquire>
      wakeup(&ticks);
80105f0d:	c7 04 24 a0 4d 11 80 	movl   $0x80114da0,(%esp)
      ticks++;
80105f14:	83 05 a0 4d 11 80 01 	addl   $0x1,0x80114da0
      wakeup(&ticks);
80105f1b:	e8 10 e5 ff ff       	call   80104430 <wakeup>
      release(&tickslock);
80105f20:	c7 04 24 c0 4d 11 80 	movl   $0x80114dc0,(%esp)
80105f27:	e8 94 e9 ff ff       	call   801048c0 <release>
80105f2c:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80105f2f:	e9 b9 fd ff ff       	jmp    80105ced <trap+0x3d>
80105f34:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105f37:	e8 d4 dc ff ff       	call   80103c10 <cpuid>
80105f3c:	83 ec 0c             	sub    $0xc,%esp
80105f3f:	56                   	push   %esi
80105f40:	57                   	push   %edi
80105f41:	50                   	push   %eax
80105f42:	ff 73 30             	push   0x30(%ebx)
80105f45:	68 70 7f 10 80       	push   $0x80107f70
80105f4a:	e8 81 a8 ff ff       	call   801007d0 <cprintf>
      panic("trap");
80105f4f:	83 c4 14             	add    $0x14,%esp
80105f52:	68 46 7f 10 80       	push   $0x80107f46
80105f57:	e8 54 a5 ff ff       	call   801004b0 <panic>
80105f5c:	66 90                	xchg   %ax,%ax
80105f5e:	66 90                	xchg   %ax,%ax

80105f60 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105f60:	a1 00 56 11 80       	mov    0x80115600,%eax
80105f65:	85 c0                	test   %eax,%eax
80105f67:	74 17                	je     80105f80 <uartgetc+0x20>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105f69:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105f6e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105f6f:	a8 01                	test   $0x1,%al
80105f71:	74 0d                	je     80105f80 <uartgetc+0x20>
80105f73:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105f78:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105f79:	0f b6 c0             	movzbl %al,%eax
80105f7c:	c3                   	ret    
80105f7d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105f80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f85:	c3                   	ret    
80105f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105f8d:	8d 76 00             	lea    0x0(%esi),%esi

80105f90 <uartinit>:
{
80105f90:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105f91:	31 c9                	xor    %ecx,%ecx
80105f93:	89 c8                	mov    %ecx,%eax
80105f95:	89 e5                	mov    %esp,%ebp
80105f97:	57                   	push   %edi
80105f98:	bf fa 03 00 00       	mov    $0x3fa,%edi
80105f9d:	56                   	push   %esi
80105f9e:	89 fa                	mov    %edi,%edx
80105fa0:	53                   	push   %ebx
80105fa1:	83 ec 1c             	sub    $0x1c,%esp
80105fa4:	ee                   	out    %al,(%dx)
80105fa5:	be fb 03 00 00       	mov    $0x3fb,%esi
80105faa:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105faf:	89 f2                	mov    %esi,%edx
80105fb1:	ee                   	out    %al,(%dx)
80105fb2:	b8 0c 00 00 00       	mov    $0xc,%eax
80105fb7:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105fbc:	ee                   	out    %al,(%dx)
80105fbd:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105fc2:	89 c8                	mov    %ecx,%eax
80105fc4:	89 da                	mov    %ebx,%edx
80105fc6:	ee                   	out    %al,(%dx)
80105fc7:	b8 03 00 00 00       	mov    $0x3,%eax
80105fcc:	89 f2                	mov    %esi,%edx
80105fce:	ee                   	out    %al,(%dx)
80105fcf:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105fd4:	89 c8                	mov    %ecx,%eax
80105fd6:	ee                   	out    %al,(%dx)
80105fd7:	b8 01 00 00 00       	mov    $0x1,%eax
80105fdc:	89 da                	mov    %ebx,%edx
80105fde:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105fdf:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105fe4:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105fe5:	3c ff                	cmp    $0xff,%al
80105fe7:	74 78                	je     80106061 <uartinit+0xd1>
  uart = 1;
80105fe9:	c7 05 00 56 11 80 01 	movl   $0x1,0x80115600
80105ff0:	00 00 00 
80105ff3:	89 fa                	mov    %edi,%edx
80105ff5:	ec                   	in     (%dx),%al
80105ff6:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105ffb:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105ffc:	83 ec 08             	sub    $0x8,%esp
  for(p="xv6...\n"; *p; p++)
80105fff:	bf b0 80 10 80       	mov    $0x801080b0,%edi
80106004:	be fd 03 00 00       	mov    $0x3fd,%esi
  ioapicenable(IRQ_COM1, 0);
80106009:	6a 00                	push   $0x0
8010600b:	6a 04                	push   $0x4
8010600d:	e8 be c6 ff ff       	call   801026d0 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80106012:	c6 45 e7 78          	movb   $0x78,-0x19(%ebp)
  ioapicenable(IRQ_COM1, 0);
80106016:	83 c4 10             	add    $0x10,%esp
80106019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(!uart)
80106020:	a1 00 56 11 80       	mov    0x80115600,%eax
80106025:	bb 80 00 00 00       	mov    $0x80,%ebx
8010602a:	85 c0                	test   %eax,%eax
8010602c:	75 14                	jne    80106042 <uartinit+0xb2>
8010602e:	eb 23                	jmp    80106053 <uartinit+0xc3>
    microdelay(10);
80106030:	83 ec 0c             	sub    $0xc,%esp
80106033:	6a 0a                	push   $0xa
80106035:	e8 96 cb ff ff       	call   80102bd0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010603a:	83 c4 10             	add    $0x10,%esp
8010603d:	83 eb 01             	sub    $0x1,%ebx
80106040:	74 07                	je     80106049 <uartinit+0xb9>
80106042:	89 f2                	mov    %esi,%edx
80106044:	ec                   	in     (%dx),%al
80106045:	a8 20                	test   $0x20,%al
80106047:	74 e7                	je     80106030 <uartinit+0xa0>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106049:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
8010604d:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106052:	ee                   	out    %al,(%dx)
  for(p="xv6...\n"; *p; p++)
80106053:	0f b6 47 01          	movzbl 0x1(%edi),%eax
80106057:	83 c7 01             	add    $0x1,%edi
8010605a:	88 45 e7             	mov    %al,-0x19(%ebp)
8010605d:	84 c0                	test   %al,%al
8010605f:	75 bf                	jne    80106020 <uartinit+0x90>
}
80106061:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106064:	5b                   	pop    %ebx
80106065:	5e                   	pop    %esi
80106066:	5f                   	pop    %edi
80106067:	5d                   	pop    %ebp
80106068:	c3                   	ret    
80106069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106070 <uartputc>:
  if(!uart)
80106070:	a1 00 56 11 80       	mov    0x80115600,%eax
80106075:	85 c0                	test   %eax,%eax
80106077:	74 47                	je     801060c0 <uartputc+0x50>
{
80106079:	55                   	push   %ebp
8010607a:	89 e5                	mov    %esp,%ebp
8010607c:	56                   	push   %esi
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010607d:	be fd 03 00 00       	mov    $0x3fd,%esi
80106082:	53                   	push   %ebx
80106083:	bb 80 00 00 00       	mov    $0x80,%ebx
80106088:	eb 18                	jmp    801060a2 <uartputc+0x32>
8010608a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    microdelay(10);
80106090:	83 ec 0c             	sub    $0xc,%esp
80106093:	6a 0a                	push   $0xa
80106095:	e8 36 cb ff ff       	call   80102bd0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010609a:	83 c4 10             	add    $0x10,%esp
8010609d:	83 eb 01             	sub    $0x1,%ebx
801060a0:	74 07                	je     801060a9 <uartputc+0x39>
801060a2:	89 f2                	mov    %esi,%edx
801060a4:	ec                   	in     (%dx),%al
801060a5:	a8 20                	test   $0x20,%al
801060a7:	74 e7                	je     80106090 <uartputc+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801060a9:	8b 45 08             	mov    0x8(%ebp),%eax
801060ac:	ba f8 03 00 00       	mov    $0x3f8,%edx
801060b1:	ee                   	out    %al,(%dx)
}
801060b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801060b5:	5b                   	pop    %ebx
801060b6:	5e                   	pop    %esi
801060b7:	5d                   	pop    %ebp
801060b8:	c3                   	ret    
801060b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801060c0:	c3                   	ret    
801060c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801060c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801060cf:	90                   	nop

801060d0 <uartintr>:

void
uartintr(void)
{
801060d0:	55                   	push   %ebp
801060d1:	89 e5                	mov    %esp,%ebp
801060d3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801060d6:	68 60 5f 10 80       	push   $0x80105f60
801060db:	e8 d0 a8 ff ff       	call   801009b0 <consoleintr>
}
801060e0:	83 c4 10             	add    $0x10,%esp
801060e3:	c9                   	leave  
801060e4:	c3                   	ret    

801060e5 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801060e5:	6a 00                	push   $0x0
  pushl $0
801060e7:	6a 00                	push   $0x0
  jmp alltraps
801060e9:	e9 ec fa ff ff       	jmp    80105bda <alltraps>

801060ee <vector1>:
.globl vector1
vector1:
  pushl $0
801060ee:	6a 00                	push   $0x0
  pushl $1
801060f0:	6a 01                	push   $0x1
  jmp alltraps
801060f2:	e9 e3 fa ff ff       	jmp    80105bda <alltraps>

801060f7 <vector2>:
.globl vector2
vector2:
  pushl $0
801060f7:	6a 00                	push   $0x0
  pushl $2
801060f9:	6a 02                	push   $0x2
  jmp alltraps
801060fb:	e9 da fa ff ff       	jmp    80105bda <alltraps>

80106100 <vector3>:
.globl vector3
vector3:
  pushl $0
80106100:	6a 00                	push   $0x0
  pushl $3
80106102:	6a 03                	push   $0x3
  jmp alltraps
80106104:	e9 d1 fa ff ff       	jmp    80105bda <alltraps>

80106109 <vector4>:
.globl vector4
vector4:
  pushl $0
80106109:	6a 00                	push   $0x0
  pushl $4
8010610b:	6a 04                	push   $0x4
  jmp alltraps
8010610d:	e9 c8 fa ff ff       	jmp    80105bda <alltraps>

80106112 <vector5>:
.globl vector5
vector5:
  pushl $0
80106112:	6a 00                	push   $0x0
  pushl $5
80106114:	6a 05                	push   $0x5
  jmp alltraps
80106116:	e9 bf fa ff ff       	jmp    80105bda <alltraps>

8010611b <vector6>:
.globl vector6
vector6:
  pushl $0
8010611b:	6a 00                	push   $0x0
  pushl $6
8010611d:	6a 06                	push   $0x6
  jmp alltraps
8010611f:	e9 b6 fa ff ff       	jmp    80105bda <alltraps>

80106124 <vector7>:
.globl vector7
vector7:
  pushl $0
80106124:	6a 00                	push   $0x0
  pushl $7
80106126:	6a 07                	push   $0x7
  jmp alltraps
80106128:	e9 ad fa ff ff       	jmp    80105bda <alltraps>

8010612d <vector8>:
.globl vector8
vector8:
  pushl $8
8010612d:	6a 08                	push   $0x8
  jmp alltraps
8010612f:	e9 a6 fa ff ff       	jmp    80105bda <alltraps>

80106134 <vector9>:
.globl vector9
vector9:
  pushl $0
80106134:	6a 00                	push   $0x0
  pushl $9
80106136:	6a 09                	push   $0x9
  jmp alltraps
80106138:	e9 9d fa ff ff       	jmp    80105bda <alltraps>

8010613d <vector10>:
.globl vector10
vector10:
  pushl $10
8010613d:	6a 0a                	push   $0xa
  jmp alltraps
8010613f:	e9 96 fa ff ff       	jmp    80105bda <alltraps>

80106144 <vector11>:
.globl vector11
vector11:
  pushl $11
80106144:	6a 0b                	push   $0xb
  jmp alltraps
80106146:	e9 8f fa ff ff       	jmp    80105bda <alltraps>

8010614b <vector12>:
.globl vector12
vector12:
  pushl $12
8010614b:	6a 0c                	push   $0xc
  jmp alltraps
8010614d:	e9 88 fa ff ff       	jmp    80105bda <alltraps>

80106152 <vector13>:
.globl vector13
vector13:
  pushl $13
80106152:	6a 0d                	push   $0xd
  jmp alltraps
80106154:	e9 81 fa ff ff       	jmp    80105bda <alltraps>

80106159 <vector14>:
.globl vector14
vector14:
  pushl $14
80106159:	6a 0e                	push   $0xe
  jmp alltraps
8010615b:	e9 7a fa ff ff       	jmp    80105bda <alltraps>

80106160 <vector15>:
.globl vector15
vector15:
  pushl $0
80106160:	6a 00                	push   $0x0
  pushl $15
80106162:	6a 0f                	push   $0xf
  jmp alltraps
80106164:	e9 71 fa ff ff       	jmp    80105bda <alltraps>

80106169 <vector16>:
.globl vector16
vector16:
  pushl $0
80106169:	6a 00                	push   $0x0
  pushl $16
8010616b:	6a 10                	push   $0x10
  jmp alltraps
8010616d:	e9 68 fa ff ff       	jmp    80105bda <alltraps>

80106172 <vector17>:
.globl vector17
vector17:
  pushl $17
80106172:	6a 11                	push   $0x11
  jmp alltraps
80106174:	e9 61 fa ff ff       	jmp    80105bda <alltraps>

80106179 <vector18>:
.globl vector18
vector18:
  pushl $0
80106179:	6a 00                	push   $0x0
  pushl $18
8010617b:	6a 12                	push   $0x12
  jmp alltraps
8010617d:	e9 58 fa ff ff       	jmp    80105bda <alltraps>

80106182 <vector19>:
.globl vector19
vector19:
  pushl $0
80106182:	6a 00                	push   $0x0
  pushl $19
80106184:	6a 13                	push   $0x13
  jmp alltraps
80106186:	e9 4f fa ff ff       	jmp    80105bda <alltraps>

8010618b <vector20>:
.globl vector20
vector20:
  pushl $0
8010618b:	6a 00                	push   $0x0
  pushl $20
8010618d:	6a 14                	push   $0x14
  jmp alltraps
8010618f:	e9 46 fa ff ff       	jmp    80105bda <alltraps>

80106194 <vector21>:
.globl vector21
vector21:
  pushl $0
80106194:	6a 00                	push   $0x0
  pushl $21
80106196:	6a 15                	push   $0x15
  jmp alltraps
80106198:	e9 3d fa ff ff       	jmp    80105bda <alltraps>

8010619d <vector22>:
.globl vector22
vector22:
  pushl $0
8010619d:	6a 00                	push   $0x0
  pushl $22
8010619f:	6a 16                	push   $0x16
  jmp alltraps
801061a1:	e9 34 fa ff ff       	jmp    80105bda <alltraps>

801061a6 <vector23>:
.globl vector23
vector23:
  pushl $0
801061a6:	6a 00                	push   $0x0
  pushl $23
801061a8:	6a 17                	push   $0x17
  jmp alltraps
801061aa:	e9 2b fa ff ff       	jmp    80105bda <alltraps>

801061af <vector24>:
.globl vector24
vector24:
  pushl $0
801061af:	6a 00                	push   $0x0
  pushl $24
801061b1:	6a 18                	push   $0x18
  jmp alltraps
801061b3:	e9 22 fa ff ff       	jmp    80105bda <alltraps>

801061b8 <vector25>:
.globl vector25
vector25:
  pushl $0
801061b8:	6a 00                	push   $0x0
  pushl $25
801061ba:	6a 19                	push   $0x19
  jmp alltraps
801061bc:	e9 19 fa ff ff       	jmp    80105bda <alltraps>

801061c1 <vector26>:
.globl vector26
vector26:
  pushl $0
801061c1:	6a 00                	push   $0x0
  pushl $26
801061c3:	6a 1a                	push   $0x1a
  jmp alltraps
801061c5:	e9 10 fa ff ff       	jmp    80105bda <alltraps>

801061ca <vector27>:
.globl vector27
vector27:
  pushl $0
801061ca:	6a 00                	push   $0x0
  pushl $27
801061cc:	6a 1b                	push   $0x1b
  jmp alltraps
801061ce:	e9 07 fa ff ff       	jmp    80105bda <alltraps>

801061d3 <vector28>:
.globl vector28
vector28:
  pushl $0
801061d3:	6a 00                	push   $0x0
  pushl $28
801061d5:	6a 1c                	push   $0x1c
  jmp alltraps
801061d7:	e9 fe f9 ff ff       	jmp    80105bda <alltraps>

801061dc <vector29>:
.globl vector29
vector29:
  pushl $0
801061dc:	6a 00                	push   $0x0
  pushl $29
801061de:	6a 1d                	push   $0x1d
  jmp alltraps
801061e0:	e9 f5 f9 ff ff       	jmp    80105bda <alltraps>

801061e5 <vector30>:
.globl vector30
vector30:
  pushl $0
801061e5:	6a 00                	push   $0x0
  pushl $30
801061e7:	6a 1e                	push   $0x1e
  jmp alltraps
801061e9:	e9 ec f9 ff ff       	jmp    80105bda <alltraps>

801061ee <vector31>:
.globl vector31
vector31:
  pushl $0
801061ee:	6a 00                	push   $0x0
  pushl $31
801061f0:	6a 1f                	push   $0x1f
  jmp alltraps
801061f2:	e9 e3 f9 ff ff       	jmp    80105bda <alltraps>

801061f7 <vector32>:
.globl vector32
vector32:
  pushl $0
801061f7:	6a 00                	push   $0x0
  pushl $32
801061f9:	6a 20                	push   $0x20
  jmp alltraps
801061fb:	e9 da f9 ff ff       	jmp    80105bda <alltraps>

80106200 <vector33>:
.globl vector33
vector33:
  pushl $0
80106200:	6a 00                	push   $0x0
  pushl $33
80106202:	6a 21                	push   $0x21
  jmp alltraps
80106204:	e9 d1 f9 ff ff       	jmp    80105bda <alltraps>

80106209 <vector34>:
.globl vector34
vector34:
  pushl $0
80106209:	6a 00                	push   $0x0
  pushl $34
8010620b:	6a 22                	push   $0x22
  jmp alltraps
8010620d:	e9 c8 f9 ff ff       	jmp    80105bda <alltraps>

80106212 <vector35>:
.globl vector35
vector35:
  pushl $0
80106212:	6a 00                	push   $0x0
  pushl $35
80106214:	6a 23                	push   $0x23
  jmp alltraps
80106216:	e9 bf f9 ff ff       	jmp    80105bda <alltraps>

8010621b <vector36>:
.globl vector36
vector36:
  pushl $0
8010621b:	6a 00                	push   $0x0
  pushl $36
8010621d:	6a 24                	push   $0x24
  jmp alltraps
8010621f:	e9 b6 f9 ff ff       	jmp    80105bda <alltraps>

80106224 <vector37>:
.globl vector37
vector37:
  pushl $0
80106224:	6a 00                	push   $0x0
  pushl $37
80106226:	6a 25                	push   $0x25
  jmp alltraps
80106228:	e9 ad f9 ff ff       	jmp    80105bda <alltraps>

8010622d <vector38>:
.globl vector38
vector38:
  pushl $0
8010622d:	6a 00                	push   $0x0
  pushl $38
8010622f:	6a 26                	push   $0x26
  jmp alltraps
80106231:	e9 a4 f9 ff ff       	jmp    80105bda <alltraps>

80106236 <vector39>:
.globl vector39
vector39:
  pushl $0
80106236:	6a 00                	push   $0x0
  pushl $39
80106238:	6a 27                	push   $0x27
  jmp alltraps
8010623a:	e9 9b f9 ff ff       	jmp    80105bda <alltraps>

8010623f <vector40>:
.globl vector40
vector40:
  pushl $0
8010623f:	6a 00                	push   $0x0
  pushl $40
80106241:	6a 28                	push   $0x28
  jmp alltraps
80106243:	e9 92 f9 ff ff       	jmp    80105bda <alltraps>

80106248 <vector41>:
.globl vector41
vector41:
  pushl $0
80106248:	6a 00                	push   $0x0
  pushl $41
8010624a:	6a 29                	push   $0x29
  jmp alltraps
8010624c:	e9 89 f9 ff ff       	jmp    80105bda <alltraps>

80106251 <vector42>:
.globl vector42
vector42:
  pushl $0
80106251:	6a 00                	push   $0x0
  pushl $42
80106253:	6a 2a                	push   $0x2a
  jmp alltraps
80106255:	e9 80 f9 ff ff       	jmp    80105bda <alltraps>

8010625a <vector43>:
.globl vector43
vector43:
  pushl $0
8010625a:	6a 00                	push   $0x0
  pushl $43
8010625c:	6a 2b                	push   $0x2b
  jmp alltraps
8010625e:	e9 77 f9 ff ff       	jmp    80105bda <alltraps>

80106263 <vector44>:
.globl vector44
vector44:
  pushl $0
80106263:	6a 00                	push   $0x0
  pushl $44
80106265:	6a 2c                	push   $0x2c
  jmp alltraps
80106267:	e9 6e f9 ff ff       	jmp    80105bda <alltraps>

8010626c <vector45>:
.globl vector45
vector45:
  pushl $0
8010626c:	6a 00                	push   $0x0
  pushl $45
8010626e:	6a 2d                	push   $0x2d
  jmp alltraps
80106270:	e9 65 f9 ff ff       	jmp    80105bda <alltraps>

80106275 <vector46>:
.globl vector46
vector46:
  pushl $0
80106275:	6a 00                	push   $0x0
  pushl $46
80106277:	6a 2e                	push   $0x2e
  jmp alltraps
80106279:	e9 5c f9 ff ff       	jmp    80105bda <alltraps>

8010627e <vector47>:
.globl vector47
vector47:
  pushl $0
8010627e:	6a 00                	push   $0x0
  pushl $47
80106280:	6a 2f                	push   $0x2f
  jmp alltraps
80106282:	e9 53 f9 ff ff       	jmp    80105bda <alltraps>

80106287 <vector48>:
.globl vector48
vector48:
  pushl $0
80106287:	6a 00                	push   $0x0
  pushl $48
80106289:	6a 30                	push   $0x30
  jmp alltraps
8010628b:	e9 4a f9 ff ff       	jmp    80105bda <alltraps>

80106290 <vector49>:
.globl vector49
vector49:
  pushl $0
80106290:	6a 00                	push   $0x0
  pushl $49
80106292:	6a 31                	push   $0x31
  jmp alltraps
80106294:	e9 41 f9 ff ff       	jmp    80105bda <alltraps>

80106299 <vector50>:
.globl vector50
vector50:
  pushl $0
80106299:	6a 00                	push   $0x0
  pushl $50
8010629b:	6a 32                	push   $0x32
  jmp alltraps
8010629d:	e9 38 f9 ff ff       	jmp    80105bda <alltraps>

801062a2 <vector51>:
.globl vector51
vector51:
  pushl $0
801062a2:	6a 00                	push   $0x0
  pushl $51
801062a4:	6a 33                	push   $0x33
  jmp alltraps
801062a6:	e9 2f f9 ff ff       	jmp    80105bda <alltraps>

801062ab <vector52>:
.globl vector52
vector52:
  pushl $0
801062ab:	6a 00                	push   $0x0
  pushl $52
801062ad:	6a 34                	push   $0x34
  jmp alltraps
801062af:	e9 26 f9 ff ff       	jmp    80105bda <alltraps>

801062b4 <vector53>:
.globl vector53
vector53:
  pushl $0
801062b4:	6a 00                	push   $0x0
  pushl $53
801062b6:	6a 35                	push   $0x35
  jmp alltraps
801062b8:	e9 1d f9 ff ff       	jmp    80105bda <alltraps>

801062bd <vector54>:
.globl vector54
vector54:
  pushl $0
801062bd:	6a 00                	push   $0x0
  pushl $54
801062bf:	6a 36                	push   $0x36
  jmp alltraps
801062c1:	e9 14 f9 ff ff       	jmp    80105bda <alltraps>

801062c6 <vector55>:
.globl vector55
vector55:
  pushl $0
801062c6:	6a 00                	push   $0x0
  pushl $55
801062c8:	6a 37                	push   $0x37
  jmp alltraps
801062ca:	e9 0b f9 ff ff       	jmp    80105bda <alltraps>

801062cf <vector56>:
.globl vector56
vector56:
  pushl $0
801062cf:	6a 00                	push   $0x0
  pushl $56
801062d1:	6a 38                	push   $0x38
  jmp alltraps
801062d3:	e9 02 f9 ff ff       	jmp    80105bda <alltraps>

801062d8 <vector57>:
.globl vector57
vector57:
  pushl $0
801062d8:	6a 00                	push   $0x0
  pushl $57
801062da:	6a 39                	push   $0x39
  jmp alltraps
801062dc:	e9 f9 f8 ff ff       	jmp    80105bda <alltraps>

801062e1 <vector58>:
.globl vector58
vector58:
  pushl $0
801062e1:	6a 00                	push   $0x0
  pushl $58
801062e3:	6a 3a                	push   $0x3a
  jmp alltraps
801062e5:	e9 f0 f8 ff ff       	jmp    80105bda <alltraps>

801062ea <vector59>:
.globl vector59
vector59:
  pushl $0
801062ea:	6a 00                	push   $0x0
  pushl $59
801062ec:	6a 3b                	push   $0x3b
  jmp alltraps
801062ee:	e9 e7 f8 ff ff       	jmp    80105bda <alltraps>

801062f3 <vector60>:
.globl vector60
vector60:
  pushl $0
801062f3:	6a 00                	push   $0x0
  pushl $60
801062f5:	6a 3c                	push   $0x3c
  jmp alltraps
801062f7:	e9 de f8 ff ff       	jmp    80105bda <alltraps>

801062fc <vector61>:
.globl vector61
vector61:
  pushl $0
801062fc:	6a 00                	push   $0x0
  pushl $61
801062fe:	6a 3d                	push   $0x3d
  jmp alltraps
80106300:	e9 d5 f8 ff ff       	jmp    80105bda <alltraps>

80106305 <vector62>:
.globl vector62
vector62:
  pushl $0
80106305:	6a 00                	push   $0x0
  pushl $62
80106307:	6a 3e                	push   $0x3e
  jmp alltraps
80106309:	e9 cc f8 ff ff       	jmp    80105bda <alltraps>

8010630e <vector63>:
.globl vector63
vector63:
  pushl $0
8010630e:	6a 00                	push   $0x0
  pushl $63
80106310:	6a 3f                	push   $0x3f
  jmp alltraps
80106312:	e9 c3 f8 ff ff       	jmp    80105bda <alltraps>

80106317 <vector64>:
.globl vector64
vector64:
  pushl $0
80106317:	6a 00                	push   $0x0
  pushl $64
80106319:	6a 40                	push   $0x40
  jmp alltraps
8010631b:	e9 ba f8 ff ff       	jmp    80105bda <alltraps>

80106320 <vector65>:
.globl vector65
vector65:
  pushl $0
80106320:	6a 00                	push   $0x0
  pushl $65
80106322:	6a 41                	push   $0x41
  jmp alltraps
80106324:	e9 b1 f8 ff ff       	jmp    80105bda <alltraps>

80106329 <vector66>:
.globl vector66
vector66:
  pushl $0
80106329:	6a 00                	push   $0x0
  pushl $66
8010632b:	6a 42                	push   $0x42
  jmp alltraps
8010632d:	e9 a8 f8 ff ff       	jmp    80105bda <alltraps>

80106332 <vector67>:
.globl vector67
vector67:
  pushl $0
80106332:	6a 00                	push   $0x0
  pushl $67
80106334:	6a 43                	push   $0x43
  jmp alltraps
80106336:	e9 9f f8 ff ff       	jmp    80105bda <alltraps>

8010633b <vector68>:
.globl vector68
vector68:
  pushl $0
8010633b:	6a 00                	push   $0x0
  pushl $68
8010633d:	6a 44                	push   $0x44
  jmp alltraps
8010633f:	e9 96 f8 ff ff       	jmp    80105bda <alltraps>

80106344 <vector69>:
.globl vector69
vector69:
  pushl $0
80106344:	6a 00                	push   $0x0
  pushl $69
80106346:	6a 45                	push   $0x45
  jmp alltraps
80106348:	e9 8d f8 ff ff       	jmp    80105bda <alltraps>

8010634d <vector70>:
.globl vector70
vector70:
  pushl $0
8010634d:	6a 00                	push   $0x0
  pushl $70
8010634f:	6a 46                	push   $0x46
  jmp alltraps
80106351:	e9 84 f8 ff ff       	jmp    80105bda <alltraps>

80106356 <vector71>:
.globl vector71
vector71:
  pushl $0
80106356:	6a 00                	push   $0x0
  pushl $71
80106358:	6a 47                	push   $0x47
  jmp alltraps
8010635a:	e9 7b f8 ff ff       	jmp    80105bda <alltraps>

8010635f <vector72>:
.globl vector72
vector72:
  pushl $0
8010635f:	6a 00                	push   $0x0
  pushl $72
80106361:	6a 48                	push   $0x48
  jmp alltraps
80106363:	e9 72 f8 ff ff       	jmp    80105bda <alltraps>

80106368 <vector73>:
.globl vector73
vector73:
  pushl $0
80106368:	6a 00                	push   $0x0
  pushl $73
8010636a:	6a 49                	push   $0x49
  jmp alltraps
8010636c:	e9 69 f8 ff ff       	jmp    80105bda <alltraps>

80106371 <vector74>:
.globl vector74
vector74:
  pushl $0
80106371:	6a 00                	push   $0x0
  pushl $74
80106373:	6a 4a                	push   $0x4a
  jmp alltraps
80106375:	e9 60 f8 ff ff       	jmp    80105bda <alltraps>

8010637a <vector75>:
.globl vector75
vector75:
  pushl $0
8010637a:	6a 00                	push   $0x0
  pushl $75
8010637c:	6a 4b                	push   $0x4b
  jmp alltraps
8010637e:	e9 57 f8 ff ff       	jmp    80105bda <alltraps>

80106383 <vector76>:
.globl vector76
vector76:
  pushl $0
80106383:	6a 00                	push   $0x0
  pushl $76
80106385:	6a 4c                	push   $0x4c
  jmp alltraps
80106387:	e9 4e f8 ff ff       	jmp    80105bda <alltraps>

8010638c <vector77>:
.globl vector77
vector77:
  pushl $0
8010638c:	6a 00                	push   $0x0
  pushl $77
8010638e:	6a 4d                	push   $0x4d
  jmp alltraps
80106390:	e9 45 f8 ff ff       	jmp    80105bda <alltraps>

80106395 <vector78>:
.globl vector78
vector78:
  pushl $0
80106395:	6a 00                	push   $0x0
  pushl $78
80106397:	6a 4e                	push   $0x4e
  jmp alltraps
80106399:	e9 3c f8 ff ff       	jmp    80105bda <alltraps>

8010639e <vector79>:
.globl vector79
vector79:
  pushl $0
8010639e:	6a 00                	push   $0x0
  pushl $79
801063a0:	6a 4f                	push   $0x4f
  jmp alltraps
801063a2:	e9 33 f8 ff ff       	jmp    80105bda <alltraps>

801063a7 <vector80>:
.globl vector80
vector80:
  pushl $0
801063a7:	6a 00                	push   $0x0
  pushl $80
801063a9:	6a 50                	push   $0x50
  jmp alltraps
801063ab:	e9 2a f8 ff ff       	jmp    80105bda <alltraps>

801063b0 <vector81>:
.globl vector81
vector81:
  pushl $0
801063b0:	6a 00                	push   $0x0
  pushl $81
801063b2:	6a 51                	push   $0x51
  jmp alltraps
801063b4:	e9 21 f8 ff ff       	jmp    80105bda <alltraps>

801063b9 <vector82>:
.globl vector82
vector82:
  pushl $0
801063b9:	6a 00                	push   $0x0
  pushl $82
801063bb:	6a 52                	push   $0x52
  jmp alltraps
801063bd:	e9 18 f8 ff ff       	jmp    80105bda <alltraps>

801063c2 <vector83>:
.globl vector83
vector83:
  pushl $0
801063c2:	6a 00                	push   $0x0
  pushl $83
801063c4:	6a 53                	push   $0x53
  jmp alltraps
801063c6:	e9 0f f8 ff ff       	jmp    80105bda <alltraps>

801063cb <vector84>:
.globl vector84
vector84:
  pushl $0
801063cb:	6a 00                	push   $0x0
  pushl $84
801063cd:	6a 54                	push   $0x54
  jmp alltraps
801063cf:	e9 06 f8 ff ff       	jmp    80105bda <alltraps>

801063d4 <vector85>:
.globl vector85
vector85:
  pushl $0
801063d4:	6a 00                	push   $0x0
  pushl $85
801063d6:	6a 55                	push   $0x55
  jmp alltraps
801063d8:	e9 fd f7 ff ff       	jmp    80105bda <alltraps>

801063dd <vector86>:
.globl vector86
vector86:
  pushl $0
801063dd:	6a 00                	push   $0x0
  pushl $86
801063df:	6a 56                	push   $0x56
  jmp alltraps
801063e1:	e9 f4 f7 ff ff       	jmp    80105bda <alltraps>

801063e6 <vector87>:
.globl vector87
vector87:
  pushl $0
801063e6:	6a 00                	push   $0x0
  pushl $87
801063e8:	6a 57                	push   $0x57
  jmp alltraps
801063ea:	e9 eb f7 ff ff       	jmp    80105bda <alltraps>

801063ef <vector88>:
.globl vector88
vector88:
  pushl $0
801063ef:	6a 00                	push   $0x0
  pushl $88
801063f1:	6a 58                	push   $0x58
  jmp alltraps
801063f3:	e9 e2 f7 ff ff       	jmp    80105bda <alltraps>

801063f8 <vector89>:
.globl vector89
vector89:
  pushl $0
801063f8:	6a 00                	push   $0x0
  pushl $89
801063fa:	6a 59                	push   $0x59
  jmp alltraps
801063fc:	e9 d9 f7 ff ff       	jmp    80105bda <alltraps>

80106401 <vector90>:
.globl vector90
vector90:
  pushl $0
80106401:	6a 00                	push   $0x0
  pushl $90
80106403:	6a 5a                	push   $0x5a
  jmp alltraps
80106405:	e9 d0 f7 ff ff       	jmp    80105bda <alltraps>

8010640a <vector91>:
.globl vector91
vector91:
  pushl $0
8010640a:	6a 00                	push   $0x0
  pushl $91
8010640c:	6a 5b                	push   $0x5b
  jmp alltraps
8010640e:	e9 c7 f7 ff ff       	jmp    80105bda <alltraps>

80106413 <vector92>:
.globl vector92
vector92:
  pushl $0
80106413:	6a 00                	push   $0x0
  pushl $92
80106415:	6a 5c                	push   $0x5c
  jmp alltraps
80106417:	e9 be f7 ff ff       	jmp    80105bda <alltraps>

8010641c <vector93>:
.globl vector93
vector93:
  pushl $0
8010641c:	6a 00                	push   $0x0
  pushl $93
8010641e:	6a 5d                	push   $0x5d
  jmp alltraps
80106420:	e9 b5 f7 ff ff       	jmp    80105bda <alltraps>

80106425 <vector94>:
.globl vector94
vector94:
  pushl $0
80106425:	6a 00                	push   $0x0
  pushl $94
80106427:	6a 5e                	push   $0x5e
  jmp alltraps
80106429:	e9 ac f7 ff ff       	jmp    80105bda <alltraps>

8010642e <vector95>:
.globl vector95
vector95:
  pushl $0
8010642e:	6a 00                	push   $0x0
  pushl $95
80106430:	6a 5f                	push   $0x5f
  jmp alltraps
80106432:	e9 a3 f7 ff ff       	jmp    80105bda <alltraps>

80106437 <vector96>:
.globl vector96
vector96:
  pushl $0
80106437:	6a 00                	push   $0x0
  pushl $96
80106439:	6a 60                	push   $0x60
  jmp alltraps
8010643b:	e9 9a f7 ff ff       	jmp    80105bda <alltraps>

80106440 <vector97>:
.globl vector97
vector97:
  pushl $0
80106440:	6a 00                	push   $0x0
  pushl $97
80106442:	6a 61                	push   $0x61
  jmp alltraps
80106444:	e9 91 f7 ff ff       	jmp    80105bda <alltraps>

80106449 <vector98>:
.globl vector98
vector98:
  pushl $0
80106449:	6a 00                	push   $0x0
  pushl $98
8010644b:	6a 62                	push   $0x62
  jmp alltraps
8010644d:	e9 88 f7 ff ff       	jmp    80105bda <alltraps>

80106452 <vector99>:
.globl vector99
vector99:
  pushl $0
80106452:	6a 00                	push   $0x0
  pushl $99
80106454:	6a 63                	push   $0x63
  jmp alltraps
80106456:	e9 7f f7 ff ff       	jmp    80105bda <alltraps>

8010645b <vector100>:
.globl vector100
vector100:
  pushl $0
8010645b:	6a 00                	push   $0x0
  pushl $100
8010645d:	6a 64                	push   $0x64
  jmp alltraps
8010645f:	e9 76 f7 ff ff       	jmp    80105bda <alltraps>

80106464 <vector101>:
.globl vector101
vector101:
  pushl $0
80106464:	6a 00                	push   $0x0
  pushl $101
80106466:	6a 65                	push   $0x65
  jmp alltraps
80106468:	e9 6d f7 ff ff       	jmp    80105bda <alltraps>

8010646d <vector102>:
.globl vector102
vector102:
  pushl $0
8010646d:	6a 00                	push   $0x0
  pushl $102
8010646f:	6a 66                	push   $0x66
  jmp alltraps
80106471:	e9 64 f7 ff ff       	jmp    80105bda <alltraps>

80106476 <vector103>:
.globl vector103
vector103:
  pushl $0
80106476:	6a 00                	push   $0x0
  pushl $103
80106478:	6a 67                	push   $0x67
  jmp alltraps
8010647a:	e9 5b f7 ff ff       	jmp    80105bda <alltraps>

8010647f <vector104>:
.globl vector104
vector104:
  pushl $0
8010647f:	6a 00                	push   $0x0
  pushl $104
80106481:	6a 68                	push   $0x68
  jmp alltraps
80106483:	e9 52 f7 ff ff       	jmp    80105bda <alltraps>

80106488 <vector105>:
.globl vector105
vector105:
  pushl $0
80106488:	6a 00                	push   $0x0
  pushl $105
8010648a:	6a 69                	push   $0x69
  jmp alltraps
8010648c:	e9 49 f7 ff ff       	jmp    80105bda <alltraps>

80106491 <vector106>:
.globl vector106
vector106:
  pushl $0
80106491:	6a 00                	push   $0x0
  pushl $106
80106493:	6a 6a                	push   $0x6a
  jmp alltraps
80106495:	e9 40 f7 ff ff       	jmp    80105bda <alltraps>

8010649a <vector107>:
.globl vector107
vector107:
  pushl $0
8010649a:	6a 00                	push   $0x0
  pushl $107
8010649c:	6a 6b                	push   $0x6b
  jmp alltraps
8010649e:	e9 37 f7 ff ff       	jmp    80105bda <alltraps>

801064a3 <vector108>:
.globl vector108
vector108:
  pushl $0
801064a3:	6a 00                	push   $0x0
  pushl $108
801064a5:	6a 6c                	push   $0x6c
  jmp alltraps
801064a7:	e9 2e f7 ff ff       	jmp    80105bda <alltraps>

801064ac <vector109>:
.globl vector109
vector109:
  pushl $0
801064ac:	6a 00                	push   $0x0
  pushl $109
801064ae:	6a 6d                	push   $0x6d
  jmp alltraps
801064b0:	e9 25 f7 ff ff       	jmp    80105bda <alltraps>

801064b5 <vector110>:
.globl vector110
vector110:
  pushl $0
801064b5:	6a 00                	push   $0x0
  pushl $110
801064b7:	6a 6e                	push   $0x6e
  jmp alltraps
801064b9:	e9 1c f7 ff ff       	jmp    80105bda <alltraps>

801064be <vector111>:
.globl vector111
vector111:
  pushl $0
801064be:	6a 00                	push   $0x0
  pushl $111
801064c0:	6a 6f                	push   $0x6f
  jmp alltraps
801064c2:	e9 13 f7 ff ff       	jmp    80105bda <alltraps>

801064c7 <vector112>:
.globl vector112
vector112:
  pushl $0
801064c7:	6a 00                	push   $0x0
  pushl $112
801064c9:	6a 70                	push   $0x70
  jmp alltraps
801064cb:	e9 0a f7 ff ff       	jmp    80105bda <alltraps>

801064d0 <vector113>:
.globl vector113
vector113:
  pushl $0
801064d0:	6a 00                	push   $0x0
  pushl $113
801064d2:	6a 71                	push   $0x71
  jmp alltraps
801064d4:	e9 01 f7 ff ff       	jmp    80105bda <alltraps>

801064d9 <vector114>:
.globl vector114
vector114:
  pushl $0
801064d9:	6a 00                	push   $0x0
  pushl $114
801064db:	6a 72                	push   $0x72
  jmp alltraps
801064dd:	e9 f8 f6 ff ff       	jmp    80105bda <alltraps>

801064e2 <vector115>:
.globl vector115
vector115:
  pushl $0
801064e2:	6a 00                	push   $0x0
  pushl $115
801064e4:	6a 73                	push   $0x73
  jmp alltraps
801064e6:	e9 ef f6 ff ff       	jmp    80105bda <alltraps>

801064eb <vector116>:
.globl vector116
vector116:
  pushl $0
801064eb:	6a 00                	push   $0x0
  pushl $116
801064ed:	6a 74                	push   $0x74
  jmp alltraps
801064ef:	e9 e6 f6 ff ff       	jmp    80105bda <alltraps>

801064f4 <vector117>:
.globl vector117
vector117:
  pushl $0
801064f4:	6a 00                	push   $0x0
  pushl $117
801064f6:	6a 75                	push   $0x75
  jmp alltraps
801064f8:	e9 dd f6 ff ff       	jmp    80105bda <alltraps>

801064fd <vector118>:
.globl vector118
vector118:
  pushl $0
801064fd:	6a 00                	push   $0x0
  pushl $118
801064ff:	6a 76                	push   $0x76
  jmp alltraps
80106501:	e9 d4 f6 ff ff       	jmp    80105bda <alltraps>

80106506 <vector119>:
.globl vector119
vector119:
  pushl $0
80106506:	6a 00                	push   $0x0
  pushl $119
80106508:	6a 77                	push   $0x77
  jmp alltraps
8010650a:	e9 cb f6 ff ff       	jmp    80105bda <alltraps>

8010650f <vector120>:
.globl vector120
vector120:
  pushl $0
8010650f:	6a 00                	push   $0x0
  pushl $120
80106511:	6a 78                	push   $0x78
  jmp alltraps
80106513:	e9 c2 f6 ff ff       	jmp    80105bda <alltraps>

80106518 <vector121>:
.globl vector121
vector121:
  pushl $0
80106518:	6a 00                	push   $0x0
  pushl $121
8010651a:	6a 79                	push   $0x79
  jmp alltraps
8010651c:	e9 b9 f6 ff ff       	jmp    80105bda <alltraps>

80106521 <vector122>:
.globl vector122
vector122:
  pushl $0
80106521:	6a 00                	push   $0x0
  pushl $122
80106523:	6a 7a                	push   $0x7a
  jmp alltraps
80106525:	e9 b0 f6 ff ff       	jmp    80105bda <alltraps>

8010652a <vector123>:
.globl vector123
vector123:
  pushl $0
8010652a:	6a 00                	push   $0x0
  pushl $123
8010652c:	6a 7b                	push   $0x7b
  jmp alltraps
8010652e:	e9 a7 f6 ff ff       	jmp    80105bda <alltraps>

80106533 <vector124>:
.globl vector124
vector124:
  pushl $0
80106533:	6a 00                	push   $0x0
  pushl $124
80106535:	6a 7c                	push   $0x7c
  jmp alltraps
80106537:	e9 9e f6 ff ff       	jmp    80105bda <alltraps>

8010653c <vector125>:
.globl vector125
vector125:
  pushl $0
8010653c:	6a 00                	push   $0x0
  pushl $125
8010653e:	6a 7d                	push   $0x7d
  jmp alltraps
80106540:	e9 95 f6 ff ff       	jmp    80105bda <alltraps>

80106545 <vector126>:
.globl vector126
vector126:
  pushl $0
80106545:	6a 00                	push   $0x0
  pushl $126
80106547:	6a 7e                	push   $0x7e
  jmp alltraps
80106549:	e9 8c f6 ff ff       	jmp    80105bda <alltraps>

8010654e <vector127>:
.globl vector127
vector127:
  pushl $0
8010654e:	6a 00                	push   $0x0
  pushl $127
80106550:	6a 7f                	push   $0x7f
  jmp alltraps
80106552:	e9 83 f6 ff ff       	jmp    80105bda <alltraps>

80106557 <vector128>:
.globl vector128
vector128:
  pushl $0
80106557:	6a 00                	push   $0x0
  pushl $128
80106559:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010655e:	e9 77 f6 ff ff       	jmp    80105bda <alltraps>

80106563 <vector129>:
.globl vector129
vector129:
  pushl $0
80106563:	6a 00                	push   $0x0
  pushl $129
80106565:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010656a:	e9 6b f6 ff ff       	jmp    80105bda <alltraps>

8010656f <vector130>:
.globl vector130
vector130:
  pushl $0
8010656f:	6a 00                	push   $0x0
  pushl $130
80106571:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106576:	e9 5f f6 ff ff       	jmp    80105bda <alltraps>

8010657b <vector131>:
.globl vector131
vector131:
  pushl $0
8010657b:	6a 00                	push   $0x0
  pushl $131
8010657d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106582:	e9 53 f6 ff ff       	jmp    80105bda <alltraps>

80106587 <vector132>:
.globl vector132
vector132:
  pushl $0
80106587:	6a 00                	push   $0x0
  pushl $132
80106589:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010658e:	e9 47 f6 ff ff       	jmp    80105bda <alltraps>

80106593 <vector133>:
.globl vector133
vector133:
  pushl $0
80106593:	6a 00                	push   $0x0
  pushl $133
80106595:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010659a:	e9 3b f6 ff ff       	jmp    80105bda <alltraps>

8010659f <vector134>:
.globl vector134
vector134:
  pushl $0
8010659f:	6a 00                	push   $0x0
  pushl $134
801065a1:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801065a6:	e9 2f f6 ff ff       	jmp    80105bda <alltraps>

801065ab <vector135>:
.globl vector135
vector135:
  pushl $0
801065ab:	6a 00                	push   $0x0
  pushl $135
801065ad:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801065b2:	e9 23 f6 ff ff       	jmp    80105bda <alltraps>

801065b7 <vector136>:
.globl vector136
vector136:
  pushl $0
801065b7:	6a 00                	push   $0x0
  pushl $136
801065b9:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801065be:	e9 17 f6 ff ff       	jmp    80105bda <alltraps>

801065c3 <vector137>:
.globl vector137
vector137:
  pushl $0
801065c3:	6a 00                	push   $0x0
  pushl $137
801065c5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801065ca:	e9 0b f6 ff ff       	jmp    80105bda <alltraps>

801065cf <vector138>:
.globl vector138
vector138:
  pushl $0
801065cf:	6a 00                	push   $0x0
  pushl $138
801065d1:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801065d6:	e9 ff f5 ff ff       	jmp    80105bda <alltraps>

801065db <vector139>:
.globl vector139
vector139:
  pushl $0
801065db:	6a 00                	push   $0x0
  pushl $139
801065dd:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801065e2:	e9 f3 f5 ff ff       	jmp    80105bda <alltraps>

801065e7 <vector140>:
.globl vector140
vector140:
  pushl $0
801065e7:	6a 00                	push   $0x0
  pushl $140
801065e9:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801065ee:	e9 e7 f5 ff ff       	jmp    80105bda <alltraps>

801065f3 <vector141>:
.globl vector141
vector141:
  pushl $0
801065f3:	6a 00                	push   $0x0
  pushl $141
801065f5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801065fa:	e9 db f5 ff ff       	jmp    80105bda <alltraps>

801065ff <vector142>:
.globl vector142
vector142:
  pushl $0
801065ff:	6a 00                	push   $0x0
  pushl $142
80106601:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106606:	e9 cf f5 ff ff       	jmp    80105bda <alltraps>

8010660b <vector143>:
.globl vector143
vector143:
  pushl $0
8010660b:	6a 00                	push   $0x0
  pushl $143
8010660d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106612:	e9 c3 f5 ff ff       	jmp    80105bda <alltraps>

80106617 <vector144>:
.globl vector144
vector144:
  pushl $0
80106617:	6a 00                	push   $0x0
  pushl $144
80106619:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010661e:	e9 b7 f5 ff ff       	jmp    80105bda <alltraps>

80106623 <vector145>:
.globl vector145
vector145:
  pushl $0
80106623:	6a 00                	push   $0x0
  pushl $145
80106625:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010662a:	e9 ab f5 ff ff       	jmp    80105bda <alltraps>

8010662f <vector146>:
.globl vector146
vector146:
  pushl $0
8010662f:	6a 00                	push   $0x0
  pushl $146
80106631:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106636:	e9 9f f5 ff ff       	jmp    80105bda <alltraps>

8010663b <vector147>:
.globl vector147
vector147:
  pushl $0
8010663b:	6a 00                	push   $0x0
  pushl $147
8010663d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106642:	e9 93 f5 ff ff       	jmp    80105bda <alltraps>

80106647 <vector148>:
.globl vector148
vector148:
  pushl $0
80106647:	6a 00                	push   $0x0
  pushl $148
80106649:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010664e:	e9 87 f5 ff ff       	jmp    80105bda <alltraps>

80106653 <vector149>:
.globl vector149
vector149:
  pushl $0
80106653:	6a 00                	push   $0x0
  pushl $149
80106655:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010665a:	e9 7b f5 ff ff       	jmp    80105bda <alltraps>

8010665f <vector150>:
.globl vector150
vector150:
  pushl $0
8010665f:	6a 00                	push   $0x0
  pushl $150
80106661:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106666:	e9 6f f5 ff ff       	jmp    80105bda <alltraps>

8010666b <vector151>:
.globl vector151
vector151:
  pushl $0
8010666b:	6a 00                	push   $0x0
  pushl $151
8010666d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106672:	e9 63 f5 ff ff       	jmp    80105bda <alltraps>

80106677 <vector152>:
.globl vector152
vector152:
  pushl $0
80106677:	6a 00                	push   $0x0
  pushl $152
80106679:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010667e:	e9 57 f5 ff ff       	jmp    80105bda <alltraps>

80106683 <vector153>:
.globl vector153
vector153:
  pushl $0
80106683:	6a 00                	push   $0x0
  pushl $153
80106685:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010668a:	e9 4b f5 ff ff       	jmp    80105bda <alltraps>

8010668f <vector154>:
.globl vector154
vector154:
  pushl $0
8010668f:	6a 00                	push   $0x0
  pushl $154
80106691:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106696:	e9 3f f5 ff ff       	jmp    80105bda <alltraps>

8010669b <vector155>:
.globl vector155
vector155:
  pushl $0
8010669b:	6a 00                	push   $0x0
  pushl $155
8010669d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801066a2:	e9 33 f5 ff ff       	jmp    80105bda <alltraps>

801066a7 <vector156>:
.globl vector156
vector156:
  pushl $0
801066a7:	6a 00                	push   $0x0
  pushl $156
801066a9:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801066ae:	e9 27 f5 ff ff       	jmp    80105bda <alltraps>

801066b3 <vector157>:
.globl vector157
vector157:
  pushl $0
801066b3:	6a 00                	push   $0x0
  pushl $157
801066b5:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801066ba:	e9 1b f5 ff ff       	jmp    80105bda <alltraps>

801066bf <vector158>:
.globl vector158
vector158:
  pushl $0
801066bf:	6a 00                	push   $0x0
  pushl $158
801066c1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801066c6:	e9 0f f5 ff ff       	jmp    80105bda <alltraps>

801066cb <vector159>:
.globl vector159
vector159:
  pushl $0
801066cb:	6a 00                	push   $0x0
  pushl $159
801066cd:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801066d2:	e9 03 f5 ff ff       	jmp    80105bda <alltraps>

801066d7 <vector160>:
.globl vector160
vector160:
  pushl $0
801066d7:	6a 00                	push   $0x0
  pushl $160
801066d9:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801066de:	e9 f7 f4 ff ff       	jmp    80105bda <alltraps>

801066e3 <vector161>:
.globl vector161
vector161:
  pushl $0
801066e3:	6a 00                	push   $0x0
  pushl $161
801066e5:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801066ea:	e9 eb f4 ff ff       	jmp    80105bda <alltraps>

801066ef <vector162>:
.globl vector162
vector162:
  pushl $0
801066ef:	6a 00                	push   $0x0
  pushl $162
801066f1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801066f6:	e9 df f4 ff ff       	jmp    80105bda <alltraps>

801066fb <vector163>:
.globl vector163
vector163:
  pushl $0
801066fb:	6a 00                	push   $0x0
  pushl $163
801066fd:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106702:	e9 d3 f4 ff ff       	jmp    80105bda <alltraps>

80106707 <vector164>:
.globl vector164
vector164:
  pushl $0
80106707:	6a 00                	push   $0x0
  pushl $164
80106709:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010670e:	e9 c7 f4 ff ff       	jmp    80105bda <alltraps>

80106713 <vector165>:
.globl vector165
vector165:
  pushl $0
80106713:	6a 00                	push   $0x0
  pushl $165
80106715:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010671a:	e9 bb f4 ff ff       	jmp    80105bda <alltraps>

8010671f <vector166>:
.globl vector166
vector166:
  pushl $0
8010671f:	6a 00                	push   $0x0
  pushl $166
80106721:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106726:	e9 af f4 ff ff       	jmp    80105bda <alltraps>

8010672b <vector167>:
.globl vector167
vector167:
  pushl $0
8010672b:	6a 00                	push   $0x0
  pushl $167
8010672d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106732:	e9 a3 f4 ff ff       	jmp    80105bda <alltraps>

80106737 <vector168>:
.globl vector168
vector168:
  pushl $0
80106737:	6a 00                	push   $0x0
  pushl $168
80106739:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010673e:	e9 97 f4 ff ff       	jmp    80105bda <alltraps>

80106743 <vector169>:
.globl vector169
vector169:
  pushl $0
80106743:	6a 00                	push   $0x0
  pushl $169
80106745:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010674a:	e9 8b f4 ff ff       	jmp    80105bda <alltraps>

8010674f <vector170>:
.globl vector170
vector170:
  pushl $0
8010674f:	6a 00                	push   $0x0
  pushl $170
80106751:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106756:	e9 7f f4 ff ff       	jmp    80105bda <alltraps>

8010675b <vector171>:
.globl vector171
vector171:
  pushl $0
8010675b:	6a 00                	push   $0x0
  pushl $171
8010675d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106762:	e9 73 f4 ff ff       	jmp    80105bda <alltraps>

80106767 <vector172>:
.globl vector172
vector172:
  pushl $0
80106767:	6a 00                	push   $0x0
  pushl $172
80106769:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010676e:	e9 67 f4 ff ff       	jmp    80105bda <alltraps>

80106773 <vector173>:
.globl vector173
vector173:
  pushl $0
80106773:	6a 00                	push   $0x0
  pushl $173
80106775:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010677a:	e9 5b f4 ff ff       	jmp    80105bda <alltraps>

8010677f <vector174>:
.globl vector174
vector174:
  pushl $0
8010677f:	6a 00                	push   $0x0
  pushl $174
80106781:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106786:	e9 4f f4 ff ff       	jmp    80105bda <alltraps>

8010678b <vector175>:
.globl vector175
vector175:
  pushl $0
8010678b:	6a 00                	push   $0x0
  pushl $175
8010678d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106792:	e9 43 f4 ff ff       	jmp    80105bda <alltraps>

80106797 <vector176>:
.globl vector176
vector176:
  pushl $0
80106797:	6a 00                	push   $0x0
  pushl $176
80106799:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010679e:	e9 37 f4 ff ff       	jmp    80105bda <alltraps>

801067a3 <vector177>:
.globl vector177
vector177:
  pushl $0
801067a3:	6a 00                	push   $0x0
  pushl $177
801067a5:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801067aa:	e9 2b f4 ff ff       	jmp    80105bda <alltraps>

801067af <vector178>:
.globl vector178
vector178:
  pushl $0
801067af:	6a 00                	push   $0x0
  pushl $178
801067b1:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801067b6:	e9 1f f4 ff ff       	jmp    80105bda <alltraps>

801067bb <vector179>:
.globl vector179
vector179:
  pushl $0
801067bb:	6a 00                	push   $0x0
  pushl $179
801067bd:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801067c2:	e9 13 f4 ff ff       	jmp    80105bda <alltraps>

801067c7 <vector180>:
.globl vector180
vector180:
  pushl $0
801067c7:	6a 00                	push   $0x0
  pushl $180
801067c9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801067ce:	e9 07 f4 ff ff       	jmp    80105bda <alltraps>

801067d3 <vector181>:
.globl vector181
vector181:
  pushl $0
801067d3:	6a 00                	push   $0x0
  pushl $181
801067d5:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801067da:	e9 fb f3 ff ff       	jmp    80105bda <alltraps>

801067df <vector182>:
.globl vector182
vector182:
  pushl $0
801067df:	6a 00                	push   $0x0
  pushl $182
801067e1:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801067e6:	e9 ef f3 ff ff       	jmp    80105bda <alltraps>

801067eb <vector183>:
.globl vector183
vector183:
  pushl $0
801067eb:	6a 00                	push   $0x0
  pushl $183
801067ed:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801067f2:	e9 e3 f3 ff ff       	jmp    80105bda <alltraps>

801067f7 <vector184>:
.globl vector184
vector184:
  pushl $0
801067f7:	6a 00                	push   $0x0
  pushl $184
801067f9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801067fe:	e9 d7 f3 ff ff       	jmp    80105bda <alltraps>

80106803 <vector185>:
.globl vector185
vector185:
  pushl $0
80106803:	6a 00                	push   $0x0
  pushl $185
80106805:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010680a:	e9 cb f3 ff ff       	jmp    80105bda <alltraps>

8010680f <vector186>:
.globl vector186
vector186:
  pushl $0
8010680f:	6a 00                	push   $0x0
  pushl $186
80106811:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106816:	e9 bf f3 ff ff       	jmp    80105bda <alltraps>

8010681b <vector187>:
.globl vector187
vector187:
  pushl $0
8010681b:	6a 00                	push   $0x0
  pushl $187
8010681d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106822:	e9 b3 f3 ff ff       	jmp    80105bda <alltraps>

80106827 <vector188>:
.globl vector188
vector188:
  pushl $0
80106827:	6a 00                	push   $0x0
  pushl $188
80106829:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010682e:	e9 a7 f3 ff ff       	jmp    80105bda <alltraps>

80106833 <vector189>:
.globl vector189
vector189:
  pushl $0
80106833:	6a 00                	push   $0x0
  pushl $189
80106835:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010683a:	e9 9b f3 ff ff       	jmp    80105bda <alltraps>

8010683f <vector190>:
.globl vector190
vector190:
  pushl $0
8010683f:	6a 00                	push   $0x0
  pushl $190
80106841:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106846:	e9 8f f3 ff ff       	jmp    80105bda <alltraps>

8010684b <vector191>:
.globl vector191
vector191:
  pushl $0
8010684b:	6a 00                	push   $0x0
  pushl $191
8010684d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106852:	e9 83 f3 ff ff       	jmp    80105bda <alltraps>

80106857 <vector192>:
.globl vector192
vector192:
  pushl $0
80106857:	6a 00                	push   $0x0
  pushl $192
80106859:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010685e:	e9 77 f3 ff ff       	jmp    80105bda <alltraps>

80106863 <vector193>:
.globl vector193
vector193:
  pushl $0
80106863:	6a 00                	push   $0x0
  pushl $193
80106865:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010686a:	e9 6b f3 ff ff       	jmp    80105bda <alltraps>

8010686f <vector194>:
.globl vector194
vector194:
  pushl $0
8010686f:	6a 00                	push   $0x0
  pushl $194
80106871:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106876:	e9 5f f3 ff ff       	jmp    80105bda <alltraps>

8010687b <vector195>:
.globl vector195
vector195:
  pushl $0
8010687b:	6a 00                	push   $0x0
  pushl $195
8010687d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106882:	e9 53 f3 ff ff       	jmp    80105bda <alltraps>

80106887 <vector196>:
.globl vector196
vector196:
  pushl $0
80106887:	6a 00                	push   $0x0
  pushl $196
80106889:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010688e:	e9 47 f3 ff ff       	jmp    80105bda <alltraps>

80106893 <vector197>:
.globl vector197
vector197:
  pushl $0
80106893:	6a 00                	push   $0x0
  pushl $197
80106895:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010689a:	e9 3b f3 ff ff       	jmp    80105bda <alltraps>

8010689f <vector198>:
.globl vector198
vector198:
  pushl $0
8010689f:	6a 00                	push   $0x0
  pushl $198
801068a1:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801068a6:	e9 2f f3 ff ff       	jmp    80105bda <alltraps>

801068ab <vector199>:
.globl vector199
vector199:
  pushl $0
801068ab:	6a 00                	push   $0x0
  pushl $199
801068ad:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801068b2:	e9 23 f3 ff ff       	jmp    80105bda <alltraps>

801068b7 <vector200>:
.globl vector200
vector200:
  pushl $0
801068b7:	6a 00                	push   $0x0
  pushl $200
801068b9:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801068be:	e9 17 f3 ff ff       	jmp    80105bda <alltraps>

801068c3 <vector201>:
.globl vector201
vector201:
  pushl $0
801068c3:	6a 00                	push   $0x0
  pushl $201
801068c5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801068ca:	e9 0b f3 ff ff       	jmp    80105bda <alltraps>

801068cf <vector202>:
.globl vector202
vector202:
  pushl $0
801068cf:	6a 00                	push   $0x0
  pushl $202
801068d1:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801068d6:	e9 ff f2 ff ff       	jmp    80105bda <alltraps>

801068db <vector203>:
.globl vector203
vector203:
  pushl $0
801068db:	6a 00                	push   $0x0
  pushl $203
801068dd:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801068e2:	e9 f3 f2 ff ff       	jmp    80105bda <alltraps>

801068e7 <vector204>:
.globl vector204
vector204:
  pushl $0
801068e7:	6a 00                	push   $0x0
  pushl $204
801068e9:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801068ee:	e9 e7 f2 ff ff       	jmp    80105bda <alltraps>

801068f3 <vector205>:
.globl vector205
vector205:
  pushl $0
801068f3:	6a 00                	push   $0x0
  pushl $205
801068f5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801068fa:	e9 db f2 ff ff       	jmp    80105bda <alltraps>

801068ff <vector206>:
.globl vector206
vector206:
  pushl $0
801068ff:	6a 00                	push   $0x0
  pushl $206
80106901:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106906:	e9 cf f2 ff ff       	jmp    80105bda <alltraps>

8010690b <vector207>:
.globl vector207
vector207:
  pushl $0
8010690b:	6a 00                	push   $0x0
  pushl $207
8010690d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106912:	e9 c3 f2 ff ff       	jmp    80105bda <alltraps>

80106917 <vector208>:
.globl vector208
vector208:
  pushl $0
80106917:	6a 00                	push   $0x0
  pushl $208
80106919:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010691e:	e9 b7 f2 ff ff       	jmp    80105bda <alltraps>

80106923 <vector209>:
.globl vector209
vector209:
  pushl $0
80106923:	6a 00                	push   $0x0
  pushl $209
80106925:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010692a:	e9 ab f2 ff ff       	jmp    80105bda <alltraps>

8010692f <vector210>:
.globl vector210
vector210:
  pushl $0
8010692f:	6a 00                	push   $0x0
  pushl $210
80106931:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106936:	e9 9f f2 ff ff       	jmp    80105bda <alltraps>

8010693b <vector211>:
.globl vector211
vector211:
  pushl $0
8010693b:	6a 00                	push   $0x0
  pushl $211
8010693d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106942:	e9 93 f2 ff ff       	jmp    80105bda <alltraps>

80106947 <vector212>:
.globl vector212
vector212:
  pushl $0
80106947:	6a 00                	push   $0x0
  pushl $212
80106949:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010694e:	e9 87 f2 ff ff       	jmp    80105bda <alltraps>

80106953 <vector213>:
.globl vector213
vector213:
  pushl $0
80106953:	6a 00                	push   $0x0
  pushl $213
80106955:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010695a:	e9 7b f2 ff ff       	jmp    80105bda <alltraps>

8010695f <vector214>:
.globl vector214
vector214:
  pushl $0
8010695f:	6a 00                	push   $0x0
  pushl $214
80106961:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106966:	e9 6f f2 ff ff       	jmp    80105bda <alltraps>

8010696b <vector215>:
.globl vector215
vector215:
  pushl $0
8010696b:	6a 00                	push   $0x0
  pushl $215
8010696d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106972:	e9 63 f2 ff ff       	jmp    80105bda <alltraps>

80106977 <vector216>:
.globl vector216
vector216:
  pushl $0
80106977:	6a 00                	push   $0x0
  pushl $216
80106979:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010697e:	e9 57 f2 ff ff       	jmp    80105bda <alltraps>

80106983 <vector217>:
.globl vector217
vector217:
  pushl $0
80106983:	6a 00                	push   $0x0
  pushl $217
80106985:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010698a:	e9 4b f2 ff ff       	jmp    80105bda <alltraps>

8010698f <vector218>:
.globl vector218
vector218:
  pushl $0
8010698f:	6a 00                	push   $0x0
  pushl $218
80106991:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106996:	e9 3f f2 ff ff       	jmp    80105bda <alltraps>

8010699b <vector219>:
.globl vector219
vector219:
  pushl $0
8010699b:	6a 00                	push   $0x0
  pushl $219
8010699d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801069a2:	e9 33 f2 ff ff       	jmp    80105bda <alltraps>

801069a7 <vector220>:
.globl vector220
vector220:
  pushl $0
801069a7:	6a 00                	push   $0x0
  pushl $220
801069a9:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801069ae:	e9 27 f2 ff ff       	jmp    80105bda <alltraps>

801069b3 <vector221>:
.globl vector221
vector221:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $221
801069b5:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801069ba:	e9 1b f2 ff ff       	jmp    80105bda <alltraps>

801069bf <vector222>:
.globl vector222
vector222:
  pushl $0
801069bf:	6a 00                	push   $0x0
  pushl $222
801069c1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801069c6:	e9 0f f2 ff ff       	jmp    80105bda <alltraps>

801069cb <vector223>:
.globl vector223
vector223:
  pushl $0
801069cb:	6a 00                	push   $0x0
  pushl $223
801069cd:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801069d2:	e9 03 f2 ff ff       	jmp    80105bda <alltraps>

801069d7 <vector224>:
.globl vector224
vector224:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $224
801069d9:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801069de:	e9 f7 f1 ff ff       	jmp    80105bda <alltraps>

801069e3 <vector225>:
.globl vector225
vector225:
  pushl $0
801069e3:	6a 00                	push   $0x0
  pushl $225
801069e5:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801069ea:	e9 eb f1 ff ff       	jmp    80105bda <alltraps>

801069ef <vector226>:
.globl vector226
vector226:
  pushl $0
801069ef:	6a 00                	push   $0x0
  pushl $226
801069f1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801069f6:	e9 df f1 ff ff       	jmp    80105bda <alltraps>

801069fb <vector227>:
.globl vector227
vector227:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $227
801069fd:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106a02:	e9 d3 f1 ff ff       	jmp    80105bda <alltraps>

80106a07 <vector228>:
.globl vector228
vector228:
  pushl $0
80106a07:	6a 00                	push   $0x0
  pushl $228
80106a09:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106a0e:	e9 c7 f1 ff ff       	jmp    80105bda <alltraps>

80106a13 <vector229>:
.globl vector229
vector229:
  pushl $0
80106a13:	6a 00                	push   $0x0
  pushl $229
80106a15:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106a1a:	e9 bb f1 ff ff       	jmp    80105bda <alltraps>

80106a1f <vector230>:
.globl vector230
vector230:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $230
80106a21:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106a26:	e9 af f1 ff ff       	jmp    80105bda <alltraps>

80106a2b <vector231>:
.globl vector231
vector231:
  pushl $0
80106a2b:	6a 00                	push   $0x0
  pushl $231
80106a2d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106a32:	e9 a3 f1 ff ff       	jmp    80105bda <alltraps>

80106a37 <vector232>:
.globl vector232
vector232:
  pushl $0
80106a37:	6a 00                	push   $0x0
  pushl $232
80106a39:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106a3e:	e9 97 f1 ff ff       	jmp    80105bda <alltraps>

80106a43 <vector233>:
.globl vector233
vector233:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $233
80106a45:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106a4a:	e9 8b f1 ff ff       	jmp    80105bda <alltraps>

80106a4f <vector234>:
.globl vector234
vector234:
  pushl $0
80106a4f:	6a 00                	push   $0x0
  pushl $234
80106a51:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106a56:	e9 7f f1 ff ff       	jmp    80105bda <alltraps>

80106a5b <vector235>:
.globl vector235
vector235:
  pushl $0
80106a5b:	6a 00                	push   $0x0
  pushl $235
80106a5d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106a62:	e9 73 f1 ff ff       	jmp    80105bda <alltraps>

80106a67 <vector236>:
.globl vector236
vector236:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $236
80106a69:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106a6e:	e9 67 f1 ff ff       	jmp    80105bda <alltraps>

80106a73 <vector237>:
.globl vector237
vector237:
  pushl $0
80106a73:	6a 00                	push   $0x0
  pushl $237
80106a75:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106a7a:	e9 5b f1 ff ff       	jmp    80105bda <alltraps>

80106a7f <vector238>:
.globl vector238
vector238:
  pushl $0
80106a7f:	6a 00                	push   $0x0
  pushl $238
80106a81:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106a86:	e9 4f f1 ff ff       	jmp    80105bda <alltraps>

80106a8b <vector239>:
.globl vector239
vector239:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $239
80106a8d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106a92:	e9 43 f1 ff ff       	jmp    80105bda <alltraps>

80106a97 <vector240>:
.globl vector240
vector240:
  pushl $0
80106a97:	6a 00                	push   $0x0
  pushl $240
80106a99:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106a9e:	e9 37 f1 ff ff       	jmp    80105bda <alltraps>

80106aa3 <vector241>:
.globl vector241
vector241:
  pushl $0
80106aa3:	6a 00                	push   $0x0
  pushl $241
80106aa5:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106aaa:	e9 2b f1 ff ff       	jmp    80105bda <alltraps>

80106aaf <vector242>:
.globl vector242
vector242:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $242
80106ab1:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106ab6:	e9 1f f1 ff ff       	jmp    80105bda <alltraps>

80106abb <vector243>:
.globl vector243
vector243:
  pushl $0
80106abb:	6a 00                	push   $0x0
  pushl $243
80106abd:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106ac2:	e9 13 f1 ff ff       	jmp    80105bda <alltraps>

80106ac7 <vector244>:
.globl vector244
vector244:
  pushl $0
80106ac7:	6a 00                	push   $0x0
  pushl $244
80106ac9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106ace:	e9 07 f1 ff ff       	jmp    80105bda <alltraps>

80106ad3 <vector245>:
.globl vector245
vector245:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $245
80106ad5:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106ada:	e9 fb f0 ff ff       	jmp    80105bda <alltraps>

80106adf <vector246>:
.globl vector246
vector246:
  pushl $0
80106adf:	6a 00                	push   $0x0
  pushl $246
80106ae1:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106ae6:	e9 ef f0 ff ff       	jmp    80105bda <alltraps>

80106aeb <vector247>:
.globl vector247
vector247:
  pushl $0
80106aeb:	6a 00                	push   $0x0
  pushl $247
80106aed:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106af2:	e9 e3 f0 ff ff       	jmp    80105bda <alltraps>

80106af7 <vector248>:
.globl vector248
vector248:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $248
80106af9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106afe:	e9 d7 f0 ff ff       	jmp    80105bda <alltraps>

80106b03 <vector249>:
.globl vector249
vector249:
  pushl $0
80106b03:	6a 00                	push   $0x0
  pushl $249
80106b05:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106b0a:	e9 cb f0 ff ff       	jmp    80105bda <alltraps>

80106b0f <vector250>:
.globl vector250
vector250:
  pushl $0
80106b0f:	6a 00                	push   $0x0
  pushl $250
80106b11:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106b16:	e9 bf f0 ff ff       	jmp    80105bda <alltraps>

80106b1b <vector251>:
.globl vector251
vector251:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $251
80106b1d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106b22:	e9 b3 f0 ff ff       	jmp    80105bda <alltraps>

80106b27 <vector252>:
.globl vector252
vector252:
  pushl $0
80106b27:	6a 00                	push   $0x0
  pushl $252
80106b29:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106b2e:	e9 a7 f0 ff ff       	jmp    80105bda <alltraps>

80106b33 <vector253>:
.globl vector253
vector253:
  pushl $0
80106b33:	6a 00                	push   $0x0
  pushl $253
80106b35:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106b3a:	e9 9b f0 ff ff       	jmp    80105bda <alltraps>

80106b3f <vector254>:
.globl vector254
vector254:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $254
80106b41:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106b46:	e9 8f f0 ff ff       	jmp    80105bda <alltraps>

80106b4b <vector255>:
.globl vector255
vector255:
  pushl $0
80106b4b:	6a 00                	push   $0x0
  pushl $255
80106b4d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106b52:	e9 83 f0 ff ff       	jmp    80105bda <alltraps>
80106b57:	66 90                	xchg   %ax,%ax
80106b59:	66 90                	xchg   %ax,%ax
80106b5b:	66 90                	xchg   %ax,%ax
80106b5d:	66 90                	xchg   %ax,%ax
80106b5f:	90                   	nop

80106b60 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106b60:	55                   	push   %ebp
80106b61:	89 e5                	mov    %esp,%ebp
80106b63:	57                   	push   %edi
80106b64:	56                   	push   %esi
80106b65:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80106b66:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
80106b6c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106b72:	83 ec 1c             	sub    $0x1c,%esp
80106b75:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106b78:	39 d3                	cmp    %edx,%ebx
80106b7a:	73 49                	jae    80106bc5 <deallocuvm.part.0+0x65>
80106b7c:	89 c7                	mov    %eax,%edi
80106b7e:	eb 0c                	jmp    80106b8c <deallocuvm.part.0+0x2c>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106b80:	83 c0 01             	add    $0x1,%eax
80106b83:	c1 e0 16             	shl    $0x16,%eax
80106b86:	89 c3                	mov    %eax,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106b88:	39 da                	cmp    %ebx,%edx
80106b8a:	76 39                	jbe    80106bc5 <deallocuvm.part.0+0x65>
  pde = &pgdir[PDX(va)];
80106b8c:	89 d8                	mov    %ebx,%eax
80106b8e:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80106b91:	8b 0c 87             	mov    (%edi,%eax,4),%ecx
80106b94:	f6 c1 01             	test   $0x1,%cl
80106b97:	74 e7                	je     80106b80 <deallocuvm.part.0+0x20>
  return &pgtab[PTX(va)];
80106b99:	89 de                	mov    %ebx,%esi
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106b9b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
80106ba1:	c1 ee 0a             	shr    $0xa,%esi
80106ba4:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
80106baa:	8d b4 31 00 00 00 80 	lea    -0x80000000(%ecx,%esi,1),%esi
    if(!pte)
80106bb1:	85 f6                	test   %esi,%esi
80106bb3:	74 cb                	je     80106b80 <deallocuvm.part.0+0x20>
    else if((*pte & PTE_P) != 0){
80106bb5:	8b 06                	mov    (%esi),%eax
80106bb7:	a8 01                	test   $0x1,%al
80106bb9:	75 15                	jne    80106bd0 <deallocuvm.part.0+0x70>
  for(; a  < oldsz; a += PGSIZE){
80106bbb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106bc1:	39 da                	cmp    %ebx,%edx
80106bc3:	77 c7                	ja     80106b8c <deallocuvm.part.0+0x2c>
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
}
80106bc5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106bcb:	5b                   	pop    %ebx
80106bcc:	5e                   	pop    %esi
80106bcd:	5f                   	pop    %edi
80106bce:	5d                   	pop    %ebp
80106bcf:	c3                   	ret    
      if(pa == 0)
80106bd0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106bd5:	74 25                	je     80106bfc <deallocuvm.part.0+0x9c>
      kfree(v);
80106bd7:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
80106bda:	05 00 00 00 80       	add    $0x80000000,%eax
80106bdf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106be2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      kfree(v);
80106be8:	50                   	push   %eax
80106be9:	e8 22 bb ff ff       	call   80102710 <kfree>
      *pte = 0;
80106bee:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  for(; a  < oldsz; a += PGSIZE){
80106bf4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106bf7:	83 c4 10             	add    $0x10,%esp
80106bfa:	eb 8c                	jmp    80106b88 <deallocuvm.part.0+0x28>
        panic("kfree");
80106bfc:	83 ec 0c             	sub    $0xc,%esp
80106bff:	68 e6 79 10 80       	push   $0x801079e6
80106c04:	e8 a7 98 ff ff       	call   801004b0 <panic>
80106c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106c10 <mappages>:
{
80106c10:	55                   	push   %ebp
80106c11:	89 e5                	mov    %esp,%ebp
80106c13:	57                   	push   %edi
80106c14:	56                   	push   %esi
80106c15:	53                   	push   %ebx
  a = (char*)PGROUNDDOWN((uint)va);
80106c16:	89 d3                	mov    %edx,%ebx
80106c18:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
80106c1e:	83 ec 1c             	sub    $0x1c,%esp
80106c21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106c24:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
80106c28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106c2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106c30:	8b 45 08             	mov    0x8(%ebp),%eax
80106c33:	29 d8                	sub    %ebx,%eax
80106c35:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106c38:	eb 3d                	jmp    80106c77 <mappages+0x67>
80106c3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80106c40:	89 da                	mov    %ebx,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106c42:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80106c47:	c1 ea 0a             	shr    $0xa,%edx
80106c4a:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80106c50:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106c57:	85 c0                	test   %eax,%eax
80106c59:	74 75                	je     80106cd0 <mappages+0xc0>
    if(*pte & PTE_P)
80106c5b:	f6 00 01             	testb  $0x1,(%eax)
80106c5e:	0f 85 86 00 00 00    	jne    80106cea <mappages+0xda>
    *pte = pa | perm | PTE_P;
80106c64:	0b 75 0c             	or     0xc(%ebp),%esi
80106c67:	83 ce 01             	or     $0x1,%esi
80106c6a:	89 30                	mov    %esi,(%eax)
    if(a == last)
80106c6c:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
80106c6f:	74 6f                	je     80106ce0 <mappages+0xd0>
    a += PGSIZE;
80106c71:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  for(;;){
80106c77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  pde = &pgdir[PDX(va)];
80106c7a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106c7d:	8d 34 18             	lea    (%eax,%ebx,1),%esi
80106c80:	89 d8                	mov    %ebx,%eax
80106c82:	c1 e8 16             	shr    $0x16,%eax
80106c85:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
  if(*pde & PTE_P){
80106c88:	8b 07                	mov    (%edi),%eax
80106c8a:	a8 01                	test   $0x1,%al
80106c8c:	75 b2                	jne    80106c40 <mappages+0x30>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106c8e:	e8 5d bc ff ff       	call   801028f0 <kalloc>
80106c93:	85 c0                	test   %eax,%eax
80106c95:	74 39                	je     80106cd0 <mappages+0xc0>
    memset(pgtab, 0, PGSIZE);
80106c97:	83 ec 04             	sub    $0x4,%esp
80106c9a:	89 45 d8             	mov    %eax,-0x28(%ebp)
80106c9d:	68 00 10 00 00       	push   $0x1000
80106ca2:	6a 00                	push   $0x0
80106ca4:	50                   	push   %eax
80106ca5:	e8 36 dd ff ff       	call   801049e0 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106caa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  return &pgtab[PTX(va)];
80106cad:	83 c4 10             	add    $0x10,%esp
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106cb0:	8d 82 00 00 00 80    	lea    -0x80000000(%edx),%eax
80106cb6:	83 c8 07             	or     $0x7,%eax
80106cb9:	89 07                	mov    %eax,(%edi)
  return &pgtab[PTX(va)];
80106cbb:	89 d8                	mov    %ebx,%eax
80106cbd:	c1 e8 0a             	shr    $0xa,%eax
80106cc0:	25 fc 0f 00 00       	and    $0xffc,%eax
80106cc5:	01 d0                	add    %edx,%eax
80106cc7:	eb 92                	jmp    80106c5b <mappages+0x4b>
80106cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}
80106cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106cd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106cd8:	5b                   	pop    %ebx
80106cd9:	5e                   	pop    %esi
80106cda:	5f                   	pop    %edi
80106cdb:	5d                   	pop    %ebp
80106cdc:	c3                   	ret    
80106cdd:	8d 76 00             	lea    0x0(%esi),%esi
80106ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106ce3:	31 c0                	xor    %eax,%eax
}
80106ce5:	5b                   	pop    %ebx
80106ce6:	5e                   	pop    %esi
80106ce7:	5f                   	pop    %edi
80106ce8:	5d                   	pop    %ebp
80106ce9:	c3                   	ret    
      panic("remap");
80106cea:	83 ec 0c             	sub    $0xc,%esp
80106ced:	68 b8 80 10 80       	push   $0x801080b8
80106cf2:	e8 b9 97 ff ff       	call   801004b0 <panic>
80106cf7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106cfe:	66 90                	xchg   %ax,%ax

80106d00 <seginit>:
{
80106d00:	55                   	push   %ebp
80106d01:	89 e5                	mov    %esp,%ebp
80106d03:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
80106d06:	e8 05 cf ff ff       	call   80103c10 <cpuid>
  pd[0] = size-1;
80106d0b:	ba 2f 00 00 00       	mov    $0x2f,%edx
80106d10:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106d16:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106d1a:	c7 80 58 28 11 80 ff 	movl   $0xffff,-0x7feed7a8(%eax)
80106d21:	ff 00 00 
80106d24:	c7 80 5c 28 11 80 00 	movl   $0xcf9a00,-0x7feed7a4(%eax)
80106d2b:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106d2e:	c7 80 60 28 11 80 ff 	movl   $0xffff,-0x7feed7a0(%eax)
80106d35:	ff 00 00 
80106d38:	c7 80 64 28 11 80 00 	movl   $0xcf9200,-0x7feed79c(%eax)
80106d3f:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106d42:	c7 80 68 28 11 80 ff 	movl   $0xffff,-0x7feed798(%eax)
80106d49:	ff 00 00 
80106d4c:	c7 80 6c 28 11 80 00 	movl   $0xcffa00,-0x7feed794(%eax)
80106d53:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106d56:	c7 80 70 28 11 80 ff 	movl   $0xffff,-0x7feed790(%eax)
80106d5d:	ff 00 00 
80106d60:	c7 80 74 28 11 80 00 	movl   $0xcff200,-0x7feed78c(%eax)
80106d67:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
80106d6a:	05 50 28 11 80       	add    $0x80112850,%eax
  pd[1] = (uint)p;
80106d6f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106d73:	c1 e8 10             	shr    $0x10,%eax
80106d76:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106d7a:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106d7d:	0f 01 10             	lgdtl  (%eax)
}
80106d80:	c9                   	leave  
80106d81:	c3                   	ret    
80106d82:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106d90 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106d90:	a1 04 56 11 80       	mov    0x80115604,%eax
80106d95:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106d9a:	0f 22 d8             	mov    %eax,%cr3
}
80106d9d:	c3                   	ret    
80106d9e:	66 90                	xchg   %ax,%ax

80106da0 <switchuvm>:
{
80106da0:	55                   	push   %ebp
80106da1:	89 e5                	mov    %esp,%ebp
80106da3:	57                   	push   %edi
80106da4:	56                   	push   %esi
80106da5:	53                   	push   %ebx
80106da6:	83 ec 1c             	sub    $0x1c,%esp
80106da9:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106dac:	85 f6                	test   %esi,%esi
80106dae:	0f 84 cb 00 00 00    	je     80106e7f <switchuvm+0xdf>
  if(p->kstack == 0)
80106db4:	8b 46 0c             	mov    0xc(%esi),%eax
80106db7:	85 c0                	test   %eax,%eax
80106db9:	0f 84 da 00 00 00    	je     80106e99 <switchuvm+0xf9>
  if(p->pgdir == 0)
80106dbf:	8b 46 08             	mov    0x8(%esi),%eax
80106dc2:	85 c0                	test   %eax,%eax
80106dc4:	0f 84 c2 00 00 00    	je     80106e8c <switchuvm+0xec>
  pushcli();
80106dca:	e8 01 da ff ff       	call   801047d0 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106dcf:	e8 dc cd ff ff       	call   80103bb0 <mycpu>
80106dd4:	89 c3                	mov    %eax,%ebx
80106dd6:	e8 d5 cd ff ff       	call   80103bb0 <mycpu>
80106ddb:	89 c7                	mov    %eax,%edi
80106ddd:	e8 ce cd ff ff       	call   80103bb0 <mycpu>
80106de2:	83 c7 08             	add    $0x8,%edi
80106de5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106de8:	e8 c3 cd ff ff       	call   80103bb0 <mycpu>
80106ded:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106df0:	ba 67 00 00 00       	mov    $0x67,%edx
80106df5:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106dfc:	83 c0 08             	add    $0x8,%eax
80106dff:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106e06:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106e0b:	83 c1 08             	add    $0x8,%ecx
80106e0e:	c1 e8 18             	shr    $0x18,%eax
80106e11:	c1 e9 10             	shr    $0x10,%ecx
80106e14:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
80106e1a:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106e20:	b9 99 40 00 00       	mov    $0x4099,%ecx
80106e25:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106e2c:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
80106e31:	e8 7a cd ff ff       	call   80103bb0 <mycpu>
80106e36:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106e3d:	e8 6e cd ff ff       	call   80103bb0 <mycpu>
80106e42:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106e46:	8b 5e 0c             	mov    0xc(%esi),%ebx
80106e49:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106e4f:	e8 5c cd ff ff       	call   80103bb0 <mycpu>
80106e54:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106e57:	e8 54 cd ff ff       	call   80103bb0 <mycpu>
80106e5c:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106e60:	b8 28 00 00 00       	mov    $0x28,%eax
80106e65:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106e68:	8b 46 08             	mov    0x8(%esi),%eax
80106e6b:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106e70:	0f 22 d8             	mov    %eax,%cr3
}
80106e73:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e76:	5b                   	pop    %ebx
80106e77:	5e                   	pop    %esi
80106e78:	5f                   	pop    %edi
80106e79:	5d                   	pop    %ebp
  popcli();
80106e7a:	e9 a1 d9 ff ff       	jmp    80104820 <popcli>
    panic("switchuvm: no process");
80106e7f:	83 ec 0c             	sub    $0xc,%esp
80106e82:	68 be 80 10 80       	push   $0x801080be
80106e87:	e8 24 96 ff ff       	call   801004b0 <panic>
    panic("switchuvm: no pgdir");
80106e8c:	83 ec 0c             	sub    $0xc,%esp
80106e8f:	68 e9 80 10 80       	push   $0x801080e9
80106e94:	e8 17 96 ff ff       	call   801004b0 <panic>
    panic("switchuvm: no kstack");
80106e99:	83 ec 0c             	sub    $0xc,%esp
80106e9c:	68 d4 80 10 80       	push   $0x801080d4
80106ea1:	e8 0a 96 ff ff       	call   801004b0 <panic>
80106ea6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106ead:	8d 76 00             	lea    0x0(%esi),%esi

80106eb0 <inituvm>:
{
80106eb0:	55                   	push   %ebp
80106eb1:	89 e5                	mov    %esp,%ebp
80106eb3:	57                   	push   %edi
80106eb4:	56                   	push   %esi
80106eb5:	53                   	push   %ebx
80106eb6:	83 ec 1c             	sub    $0x1c,%esp
80106eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ebc:	8b 75 10             	mov    0x10(%ebp),%esi
80106ebf:	8b 7d 08             	mov    0x8(%ebp),%edi
80106ec2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
80106ec5:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106ecb:	77 4b                	ja     80106f18 <inituvm+0x68>
  mem = kalloc();
80106ecd:	e8 1e ba ff ff       	call   801028f0 <kalloc>
  memset(mem, 0, PGSIZE);
80106ed2:	83 ec 04             	sub    $0x4,%esp
80106ed5:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
80106eda:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106edc:	6a 00                	push   $0x0
80106ede:	50                   	push   %eax
80106edf:	e8 fc da ff ff       	call   801049e0 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106ee4:	58                   	pop    %eax
80106ee5:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106eeb:	5a                   	pop    %edx
80106eec:	6a 06                	push   $0x6
80106eee:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106ef3:	31 d2                	xor    %edx,%edx
80106ef5:	50                   	push   %eax
80106ef6:	89 f8                	mov    %edi,%eax
80106ef8:	e8 13 fd ff ff       	call   80106c10 <mappages>
  memmove(mem, init, sz);
80106efd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f00:	89 75 10             	mov    %esi,0x10(%ebp)
80106f03:	83 c4 10             	add    $0x10,%esp
80106f06:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106f09:	89 45 0c             	mov    %eax,0xc(%ebp)
}
80106f0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f0f:	5b                   	pop    %ebx
80106f10:	5e                   	pop    %esi
80106f11:	5f                   	pop    %edi
80106f12:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80106f13:	e9 68 db ff ff       	jmp    80104a80 <memmove>
    panic("inituvm: more than a page");
80106f18:	83 ec 0c             	sub    $0xc,%esp
80106f1b:	68 fd 80 10 80       	push   $0x801080fd
80106f20:	e8 8b 95 ff ff       	call   801004b0 <panic>
80106f25:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106f30 <loaduvm>:
{
80106f30:	55                   	push   %ebp
80106f31:	89 e5                	mov    %esp,%ebp
80106f33:	57                   	push   %edi
80106f34:	56                   	push   %esi
80106f35:	53                   	push   %ebx
80106f36:	83 ec 1c             	sub    $0x1c,%esp
80106f39:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f3c:	8b 75 18             	mov    0x18(%ebp),%esi
  if((uint) addr % PGSIZE != 0)
80106f3f:	a9 ff 0f 00 00       	test   $0xfff,%eax
80106f44:	0f 85 bb 00 00 00    	jne    80107005 <loaduvm+0xd5>
  for(i = 0; i < sz; i += PGSIZE){
80106f4a:	01 f0                	add    %esi,%eax
80106f4c:	89 f3                	mov    %esi,%ebx
80106f4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106f51:	8b 45 14             	mov    0x14(%ebp),%eax
80106f54:	01 f0                	add    %esi,%eax
80106f56:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sz; i += PGSIZE){
80106f59:	85 f6                	test   %esi,%esi
80106f5b:	0f 84 87 00 00 00    	je     80106fe8 <loaduvm+0xb8>
80106f61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  pde = &pgdir[PDX(va)];
80106f68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  if(*pde & PTE_P){
80106f6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106f6e:	29 d8                	sub    %ebx,%eax
  pde = &pgdir[PDX(va)];
80106f70:	89 c2                	mov    %eax,%edx
80106f72:	c1 ea 16             	shr    $0x16,%edx
  if(*pde & PTE_P){
80106f75:	8b 14 91             	mov    (%ecx,%edx,4),%edx
80106f78:	f6 c2 01             	test   $0x1,%dl
80106f7b:	75 13                	jne    80106f90 <loaduvm+0x60>
      panic("loaduvm: address should exist");
80106f7d:	83 ec 0c             	sub    $0xc,%esp
80106f80:	68 17 81 10 80       	push   $0x80108117
80106f85:	e8 26 95 ff ff       	call   801004b0 <panic>
80106f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80106f90:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106f93:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80106f99:	25 fc 0f 00 00       	and    $0xffc,%eax
80106f9e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106fa5:	85 c0                	test   %eax,%eax
80106fa7:	74 d4                	je     80106f7d <loaduvm+0x4d>
    pa = PTE_ADDR(*pte);
80106fa9:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106fab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    if(sz - i < PGSIZE)
80106fae:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80106fb3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106fb8:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
80106fbe:	0f 46 fb             	cmovbe %ebx,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106fc1:	29 d9                	sub    %ebx,%ecx
80106fc3:	05 00 00 00 80       	add    $0x80000000,%eax
80106fc8:	57                   	push   %edi
80106fc9:	51                   	push   %ecx
80106fca:	50                   	push   %eax
80106fcb:	ff 75 10             	push   0x10(%ebp)
80106fce:	e8 0d ad ff ff       	call   80101ce0 <readi>
80106fd3:	83 c4 10             	add    $0x10,%esp
80106fd6:	39 f8                	cmp    %edi,%eax
80106fd8:	75 1e                	jne    80106ff8 <loaduvm+0xc8>
  for(i = 0; i < sz; i += PGSIZE){
80106fda:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
80106fe0:	89 f0                	mov    %esi,%eax
80106fe2:	29 d8                	sub    %ebx,%eax
80106fe4:	39 c6                	cmp    %eax,%esi
80106fe6:	77 80                	ja     80106f68 <loaduvm+0x38>
}
80106fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106feb:	31 c0                	xor    %eax,%eax
}
80106fed:	5b                   	pop    %ebx
80106fee:	5e                   	pop    %esi
80106fef:	5f                   	pop    %edi
80106ff0:	5d                   	pop    %ebp
80106ff1:	c3                   	ret    
80106ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106ff8:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107000:	5b                   	pop    %ebx
80107001:	5e                   	pop    %esi
80107002:	5f                   	pop    %edi
80107003:	5d                   	pop    %ebp
80107004:	c3                   	ret    
    panic("loaduvm: addr must be page aligned");
80107005:	83 ec 0c             	sub    $0xc,%esp
80107008:	68 b8 81 10 80       	push   $0x801081b8
8010700d:	e8 9e 94 ff ff       	call   801004b0 <panic>
80107012:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107020 <allocuvm>:
{
80107020:	55                   	push   %ebp
80107021:	89 e5                	mov    %esp,%ebp
80107023:	57                   	push   %edi
80107024:	56                   	push   %esi
80107025:	53                   	push   %ebx
80107026:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80107029:	8b 45 10             	mov    0x10(%ebp),%eax
{
8010702c:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
8010702f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107032:	85 c0                	test   %eax,%eax
80107034:	0f 88 b6 00 00 00    	js     801070f0 <allocuvm+0xd0>
  if(newsz < oldsz)
8010703a:	3b 45 0c             	cmp    0xc(%ebp),%eax
    return oldsz;
8010703d:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(newsz < oldsz)
80107040:	0f 82 9a 00 00 00    	jb     801070e0 <allocuvm+0xc0>
  a = PGROUNDUP(oldsz);
80107046:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
8010704c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80107052:	39 75 10             	cmp    %esi,0x10(%ebp)
80107055:	77 44                	ja     8010709b <allocuvm+0x7b>
80107057:	e9 87 00 00 00       	jmp    801070e3 <allocuvm+0xc3>
8010705c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    memset(mem, 0, PGSIZE);
80107060:	83 ec 04             	sub    $0x4,%esp
80107063:	68 00 10 00 00       	push   $0x1000
80107068:	6a 00                	push   $0x0
8010706a:	50                   	push   %eax
8010706b:	e8 70 d9 ff ff       	call   801049e0 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107070:	58                   	pop    %eax
80107071:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80107077:	5a                   	pop    %edx
80107078:	6a 06                	push   $0x6
8010707a:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010707f:	89 f2                	mov    %esi,%edx
80107081:	50                   	push   %eax
80107082:	89 f8                	mov    %edi,%eax
80107084:	e8 87 fb ff ff       	call   80106c10 <mappages>
80107089:	83 c4 10             	add    $0x10,%esp
8010708c:	85 c0                	test   %eax,%eax
8010708e:	78 78                	js     80107108 <allocuvm+0xe8>
  for(; a < newsz; a += PGSIZE){
80107090:	81 c6 00 10 00 00    	add    $0x1000,%esi
80107096:	39 75 10             	cmp    %esi,0x10(%ebp)
80107099:	76 48                	jbe    801070e3 <allocuvm+0xc3>
    mem = kalloc();
8010709b:	e8 50 b8 ff ff       	call   801028f0 <kalloc>
801070a0:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
801070a2:	85 c0                	test   %eax,%eax
801070a4:	75 ba                	jne    80107060 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
801070a6:	83 ec 0c             	sub    $0xc,%esp
801070a9:	68 35 81 10 80       	push   $0x80108135
801070ae:	e8 1d 97 ff ff       	call   801007d0 <cprintf>
  if(newsz >= oldsz)
801070b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801070b6:	83 c4 10             	add    $0x10,%esp
801070b9:	39 45 10             	cmp    %eax,0x10(%ebp)
801070bc:	74 32                	je     801070f0 <allocuvm+0xd0>
801070be:	8b 55 10             	mov    0x10(%ebp),%edx
801070c1:	89 c1                	mov    %eax,%ecx
801070c3:	89 f8                	mov    %edi,%eax
801070c5:	e8 96 fa ff ff       	call   80106b60 <deallocuvm.part.0>
      return 0;
801070ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801070d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801070d7:	5b                   	pop    %ebx
801070d8:	5e                   	pop    %esi
801070d9:	5f                   	pop    %edi
801070da:	5d                   	pop    %ebp
801070db:	c3                   	ret    
801070dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return oldsz;
801070e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}
801070e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801070e9:	5b                   	pop    %ebx
801070ea:	5e                   	pop    %esi
801070eb:	5f                   	pop    %edi
801070ec:	5d                   	pop    %ebp
801070ed:	c3                   	ret    
801070ee:	66 90                	xchg   %ax,%ax
    return 0;
801070f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801070f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801070fd:	5b                   	pop    %ebx
801070fe:	5e                   	pop    %esi
801070ff:	5f                   	pop    %edi
80107100:	5d                   	pop    %ebp
80107101:	c3                   	ret    
80107102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
80107108:	83 ec 0c             	sub    $0xc,%esp
8010710b:	68 4d 81 10 80       	push   $0x8010814d
80107110:	e8 bb 96 ff ff       	call   801007d0 <cprintf>
  if(newsz >= oldsz)
80107115:	8b 45 0c             	mov    0xc(%ebp),%eax
80107118:	83 c4 10             	add    $0x10,%esp
8010711b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010711e:	74 0c                	je     8010712c <allocuvm+0x10c>
80107120:	8b 55 10             	mov    0x10(%ebp),%edx
80107123:	89 c1                	mov    %eax,%ecx
80107125:	89 f8                	mov    %edi,%eax
80107127:	e8 34 fa ff ff       	call   80106b60 <deallocuvm.part.0>
      kfree(mem);
8010712c:	83 ec 0c             	sub    $0xc,%esp
8010712f:	53                   	push   %ebx
80107130:	e8 db b5 ff ff       	call   80102710 <kfree>
      return 0;
80107135:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010713c:	83 c4 10             	add    $0x10,%esp
}
8010713f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107142:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107145:	5b                   	pop    %ebx
80107146:	5e                   	pop    %esi
80107147:	5f                   	pop    %edi
80107148:	5d                   	pop    %ebp
80107149:	c3                   	ret    
8010714a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107150 <deallocuvm>:
{
80107150:	55                   	push   %ebp
80107151:	89 e5                	mov    %esp,%ebp
80107153:	8b 55 0c             	mov    0xc(%ebp),%edx
80107156:	8b 4d 10             	mov    0x10(%ebp),%ecx
80107159:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
8010715c:	39 d1                	cmp    %edx,%ecx
8010715e:	73 10                	jae    80107170 <deallocuvm+0x20>
}
80107160:	5d                   	pop    %ebp
80107161:	e9 fa f9 ff ff       	jmp    80106b60 <deallocuvm.part.0>
80107166:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010716d:	8d 76 00             	lea    0x0(%esi),%esi
80107170:	89 d0                	mov    %edx,%eax
80107172:	5d                   	pop    %ebp
80107173:	c3                   	ret    
80107174:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010717b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010717f:	90                   	nop

80107180 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107180:	55                   	push   %ebp
80107181:	89 e5                	mov    %esp,%ebp
80107183:	57                   	push   %edi
80107184:	56                   	push   %esi
80107185:	53                   	push   %ebx
80107186:	83 ec 0c             	sub    $0xc,%esp
80107189:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010718c:	85 f6                	test   %esi,%esi
8010718e:	74 59                	je     801071e9 <freevm+0x69>
  if(newsz >= oldsz)
80107190:	31 c9                	xor    %ecx,%ecx
80107192:	ba 00 00 00 80       	mov    $0x80000000,%edx
80107197:	89 f0                	mov    %esi,%eax
80107199:	89 f3                	mov    %esi,%ebx
8010719b:	e8 c0 f9 ff ff       	call   80106b60 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801071a0:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
801071a6:	eb 0f                	jmp    801071b7 <freevm+0x37>
801071a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801071af:	90                   	nop
801071b0:	83 c3 04             	add    $0x4,%ebx
801071b3:	39 df                	cmp    %ebx,%edi
801071b5:	74 23                	je     801071da <freevm+0x5a>
    if(pgdir[i] & PTE_P){
801071b7:	8b 03                	mov    (%ebx),%eax
801071b9:	a8 01                	test   $0x1,%al
801071bb:	74 f3                	je     801071b0 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801071bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
801071c2:	83 ec 0c             	sub    $0xc,%esp
  for(i = 0; i < NPDENTRIES; i++){
801071c5:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
801071c8:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801071cd:	50                   	push   %eax
801071ce:	e8 3d b5 ff ff       	call   80102710 <kfree>
801071d3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801071d6:	39 df                	cmp    %ebx,%edi
801071d8:	75 dd                	jne    801071b7 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
801071da:	89 75 08             	mov    %esi,0x8(%ebp)
}
801071dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801071e0:	5b                   	pop    %ebx
801071e1:	5e                   	pop    %esi
801071e2:	5f                   	pop    %edi
801071e3:	5d                   	pop    %ebp
  kfree((char*)pgdir);
801071e4:	e9 27 b5 ff ff       	jmp    80102710 <kfree>
    panic("freevm: no pgdir");
801071e9:	83 ec 0c             	sub    $0xc,%esp
801071ec:	68 69 81 10 80       	push   $0x80108169
801071f1:	e8 ba 92 ff ff       	call   801004b0 <panic>
801071f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801071fd:	8d 76 00             	lea    0x0(%esi),%esi

80107200 <setupkvm>:
{
80107200:	55                   	push   %ebp
80107201:	89 e5                	mov    %esp,%ebp
80107203:	56                   	push   %esi
80107204:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80107205:	e8 e6 b6 ff ff       	call   801028f0 <kalloc>
8010720a:	89 c6                	mov    %eax,%esi
8010720c:	85 c0                	test   %eax,%eax
8010720e:	74 42                	je     80107252 <setupkvm+0x52>
  memset(pgdir, 0, PGSIZE);
80107210:	83 ec 04             	sub    $0x4,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107213:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
80107218:	68 00 10 00 00       	push   $0x1000
8010721d:	6a 00                	push   $0x0
8010721f:	50                   	push   %eax
80107220:	e8 bb d7 ff ff       	call   801049e0 <memset>
80107225:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0) {
80107228:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010722b:	83 ec 08             	sub    $0x8,%esp
8010722e:	8b 4b 08             	mov    0x8(%ebx),%ecx
80107231:	ff 73 0c             	push   0xc(%ebx)
80107234:	8b 13                	mov    (%ebx),%edx
80107236:	50                   	push   %eax
80107237:	29 c1                	sub    %eax,%ecx
80107239:	89 f0                	mov    %esi,%eax
8010723b:	e8 d0 f9 ff ff       	call   80106c10 <mappages>
80107240:	83 c4 10             	add    $0x10,%esp
80107243:	85 c0                	test   %eax,%eax
80107245:	78 19                	js     80107260 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107247:	83 c3 10             	add    $0x10,%ebx
8010724a:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
80107250:	75 d6                	jne    80107228 <setupkvm+0x28>
}
80107252:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107255:	89 f0                	mov    %esi,%eax
80107257:	5b                   	pop    %ebx
80107258:	5e                   	pop    %esi
80107259:	5d                   	pop    %ebp
8010725a:	c3                   	ret    
8010725b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010725f:	90                   	nop
      freevm(pgdir);
80107260:	83 ec 0c             	sub    $0xc,%esp
80107263:	56                   	push   %esi
      return 0;
80107264:	31 f6                	xor    %esi,%esi
      freevm(pgdir);
80107266:	e8 15 ff ff ff       	call   80107180 <freevm>
      return 0;
8010726b:	83 c4 10             	add    $0x10,%esp
}
8010726e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107271:	89 f0                	mov    %esi,%eax
80107273:	5b                   	pop    %ebx
80107274:	5e                   	pop    %esi
80107275:	5d                   	pop    %ebp
80107276:	c3                   	ret    
80107277:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010727e:	66 90                	xchg   %ax,%ax

80107280 <kvmalloc>:
{
80107280:	55                   	push   %ebp
80107281:	89 e5                	mov    %esp,%ebp
80107283:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107286:	e8 75 ff ff ff       	call   80107200 <setupkvm>
8010728b:	a3 04 56 11 80       	mov    %eax,0x80115604
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107290:	05 00 00 00 80       	add    $0x80000000,%eax
80107295:	0f 22 d8             	mov    %eax,%cr3
}
80107298:	c9                   	leave  
80107299:	c3                   	ret    
8010729a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801072a0 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801072a0:	55                   	push   %ebp
801072a1:	89 e5                	mov    %esp,%ebp
801072a3:	83 ec 08             	sub    $0x8,%esp
801072a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
801072a9:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
801072ac:	89 c1                	mov    %eax,%ecx
801072ae:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
801072b1:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
801072b4:	f6 c2 01             	test   $0x1,%dl
801072b7:	75 17                	jne    801072d0 <clearpteu+0x30>
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
801072b9:	83 ec 0c             	sub    $0xc,%esp
801072bc:	68 7a 81 10 80       	push   $0x8010817a
801072c1:	e8 ea 91 ff ff       	call   801004b0 <panic>
801072c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801072cd:	8d 76 00             	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
801072d0:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801072d3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
801072d9:	25 fc 0f 00 00       	and    $0xffc,%eax
801072de:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
  if(pte == 0)
801072e5:	85 c0                	test   %eax,%eax
801072e7:	74 d0                	je     801072b9 <clearpteu+0x19>
  *pte &= ~PTE_U;
801072e9:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801072ec:	c9                   	leave  
801072ed:	c3                   	ret    
801072ee:	66 90                	xchg   %ax,%ax

801072f0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801072f0:	55                   	push   %ebp
801072f1:	89 e5                	mov    %esp,%ebp
801072f3:	57                   	push   %edi
801072f4:	56                   	push   %esi
801072f5:	53                   	push   %ebx
801072f6:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801072f9:	e8 02 ff ff ff       	call   80107200 <setupkvm>
801072fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107301:	85 c0                	test   %eax,%eax
80107303:	0f 84 bd 00 00 00    	je     801073c6 <copyuvm+0xd6>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80107309:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010730c:	85 c9                	test   %ecx,%ecx
8010730e:	0f 84 b2 00 00 00    	je     801073c6 <copyuvm+0xd6>
80107314:	31 f6                	xor    %esi,%esi
80107316:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010731d:	8d 76 00             	lea    0x0(%esi),%esi
  if(*pde & PTE_P){
80107320:	8b 4d 08             	mov    0x8(%ebp),%ecx
  pde = &pgdir[PDX(va)];
80107323:	89 f0                	mov    %esi,%eax
80107325:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80107328:	8b 04 81             	mov    (%ecx,%eax,4),%eax
8010732b:	a8 01                	test   $0x1,%al
8010732d:	75 11                	jne    80107340 <copyuvm+0x50>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
8010732f:	83 ec 0c             	sub    $0xc,%esp
80107332:	68 84 81 10 80       	push   $0x80108184
80107337:	e8 74 91 ff ff       	call   801004b0 <panic>
8010733c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return &pgtab[PTX(va)];
80107340:	89 f2                	mov    %esi,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107342:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80107347:	c1 ea 0a             	shr    $0xa,%edx
8010734a:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107350:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107357:	85 c0                	test   %eax,%eax
80107359:	74 d4                	je     8010732f <copyuvm+0x3f>
    if(!(*pte & PTE_P))
8010735b:	8b 00                	mov    (%eax),%eax
8010735d:	a8 01                	test   $0x1,%al
8010735f:	0f 84 9f 00 00 00    	je     80107404 <copyuvm+0x114>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80107365:	89 c7                	mov    %eax,%edi
    flags = PTE_FLAGS(*pte);
80107367:	25 ff 0f 00 00       	and    $0xfff,%eax
8010736c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pa = PTE_ADDR(*pte);
8010736f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
80107375:	e8 76 b5 ff ff       	call   801028f0 <kalloc>
8010737a:	89 c3                	mov    %eax,%ebx
8010737c:	85 c0                	test   %eax,%eax
8010737e:	74 64                	je     801073e4 <copyuvm+0xf4>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107380:	83 ec 04             	sub    $0x4,%esp
80107383:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80107389:	68 00 10 00 00       	push   $0x1000
8010738e:	57                   	push   %edi
8010738f:	50                   	push   %eax
80107390:	e8 eb d6 ff ff       	call   80104a80 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80107395:	58                   	pop    %eax
80107396:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010739c:	5a                   	pop    %edx
8010739d:	ff 75 e4             	push   -0x1c(%ebp)
801073a0:	b9 00 10 00 00       	mov    $0x1000,%ecx
801073a5:	89 f2                	mov    %esi,%edx
801073a7:	50                   	push   %eax
801073a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801073ab:	e8 60 f8 ff ff       	call   80106c10 <mappages>
801073b0:	83 c4 10             	add    $0x10,%esp
801073b3:	85 c0                	test   %eax,%eax
801073b5:	78 21                	js     801073d8 <copyuvm+0xe8>
  for(i = 0; i < sz; i += PGSIZE){
801073b7:	81 c6 00 10 00 00    	add    $0x1000,%esi
801073bd:	39 75 0c             	cmp    %esi,0xc(%ebp)
801073c0:	0f 87 5a ff ff ff    	ja     80107320 <copyuvm+0x30>
  return d;

bad:
  freevm(d);
  return 0;
}
801073c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801073c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801073cc:	5b                   	pop    %ebx
801073cd:	5e                   	pop    %esi
801073ce:	5f                   	pop    %edi
801073cf:	5d                   	pop    %ebp
801073d0:	c3                   	ret    
801073d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      kfree(mem);
801073d8:	83 ec 0c             	sub    $0xc,%esp
801073db:	53                   	push   %ebx
801073dc:	e8 2f b3 ff ff       	call   80102710 <kfree>
      goto bad;
801073e1:	83 c4 10             	add    $0x10,%esp
  freevm(d);
801073e4:	83 ec 0c             	sub    $0xc,%esp
801073e7:	ff 75 e0             	push   -0x20(%ebp)
801073ea:	e8 91 fd ff ff       	call   80107180 <freevm>
  return 0;
801073ef:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801073f6:	83 c4 10             	add    $0x10,%esp
}
801073f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801073fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801073ff:	5b                   	pop    %ebx
80107400:	5e                   	pop    %esi
80107401:	5f                   	pop    %edi
80107402:	5d                   	pop    %ebp
80107403:	c3                   	ret    
      panic("copyuvm: page not present");
80107404:	83 ec 0c             	sub    $0xc,%esp
80107407:	68 9e 81 10 80       	push   $0x8010819e
8010740c:	e8 9f 90 ff ff       	call   801004b0 <panic>
80107411:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107418:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010741f:	90                   	nop

80107420 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107420:	55                   	push   %ebp
80107421:	89 e5                	mov    %esp,%ebp
80107423:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
80107426:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
80107429:	89 c1                	mov    %eax,%ecx
8010742b:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
8010742e:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80107431:	f6 c2 01             	test   $0x1,%dl
80107434:	0f 84 29 03 00 00    	je     80107763 <uva2ka.cold>
  return &pgtab[PTX(va)];
8010743a:	c1 e8 0c             	shr    $0xc,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010743d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80107443:	5d                   	pop    %ebp
  return &pgtab[PTX(va)];
80107444:	25 ff 03 00 00       	and    $0x3ff,%eax
  if((*pte & PTE_P) == 0)
80107449:	8b 84 82 00 00 00 80 	mov    -0x80000000(%edx,%eax,4),%eax
  if((*pte & PTE_U) == 0)
80107450:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107452:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
80107457:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
8010745a:	05 00 00 00 80       	add    $0x80000000,%eax
8010745f:	83 fa 05             	cmp    $0x5,%edx
80107462:	ba 00 00 00 00       	mov    $0x0,%edx
80107467:	0f 45 c2             	cmovne %edx,%eax
}
8010746a:	c3                   	ret    
8010746b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010746f:	90                   	nop

80107470 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107470:	55                   	push   %ebp
80107471:	89 e5                	mov    %esp,%ebp
80107473:	57                   	push   %edi
80107474:	56                   	push   %esi
80107475:	53                   	push   %ebx
80107476:	83 ec 0c             	sub    $0xc,%esp
80107479:	8b 75 14             	mov    0x14(%ebp),%esi
8010747c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010747f:	8b 55 10             	mov    0x10(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80107482:	85 f6                	test   %esi,%esi
80107484:	75 51                	jne    801074d7 <copyout+0x67>
80107486:	e9 a5 00 00 00       	jmp    80107530 <copyout+0xc0>
8010748b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010748f:	90                   	nop
  return (char*)P2V(PTE_ADDR(*pte));
80107490:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80107496:	8d 8b 00 00 00 80    	lea    -0x80000000(%ebx),%ecx
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
8010749c:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
801074a2:	74 75                	je     80107519 <copyout+0xa9>
      return -1;
    n = PGSIZE - (va - va0);
801074a4:	89 fb                	mov    %edi,%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801074a6:	89 55 10             	mov    %edx,0x10(%ebp)
    n = PGSIZE - (va - va0);
801074a9:	29 c3                	sub    %eax,%ebx
801074ab:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801074b1:	39 f3                	cmp    %esi,%ebx
801074b3:	0f 47 de             	cmova  %esi,%ebx
    memmove(pa0 + (va - va0), buf, n);
801074b6:	29 f8                	sub    %edi,%eax
801074b8:	83 ec 04             	sub    $0x4,%esp
801074bb:	01 c1                	add    %eax,%ecx
801074bd:	53                   	push   %ebx
801074be:	52                   	push   %edx
801074bf:	51                   	push   %ecx
801074c0:	e8 bb d5 ff ff       	call   80104a80 <memmove>
    len -= n;
    buf += n;
801074c5:	8b 55 10             	mov    0x10(%ebp),%edx
    va = va0 + PGSIZE;
801074c8:	8d 87 00 10 00 00    	lea    0x1000(%edi),%eax
  while(len > 0){
801074ce:	83 c4 10             	add    $0x10,%esp
    buf += n;
801074d1:	01 da                	add    %ebx,%edx
  while(len > 0){
801074d3:	29 de                	sub    %ebx,%esi
801074d5:	74 59                	je     80107530 <copyout+0xc0>
  if(*pde & PTE_P){
801074d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pde = &pgdir[PDX(va)];
801074da:	89 c1                	mov    %eax,%ecx
    va0 = (uint)PGROUNDDOWN(va);
801074dc:	89 c7                	mov    %eax,%edi
  pde = &pgdir[PDX(va)];
801074de:	c1 e9 16             	shr    $0x16,%ecx
    va0 = (uint)PGROUNDDOWN(va);
801074e1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if(*pde & PTE_P){
801074e7:	8b 0c 8b             	mov    (%ebx,%ecx,4),%ecx
801074ea:	f6 c1 01             	test   $0x1,%cl
801074ed:	0f 84 77 02 00 00    	je     8010776a <copyout.cold>
  return &pgtab[PTX(va)];
801074f3:	89 fb                	mov    %edi,%ebx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801074f5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
801074fb:	c1 eb 0c             	shr    $0xc,%ebx
801074fe:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  if((*pte & PTE_P) == 0)
80107504:	8b 9c 99 00 00 00 80 	mov    -0x80000000(%ecx,%ebx,4),%ebx
  if((*pte & PTE_U) == 0)
8010750b:	89 d9                	mov    %ebx,%ecx
8010750d:	83 e1 05             	and    $0x5,%ecx
80107510:	83 f9 05             	cmp    $0x5,%ecx
80107513:	0f 84 77 ff ff ff    	je     80107490 <copyout+0x20>
  }
  return 0;
}
80107519:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
8010751c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107521:	5b                   	pop    %ebx
80107522:	5e                   	pop    %esi
80107523:	5f                   	pop    %edi
80107524:	5d                   	pop    %ebp
80107525:	c3                   	ret    
80107526:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010752d:	8d 76 00             	lea    0x0(%esi),%esi
80107530:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107533:	31 c0                	xor    %eax,%eax
}
80107535:	5b                   	pop    %ebx
80107536:	5e                   	pop    %esi
80107537:	5f                   	pop    %edi
80107538:	5d                   	pop    %ebp
80107539:	c3                   	ret    
8010753a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107540 <find_victim>:
  *victim_page |= (pos)<<12;  // It should be 12 instead of 3 because according to slides we are storing swap space index in base address space of pagetable entry

  return victim_page;
}

pte_t* find_victim(pde_t *pgdir){
80107540:	55                   	push   %ebp
  uint add=0;
80107541:	31 c0                	xor    %eax,%eax
pte_t* find_victim(pde_t *pgdir){
80107543:	89 e5                	mov    %esp,%ebp
80107545:	53                   	push   %ebx
80107546:	8b 5d 08             	mov    0x8(%ebp),%ebx
80107549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  pde = &pgdir[PDX(va)];
80107550:	89 c2                	mov    %eax,%edx
80107552:	c1 ea 16             	shr    $0x16,%edx
  if(*pde & PTE_P){
80107555:	8b 14 93             	mov    (%ebx,%edx,4),%edx
80107558:	f6 c2 01             	test   $0x1,%dl
8010755b:	74 21                	je     8010757e <find_victim+0x3e>
  return &pgtab[PTX(va)];
8010755d:	89 c1                	mov    %eax,%ecx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010755f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80107565:	c1 e9 0a             	shr    $0xa,%ecx
80107568:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
8010756e:	8d 94 0a 00 00 00 80 	lea    -0x80000000(%edx,%ecx,1),%edx
  while(add < KERNBASE){
    pte_t *x= walkpgdir(pgdir,(void*)add,0);
    // PTE_P is set for x (otherwise walkpgdir function will return 0)
    if(x!=0){
80107575:	85 d2                	test   %edx,%edx
80107577:	74 05                	je     8010757e <find_victim+0x3e>
      // Found a process with PTE_A Flag unset
      if((*x & PTE_A)==0){
80107579:	f6 02 20             	testb  $0x20,(%edx)
8010757c:	74 09                	je     80107587 <find_victim+0x47>
  while(add < KERNBASE){
8010757e:	05 00 10 00 00       	add    $0x1000,%eax
80107583:	79 cb                	jns    80107550 <find_victim+0x10>
      }
    }
    add+=PGSIZE;
  }
  // Failed to find victim page
  return 0;
80107585:	31 d2                	xor    %edx,%edx
}
80107587:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010758a:	89 d0                	mov    %edx,%eax
8010758c:	c9                   	leave  
8010758d:	c3                   	ret    
8010758e:	66 90                	xchg   %ax,%ax

80107590 <unset_access>:

void unset_access(pde_t *pgdir){
80107590:	55                   	push   %ebp
  uint add=0;
  int counter=0;
80107591:	31 d2                	xor    %edx,%edx
  uint add=0;
80107593:	31 c9                	xor    %ecx,%ecx
void unset_access(pde_t *pgdir){
80107595:	89 e5                	mov    %esp,%ebp
80107597:	57                   	push   %edi
    if(x!=0){
      // Unset access bit of every tenth process
      if(counter==0){
        *x &= ~ PTE_A;
      }
      counter= (counter+1)%10;
80107598:	bf cd cc cc cc       	mov    $0xcccccccd,%edi
void unset_access(pde_t *pgdir){
8010759d:	56                   	push   %esi
8010759e:	8b 75 08             	mov    0x8(%ebp),%esi
801075a1:	53                   	push   %ebx
801075a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  pde = &pgdir[PDX(va)];
801075a8:	89 c8                	mov    %ecx,%eax
801075aa:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
801075ad:	8b 04 86             	mov    (%esi,%eax,4),%eax
801075b0:	a8 01                	test   $0x1,%al
801075b2:	74 35                	je     801075e9 <unset_access+0x59>
  return &pgtab[PTX(va)];
801075b4:	89 cb                	mov    %ecx,%ebx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801075b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
801075bb:	c1 eb 0a             	shr    $0xa,%ebx
801075be:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
801075c4:	8d 84 18 00 00 00 80 	lea    -0x80000000(%eax,%ebx,1),%eax
    if(x!=0){
801075cb:	85 c0                	test   %eax,%eax
801075cd:	74 1a                	je     801075e9 <unset_access+0x59>
      if(counter==0){
801075cf:	85 d2                	test   %edx,%edx
801075d1:	75 03                	jne    801075d6 <unset_access+0x46>
        *x &= ~ PTE_A;
801075d3:	83 20 df             	andl   $0xffffffdf,(%eax)
      counter= (counter+1)%10;
801075d6:	8d 5a 01             	lea    0x1(%edx),%ebx
801075d9:	89 d8                	mov    %ebx,%eax
801075db:	f7 e7                	mul    %edi
801075dd:	c1 ea 03             	shr    $0x3,%edx
801075e0:	8d 04 92             	lea    (%edx,%edx,4),%eax
801075e3:	01 c0                	add    %eax,%eax
801075e5:	29 c3                	sub    %eax,%ebx
801075e7:	89 da                	mov    %ebx,%edx
  while(add < KERNBASE){
801075e9:	81 c1 00 10 00 00    	add    $0x1000,%ecx
801075ef:	79 b7                	jns    801075a8 <unset_access+0x18>
    }
    add+=PGSIZE;
  }
  return;
}
801075f1:	5b                   	pop    %ebx
801075f2:	5e                   	pop    %esi
801075f3:	5f                   	pop    %edi
801075f4:	5d                   	pop    %ebp
801075f5:	c3                   	ret    
801075f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801075fd:	8d 76 00             	lea    0x0(%esi),%esi

80107600 <allocate_page>:
pte_t* allocate_page(){
80107600:	55                   	push   %ebp
80107601:	89 e5                	mov    %esp,%ebp
80107603:	56                   	push   %esi
80107604:	53                   	push   %ebx
  pde_t *victim_pde= victim_pgdir();
80107605:	e8 c6 cf ff ff       	call   801045d0 <victim_pgdir>
  victim_page= find_victim(victim_pde);
8010760a:	83 ec 0c             	sub    $0xc,%esp
8010760d:	50                   	push   %eax
  pde_t *victim_pde= victim_pgdir();
8010760e:	89 c6                	mov    %eax,%esi
  victim_page= find_victim(victim_pde);
80107610:	e8 2b ff ff ff       	call   80107540 <find_victim>
80107615:	83 c4 10             	add    $0x10,%esp
  if(victim_page==0){
80107618:	89 c3                	mov    %eax,%ebx
8010761a:	85 c0                	test   %eax,%eax
8010761c:	74 42                	je     80107660 <allocate_page+0x60>
  memmove(data, (char*)P2V(PTE_ADDR(victim_page)), PGSIZE);
8010761e:	89 d8                	mov    %ebx,%eax
80107620:	83 ec 04             	sub    $0x4,%esp
80107623:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107628:	68 00 10 00 00       	push   $0x1000
8010762d:	05 00 00 00 80       	add    $0x80000000,%eax
80107632:	50                   	push   %eax
80107633:	6a 00                	push   $0x0
80107635:	e8 46 d4 ff ff       	call   80104a80 <memmove>
  uint pos= add_page(data,permissions);
8010763a:	58                   	pop    %eax
  int permissions= (*victim_page) & 0x07;
8010763b:	8b 03                	mov    (%ebx),%eax
  uint pos= add_page(data,permissions);
8010763d:	5a                   	pop    %edx
  int permissions= (*victim_page) & 0x07;
8010763e:	83 e0 07             	and    $0x7,%eax
  uint pos= add_page(data,permissions);
80107641:	50                   	push   %eax
80107642:	6a 00                	push   $0x0
80107644:	e8 97 a0 ff ff       	call   801016e0 <add_page>
  *victim_page &= ~PTE_P;
80107649:	8b 13                	mov    (%ebx),%edx
  *victim_page |= (pos)<<12;  // It should be 12 instead of 3 because according to slides we are storing swap space index in base address space of pagetable entry
8010764b:	c1 e0 0c             	shl    $0xc,%eax
  *victim_page &= ~PTE_P;
8010764e:	83 e2 fe             	and    $0xfffffffe,%edx
  *victim_page |= (pos)<<12;  // It should be 12 instead of 3 because according to slides we are storing swap space index in base address space of pagetable entry
80107651:	09 c2                	or     %eax,%edx
}
80107653:	89 d8                	mov    %ebx,%eax
  *victim_page |= (pos)<<12;  // It should be 12 instead of 3 because according to slides we are storing swap space index in base address space of pagetable entry
80107655:	89 13                	mov    %edx,(%ebx)
}
80107657:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010765a:	5b                   	pop    %ebx
8010765b:	5e                   	pop    %esi
8010765c:	5d                   	pop    %ebp
8010765d:	c3                   	ret    
8010765e:	66 90                	xchg   %ax,%ax
    unset_access(victim_pde);
80107660:	83 ec 0c             	sub    $0xc,%esp
80107663:	56                   	push   %esi
80107664:	e8 27 ff ff ff       	call   80107590 <unset_access>
    victim_page= find_victim(victim_pde);
80107669:	89 34 24             	mov    %esi,(%esp)
8010766c:	e8 cf fe ff ff       	call   80107540 <find_victim>
80107671:	83 c4 10             	add    $0x10,%esp
80107674:	89 c3                	mov    %eax,%ebx
80107676:	eb a6                	jmp    8010761e <allocate_page+0x1e>
80107678:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010767f:	90                   	nop

80107680 <page_fault>:

void page_fault(){
80107680:	55                   	push   %ebp
80107681:	89 e5                	mov    %esp,%ebp
80107683:	57                   	push   %edi
80107684:	56                   	push   %esi
80107685:	53                   	push   %ebx
80107686:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010768c:	0f 20 d3             	mov    %cr2,%ebx
  uint vadd= rcr2();
  pte_t *add = walkpgdir(myproc()->pgdir,(void*)vadd,0);
8010768f:	e8 9c c5 ff ff       	call   80103c30 <myproc>
  pde = &pgdir[PDX(va)];
80107694:	89 da                	mov    %ebx,%edx
  if(*pde & PTE_P){
80107696:	8b 40 08             	mov    0x8(%eax),%eax
  pde = &pgdir[PDX(va)];
80107699:	c1 ea 16             	shr    $0x16,%edx
  if(*pde & PTE_P){
8010769c:	8b 04 90             	mov    (%eax,%edx,4),%eax
8010769f:	a8 01                	test   $0x1,%al
801076a1:	0f 84 ca 00 00 00    	je     80107771 <page_fault.cold>
  return &pgtab[PTX(va)];
801076a7:	c1 eb 0a             	shr    $0xa,%ebx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801076aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076af:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  return &pgtab[PTX(va)];
801076b5:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
801076bb:	8d 84 18 00 00 00 80 	lea    -0x80000000(%eax,%ebx,1),%eax
801076c2:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
  // No need of taking and
  uint x= (*add>>12); // Instead of 3->12  and confusion in and
801076c8:	8b 00                	mov    (%eax),%eax
801076ca:	c1 e8 0c             	shr    $0xc,%eax
801076cd:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)
  uint st= x*8+2;
801076d3:	8d 3c c5 02 00 00 00 	lea    0x2(,%eax,8),%edi
  // Read contents of page in mem
  char *mem= kalloc();
801076da:	e8 11 b2 ff ff       	call   801028f0 <kalloc>
801076df:	89 85 dc fd ff ff    	mov    %eax,-0x224(%ebp)
801076e5:	89 c3                	mov    %eax,%ebx
801076e7:	8d 80 00 10 00 00    	lea    0x1000(%eax),%eax
801076ed:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
801076f3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801076f7:	90                   	nop
  //   }
  // }
  char *cur=mem;
  char buf[BSIZE];
  for(int j=0;j<8;j++){
    read_page_from_disk(ROOTDEV,buf,st+j);
801076f8:	83 ec 04             	sub    $0x4,%esp
801076fb:	57                   	push   %edi
  for(int j=0;j<8;j++){
801076fc:	83 c7 01             	add    $0x1,%edi
    read_page_from_disk(ROOTDEV,buf,st+j);
801076ff:	56                   	push   %esi
80107700:	6a 01                	push   $0x1
80107702:	e8 29 8c ff ff       	call   80100330 <read_page_from_disk>
    memmove(cur,buf,BSIZE);
80107707:	83 c4 0c             	add    $0xc,%esp
8010770a:	68 00 02 00 00       	push   $0x200
8010770f:	56                   	push   %esi
80107710:	53                   	push   %ebx
    cur+=BSIZE;
80107711:	81 c3 00 02 00 00    	add    $0x200,%ebx
    memmove(cur,buf,BSIZE);
80107717:	e8 64 d3 ff ff       	call   80104a80 <memmove>
  for(int j=0;j<8;j++){
8010771c:	83 c4 10             	add    $0x10,%esp
8010771f:	39 9d e4 fd ff ff    	cmp    %ebx,-0x21c(%ebp)
80107725:	75 d1                	jne    801076f8 <page_fault+0x78>
    // st++;
  }
  uint permission = ss[x].page_perm;
  *add = *((char*)(V2P(mem)))<<12 | PTE_P | PTE_A | permission;
80107727:	8b 85 dc fd ff ff    	mov    -0x224(%ebp),%eax
8010772d:	8b 8d e0 fd ff ff    	mov    -0x220(%ebp),%ecx
80107733:	0f be 80 00 00 00 80 	movsbl -0x80000000(%eax),%eax
8010773a:	c1 e0 0c             	shl    $0xc,%eax
8010773d:	0b 04 cd c0 25 11 80 	or     -0x7feeda40(,%ecx,8),%eax
80107744:	8b 8d d8 fd ff ff    	mov    -0x228(%ebp),%ecx
8010774a:	83 c8 21             	or     $0x21,%eax
8010774d:	89 01                	mov    %eax,(%ecx)
  myproc()->rss+=PGSIZE;
8010774f:	e8 dc c4 ff ff       	call   80103c30 <myproc>
80107754:	81 40 04 00 10 00 00 	addl   $0x1000,0x4(%eax)
  // Fetch permissions of page and mark swap slot free
  // uint per= remove_page(x);
  // add new page

8010775b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010775e:	5b                   	pop    %ebx
8010775f:	5e                   	pop    %esi
80107760:	5f                   	pop    %edi
80107761:	5d                   	pop    %ebp
80107762:	c3                   	ret    

80107763 <uva2ka.cold>:
  if((*pte & PTE_P) == 0)
80107763:	a1 00 00 00 00       	mov    0x0,%eax
80107768:	0f 0b                	ud2    

8010776a <copyout.cold>:
8010776a:	a1 00 00 00 00       	mov    0x0,%eax
8010776f:	0f 0b                	ud2    

80107771 <page_fault.cold>:
  uint x= (*add>>12); // Instead of 3->12  and confusion in and
80107771:	a1 00 00 00 00       	mov    0x0,%eax
80107776:	0f 0b                	ud2    
