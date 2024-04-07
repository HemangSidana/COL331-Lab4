
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
80100028:	bc 60 6f 11 80       	mov    $0x80116f60,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 20 32 10 80       	mov    $0x80103220,%eax
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
80100052:	e8 f9 47 00 00       	call   80104850 <acquire>
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
801000d2:	e8 19 47 00 00       	call   801047f0 <release>
      acquiresleep(&b->lock);
801000d7:	8d 43 0c             	lea    0xc(%ebx),%eax
801000da:	89 04 24             	mov    %eax,(%esp)
801000dd:	e8 ae 44 00 00       	call   80104590 <acquiresleep>
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
801000f2:	68 20 78 10 80       	push   $0x80107820
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
8010010c:	68 31 78 10 80       	push   $0x80107831
80100111:	68 20 b5 10 80       	push   $0x8010b520
80100116:	e8 65 45 00 00       	call   80104680 <initlock>
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
80100152:	68 38 78 10 80       	push   $0x80107838
80100157:	50                   	push   %eax
80100158:	e8 f3 43 00 00       	call   80104550 <initsleeplock>
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
801001b7:	e8 54 22 00 00       	call   80102410 <iderw>
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
801001de:	e8 4d 44 00 00       	call   80104630 <holdingsleep>
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
801001f4:	e9 17 22 00 00       	jmp    80102410 <iderw>
    panic("bwrite");
801001f9:	83 ec 0c             	sub    $0xc,%esp
801001fc:	68 3f 78 10 80       	push   $0x8010783f
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
8010021f:	e8 0c 44 00 00       	call   80104630 <holdingsleep>
80100224:	83 c4 10             	add    $0x10,%esp
80100227:	85 c0                	test   %eax,%eax
80100229:	74 66                	je     80100291 <brelse+0x81>
    panic("brelse");

  releasesleep(&b->lock);
8010022b:	83 ec 0c             	sub    $0xc,%esp
8010022e:	56                   	push   %esi
8010022f:	e8 bc 43 00 00       	call   801045f0 <releasesleep>

  acquire(&bcache.lock);
80100234:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010023b:	e8 10 46 00 00       	call   80104850 <acquire>
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
8010028c:	e9 5f 45 00 00       	jmp    801047f0 <release>
    panic("brelse");
80100291:	83 ec 0c             	sub    $0xc,%esp
80100294:	68 46 78 10 80       	push   $0x80107846
80100299:	e8 12 02 00 00       	call   801004b0 <panic>
8010029e:	66 90                	xchg   %ax,%ax

801002a0 <write_page>:
//PAGEBREAK!
// Blank page.

void
write_page(char *pg, uint blk)
{
801002a0:	55                   	push   %ebp
801002a1:	89 e5                	mov    %esp,%ebp
801002a3:	57                   	push   %edi
801002a4:	56                   	push   %esi
801002a5:	53                   	push   %ebx
801002a6:	83 ec 1c             	sub    $0x1c,%esp
801002a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
801002ac:	8b 75 08             	mov    0x8(%ebp),%esi
801002af:	8d 47 08             	lea    0x8(%edi),%eax
801002b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801002b5:	8d 76 00             	lea    0x0(%esi),%esi
  struct buf* buffer;
  for(int i=0;i<8;i++){
    buffer=bget(ROOTDEV,blk+i);
801002b8:	89 fa                	mov    %edi,%edx
801002ba:	b8 01 00 00 00       	mov    $0x1,%eax
801002bf:	e8 7c fd ff ff       	call   80100040 <bget>
    memmove(buffer->data,pg + i*512,512);  
801002c4:	83 ec 04             	sub    $0x4,%esp
    buffer=bget(ROOTDEV,blk+i);
801002c7:	89 c3                	mov    %eax,%ebx
    memmove(buffer->data,pg + i*512,512);  
801002c9:	8d 40 5c             	lea    0x5c(%eax),%eax
801002cc:	68 00 02 00 00       	push   $0x200
801002d1:	56                   	push   %esi
801002d2:	50                   	push   %eax
801002d3:	e8 d8 46 00 00       	call   801049b0 <memmove>
  if(!holdingsleep(&b->lock))
801002d8:	8d 43 0c             	lea    0xc(%ebx),%eax
801002db:	89 04 24             	mov    %eax,(%esp)
801002de:	e8 4d 43 00 00       	call   80104630 <holdingsleep>
801002e3:	83 c4 10             	add    $0x10,%esp
801002e6:	85 c0                	test   %eax,%eax
801002e8:	74 2d                	je     80100317 <write_page+0x77>
  iderw(b);
801002ea:	83 ec 0c             	sub    $0xc,%esp
  b->flags |= B_DIRTY;
801002ed:	83 0b 04             	orl    $0x4,(%ebx)
  for(int i=0;i<8;i++){
801002f0:	83 c7 01             	add    $0x1,%edi
801002f3:	81 c6 00 02 00 00    	add    $0x200,%esi
  iderw(b);
801002f9:	53                   	push   %ebx
801002fa:	e8 11 21 00 00       	call   80102410 <iderw>
    bwrite(buffer);
    brelse(buffer);                               
801002ff:	89 1c 24             	mov    %ebx,(%esp)
80100302:	e8 09 ff ff ff       	call   80100210 <brelse>
  for(int i=0;i<8;i++){
80100307:	83 c4 10             	add    $0x10,%esp
8010030a:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
8010030d:	75 a9                	jne    801002b8 <write_page+0x18>
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
8010031a:	68 3f 78 10 80       	push   $0x8010783f
8010031f:	e8 8c 01 00 00       	call   801004b0 <panic>
80100324:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010032b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010032f:	90                   	nop

80100330 <read_page>:


void
read_page(char *pg, uint blk)
{
80100330:	55                   	push   %ebp
80100331:	89 e5                	mov    %esp,%ebp
80100333:	57                   	push   %edi
80100334:	56                   	push   %esi
80100335:	53                   	push   %ebx
80100336:	83 ec 1c             	sub    $0x1c,%esp
80100339:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010033c:	8b 75 08             	mov    0x8(%ebp),%esi
8010033f:	8d 43 08             	lea    0x8(%ebx),%eax
80100342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100345:	eb 34                	jmp    8010037b <read_page+0x4b>
80100347:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010034e:	66 90                	xchg   %ax,%ax
  struct buf* buffer;
  for(int i=0;i<8;i++){
    buffer=bread(ROOTDEV,blk+i);   
    memmove(pg+i*512, buffer->data,512);  
80100350:	83 ec 04             	sub    $0x4,%esp
80100353:	8d 47 5c             	lea    0x5c(%edi),%eax
  for(int i=0;i<8;i++){
80100356:	83 c3 01             	add    $0x1,%ebx
    memmove(pg+i*512, buffer->data,512);  
80100359:	68 00 02 00 00       	push   $0x200
8010035e:	50                   	push   %eax
8010035f:	56                   	push   %esi
  for(int i=0;i<8;i++){
80100360:	81 c6 00 02 00 00    	add    $0x200,%esi
    memmove(pg+i*512, buffer->data,512);  
80100366:	e8 45 46 00 00       	call   801049b0 <memmove>
    brelse(buffer);            
8010036b:	89 3c 24             	mov    %edi,(%esp)
8010036e:	e8 9d fe ff ff       	call   80100210 <brelse>
  for(int i=0;i<8;i++){
80100373:	83 c4 10             	add    $0x10,%esp
80100376:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100379:	74 25                	je     801003a0 <read_page+0x70>
  b = bget(dev, blockno);
8010037b:	89 da                	mov    %ebx,%edx
8010037d:	b8 01 00 00 00       	mov    $0x1,%eax
80100382:	e8 b9 fc ff ff       	call   80100040 <bget>
80100387:	89 c7                	mov    %eax,%edi
  if((b->flags & B_VALID) == 0) {
80100389:	f6 00 02             	testb  $0x2,(%eax)
8010038c:	75 c2                	jne    80100350 <read_page+0x20>
    iderw(b);
8010038e:	83 ec 0c             	sub    $0xc,%esp
80100391:	50                   	push   %eax
80100392:	e8 79 20 00 00       	call   80102410 <iderw>
80100397:	83 c4 10             	add    $0x10,%esp
8010039a:	eb b4                	jmp    80100350 <read_page+0x20>
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
801003c4:	e8 c7 15 00 00       	call   80101990 <iunlock>
  acquire(&cons.lock);
801003c9:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801003d0:	e8 7b 44 00 00       	call   80104850 <acquire>
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
801003fd:	e8 8e 3e 00 00       	call   80104290 <sleep>
    while(input.r == input.w){
80100402:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
80100407:	83 c4 10             	add    $0x10,%esp
8010040a:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
80100410:	75 36                	jne    80100448 <consoleread+0x98>
      if(myproc()->killed){
80100412:	e8 29 37 00 00       	call   80103b40 <myproc>
80100417:	8b 48 28             	mov    0x28(%eax),%ecx
8010041a:	85 c9                	test   %ecx,%ecx
8010041c:	74 d2                	je     801003f0 <consoleread+0x40>
        release(&cons.lock);
8010041e:	83 ec 0c             	sub    $0xc,%esp
80100421:	68 20 ff 10 80       	push   $0x8010ff20
80100426:	e8 c5 43 00 00       	call   801047f0 <release>
        ilock(ip);
8010042b:	5a                   	pop    %edx
8010042c:	ff 75 08             	push   0x8(%ebp)
8010042f:	e8 7c 14 00 00       	call   801018b0 <ilock>
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
8010047c:	e8 6f 43 00 00       	call   801047f0 <release>
  ilock(ip);
80100481:	58                   	pop    %eax
80100482:	ff 75 08             	push   0x8(%ebp)
80100485:	e8 26 14 00 00       	call   801018b0 <ilock>
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
801004c9:	e8 e2 25 00 00       	call   80102ab0 <lapicid>
801004ce:	83 ec 08             	sub    $0x8,%esp
801004d1:	50                   	push   %eax
801004d2:	68 4d 78 10 80       	push   $0x8010784d
801004d7:	e8 f4 02 00 00       	call   801007d0 <cprintf>
  cprintf(s);
801004dc:	58                   	pop    %eax
801004dd:	ff 75 08             	push   0x8(%ebp)
801004e0:	e8 eb 02 00 00       	call   801007d0 <cprintf>
  cprintf("\n");
801004e5:	c7 04 24 07 82 10 80 	movl   $0x80108207,(%esp)
801004ec:	e8 df 02 00 00       	call   801007d0 <cprintf>
  getcallerpcs(&s, pcs);
801004f1:	8d 45 08             	lea    0x8(%ebp),%eax
801004f4:	5a                   	pop    %edx
801004f5:	59                   	pop    %ecx
801004f6:	53                   	push   %ebx
801004f7:	50                   	push   %eax
801004f8:	e8 a3 41 00 00       	call   801046a0 <getcallerpcs>
  for(i=0; i<10; i++)
801004fd:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
80100500:	83 ec 08             	sub    $0x8,%esp
80100503:	ff 33                	push   (%ebx)
  for(i=0; i<10; i++)
80100505:	83 c3 04             	add    $0x4,%ebx
    cprintf(" %p", pcs[i]);
80100508:	68 61 78 10 80       	push   $0x80107861
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
8010054a:	e8 51 5a 00 00       	call   80105fa0 <uartputc>
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
80100635:	e8 66 59 00 00       	call   80105fa0 <uartputc>
8010063a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100641:	e8 5a 59 00 00       	call   80105fa0 <uartputc>
80100646:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010064d:	e8 4e 59 00 00       	call   80105fa0 <uartputc>
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
80100681:	e8 2a 43 00 00       	call   801049b0 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100686:	b8 80 07 00 00       	mov    $0x780,%eax
8010068b:	83 c4 0c             	add    $0xc,%esp
8010068e:	29 d8                	sub    %ebx,%eax
80100690:	01 c0                	add    %eax,%eax
80100692:	50                   	push   %eax
80100693:	6a 00                	push   $0x0
80100695:	56                   	push   %esi
80100696:	e8 75 42 00 00       	call   80104910 <memset>
  outb(CRTPORT+1, pos);
8010069b:	88 5d e7             	mov    %bl,-0x19(%ebp)
8010069e:	83 c4 10             	add    $0x10,%esp
801006a1:	e9 20 ff ff ff       	jmp    801005c6 <consputc.part.0+0x96>
    panic("pos under/overflow");
801006a6:	83 ec 0c             	sub    $0xc,%esp
801006a9:	68 65 78 10 80       	push   $0x80107865
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
801006cf:	e8 bc 12 00 00       	call   80101990 <iunlock>
  acquire(&cons.lock);
801006d4:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801006db:	e8 70 41 00 00       	call   80104850 <acquire>
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
80100714:	e8 d7 40 00 00       	call   801047f0 <release>
  ilock(ip);
80100719:	58                   	pop    %eax
8010071a:	ff 75 08             	push   0x8(%ebp)
8010071d:	e8 8e 11 00 00       	call   801018b0 <ilock>

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
80100766:	0f b6 92 90 78 10 80 	movzbl -0x7fef8770(%edx),%edx
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
80100918:	e8 33 3f 00 00       	call   80104850 <acquire>
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
80100968:	bf 78 78 10 80       	mov    $0x80107878,%edi
      for(; *s; s++)
8010096d:	b8 28 00 00 00       	mov    $0x28,%eax
80100972:	e9 19 ff ff ff       	jmp    80100890 <cprintf+0xc0>
80100977:	89 d0                	mov    %edx,%eax
80100979:	e8 b2 fb ff ff       	call   80100530 <consputc.part.0>
8010097e:	e9 c8 fe ff ff       	jmp    8010084b <cprintf+0x7b>
    release(&cons.lock);
80100983:	83 ec 0c             	sub    $0xc,%esp
80100986:	68 20 ff 10 80       	push   $0x8010ff20
8010098b:	e8 60 3e 00 00       	call   801047f0 <release>
80100990:	83 c4 10             	add    $0x10,%esp
}
80100993:	e9 c9 fe ff ff       	jmp    80100861 <cprintf+0x91>
      if((s = (char*)*argp++) == 0)
80100998:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010099b:	e9 ab fe ff ff       	jmp    8010084b <cprintf+0x7b>
    panic("null fmt");
801009a0:	83 ec 0c             	sub    $0xc,%esp
801009a3:	68 7f 78 10 80       	push   $0x8010787f
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
801009c3:	e8 88 3e 00 00       	call   80104850 <acquire>
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
80100b00:	e8 eb 3c 00 00       	call   801047f0 <release>
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
80100b3e:	e9 ed 38 00 00       	jmp    80104430 <procdump>
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
80100b74:	e8 d7 37 00 00       	call   80104350 <wakeup>
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
80100b96:	68 88 78 10 80       	push   $0x80107888
80100b9b:	68 20 ff 10 80       	push   $0x8010ff20
80100ba0:	e8 db 3a 00 00       	call   80104680 <initlock>

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
80100bc9:	e8 e2 19 00 00       	call   801025b0 <ioapicenable>
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
80100bec:	e8 4f 2f 00 00       	call   80103b40 <myproc>
80100bf1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100bf7:	e8 24 23 00 00       	call   80102f20 <begin_op>

  if((ip = namei(path)) == 0){
80100bfc:	83 ec 0c             	sub    $0xc,%esp
80100bff:	ff 75 08             	push   0x8(%ebp)
80100c02:	e8 c9 15 00 00       	call   801021d0 <namei>
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
80100c18:	e8 93 0c 00 00       	call   801018b0 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c1d:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100c23:	6a 34                	push   $0x34
80100c25:	6a 00                	push   $0x0
80100c27:	50                   	push   %eax
80100c28:	53                   	push   %ebx
80100c29:	e8 92 0f 00 00       	call   80101bc0 <readi>
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
80100c3a:	e8 01 0f 00 00       	call   80101b40 <iunlockput>
    end_op();
80100c3f:	e8 4c 23 00 00       	call   80102f90 <end_op>
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
80100cd3:	e8 38 63 00 00       	call   80107010 <allocuvm>
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
80100d09:	e8 12 62 00 00       	call   80106f20 <loaduvm>
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
80100d31:	e8 8a 0e 00 00       	call   80101bc0 <readi>
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
80100d7c:	e8 bf 0d 00 00       	call   80101b40 <iunlockput>
  end_op();
80100d81:	e8 0a 22 00 00       	call   80102f90 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d86:	83 c4 0c             	add    $0xc,%esp
80100d89:	56                   	push   %esi
80100d8a:	57                   	push   %edi
80100d8b:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100d91:	57                   	push   %edi
80100d92:	e8 79 62 00 00       	call   80107010 <allocuvm>
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
80100e03:	e8 08 3d 00 00       	call   80104b10 <strlen>
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
80100e17:	e8 f4 3c 00 00       	call   80104b10 <strlen>
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
80100ed1:	e8 fa 3b 00 00       	call   80104ad0 <safestrcpy>
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
80100efd:	e8 8e 5e 00 00       	call   80106d90 <switchuvm>
  freevm(oldpgdir);
80100f02:	89 3c 24             	mov    %edi,(%esp)
80100f05:	e8 76 62 00 00       	call   80107180 <freevm>
  return 0;
80100f0a:	83 c4 10             	add    $0x10,%esp
80100f0d:	31 c0                	xor    %eax,%eax
80100f0f:	e9 38 fd ff ff       	jmp    80100c4c <exec+0x6c>
    end_op();
80100f14:	e8 77 20 00 00       	call   80102f90 <end_op>
    cprintf("exec: fail\n");
80100f19:	83 ec 0c             	sub    $0xc,%esp
80100f1c:	68 a1 78 10 80       	push   $0x801078a1
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
80100f46:	68 ad 78 10 80       	push   $0x801078ad
80100f4b:	68 60 ff 10 80       	push   $0x8010ff60
80100f50:	e8 2b 37 00 00       	call   80104680 <initlock>
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
80100f71:	e8 da 38 00 00       	call   80104850 <acquire>
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
80100fa1:	e8 4a 38 00 00       	call   801047f0 <release>
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
80100fba:	e8 31 38 00 00       	call   801047f0 <release>
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
80100fdf:	e8 6c 38 00 00       	call   80104850 <acquire>
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
80100ffc:	e8 ef 37 00 00       	call   801047f0 <release>
  return f;
}
80101001:	89 d8                	mov    %ebx,%eax
80101003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101006:	c9                   	leave  
80101007:	c3                   	ret    
    panic("filedup");
80101008:	83 ec 0c             	sub    $0xc,%esp
8010100b:	68 b4 78 10 80       	push   $0x801078b4
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
80101031:	e8 1a 38 00 00       	call   80104850 <acquire>
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
8010106c:	e8 7f 37 00 00       	call   801047f0 <release>

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
8010109e:	e9 4d 37 00 00       	jmp    801047f0 <release>
801010a3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801010a7:	90                   	nop
    begin_op();
801010a8:	e8 73 1e 00 00       	call   80102f20 <begin_op>
    iput(ff.ip);
801010ad:	83 ec 0c             	sub    $0xc,%esp
801010b0:	ff 75 e0             	push   -0x20(%ebp)
801010b3:	e8 28 09 00 00       	call   801019e0 <iput>
    end_op();
801010b8:	83 c4 10             	add    $0x10,%esp
}
801010bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010be:	5b                   	pop    %ebx
801010bf:	5e                   	pop    %esi
801010c0:	5f                   	pop    %edi
801010c1:	5d                   	pop    %ebp
    end_op();
801010c2:	e9 c9 1e 00 00       	jmp    80102f90 <end_op>
801010c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801010ce:	66 90                	xchg   %ax,%ax
    pipeclose(ff.pipe, ff.writable);
801010d0:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
801010d4:	83 ec 08             	sub    $0x8,%esp
801010d7:	53                   	push   %ebx
801010d8:	56                   	push   %esi
801010d9:	e8 12 26 00 00       	call   801036f0 <pipeclose>
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
801010ec:	68 bc 78 10 80       	push   $0x801078bc
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
80101115:	e8 96 07 00 00       	call   801018b0 <ilock>
    stati(f->ip, st);
8010111a:	58                   	pop    %eax
8010111b:	5a                   	pop    %edx
8010111c:	ff 75 0c             	push   0xc(%ebp)
8010111f:	ff 73 10             	push   0x10(%ebx)
80101122:	e8 69 0a 00 00       	call   80101b90 <stati>
    iunlock(f->ip);
80101127:	59                   	pop    %ecx
80101128:	ff 73 10             	push   0x10(%ebx)
8010112b:	e8 60 08 00 00       	call   80101990 <iunlock>
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
8010117a:	e8 31 07 00 00       	call   801018b0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010117f:	57                   	push   %edi
80101180:	ff 73 14             	push   0x14(%ebx)
80101183:	56                   	push   %esi
80101184:	ff 73 10             	push   0x10(%ebx)
80101187:	e8 34 0a 00 00       	call   80101bc0 <readi>
8010118c:	83 c4 20             	add    $0x20,%esp
8010118f:	89 c6                	mov    %eax,%esi
80101191:	85 c0                	test   %eax,%eax
80101193:	7e 03                	jle    80101198 <fileread+0x48>
      f->off += r;
80101195:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80101198:	83 ec 0c             	sub    $0xc,%esp
8010119b:	ff 73 10             	push   0x10(%ebx)
8010119e:	e8 ed 07 00 00       	call   80101990 <iunlock>
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
801011bd:	e9 ce 26 00 00       	jmp    80103890 <piperead>
801011c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801011c8:	be ff ff ff ff       	mov    $0xffffffff,%esi
801011cd:	eb d7                	jmp    801011a6 <fileread+0x56>
  panic("fileread");
801011cf:	83 ec 0c             	sub    $0xc,%esp
801011d2:	68 c6 78 10 80       	push   $0x801078c6
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
80101234:	e8 57 07 00 00       	call   80101990 <iunlock>
      end_op();
80101239:	e8 52 1d 00 00       	call   80102f90 <end_op>

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
8010125e:	e8 bd 1c 00 00       	call   80102f20 <begin_op>
      ilock(f->ip);
80101263:	83 ec 0c             	sub    $0xc,%esp
80101266:	ff 73 10             	push   0x10(%ebx)
80101269:	e8 42 06 00 00       	call   801018b0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010126e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101271:	57                   	push   %edi
80101272:	ff 73 14             	push   0x14(%ebx)
80101275:	01 f0                	add    %esi,%eax
80101277:	50                   	push   %eax
80101278:	ff 73 10             	push   0x10(%ebx)
8010127b:	e8 40 0a 00 00       	call   80101cc0 <writei>
80101280:	83 c4 20             	add    $0x20,%esp
80101283:	85 c0                	test   %eax,%eax
80101285:	7f a1                	jg     80101228 <filewrite+0x48>
      iunlock(f->ip);
80101287:	83 ec 0c             	sub    $0xc,%esp
8010128a:	ff 73 10             	push   0x10(%ebx)
8010128d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101290:	e8 fb 06 00 00       	call   80101990 <iunlock>
      end_op();
80101295:	e8 f6 1c 00 00       	call   80102f90 <end_op>
      if(r < 0)
8010129a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010129d:	83 c4 10             	add    $0x10,%esp
801012a0:	85 c0                	test   %eax,%eax
801012a2:	75 1b                	jne    801012bf <filewrite+0xdf>
        panic("short filewrite");
801012a4:	83 ec 0c             	sub    $0xc,%esp
801012a7:	68 cf 78 10 80       	push   $0x801078cf
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
801012d9:	e9 b2 24 00 00       	jmp    80103790 <pipewrite>
  panic("filewrite");
801012de:	83 ec 0c             	sub    $0xc,%esp
801012e1:	68 d5 78 10 80       	push   $0x801078d5
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
801012f8:	03 05 dc 25 11 80    	add    0x801125dc,%eax
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
8010133d:	e8 be 1d 00 00       	call   80103100 <log_write>
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
80101357:	68 df 78 10 80       	push   $0x801078df
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
80101379:	8b 0d c0 25 11 80    	mov    0x801125c0,%ecx
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
8010139c:	03 05 dc 25 11 80    	add    0x801125dc,%eax
801013a2:	50                   	push   %eax
801013a3:	ff 75 d8             	push   -0x28(%ebp)
801013a6:	e8 e5 ed ff ff       	call   80100190 <bread>
801013ab:	83 c4 10             	add    $0x10,%esp
801013ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013b1:	a1 c0 25 11 80       	mov    0x801125c0,%eax
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
80101409:	39 05 c0 25 11 80    	cmp    %eax,0x801125c0
8010140f:	77 80                	ja     80101391 <balloc+0x21>
  panic("balloc: out of blocks");
80101411:	83 ec 0c             	sub    $0xc,%esp
80101414:	68 f2 78 10 80       	push   $0x801078f2
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
8010142d:	e8 ce 1c 00 00       	call   80103100 <log_write>
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
80101455:	e8 b6 34 00 00       	call   80104910 <memset>
  log_write(bp);
8010145a:	89 1c 24             	mov    %ebx,(%esp)
8010145d:	e8 9e 1c 00 00       	call   80103100 <log_write>
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
8010149a:	e8 b1 33 00 00       	call   80104850 <acquire>
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
80101507:	e8 e4 32 00 00       	call   801047f0 <release>

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
80101535:	e8 b6 32 00 00       	call   801047f0 <release>
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
80101568:	68 08 79 10 80       	push   $0x80107908
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
801015f5:	e8 06 1b 00 00       	call   80103100 <log_write>
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
80101645:	68 18 79 10 80       	push   $0x80107918
8010164a:	e8 61 ee ff ff       	call   801004b0 <panic>
8010164f:	90                   	nop

80101650 <readsb>:
{
80101650:	55                   	push   %ebp
80101651:	89 e5                	mov    %esp,%ebp
80101653:	56                   	push   %esi
80101654:	53                   	push   %ebx
80101655:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101658:	83 ec 08             	sub    $0x8,%esp
8010165b:	6a 01                	push   $0x1
8010165d:	ff 75 08             	push   0x8(%ebp)
80101660:	e8 2b eb ff ff       	call   80100190 <bread>
  memmove(sb, bp->data, sizeof(*sb));
80101665:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
80101668:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010166a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010166d:	6a 24                	push   $0x24
8010166f:	50                   	push   %eax
80101670:	56                   	push   %esi
80101671:	e8 3a 33 00 00       	call   801049b0 <memmove>
  brelse(bp);
80101676:	89 1c 24             	mov    %ebx,(%esp)
80101679:	e8 92 eb ff ff       	call   80100210 <brelse>
  init_slot();
8010167e:	83 c4 10             	add    $0x10,%esp
}
80101681:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101684:	5b                   	pop    %ebx
80101685:	5e                   	pop    %esi
80101686:	5d                   	pop    %ebp
  init_slot();
80101687:	e9 c4 5e 00 00       	jmp    80107550 <init_slot>
8010168c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101690 <iinit>:
{
80101690:	55                   	push   %ebp
80101691:	89 e5                	mov    %esp,%ebp
80101693:	53                   	push   %ebx
80101694:	bb a0 09 11 80       	mov    $0x801109a0,%ebx
80101699:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010169c:	68 2b 79 10 80       	push   $0x8010792b
801016a1:	68 60 09 11 80       	push   $0x80110960
801016a6:	e8 d5 2f 00 00       	call   80104680 <initlock>
  for(i = 0; i < NINODE; i++) {
801016ab:	83 c4 10             	add    $0x10,%esp
801016ae:	66 90                	xchg   %ax,%ax
    initsleeplock(&icache.inode[i].lock, "inode");
801016b0:	83 ec 08             	sub    $0x8,%esp
801016b3:	68 32 79 10 80       	push   $0x80107932
801016b8:	53                   	push   %ebx
  for(i = 0; i < NINODE; i++) {
801016b9:	81 c3 90 00 00 00    	add    $0x90,%ebx
    initsleeplock(&icache.inode[i].lock, "inode");
801016bf:	e8 8c 2e 00 00       	call   80104550 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801016c4:	83 c4 10             	add    $0x10,%esp
801016c7:	81 fb c0 25 11 80    	cmp    $0x801125c0,%ebx
801016cd:	75 e1                	jne    801016b0 <iinit+0x20>
  bp = bread(dev, 1);
801016cf:	83 ec 08             	sub    $0x8,%esp
801016d2:	6a 01                	push   $0x1
801016d4:	ff 75 08             	push   0x8(%ebp)
801016d7:	e8 b4 ea ff ff       	call   80100190 <bread>
  memmove(sb, bp->data, sizeof(*sb));
801016dc:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
801016df:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801016e1:	8d 40 5c             	lea    0x5c(%eax),%eax
801016e4:	6a 24                	push   $0x24
801016e6:	50                   	push   %eax
801016e7:	68 c0 25 11 80       	push   $0x801125c0
801016ec:	e8 bf 32 00 00       	call   801049b0 <memmove>
  brelse(bp);
801016f1:	89 1c 24             	mov    %ebx,(%esp)
801016f4:	e8 17 eb ff ff       	call   80100210 <brelse>
  init_slot();
801016f9:	e8 52 5e 00 00       	call   80107550 <init_slot>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016fe:	ff 35 dc 25 11 80    	push   0x801125dc
80101704:	ff 35 d8 25 11 80    	push   0x801125d8
8010170a:	ff 35 d4 25 11 80    	push   0x801125d4
80101710:	ff 35 cc 25 11 80    	push   0x801125cc
80101716:	ff 35 c8 25 11 80    	push   0x801125c8
8010171c:	ff 35 c4 25 11 80    	push   0x801125c4
80101722:	ff 35 c0 25 11 80    	push   0x801125c0
80101728:	68 98 79 10 80       	push   $0x80107998
8010172d:	e8 9e f0 ff ff       	call   801007d0 <cprintf>
}
80101732:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101735:	83 c4 30             	add    $0x30,%esp
80101738:	c9                   	leave  
80101739:	c3                   	ret    
8010173a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101740 <ialloc>:
{
80101740:	55                   	push   %ebp
80101741:	89 e5                	mov    %esp,%ebp
80101743:	57                   	push   %edi
80101744:	56                   	push   %esi
80101745:	53                   	push   %ebx
80101746:	83 ec 1c             	sub    $0x1c,%esp
80101749:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
8010174c:	83 3d c8 25 11 80 01 	cmpl   $0x1,0x801125c8
{
80101753:	8b 75 08             	mov    0x8(%ebp),%esi
80101756:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101759:	0f 86 91 00 00 00    	jbe    801017f0 <ialloc+0xb0>
8010175f:	bf 01 00 00 00       	mov    $0x1,%edi
80101764:	eb 21                	jmp    80101787 <ialloc+0x47>
80101766:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010176d:	8d 76 00             	lea    0x0(%esi),%esi
    brelse(bp);
80101770:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101773:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
80101776:	53                   	push   %ebx
80101777:	e8 94 ea ff ff       	call   80100210 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010177c:	83 c4 10             	add    $0x10,%esp
8010177f:	3b 3d c8 25 11 80    	cmp    0x801125c8,%edi
80101785:	73 69                	jae    801017f0 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
80101787:	89 f8                	mov    %edi,%eax
80101789:	83 ec 08             	sub    $0x8,%esp
8010178c:	c1 e8 03             	shr    $0x3,%eax
8010178f:	03 05 d8 25 11 80    	add    0x801125d8,%eax
80101795:	50                   	push   %eax
80101796:	56                   	push   %esi
80101797:	e8 f4 e9 ff ff       	call   80100190 <bread>
    if(dip->type == 0){  // a free inode
8010179c:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
8010179f:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
801017a1:	89 f8                	mov    %edi,%eax
801017a3:	83 e0 07             	and    $0x7,%eax
801017a6:	c1 e0 06             	shl    $0x6,%eax
801017a9:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
801017ad:	66 83 39 00          	cmpw   $0x0,(%ecx)
801017b1:	75 bd                	jne    80101770 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
801017b3:	83 ec 04             	sub    $0x4,%esp
801017b6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801017b9:	6a 40                	push   $0x40
801017bb:	6a 00                	push   $0x0
801017bd:	51                   	push   %ecx
801017be:	e8 4d 31 00 00       	call   80104910 <memset>
      dip->type = type;
801017c3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801017c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801017ca:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
801017cd:	89 1c 24             	mov    %ebx,(%esp)
801017d0:	e8 2b 19 00 00       	call   80103100 <log_write>
      brelse(bp);
801017d5:	89 1c 24             	mov    %ebx,(%esp)
801017d8:	e8 33 ea ff ff       	call   80100210 <brelse>
      return iget(dev, inum);
801017dd:	83 c4 10             	add    $0x10,%esp
}
801017e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
801017e3:	89 fa                	mov    %edi,%edx
}
801017e5:	5b                   	pop    %ebx
      return iget(dev, inum);
801017e6:	89 f0                	mov    %esi,%eax
}
801017e8:	5e                   	pop    %esi
801017e9:	5f                   	pop    %edi
801017ea:	5d                   	pop    %ebp
      return iget(dev, inum);
801017eb:	e9 90 fc ff ff       	jmp    80101480 <iget>
  panic("ialloc: no inodes");
801017f0:	83 ec 0c             	sub    $0xc,%esp
801017f3:	68 38 79 10 80       	push   $0x80107938
801017f8:	e8 b3 ec ff ff       	call   801004b0 <panic>
801017fd:	8d 76 00             	lea    0x0(%esi),%esi

80101800 <iupdate>:
{
80101800:	55                   	push   %ebp
80101801:	89 e5                	mov    %esp,%ebp
80101803:	56                   	push   %esi
80101804:	53                   	push   %ebx
80101805:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101808:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010180b:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010180e:	83 ec 08             	sub    $0x8,%esp
80101811:	c1 e8 03             	shr    $0x3,%eax
80101814:	03 05 d8 25 11 80    	add    0x801125d8,%eax
8010181a:	50                   	push   %eax
8010181b:	ff 73 a4             	push   -0x5c(%ebx)
8010181e:	e8 6d e9 ff ff       	call   80100190 <bread>
  dip->type = ip->type;
80101823:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101827:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010182a:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010182c:	8b 43 a8             	mov    -0x58(%ebx),%eax
8010182f:	83 e0 07             	and    $0x7,%eax
80101832:	c1 e0 06             	shl    $0x6,%eax
80101835:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101839:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010183c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101840:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
80101843:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
80101847:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
8010184b:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
8010184f:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
80101853:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
80101857:	8b 53 fc             	mov    -0x4(%ebx),%edx
8010185a:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010185d:	6a 34                	push   $0x34
8010185f:	53                   	push   %ebx
80101860:	50                   	push   %eax
80101861:	e8 4a 31 00 00       	call   801049b0 <memmove>
  log_write(bp);
80101866:	89 34 24             	mov    %esi,(%esp)
80101869:	e8 92 18 00 00       	call   80103100 <log_write>
  brelse(bp);
8010186e:	89 75 08             	mov    %esi,0x8(%ebp)
80101871:	83 c4 10             	add    $0x10,%esp
}
80101874:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101877:	5b                   	pop    %ebx
80101878:	5e                   	pop    %esi
80101879:	5d                   	pop    %ebp
  brelse(bp);
8010187a:	e9 91 e9 ff ff       	jmp    80100210 <brelse>
8010187f:	90                   	nop

80101880 <idup>:
{
80101880:	55                   	push   %ebp
80101881:	89 e5                	mov    %esp,%ebp
80101883:	53                   	push   %ebx
80101884:	83 ec 10             	sub    $0x10,%esp
80101887:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010188a:	68 60 09 11 80       	push   $0x80110960
8010188f:	e8 bc 2f 00 00       	call   80104850 <acquire>
  ip->ref++;
80101894:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101898:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
8010189f:	e8 4c 2f 00 00       	call   801047f0 <release>
}
801018a4:	89 d8                	mov    %ebx,%eax
801018a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801018a9:	c9                   	leave  
801018aa:	c3                   	ret    
801018ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801018af:	90                   	nop

801018b0 <ilock>:
{
801018b0:	55                   	push   %ebp
801018b1:	89 e5                	mov    %esp,%ebp
801018b3:	56                   	push   %esi
801018b4:	53                   	push   %ebx
801018b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
801018b8:	85 db                	test   %ebx,%ebx
801018ba:	0f 84 b7 00 00 00    	je     80101977 <ilock+0xc7>
801018c0:	8b 53 08             	mov    0x8(%ebx),%edx
801018c3:	85 d2                	test   %edx,%edx
801018c5:	0f 8e ac 00 00 00    	jle    80101977 <ilock+0xc7>
  acquiresleep(&ip->lock);
801018cb:	83 ec 0c             	sub    $0xc,%esp
801018ce:	8d 43 0c             	lea    0xc(%ebx),%eax
801018d1:	50                   	push   %eax
801018d2:	e8 b9 2c 00 00       	call   80104590 <acquiresleep>
  if(ip->valid == 0){
801018d7:	8b 43 4c             	mov    0x4c(%ebx),%eax
801018da:	83 c4 10             	add    $0x10,%esp
801018dd:	85 c0                	test   %eax,%eax
801018df:	74 0f                	je     801018f0 <ilock+0x40>
}
801018e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801018e4:	5b                   	pop    %ebx
801018e5:	5e                   	pop    %esi
801018e6:	5d                   	pop    %ebp
801018e7:	c3                   	ret    
801018e8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801018ef:	90                   	nop
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018f0:	8b 43 04             	mov    0x4(%ebx),%eax
801018f3:	83 ec 08             	sub    $0x8,%esp
801018f6:	c1 e8 03             	shr    $0x3,%eax
801018f9:	03 05 d8 25 11 80    	add    0x801125d8,%eax
801018ff:	50                   	push   %eax
80101900:	ff 33                	push   (%ebx)
80101902:	e8 89 e8 ff ff       	call   80100190 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101907:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010190a:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010190c:	8b 43 04             	mov    0x4(%ebx),%eax
8010190f:	83 e0 07             	and    $0x7,%eax
80101912:	c1 e0 06             	shl    $0x6,%eax
80101915:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101919:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010191c:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
8010191f:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101923:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
80101927:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
8010192b:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
8010192f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101933:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
80101937:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010193b:	8b 50 fc             	mov    -0x4(%eax),%edx
8010193e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101941:	6a 34                	push   $0x34
80101943:	50                   	push   %eax
80101944:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101947:	50                   	push   %eax
80101948:	e8 63 30 00 00       	call   801049b0 <memmove>
    brelse(bp);
8010194d:	89 34 24             	mov    %esi,(%esp)
80101950:	e8 bb e8 ff ff       	call   80100210 <brelse>
    if(ip->type == 0)
80101955:	83 c4 10             	add    $0x10,%esp
80101958:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
8010195d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101964:	0f 85 77 ff ff ff    	jne    801018e1 <ilock+0x31>
      panic("ilock: no type");
8010196a:	83 ec 0c             	sub    $0xc,%esp
8010196d:	68 50 79 10 80       	push   $0x80107950
80101972:	e8 39 eb ff ff       	call   801004b0 <panic>
    panic("ilock");
80101977:	83 ec 0c             	sub    $0xc,%esp
8010197a:	68 4a 79 10 80       	push   $0x8010794a
8010197f:	e8 2c eb ff ff       	call   801004b0 <panic>
80101984:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010198b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010198f:	90                   	nop

80101990 <iunlock>:
{
80101990:	55                   	push   %ebp
80101991:	89 e5                	mov    %esp,%ebp
80101993:	56                   	push   %esi
80101994:	53                   	push   %ebx
80101995:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101998:	85 db                	test   %ebx,%ebx
8010199a:	74 28                	je     801019c4 <iunlock+0x34>
8010199c:	83 ec 0c             	sub    $0xc,%esp
8010199f:	8d 73 0c             	lea    0xc(%ebx),%esi
801019a2:	56                   	push   %esi
801019a3:	e8 88 2c 00 00       	call   80104630 <holdingsleep>
801019a8:	83 c4 10             	add    $0x10,%esp
801019ab:	85 c0                	test   %eax,%eax
801019ad:	74 15                	je     801019c4 <iunlock+0x34>
801019af:	8b 43 08             	mov    0x8(%ebx),%eax
801019b2:	85 c0                	test   %eax,%eax
801019b4:	7e 0e                	jle    801019c4 <iunlock+0x34>
  releasesleep(&ip->lock);
801019b6:	89 75 08             	mov    %esi,0x8(%ebp)
}
801019b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801019bc:	5b                   	pop    %ebx
801019bd:	5e                   	pop    %esi
801019be:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
801019bf:	e9 2c 2c 00 00       	jmp    801045f0 <releasesleep>
    panic("iunlock");
801019c4:	83 ec 0c             	sub    $0xc,%esp
801019c7:	68 5f 79 10 80       	push   $0x8010795f
801019cc:	e8 df ea ff ff       	call   801004b0 <panic>
801019d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801019d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801019df:	90                   	nop

801019e0 <iput>:
{
801019e0:	55                   	push   %ebp
801019e1:	89 e5                	mov    %esp,%ebp
801019e3:	57                   	push   %edi
801019e4:	56                   	push   %esi
801019e5:	53                   	push   %ebx
801019e6:	83 ec 28             	sub    $0x28,%esp
801019e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801019ec:	8d 7b 0c             	lea    0xc(%ebx),%edi
801019ef:	57                   	push   %edi
801019f0:	e8 9b 2b 00 00       	call   80104590 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801019f5:	8b 53 4c             	mov    0x4c(%ebx),%edx
801019f8:	83 c4 10             	add    $0x10,%esp
801019fb:	85 d2                	test   %edx,%edx
801019fd:	74 07                	je     80101a06 <iput+0x26>
801019ff:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101a04:	74 32                	je     80101a38 <iput+0x58>
  releasesleep(&ip->lock);
80101a06:	83 ec 0c             	sub    $0xc,%esp
80101a09:	57                   	push   %edi
80101a0a:	e8 e1 2b 00 00       	call   801045f0 <releasesleep>
  acquire(&icache.lock);
80101a0f:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101a16:	e8 35 2e 00 00       	call   80104850 <acquire>
  ip->ref--;
80101a1b:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101a1f:	83 c4 10             	add    $0x10,%esp
80101a22:	c7 45 08 60 09 11 80 	movl   $0x80110960,0x8(%ebp)
}
80101a29:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a2c:	5b                   	pop    %ebx
80101a2d:	5e                   	pop    %esi
80101a2e:	5f                   	pop    %edi
80101a2f:	5d                   	pop    %ebp
  release(&icache.lock);
80101a30:	e9 bb 2d 00 00       	jmp    801047f0 <release>
80101a35:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&icache.lock);
80101a38:	83 ec 0c             	sub    $0xc,%esp
80101a3b:	68 60 09 11 80       	push   $0x80110960
80101a40:	e8 0b 2e 00 00       	call   80104850 <acquire>
    int r = ip->ref;
80101a45:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101a48:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101a4f:	e8 9c 2d 00 00       	call   801047f0 <release>
    if(r == 1){
80101a54:	83 c4 10             	add    $0x10,%esp
80101a57:	83 fe 01             	cmp    $0x1,%esi
80101a5a:	75 aa                	jne    80101a06 <iput+0x26>
80101a5c:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101a62:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101a65:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101a68:	89 cf                	mov    %ecx,%edi
80101a6a:	eb 0b                	jmp    80101a77 <iput+0x97>
80101a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101a70:	83 c6 04             	add    $0x4,%esi
80101a73:	39 fe                	cmp    %edi,%esi
80101a75:	74 19                	je     80101a90 <iput+0xb0>
    if(ip->addrs[i]){
80101a77:	8b 16                	mov    (%esi),%edx
80101a79:	85 d2                	test   %edx,%edx
80101a7b:	74 f3                	je     80101a70 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
80101a7d:	8b 03                	mov    (%ebx),%eax
80101a7f:	e8 6c f8 ff ff       	call   801012f0 <bfree>
      ip->addrs[i] = 0;
80101a84:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80101a8a:	eb e4                	jmp    80101a70 <iput+0x90>
80101a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101a90:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101a96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101a99:	85 c0                	test   %eax,%eax
80101a9b:	75 2d                	jne    80101aca <iput+0xea>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
80101a9d:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101aa0:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101aa7:	53                   	push   %ebx
80101aa8:	e8 53 fd ff ff       	call   80101800 <iupdate>
      ip->type = 0;
80101aad:	31 c0                	xor    %eax,%eax
80101aaf:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101ab3:	89 1c 24             	mov    %ebx,(%esp)
80101ab6:	e8 45 fd ff ff       	call   80101800 <iupdate>
      ip->valid = 0;
80101abb:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101ac2:	83 c4 10             	add    $0x10,%esp
80101ac5:	e9 3c ff ff ff       	jmp    80101a06 <iput+0x26>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101aca:	83 ec 08             	sub    $0x8,%esp
80101acd:	50                   	push   %eax
80101ace:	ff 33                	push   (%ebx)
80101ad0:	e8 bb e6 ff ff       	call   80100190 <bread>
80101ad5:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101ad8:	83 c4 10             	add    $0x10,%esp
80101adb:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
80101ae1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ae4:	8d 70 5c             	lea    0x5c(%eax),%esi
80101ae7:	89 cf                	mov    %ecx,%edi
80101ae9:	eb 0c                	jmp    80101af7 <iput+0x117>
80101aeb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101aef:	90                   	nop
80101af0:	83 c6 04             	add    $0x4,%esi
80101af3:	39 f7                	cmp    %esi,%edi
80101af5:	74 0f                	je     80101b06 <iput+0x126>
      if(a[j])
80101af7:	8b 16                	mov    (%esi),%edx
80101af9:	85 d2                	test   %edx,%edx
80101afb:	74 f3                	je     80101af0 <iput+0x110>
        bfree(ip->dev, a[j]);
80101afd:	8b 03                	mov    (%ebx),%eax
80101aff:	e8 ec f7 ff ff       	call   801012f0 <bfree>
80101b04:	eb ea                	jmp    80101af0 <iput+0x110>
    brelse(bp);
80101b06:	83 ec 0c             	sub    $0xc,%esp
80101b09:	ff 75 e4             	push   -0x1c(%ebp)
80101b0c:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101b0f:	e8 fc e6 ff ff       	call   80100210 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101b14:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101b1a:	8b 03                	mov    (%ebx),%eax
80101b1c:	e8 cf f7 ff ff       	call   801012f0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101b21:	83 c4 10             	add    $0x10,%esp
80101b24:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101b2b:	00 00 00 
80101b2e:	e9 6a ff ff ff       	jmp    80101a9d <iput+0xbd>
80101b33:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101b40 <iunlockput>:
{
80101b40:	55                   	push   %ebp
80101b41:	89 e5                	mov    %esp,%ebp
80101b43:	56                   	push   %esi
80101b44:	53                   	push   %ebx
80101b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b48:	85 db                	test   %ebx,%ebx
80101b4a:	74 34                	je     80101b80 <iunlockput+0x40>
80101b4c:	83 ec 0c             	sub    $0xc,%esp
80101b4f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101b52:	56                   	push   %esi
80101b53:	e8 d8 2a 00 00       	call   80104630 <holdingsleep>
80101b58:	83 c4 10             	add    $0x10,%esp
80101b5b:	85 c0                	test   %eax,%eax
80101b5d:	74 21                	je     80101b80 <iunlockput+0x40>
80101b5f:	8b 43 08             	mov    0x8(%ebx),%eax
80101b62:	85 c0                	test   %eax,%eax
80101b64:	7e 1a                	jle    80101b80 <iunlockput+0x40>
  releasesleep(&ip->lock);
80101b66:	83 ec 0c             	sub    $0xc,%esp
80101b69:	56                   	push   %esi
80101b6a:	e8 81 2a 00 00       	call   801045f0 <releasesleep>
  iput(ip);
80101b6f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101b72:	83 c4 10             	add    $0x10,%esp
}
80101b75:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101b78:	5b                   	pop    %ebx
80101b79:	5e                   	pop    %esi
80101b7a:	5d                   	pop    %ebp
  iput(ip);
80101b7b:	e9 60 fe ff ff       	jmp    801019e0 <iput>
    panic("iunlock");
80101b80:	83 ec 0c             	sub    $0xc,%esp
80101b83:	68 5f 79 10 80       	push   $0x8010795f
80101b88:	e8 23 e9 ff ff       	call   801004b0 <panic>
80101b8d:	8d 76 00             	lea    0x0(%esi),%esi

80101b90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101b90:	55                   	push   %ebp
80101b91:	89 e5                	mov    %esp,%ebp
80101b93:	8b 55 08             	mov    0x8(%ebp),%edx
80101b96:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101b99:	8b 0a                	mov    (%edx),%ecx
80101b9b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101b9e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101ba1:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101ba4:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101ba8:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101bab:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101baf:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101bb3:	8b 52 58             	mov    0x58(%edx),%edx
80101bb6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101bb9:	5d                   	pop    %ebp
80101bba:	c3                   	ret    
80101bbb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101bbf:	90                   	nop

80101bc0 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101bc0:	55                   	push   %ebp
80101bc1:	89 e5                	mov    %esp,%ebp
80101bc3:	57                   	push   %edi
80101bc4:	56                   	push   %esi
80101bc5:	53                   	push   %ebx
80101bc6:	83 ec 1c             	sub    $0x1c,%esp
80101bc9:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcf:	8b 75 10             	mov    0x10(%ebp),%esi
80101bd2:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101bd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101bd8:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101bdd:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101be0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101be3:	0f 84 a7 00 00 00    	je     80101c90 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101be9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101bec:	8b 40 58             	mov    0x58(%eax),%eax
80101bef:	39 c6                	cmp    %eax,%esi
80101bf1:	0f 87 ba 00 00 00    	ja     80101cb1 <readi+0xf1>
80101bf7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101bfa:	31 c9                	xor    %ecx,%ecx
80101bfc:	89 da                	mov    %ebx,%edx
80101bfe:	01 f2                	add    %esi,%edx
80101c00:	0f 92 c1             	setb   %cl
80101c03:	89 cf                	mov    %ecx,%edi
80101c05:	0f 82 a6 00 00 00    	jb     80101cb1 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101c0b:	89 c1                	mov    %eax,%ecx
80101c0d:	29 f1                	sub    %esi,%ecx
80101c0f:	39 d0                	cmp    %edx,%eax
80101c11:	0f 43 cb             	cmovae %ebx,%ecx
80101c14:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c17:	85 c9                	test   %ecx,%ecx
80101c19:	74 67                	je     80101c82 <readi+0xc2>
80101c1b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101c1f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c20:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101c23:	89 f2                	mov    %esi,%edx
80101c25:	c1 ea 09             	shr    $0x9,%edx
80101c28:	89 d8                	mov    %ebx,%eax
80101c2a:	e8 51 f9 ff ff       	call   80101580 <bmap>
80101c2f:	83 ec 08             	sub    $0x8,%esp
80101c32:	50                   	push   %eax
80101c33:	ff 33                	push   (%ebx)
80101c35:	e8 56 e5 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101c3a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101c3d:	b9 00 02 00 00       	mov    $0x200,%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c42:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101c44:	89 f0                	mov    %esi,%eax
80101c46:	25 ff 01 00 00       	and    $0x1ff,%eax
80101c4b:	29 fb                	sub    %edi,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101c4d:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101c50:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101c52:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101c56:	39 d9                	cmp    %ebx,%ecx
80101c58:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101c5b:	83 c4 0c             	add    $0xc,%esp
80101c5e:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c5f:	01 df                	add    %ebx,%edi
80101c61:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
80101c63:	50                   	push   %eax
80101c64:	ff 75 e0             	push   -0x20(%ebp)
80101c67:	e8 44 2d 00 00       	call   801049b0 <memmove>
    brelse(bp);
80101c6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101c6f:	89 14 24             	mov    %edx,(%esp)
80101c72:	e8 99 e5 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c77:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101c7a:	83 c4 10             	add    $0x10,%esp
80101c7d:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101c80:	77 9e                	ja     80101c20 <readi+0x60>
  }
  return n;
80101c82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c88:	5b                   	pop    %ebx
80101c89:	5e                   	pop    %esi
80101c8a:	5f                   	pop    %edi
80101c8b:	5d                   	pop    %ebp
80101c8c:	c3                   	ret    
80101c8d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101c90:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101c94:	66 83 f8 09          	cmp    $0x9,%ax
80101c98:	77 17                	ja     80101cb1 <readi+0xf1>
80101c9a:	8b 04 c5 00 09 11 80 	mov    -0x7feef700(,%eax,8),%eax
80101ca1:	85 c0                	test   %eax,%eax
80101ca3:	74 0c                	je     80101cb1 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101ca5:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101cab:	5b                   	pop    %ebx
80101cac:	5e                   	pop    %esi
80101cad:	5f                   	pop    %edi
80101cae:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101caf:	ff e0                	jmp    *%eax
      return -1;
80101cb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101cb6:	eb cd                	jmp    80101c85 <readi+0xc5>
80101cb8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101cbf:	90                   	nop

80101cc0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101cc0:	55                   	push   %ebp
80101cc1:	89 e5                	mov    %esp,%ebp
80101cc3:	57                   	push   %edi
80101cc4:	56                   	push   %esi
80101cc5:	53                   	push   %ebx
80101cc6:	83 ec 1c             	sub    $0x1c,%esp
80101cc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccc:	8b 75 0c             	mov    0xc(%ebp),%esi
80101ccf:	8b 55 14             	mov    0x14(%ebp),%edx
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101cd2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101cd7:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101cda:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101cdd:	8b 75 10             	mov    0x10(%ebp),%esi
80101ce0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(ip->type == T_DEV){
80101ce3:	0f 84 b7 00 00 00    	je     80101da0 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101ce9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101cec:	3b 70 58             	cmp    0x58(%eax),%esi
80101cef:	0f 87 e7 00 00 00    	ja     80101ddc <writei+0x11c>
80101cf5:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101cf8:	31 d2                	xor    %edx,%edx
80101cfa:	89 f8                	mov    %edi,%eax
80101cfc:	01 f0                	add    %esi,%eax
80101cfe:	0f 92 c2             	setb   %dl
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101d01:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101d06:	0f 87 d0 00 00 00    	ja     80101ddc <writei+0x11c>
80101d0c:	85 d2                	test   %edx,%edx
80101d0e:	0f 85 c8 00 00 00    	jne    80101ddc <writei+0x11c>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d14:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101d1b:	85 ff                	test   %edi,%edi
80101d1d:	74 72                	je     80101d91 <writei+0xd1>
80101d1f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d20:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101d23:	89 f2                	mov    %esi,%edx
80101d25:	c1 ea 09             	shr    $0x9,%edx
80101d28:	89 f8                	mov    %edi,%eax
80101d2a:	e8 51 f8 ff ff       	call   80101580 <bmap>
80101d2f:	83 ec 08             	sub    $0x8,%esp
80101d32:	50                   	push   %eax
80101d33:	ff 37                	push   (%edi)
80101d35:	e8 56 e4 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101d3a:	b9 00 02 00 00       	mov    $0x200,%ecx
80101d3f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101d42:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101d45:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101d47:	89 f0                	mov    %esi,%eax
80101d49:	25 ff 01 00 00       	and    $0x1ff,%eax
80101d4e:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101d50:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101d54:	39 d9                	cmp    %ebx,%ecx
80101d56:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101d59:	83 c4 0c             	add    $0xc,%esp
80101d5c:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d5d:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101d5f:	ff 75 dc             	push   -0x24(%ebp)
80101d62:	50                   	push   %eax
80101d63:	e8 48 2c 00 00       	call   801049b0 <memmove>
    log_write(bp);
80101d68:	89 3c 24             	mov    %edi,(%esp)
80101d6b:	e8 90 13 00 00       	call   80103100 <log_write>
    brelse(bp);
80101d70:	89 3c 24             	mov    %edi,(%esp)
80101d73:	e8 98 e4 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d78:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101d7b:	83 c4 10             	add    $0x10,%esp
80101d7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101d81:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101d84:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101d87:	77 97                	ja     80101d20 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101d89:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101d8c:	3b 70 58             	cmp    0x58(%eax),%esi
80101d8f:	77 37                	ja     80101dc8 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101d91:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d97:	5b                   	pop    %ebx
80101d98:	5e                   	pop    %esi
80101d99:	5f                   	pop    %edi
80101d9a:	5d                   	pop    %ebp
80101d9b:	c3                   	ret    
80101d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101da0:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101da4:	66 83 f8 09          	cmp    $0x9,%ax
80101da8:	77 32                	ja     80101ddc <writei+0x11c>
80101daa:	8b 04 c5 04 09 11 80 	mov    -0x7feef6fc(,%eax,8),%eax
80101db1:	85 c0                	test   %eax,%eax
80101db3:	74 27                	je     80101ddc <writei+0x11c>
    return devsw[ip->major].write(ip, src, n);
80101db5:	89 55 10             	mov    %edx,0x10(%ebp)
}
80101db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101dbb:	5b                   	pop    %ebx
80101dbc:	5e                   	pop    %esi
80101dbd:	5f                   	pop    %edi
80101dbe:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101dbf:	ff e0                	jmp    *%eax
80101dc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101dc8:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101dcb:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101dce:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101dd1:	50                   	push   %eax
80101dd2:	e8 29 fa ff ff       	call   80101800 <iupdate>
80101dd7:	83 c4 10             	add    $0x10,%esp
80101dda:	eb b5                	jmp    80101d91 <writei+0xd1>
      return -1;
80101ddc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101de1:	eb b1                	jmp    80101d94 <writei+0xd4>
80101de3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101df0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101df0:	55                   	push   %ebp
80101df1:	89 e5                	mov    %esp,%ebp
80101df3:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101df6:	6a 0e                	push   $0xe
80101df8:	ff 75 0c             	push   0xc(%ebp)
80101dfb:	ff 75 08             	push   0x8(%ebp)
80101dfe:	e8 1d 2c 00 00       	call   80104a20 <strncmp>
}
80101e03:	c9                   	leave  
80101e04:	c3                   	ret    
80101e05:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101e10 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101e10:	55                   	push   %ebp
80101e11:	89 e5                	mov    %esp,%ebp
80101e13:	57                   	push   %edi
80101e14:	56                   	push   %esi
80101e15:	53                   	push   %ebx
80101e16:	83 ec 1c             	sub    $0x1c,%esp
80101e19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101e1c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101e21:	0f 85 85 00 00 00    	jne    80101eac <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101e27:	8b 53 58             	mov    0x58(%ebx),%edx
80101e2a:	31 ff                	xor    %edi,%edi
80101e2c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101e2f:	85 d2                	test   %edx,%edx
80101e31:	74 3e                	je     80101e71 <dirlookup+0x61>
80101e33:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101e37:	90                   	nop
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101e38:	6a 10                	push   $0x10
80101e3a:	57                   	push   %edi
80101e3b:	56                   	push   %esi
80101e3c:	53                   	push   %ebx
80101e3d:	e8 7e fd ff ff       	call   80101bc0 <readi>
80101e42:	83 c4 10             	add    $0x10,%esp
80101e45:	83 f8 10             	cmp    $0x10,%eax
80101e48:	75 55                	jne    80101e9f <dirlookup+0x8f>
      panic("dirlookup read");
    if(de.inum == 0)
80101e4a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101e4f:	74 18                	je     80101e69 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101e51:	83 ec 04             	sub    $0x4,%esp
80101e54:	8d 45 da             	lea    -0x26(%ebp),%eax
80101e57:	6a 0e                	push   $0xe
80101e59:	50                   	push   %eax
80101e5a:	ff 75 0c             	push   0xc(%ebp)
80101e5d:	e8 be 2b 00 00       	call   80104a20 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101e62:	83 c4 10             	add    $0x10,%esp
80101e65:	85 c0                	test   %eax,%eax
80101e67:	74 17                	je     80101e80 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101e69:	83 c7 10             	add    $0x10,%edi
80101e6c:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101e6f:	72 c7                	jb     80101e38 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101e71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101e74:	31 c0                	xor    %eax,%eax
}
80101e76:	5b                   	pop    %ebx
80101e77:	5e                   	pop    %esi
80101e78:	5f                   	pop    %edi
80101e79:	5d                   	pop    %ebp
80101e7a:	c3                   	ret    
80101e7b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101e7f:	90                   	nop
      if(poff)
80101e80:	8b 45 10             	mov    0x10(%ebp),%eax
80101e83:	85 c0                	test   %eax,%eax
80101e85:	74 05                	je     80101e8c <dirlookup+0x7c>
        *poff = off;
80101e87:	8b 45 10             	mov    0x10(%ebp),%eax
80101e8a:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101e8c:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101e90:	8b 03                	mov    (%ebx),%eax
80101e92:	e8 e9 f5 ff ff       	call   80101480 <iget>
}
80101e97:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101e9a:	5b                   	pop    %ebx
80101e9b:	5e                   	pop    %esi
80101e9c:	5f                   	pop    %edi
80101e9d:	5d                   	pop    %ebp
80101e9e:	c3                   	ret    
      panic("dirlookup read");
80101e9f:	83 ec 0c             	sub    $0xc,%esp
80101ea2:	68 79 79 10 80       	push   $0x80107979
80101ea7:	e8 04 e6 ff ff       	call   801004b0 <panic>
    panic("dirlookup not DIR");
80101eac:	83 ec 0c             	sub    $0xc,%esp
80101eaf:	68 67 79 10 80       	push   $0x80107967
80101eb4:	e8 f7 e5 ff ff       	call   801004b0 <panic>
80101eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101ec0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101ec0:	55                   	push   %ebp
80101ec1:	89 e5                	mov    %esp,%ebp
80101ec3:	57                   	push   %edi
80101ec4:	56                   	push   %esi
80101ec5:	53                   	push   %ebx
80101ec6:	89 c3                	mov    %eax,%ebx
80101ec8:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101ecb:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101ece:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ed1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80101ed4:	0f 84 64 01 00 00    	je     8010203e <namex+0x17e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101eda:	e8 61 1c 00 00       	call   80103b40 <myproc>
  acquire(&icache.lock);
80101edf:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(myproc()->cwd);
80101ee2:	8b 70 6c             	mov    0x6c(%eax),%esi
  acquire(&icache.lock);
80101ee5:	68 60 09 11 80       	push   $0x80110960
80101eea:	e8 61 29 00 00       	call   80104850 <acquire>
  ip->ref++;
80101eef:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101ef3:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101efa:	e8 f1 28 00 00       	call   801047f0 <release>
80101eff:	83 c4 10             	add    $0x10,%esp
80101f02:	eb 07                	jmp    80101f0b <namex+0x4b>
80101f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101f08:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101f0b:	0f b6 03             	movzbl (%ebx),%eax
80101f0e:	3c 2f                	cmp    $0x2f,%al
80101f10:	74 f6                	je     80101f08 <namex+0x48>
  if(*path == 0)
80101f12:	84 c0                	test   %al,%al
80101f14:	0f 84 06 01 00 00    	je     80102020 <namex+0x160>
  while(*path != '/' && *path != 0)
80101f1a:	0f b6 03             	movzbl (%ebx),%eax
80101f1d:	84 c0                	test   %al,%al
80101f1f:	0f 84 10 01 00 00    	je     80102035 <namex+0x175>
80101f25:	89 df                	mov    %ebx,%edi
80101f27:	3c 2f                	cmp    $0x2f,%al
80101f29:	0f 84 06 01 00 00    	je     80102035 <namex+0x175>
80101f2f:	90                   	nop
80101f30:	0f b6 47 01          	movzbl 0x1(%edi),%eax
    path++;
80101f34:	83 c7 01             	add    $0x1,%edi
  while(*path != '/' && *path != 0)
80101f37:	3c 2f                	cmp    $0x2f,%al
80101f39:	74 04                	je     80101f3f <namex+0x7f>
80101f3b:	84 c0                	test   %al,%al
80101f3d:	75 f1                	jne    80101f30 <namex+0x70>
  len = path - s;
80101f3f:	89 f8                	mov    %edi,%eax
80101f41:	29 d8                	sub    %ebx,%eax
  if(len >= DIRSIZ)
80101f43:	83 f8 0d             	cmp    $0xd,%eax
80101f46:	0f 8e ac 00 00 00    	jle    80101ff8 <namex+0x138>
    memmove(name, s, DIRSIZ);
80101f4c:	83 ec 04             	sub    $0x4,%esp
80101f4f:	6a 0e                	push   $0xe
80101f51:	53                   	push   %ebx
    path++;
80101f52:	89 fb                	mov    %edi,%ebx
    memmove(name, s, DIRSIZ);
80101f54:	ff 75 e4             	push   -0x1c(%ebp)
80101f57:	e8 54 2a 00 00       	call   801049b0 <memmove>
80101f5c:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80101f5f:	80 3f 2f             	cmpb   $0x2f,(%edi)
80101f62:	75 0c                	jne    80101f70 <namex+0xb0>
80101f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101f68:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101f6b:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101f6e:	74 f8                	je     80101f68 <namex+0xa8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101f70:	83 ec 0c             	sub    $0xc,%esp
80101f73:	56                   	push   %esi
80101f74:	e8 37 f9 ff ff       	call   801018b0 <ilock>
    if(ip->type != T_DIR){
80101f79:	83 c4 10             	add    $0x10,%esp
80101f7c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101f81:	0f 85 cd 00 00 00    	jne    80102054 <namex+0x194>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101f87:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101f8a:	85 c0                	test   %eax,%eax
80101f8c:	74 09                	je     80101f97 <namex+0xd7>
80101f8e:	80 3b 00             	cmpb   $0x0,(%ebx)
80101f91:	0f 84 22 01 00 00    	je     801020b9 <namex+0x1f9>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101f97:	83 ec 04             	sub    $0x4,%esp
80101f9a:	6a 00                	push   $0x0
80101f9c:	ff 75 e4             	push   -0x1c(%ebp)
80101f9f:	56                   	push   %esi
80101fa0:	e8 6b fe ff ff       	call   80101e10 <dirlookup>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101fa5:	8d 56 0c             	lea    0xc(%esi),%edx
    if((next = dirlookup(ip, name, 0)) == 0){
80101fa8:	83 c4 10             	add    $0x10,%esp
80101fab:	89 c7                	mov    %eax,%edi
80101fad:	85 c0                	test   %eax,%eax
80101faf:	0f 84 e1 00 00 00    	je     80102096 <namex+0x1d6>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101fb5:	83 ec 0c             	sub    $0xc,%esp
80101fb8:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101fbb:	52                   	push   %edx
80101fbc:	e8 6f 26 00 00       	call   80104630 <holdingsleep>
80101fc1:	83 c4 10             	add    $0x10,%esp
80101fc4:	85 c0                	test   %eax,%eax
80101fc6:	0f 84 30 01 00 00    	je     801020fc <namex+0x23c>
80101fcc:	8b 56 08             	mov    0x8(%esi),%edx
80101fcf:	85 d2                	test   %edx,%edx
80101fd1:	0f 8e 25 01 00 00    	jle    801020fc <namex+0x23c>
  releasesleep(&ip->lock);
80101fd7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101fda:	83 ec 0c             	sub    $0xc,%esp
80101fdd:	52                   	push   %edx
80101fde:	e8 0d 26 00 00       	call   801045f0 <releasesleep>
  iput(ip);
80101fe3:	89 34 24             	mov    %esi,(%esp)
80101fe6:	89 fe                	mov    %edi,%esi
80101fe8:	e8 f3 f9 ff ff       	call   801019e0 <iput>
80101fed:	83 c4 10             	add    $0x10,%esp
80101ff0:	e9 16 ff ff ff       	jmp    80101f0b <namex+0x4b>
80101ff5:	8d 76 00             	lea    0x0(%esi),%esi
    name[len] = 0;
80101ff8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101ffb:	8d 14 01             	lea    (%ecx,%eax,1),%edx
    memmove(name, s, len);
80101ffe:	83 ec 04             	sub    $0x4,%esp
80102001:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102004:	50                   	push   %eax
80102005:	53                   	push   %ebx
    name[len] = 0;
80102006:	89 fb                	mov    %edi,%ebx
    memmove(name, s, len);
80102008:	ff 75 e4             	push   -0x1c(%ebp)
8010200b:	e8 a0 29 00 00       	call   801049b0 <memmove>
    name[len] = 0;
80102010:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102013:	83 c4 10             	add    $0x10,%esp
80102016:	c6 02 00             	movb   $0x0,(%edx)
80102019:	e9 41 ff ff ff       	jmp    80101f5f <namex+0x9f>
8010201e:	66 90                	xchg   %ax,%ax
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102020:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102023:	85 c0                	test   %eax,%eax
80102025:	0f 85 be 00 00 00    	jne    801020e9 <namex+0x229>
    iput(ip);
    return 0;
  }
  return ip;
}
8010202b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010202e:	89 f0                	mov    %esi,%eax
80102030:	5b                   	pop    %ebx
80102031:	5e                   	pop    %esi
80102032:	5f                   	pop    %edi
80102033:	5d                   	pop    %ebp
80102034:	c3                   	ret    
  while(*path != '/' && *path != 0)
80102035:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102038:	89 df                	mov    %ebx,%edi
8010203a:	31 c0                	xor    %eax,%eax
8010203c:	eb c0                	jmp    80101ffe <namex+0x13e>
    ip = iget(ROOTDEV, ROOTINO);
8010203e:	ba 01 00 00 00       	mov    $0x1,%edx
80102043:	b8 01 00 00 00       	mov    $0x1,%eax
80102048:	e8 33 f4 ff ff       	call   80101480 <iget>
8010204d:	89 c6                	mov    %eax,%esi
8010204f:	e9 b7 fe ff ff       	jmp    80101f0b <namex+0x4b>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80102054:	83 ec 0c             	sub    $0xc,%esp
80102057:	8d 5e 0c             	lea    0xc(%esi),%ebx
8010205a:	53                   	push   %ebx
8010205b:	e8 d0 25 00 00       	call   80104630 <holdingsleep>
80102060:	83 c4 10             	add    $0x10,%esp
80102063:	85 c0                	test   %eax,%eax
80102065:	0f 84 91 00 00 00    	je     801020fc <namex+0x23c>
8010206b:	8b 46 08             	mov    0x8(%esi),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	0f 8e 86 00 00 00    	jle    801020fc <namex+0x23c>
  releasesleep(&ip->lock);
80102076:	83 ec 0c             	sub    $0xc,%esp
80102079:	53                   	push   %ebx
8010207a:	e8 71 25 00 00       	call   801045f0 <releasesleep>
  iput(ip);
8010207f:	89 34 24             	mov    %esi,(%esp)
      return 0;
80102082:	31 f6                	xor    %esi,%esi
  iput(ip);
80102084:	e8 57 f9 ff ff       	call   801019e0 <iput>
      return 0;
80102089:	83 c4 10             	add    $0x10,%esp
}
8010208c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010208f:	89 f0                	mov    %esi,%eax
80102091:	5b                   	pop    %ebx
80102092:	5e                   	pop    %esi
80102093:	5f                   	pop    %edi
80102094:	5d                   	pop    %ebp
80102095:	c3                   	ret    
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80102096:	83 ec 0c             	sub    $0xc,%esp
80102099:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010209c:	52                   	push   %edx
8010209d:	e8 8e 25 00 00       	call   80104630 <holdingsleep>
801020a2:	83 c4 10             	add    $0x10,%esp
801020a5:	85 c0                	test   %eax,%eax
801020a7:	74 53                	je     801020fc <namex+0x23c>
801020a9:	8b 4e 08             	mov    0x8(%esi),%ecx
801020ac:	85 c9                	test   %ecx,%ecx
801020ae:	7e 4c                	jle    801020fc <namex+0x23c>
  releasesleep(&ip->lock);
801020b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801020b3:	83 ec 0c             	sub    $0xc,%esp
801020b6:	52                   	push   %edx
801020b7:	eb c1                	jmp    8010207a <namex+0x1ba>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801020b9:	83 ec 0c             	sub    $0xc,%esp
801020bc:	8d 5e 0c             	lea    0xc(%esi),%ebx
801020bf:	53                   	push   %ebx
801020c0:	e8 6b 25 00 00       	call   80104630 <holdingsleep>
801020c5:	83 c4 10             	add    $0x10,%esp
801020c8:	85 c0                	test   %eax,%eax
801020ca:	74 30                	je     801020fc <namex+0x23c>
801020cc:	8b 7e 08             	mov    0x8(%esi),%edi
801020cf:	85 ff                	test   %edi,%edi
801020d1:	7e 29                	jle    801020fc <namex+0x23c>
  releasesleep(&ip->lock);
801020d3:	83 ec 0c             	sub    $0xc,%esp
801020d6:	53                   	push   %ebx
801020d7:	e8 14 25 00 00       	call   801045f0 <releasesleep>
}
801020dc:	83 c4 10             	add    $0x10,%esp
}
801020df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801020e2:	89 f0                	mov    %esi,%eax
801020e4:	5b                   	pop    %ebx
801020e5:	5e                   	pop    %esi
801020e6:	5f                   	pop    %edi
801020e7:	5d                   	pop    %ebp
801020e8:	c3                   	ret    
    iput(ip);
801020e9:	83 ec 0c             	sub    $0xc,%esp
801020ec:	56                   	push   %esi
    return 0;
801020ed:	31 f6                	xor    %esi,%esi
    iput(ip);
801020ef:	e8 ec f8 ff ff       	call   801019e0 <iput>
    return 0;
801020f4:	83 c4 10             	add    $0x10,%esp
801020f7:	e9 2f ff ff ff       	jmp    8010202b <namex+0x16b>
    panic("iunlock");
801020fc:	83 ec 0c             	sub    $0xc,%esp
801020ff:	68 5f 79 10 80       	push   $0x8010795f
80102104:	e8 a7 e3 ff ff       	call   801004b0 <panic>
80102109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102110 <dirlink>:
{
80102110:	55                   	push   %ebp
80102111:	89 e5                	mov    %esp,%ebp
80102113:	57                   	push   %edi
80102114:	56                   	push   %esi
80102115:	53                   	push   %ebx
80102116:	83 ec 20             	sub    $0x20,%esp
80102119:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
8010211c:	6a 00                	push   $0x0
8010211e:	ff 75 0c             	push   0xc(%ebp)
80102121:	53                   	push   %ebx
80102122:	e8 e9 fc ff ff       	call   80101e10 <dirlookup>
80102127:	83 c4 10             	add    $0x10,%esp
8010212a:	85 c0                	test   %eax,%eax
8010212c:	75 67                	jne    80102195 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010212e:	8b 7b 58             	mov    0x58(%ebx),%edi
80102131:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102134:	85 ff                	test   %edi,%edi
80102136:	74 29                	je     80102161 <dirlink+0x51>
80102138:	31 ff                	xor    %edi,%edi
8010213a:	8d 75 d8             	lea    -0x28(%ebp),%esi
8010213d:	eb 09                	jmp    80102148 <dirlink+0x38>
8010213f:	90                   	nop
80102140:	83 c7 10             	add    $0x10,%edi
80102143:	3b 7b 58             	cmp    0x58(%ebx),%edi
80102146:	73 19                	jae    80102161 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102148:	6a 10                	push   $0x10
8010214a:	57                   	push   %edi
8010214b:	56                   	push   %esi
8010214c:	53                   	push   %ebx
8010214d:	e8 6e fa ff ff       	call   80101bc0 <readi>
80102152:	83 c4 10             	add    $0x10,%esp
80102155:	83 f8 10             	cmp    $0x10,%eax
80102158:	75 4e                	jne    801021a8 <dirlink+0x98>
    if(de.inum == 0)
8010215a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010215f:	75 df                	jne    80102140 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80102161:	83 ec 04             	sub    $0x4,%esp
80102164:	8d 45 da             	lea    -0x26(%ebp),%eax
80102167:	6a 0e                	push   $0xe
80102169:	ff 75 0c             	push   0xc(%ebp)
8010216c:	50                   	push   %eax
8010216d:	e8 fe 28 00 00       	call   80104a70 <strncpy>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102172:	6a 10                	push   $0x10
  de.inum = inum;
80102174:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102177:	57                   	push   %edi
80102178:	56                   	push   %esi
80102179:	53                   	push   %ebx
  de.inum = inum;
8010217a:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010217e:	e8 3d fb ff ff       	call   80101cc0 <writei>
80102183:	83 c4 20             	add    $0x20,%esp
80102186:	83 f8 10             	cmp    $0x10,%eax
80102189:	75 2a                	jne    801021b5 <dirlink+0xa5>
  return 0;
8010218b:	31 c0                	xor    %eax,%eax
}
8010218d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102190:	5b                   	pop    %ebx
80102191:	5e                   	pop    %esi
80102192:	5f                   	pop    %edi
80102193:	5d                   	pop    %ebp
80102194:	c3                   	ret    
    iput(ip);
80102195:	83 ec 0c             	sub    $0xc,%esp
80102198:	50                   	push   %eax
80102199:	e8 42 f8 ff ff       	call   801019e0 <iput>
    return -1;
8010219e:	83 c4 10             	add    $0x10,%esp
801021a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021a6:	eb e5                	jmp    8010218d <dirlink+0x7d>
      panic("dirlink read");
801021a8:	83 ec 0c             	sub    $0xc,%esp
801021ab:	68 88 79 10 80       	push   $0x80107988
801021b0:	e8 fb e2 ff ff       	call   801004b0 <panic>
    panic("dirlink");
801021b5:	83 ec 0c             	sub    $0xc,%esp
801021b8:	68 a6 7f 10 80       	push   $0x80107fa6
801021bd:	e8 ee e2 ff ff       	call   801004b0 <panic>
801021c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801021d0 <namei>:

struct inode*
namei(char *path)
{
801021d0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
801021d1:	31 d2                	xor    %edx,%edx
{
801021d3:	89 e5                	mov    %esp,%ebp
801021d5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	8d 4d ea             	lea    -0x16(%ebp),%ecx
801021de:	e8 dd fc ff ff       	call   80101ec0 <namex>
}
801021e3:	c9                   	leave  
801021e4:	c3                   	ret    
801021e5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801021f0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801021f0:	55                   	push   %ebp
  return namex(path, 1, name);
801021f1:	ba 01 00 00 00       	mov    $0x1,%edx
{
801021f6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
801021f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801021fb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801021fe:	5d                   	pop    %ebp
  return namex(path, 1, name);
801021ff:	e9 bc fc ff ff       	jmp    80101ec0 <namex>
80102204:	66 90                	xchg   %ax,%ax
80102206:	66 90                	xchg   %ax,%ax
80102208:	66 90                	xchg   %ax,%ax
8010220a:	66 90                	xchg   %ax,%ax
8010220c:	66 90                	xchg   %ax,%ax
8010220e:	66 90                	xchg   %ax,%ax

80102210 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102210:	55                   	push   %ebp
80102211:	89 e5                	mov    %esp,%ebp
80102213:	57                   	push   %edi
80102214:	56                   	push   %esi
80102215:	53                   	push   %ebx
80102216:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
80102219:	85 c0                	test   %eax,%eax
8010221b:	0f 84 b4 00 00 00    	je     801022d5 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80102221:	8b 70 08             	mov    0x8(%eax),%esi
80102224:	89 c3                	mov    %eax,%ebx
80102226:	81 fe ab 0d 00 00    	cmp    $0xdab,%esi
8010222c:	0f 87 96 00 00 00    	ja     801022c8 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102232:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102237:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010223e:	66 90                	xchg   %ax,%ax
80102240:	89 ca                	mov    %ecx,%edx
80102242:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102243:	83 e0 c0             	and    $0xffffffc0,%eax
80102246:	3c 40                	cmp    $0x40,%al
80102248:	75 f6                	jne    80102240 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010224a:	31 ff                	xor    %edi,%edi
8010224c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102251:	89 f8                	mov    %edi,%eax
80102253:	ee                   	out    %al,(%dx)
80102254:	b8 01 00 00 00       	mov    $0x1,%eax
80102259:	ba f2 01 00 00       	mov    $0x1f2,%edx
8010225e:	ee                   	out    %al,(%dx)
8010225f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80102264:	89 f0                	mov    %esi,%eax
80102266:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80102267:	89 f0                	mov    %esi,%eax
80102269:	ba f4 01 00 00       	mov    $0x1f4,%edx
8010226e:	c1 f8 08             	sar    $0x8,%eax
80102271:	ee                   	out    %al,(%dx)
80102272:	ba f5 01 00 00       	mov    $0x1f5,%edx
80102277:	89 f8                	mov    %edi,%eax
80102279:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010227a:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
8010227e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102283:	c1 e0 04             	shl    $0x4,%eax
80102286:	83 e0 10             	and    $0x10,%eax
80102289:	83 c8 e0             	or     $0xffffffe0,%eax
8010228c:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
8010228d:	f6 03 04             	testb  $0x4,(%ebx)
80102290:	75 16                	jne    801022a8 <idestart+0x98>
80102292:	b8 20 00 00 00       	mov    $0x20,%eax
80102297:	89 ca                	mov    %ecx,%edx
80102299:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010229a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010229d:	5b                   	pop    %ebx
8010229e:	5e                   	pop    %esi
8010229f:	5f                   	pop    %edi
801022a0:	5d                   	pop    %ebp
801022a1:	c3                   	ret    
801022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801022a8:	b8 30 00 00 00       	mov    $0x30,%eax
801022ad:	89 ca                	mov    %ecx,%edx
801022af:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
801022b0:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
801022b5:	8d 73 5c             	lea    0x5c(%ebx),%esi
801022b8:	ba f0 01 00 00       	mov    $0x1f0,%edx
801022bd:	fc                   	cld    
801022be:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
801022c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022c3:	5b                   	pop    %ebx
801022c4:	5e                   	pop    %esi
801022c5:	5f                   	pop    %edi
801022c6:	5d                   	pop    %ebp
801022c7:	c3                   	ret    
    panic("incorrect blockno");
801022c8:	83 ec 0c             	sub    $0xc,%esp
801022cb:	68 f4 79 10 80       	push   $0x801079f4
801022d0:	e8 db e1 ff ff       	call   801004b0 <panic>
    panic("idestart");
801022d5:	83 ec 0c             	sub    $0xc,%esp
801022d8:	68 eb 79 10 80       	push   $0x801079eb
801022dd:	e8 ce e1 ff ff       	call   801004b0 <panic>
801022e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801022f0 <ideinit>:
{
801022f0:	55                   	push   %ebp
801022f1:	89 e5                	mov    %esp,%ebp
801022f3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
801022f6:	68 06 7a 10 80       	push   $0x80107a06
801022fb:	68 20 26 11 80       	push   $0x80112620
80102300:	e8 7b 23 00 00       	call   80104680 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102305:	58                   	pop    %eax
80102306:	a1 a4 27 11 80       	mov    0x801127a4,%eax
8010230b:	5a                   	pop    %edx
8010230c:	83 e8 01             	sub    $0x1,%eax
8010230f:	50                   	push   %eax
80102310:	6a 0e                	push   $0xe
80102312:	e8 99 02 00 00       	call   801025b0 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102317:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010231a:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010231f:	90                   	nop
80102320:	ec                   	in     (%dx),%al
80102321:	83 e0 c0             	and    $0xffffffc0,%eax
80102324:	3c 40                	cmp    $0x40,%al
80102326:	75 f8                	jne    80102320 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102328:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010232d:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102332:	ee                   	out    %al,(%dx)
80102333:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102338:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010233d:	eb 06                	jmp    80102345 <ideinit+0x55>
8010233f:	90                   	nop
  for(i=0; i<1000; i++){
80102340:	83 e9 01             	sub    $0x1,%ecx
80102343:	74 0f                	je     80102354 <ideinit+0x64>
80102345:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102346:	84 c0                	test   %al,%al
80102348:	74 f6                	je     80102340 <ideinit+0x50>
      havedisk1 = 1;
8010234a:	c7 05 00 26 11 80 01 	movl   $0x1,0x80112600
80102351:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102354:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102359:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010235e:	ee                   	out    %al,(%dx)
}
8010235f:	c9                   	leave  
80102360:	c3                   	ret    
80102361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102368:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010236f:	90                   	nop

80102370 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102370:	55                   	push   %ebp
80102371:	89 e5                	mov    %esp,%ebp
80102373:	57                   	push   %edi
80102374:	56                   	push   %esi
80102375:	53                   	push   %ebx
80102376:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102379:	68 20 26 11 80       	push   $0x80112620
8010237e:	e8 cd 24 00 00       	call   80104850 <acquire>

  if((b = idequeue) == 0){
80102383:	8b 1d 04 26 11 80    	mov    0x80112604,%ebx
80102389:	83 c4 10             	add    $0x10,%esp
8010238c:	85 db                	test   %ebx,%ebx
8010238e:	74 63                	je     801023f3 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80102390:	8b 43 58             	mov    0x58(%ebx),%eax
80102393:	a3 04 26 11 80       	mov    %eax,0x80112604

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102398:	8b 33                	mov    (%ebx),%esi
8010239a:	f7 c6 04 00 00 00    	test   $0x4,%esi
801023a0:	75 2f                	jne    801023d1 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801023a2:	ba f7 01 00 00       	mov    $0x1f7,%edx
801023a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801023ae:	66 90                	xchg   %ax,%ax
801023b0:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801023b1:	89 c1                	mov    %eax,%ecx
801023b3:	83 e1 c0             	and    $0xffffffc0,%ecx
801023b6:	80 f9 40             	cmp    $0x40,%cl
801023b9:	75 f5                	jne    801023b0 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801023bb:	a8 21                	test   $0x21,%al
801023bd:	75 12                	jne    801023d1 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
801023bf:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
801023c2:	b9 80 00 00 00       	mov    $0x80,%ecx
801023c7:	ba f0 01 00 00       	mov    $0x1f0,%edx
801023cc:	fc                   	cld    
801023cd:	f3 6d                	rep insl (%dx),%es:(%edi)

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801023cf:	8b 33                	mov    (%ebx),%esi
  b->flags &= ~B_DIRTY;
801023d1:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
801023d4:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801023d7:	83 ce 02             	or     $0x2,%esi
801023da:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
801023dc:	53                   	push   %ebx
801023dd:	e8 6e 1f 00 00       	call   80104350 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801023e2:	a1 04 26 11 80       	mov    0x80112604,%eax
801023e7:	83 c4 10             	add    $0x10,%esp
801023ea:	85 c0                	test   %eax,%eax
801023ec:	74 05                	je     801023f3 <ideintr+0x83>
    idestart(idequeue);
801023ee:	e8 1d fe ff ff       	call   80102210 <idestart>
    release(&idelock);
801023f3:	83 ec 0c             	sub    $0xc,%esp
801023f6:	68 20 26 11 80       	push   $0x80112620
801023fb:	e8 f0 23 00 00       	call   801047f0 <release>

  release(&idelock);
}
80102400:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102403:	5b                   	pop    %ebx
80102404:	5e                   	pop    %esi
80102405:	5f                   	pop    %edi
80102406:	5d                   	pop    %ebp
80102407:	c3                   	ret    
80102408:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010240f:	90                   	nop

80102410 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102410:	55                   	push   %ebp
80102411:	89 e5                	mov    %esp,%ebp
80102413:	53                   	push   %ebx
80102414:	83 ec 10             	sub    $0x10,%esp
80102417:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010241a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010241d:	50                   	push   %eax
8010241e:	e8 0d 22 00 00       	call   80104630 <holdingsleep>
80102423:	83 c4 10             	add    $0x10,%esp
80102426:	85 c0                	test   %eax,%eax
80102428:	0f 84 c3 00 00 00    	je     801024f1 <iderw+0xe1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010242e:	8b 03                	mov    (%ebx),%eax
80102430:	83 e0 06             	and    $0x6,%eax
80102433:	83 f8 02             	cmp    $0x2,%eax
80102436:	0f 84 a8 00 00 00    	je     801024e4 <iderw+0xd4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010243c:	8b 53 04             	mov    0x4(%ebx),%edx
8010243f:	85 d2                	test   %edx,%edx
80102441:	74 0d                	je     80102450 <iderw+0x40>
80102443:	a1 00 26 11 80       	mov    0x80112600,%eax
80102448:	85 c0                	test   %eax,%eax
8010244a:	0f 84 87 00 00 00    	je     801024d7 <iderw+0xc7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102450:	83 ec 0c             	sub    $0xc,%esp
80102453:	68 20 26 11 80       	push   $0x80112620
80102458:	e8 f3 23 00 00       	call   80104850 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010245d:	a1 04 26 11 80       	mov    0x80112604,%eax
  b->qnext = 0;
80102462:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102469:	83 c4 10             	add    $0x10,%esp
8010246c:	85 c0                	test   %eax,%eax
8010246e:	74 60                	je     801024d0 <iderw+0xc0>
80102470:	89 c2                	mov    %eax,%edx
80102472:	8b 40 58             	mov    0x58(%eax),%eax
80102475:	85 c0                	test   %eax,%eax
80102477:	75 f7                	jne    80102470 <iderw+0x60>
80102479:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
8010247c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010247e:	39 1d 04 26 11 80    	cmp    %ebx,0x80112604
80102484:	74 3a                	je     801024c0 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102486:	8b 03                	mov    (%ebx),%eax
80102488:	83 e0 06             	and    $0x6,%eax
8010248b:	83 f8 02             	cmp    $0x2,%eax
8010248e:	74 1b                	je     801024ab <iderw+0x9b>
    sleep(b, &idelock);
80102490:	83 ec 08             	sub    $0x8,%esp
80102493:	68 20 26 11 80       	push   $0x80112620
80102498:	53                   	push   %ebx
80102499:	e8 f2 1d 00 00       	call   80104290 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010249e:	8b 03                	mov    (%ebx),%eax
801024a0:	83 c4 10             	add    $0x10,%esp
801024a3:	83 e0 06             	and    $0x6,%eax
801024a6:	83 f8 02             	cmp    $0x2,%eax
801024a9:	75 e5                	jne    80102490 <iderw+0x80>
  }


  release(&idelock);
801024ab:	c7 45 08 20 26 11 80 	movl   $0x80112620,0x8(%ebp)
}
801024b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801024b5:	c9                   	leave  
  release(&idelock);
801024b6:	e9 35 23 00 00       	jmp    801047f0 <release>
801024bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801024bf:	90                   	nop
    idestart(b);
801024c0:	89 d8                	mov    %ebx,%eax
801024c2:	e8 49 fd ff ff       	call   80102210 <idestart>
801024c7:	eb bd                	jmp    80102486 <iderw+0x76>
801024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801024d0:	ba 04 26 11 80       	mov    $0x80112604,%edx
801024d5:	eb a5                	jmp    8010247c <iderw+0x6c>
    panic("iderw: ide disk 1 not present");
801024d7:	83 ec 0c             	sub    $0xc,%esp
801024da:	68 35 7a 10 80       	push   $0x80107a35
801024df:	e8 cc df ff ff       	call   801004b0 <panic>
    panic("iderw: nothing to do");
801024e4:	83 ec 0c             	sub    $0xc,%esp
801024e7:	68 20 7a 10 80       	push   $0x80107a20
801024ec:	e8 bf df ff ff       	call   801004b0 <panic>
    panic("iderw: buf not locked");
801024f1:	83 ec 0c             	sub    $0xc,%esp
801024f4:	68 0a 7a 10 80       	push   $0x80107a0a
801024f9:	e8 b2 df ff ff       	call   801004b0 <panic>
801024fe:	66 90                	xchg   %ax,%ax

80102500 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
80102500:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102501:	c7 05 54 26 11 80 00 	movl   $0xfec00000,0x80112654
80102508:	00 c0 fe 
{
8010250b:	89 e5                	mov    %esp,%ebp
8010250d:	56                   	push   %esi
8010250e:	53                   	push   %ebx
  ioapic->reg = reg;
8010250f:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80102516:	00 00 00 
  return ioapic->data;
80102519:	8b 15 54 26 11 80    	mov    0x80112654,%edx
8010251f:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
80102522:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
80102528:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010252e:	0f b6 15 a0 27 11 80 	movzbl 0x801127a0,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102535:	c1 ee 10             	shr    $0x10,%esi
80102538:	89 f0                	mov    %esi,%eax
8010253a:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
8010253d:	8b 41 10             	mov    0x10(%ecx),%eax
  id = ioapicread(REG_ID) >> 24;
80102540:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102543:	39 c2                	cmp    %eax,%edx
80102545:	74 16                	je     8010255d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102547:	83 ec 0c             	sub    $0xc,%esp
8010254a:	68 54 7a 10 80       	push   $0x80107a54
8010254f:	e8 7c e2 ff ff       	call   801007d0 <cprintf>
  ioapic->reg = reg;
80102554:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
8010255a:	83 c4 10             	add    $0x10,%esp
8010255d:	83 c6 21             	add    $0x21,%esi
{
80102560:	ba 10 00 00 00       	mov    $0x10,%edx
80102565:	b8 20 00 00 00       	mov    $0x20,%eax
8010256a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  ioapic->reg = reg;
80102570:	89 11                	mov    %edx,(%ecx)

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102572:	89 c3                	mov    %eax,%ebx
  ioapic->data = data;
80102574:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
  for(i = 0; i <= maxintr; i++){
8010257a:	83 c0 01             	add    $0x1,%eax
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010257d:	81 cb 00 00 01 00    	or     $0x10000,%ebx
  ioapic->data = data;
80102583:	89 59 10             	mov    %ebx,0x10(%ecx)
  ioapic->reg = reg;
80102586:	8d 5a 01             	lea    0x1(%edx),%ebx
  for(i = 0; i <= maxintr; i++){
80102589:	83 c2 02             	add    $0x2,%edx
  ioapic->reg = reg;
8010258c:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
8010258e:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
80102594:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
8010259b:	39 f0                	cmp    %esi,%eax
8010259d:	75 d1                	jne    80102570 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010259f:	8d 65 f8             	lea    -0x8(%ebp),%esp
801025a2:	5b                   	pop    %ebx
801025a3:	5e                   	pop    %esi
801025a4:	5d                   	pop    %ebp
801025a5:	c3                   	ret    
801025a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801025ad:	8d 76 00             	lea    0x0(%esi),%esi

801025b0 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801025b0:	55                   	push   %ebp
  ioapic->reg = reg;
801025b1:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
{
801025b7:	89 e5                	mov    %esp,%ebp
801025b9:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801025bc:	8d 50 20             	lea    0x20(%eax),%edx
801025bf:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801025c3:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801025c5:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025cb:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
801025ce:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
801025d4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801025d6:	a1 54 26 11 80       	mov    0x80112654,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801025db:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
801025de:	89 50 10             	mov    %edx,0x10(%eax)
}
801025e1:	5d                   	pop    %ebp
801025e2:	c3                   	ret    
801025e3:	66 90                	xchg   %ax,%ax
801025e5:	66 90                	xchg   %ax,%ax
801025e7:	66 90                	xchg   %ax,%ax
801025e9:	66 90                	xchg   %ax,%ax
801025eb:	66 90                	xchg   %ax,%ax
801025ed:	66 90                	xchg   %ax,%ax
801025ef:	90                   	nop

801025f0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801025f0:	55                   	push   %ebp
801025f1:	89 e5                	mov    %esp,%ebp
801025f3:	53                   	push   %ebx
801025f4:	83 ec 04             	sub    $0x4,%esp
801025f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;
  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP){
801025fa:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102600:	0f 85 82 00 00 00    	jne    80102688 <kfree+0x98>
80102606:	81 fb 60 6f 11 80    	cmp    $0x80116f60,%ebx
8010260c:	72 7a                	jb     80102688 <kfree+0x98>
8010260e:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102614:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
80102619:	77 6d                	ja     80102688 <kfree+0x98>
    panic("kfree");
  }  
  
  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010261b:	83 ec 04             	sub    $0x4,%esp
8010261e:	68 00 10 00 00       	push   $0x1000
80102623:	6a 01                	push   $0x1
80102625:	53                   	push   %ebx
80102626:	e8 e5 22 00 00       	call   80104910 <memset>

  if(kmem.use_lock)
8010262b:	8b 15 94 26 11 80    	mov    0x80112694,%edx
80102631:	83 c4 10             	add    $0x10,%esp
80102634:	85 d2                	test   %edx,%edx
80102636:	75 28                	jne    80102660 <kfree+0x70>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102638:	a1 9c 26 11 80       	mov    0x8011269c,%eax
8010263d:	89 03                	mov    %eax,(%ebx)
  kmem.num_free_pages+=1;
  kmem.freelist = r;
  if(kmem.use_lock)
8010263f:	a1 94 26 11 80       	mov    0x80112694,%eax
  kmem.num_free_pages+=1;
80102644:	83 05 98 26 11 80 01 	addl   $0x1,0x80112698
  kmem.freelist = r;
8010264b:	89 1d 9c 26 11 80    	mov    %ebx,0x8011269c
  if(kmem.use_lock)
80102651:	85 c0                	test   %eax,%eax
80102653:	75 23                	jne    80102678 <kfree+0x88>
    release(&kmem.lock);
}
80102655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102658:	c9                   	leave  
80102659:	c3                   	ret    
8010265a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    acquire(&kmem.lock);
80102660:	83 ec 0c             	sub    $0xc,%esp
80102663:	68 60 26 11 80       	push   $0x80112660
80102668:	e8 e3 21 00 00       	call   80104850 <acquire>
8010266d:	83 c4 10             	add    $0x10,%esp
80102670:	eb c6                	jmp    80102638 <kfree+0x48>
80102672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
80102678:	c7 45 08 60 26 11 80 	movl   $0x80112660,0x8(%ebp)
}
8010267f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102682:	c9                   	leave  
    release(&kmem.lock);
80102683:	e9 68 21 00 00       	jmp    801047f0 <release>
    panic("kfree");
80102688:	83 ec 0c             	sub    $0xc,%esp
8010268b:	68 86 7a 10 80       	push   $0x80107a86
80102690:	e8 1b de ff ff       	call   801004b0 <panic>
80102695:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010269c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801026a0 <freerange>:
{
801026a0:	55                   	push   %ebp
801026a1:	89 e5                	mov    %esp,%ebp
801026a3:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
801026a4:	8b 45 08             	mov    0x8(%ebp),%eax
{
801026a7:	8b 75 0c             	mov    0xc(%ebp),%esi
801026aa:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801026ab:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801026b1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026b7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801026bd:	39 de                	cmp    %ebx,%esi
801026bf:	72 2a                	jb     801026eb <freerange+0x4b>
801026c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801026c8:	83 ec 0c             	sub    $0xc,%esp
801026cb:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026d1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801026d7:	50                   	push   %eax
801026d8:	e8 13 ff ff ff       	call   801025f0 <kfree>
    kmem.num_free_pages+=1;
801026dd:	83 05 98 26 11 80 01 	addl   $0x1,0x80112698
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e4:	83 c4 10             	add    $0x10,%esp
801026e7:	39 f3                	cmp    %esi,%ebx
801026e9:	76 dd                	jbe    801026c8 <freerange+0x28>
}
801026eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
801026ee:	5b                   	pop    %ebx
801026ef:	5e                   	pop    %esi
801026f0:	5d                   	pop    %ebp
801026f1:	c3                   	ret    
801026f2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801026f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102700 <kinit2>:
{
80102700:	55                   	push   %ebp
80102701:	89 e5                	mov    %esp,%ebp
80102703:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
80102704:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102707:	8b 75 0c             	mov    0xc(%ebp),%esi
8010270a:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010270b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102711:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102717:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010271d:	39 de                	cmp    %ebx,%esi
8010271f:	72 2a                	jb     8010274b <kinit2+0x4b>
80102721:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102728:	83 ec 0c             	sub    $0xc,%esp
8010272b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102731:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102737:	50                   	push   %eax
80102738:	e8 b3 fe ff ff       	call   801025f0 <kfree>
    kmem.num_free_pages+=1;
8010273d:	83 05 98 26 11 80 01 	addl   $0x1,0x80112698
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102744:	83 c4 10             	add    $0x10,%esp
80102747:	39 de                	cmp    %ebx,%esi
80102749:	73 dd                	jae    80102728 <kinit2+0x28>
  kmem.use_lock = 1;
8010274b:	c7 05 94 26 11 80 01 	movl   $0x1,0x80112694
80102752:	00 00 00 
}
80102755:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102758:	5b                   	pop    %ebx
80102759:	5e                   	pop    %esi
8010275a:	5d                   	pop    %ebp
8010275b:	c3                   	ret    
8010275c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102760 <kinit1>:
{
80102760:	55                   	push   %ebp
80102761:	89 e5                	mov    %esp,%ebp
80102763:	56                   	push   %esi
80102764:	53                   	push   %ebx
80102765:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102768:	83 ec 08             	sub    $0x8,%esp
8010276b:	68 8c 7a 10 80       	push   $0x80107a8c
80102770:	68 60 26 11 80       	push   $0x80112660
80102775:	e8 06 1f 00 00       	call   80104680 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010277a:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010277d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102780:	c7 05 94 26 11 80 00 	movl   $0x0,0x80112694
80102787:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
8010278a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102790:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102796:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010279c:	39 de                	cmp    %ebx,%esi
8010279e:	72 23                	jb     801027c3 <kinit1+0x63>
    kfree(p);
801027a0:	83 ec 0c             	sub    $0xc,%esp
801027a3:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027a9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801027af:	50                   	push   %eax
801027b0:	e8 3b fe ff ff       	call   801025f0 <kfree>
    kmem.num_free_pages+=1;
801027b5:	83 05 98 26 11 80 01 	addl   $0x1,0x80112698
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027bc:	83 c4 10             	add    $0x10,%esp
801027bf:	39 de                	cmp    %ebx,%esi
801027c1:	73 dd                	jae    801027a0 <kinit1+0x40>
}
801027c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801027c6:	5b                   	pop    %ebx
801027c7:	5e                   	pop    %esi
801027c8:	5d                   	pop    %ebp
801027c9:	c3                   	ret    
801027ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801027d0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027d0:	55                   	push   %ebp
801027d1:	89 e5                	mov    %esp,%ebp
801027d3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027d6:	8b 0d 94 26 11 80    	mov    0x80112694,%ecx
801027dc:	85 c9                	test   %ecx,%ecx
801027de:	75 38                	jne    80102818 <kalloc+0x48>
    acquire(&kmem.lock);
  r = kmem.freelist;
801027e0:	a1 9c 26 11 80       	mov    0x8011269c,%eax
  if(r)
801027e5:	85 c0                	test   %eax,%eax
801027e7:	74 20                	je     80102809 <kalloc+0x39>
  {
    kmem.freelist = r->next;
801027e9:	8b 10                	mov    (%eax),%edx
    kmem.num_free_pages-=1;
801027eb:	83 2d 98 26 11 80 01 	subl   $0x1,0x80112698
    kmem.freelist = r->next;
801027f2:	89 15 9c 26 11 80    	mov    %edx,0x8011269c
  if(r){
    return (char*)r;
  }
  allocate_page();
  return kalloc();
}
801027f8:	c9                   	leave  
801027f9:	c3                   	ret    
801027fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if(kmem.use_lock)
80102800:	a1 94 26 11 80       	mov    0x80112694,%eax
80102805:	85 c0                	test   %eax,%eax
80102807:	75 59                	jne    80102862 <kalloc+0x92>
  allocate_page();
80102809:	e8 72 4e 00 00       	call   80107680 <allocate_page>
  if(kmem.use_lock)
8010280e:	8b 0d 94 26 11 80    	mov    0x80112694,%ecx
80102814:	85 c9                	test   %ecx,%ecx
80102816:	74 c8                	je     801027e0 <kalloc+0x10>
    acquire(&kmem.lock);
80102818:	83 ec 0c             	sub    $0xc,%esp
8010281b:	68 60 26 11 80       	push   $0x80112660
80102820:	e8 2b 20 00 00       	call   80104850 <acquire>
  r = kmem.freelist;
80102825:	a1 9c 26 11 80       	mov    0x8011269c,%eax
  if(r)
8010282a:	83 c4 10             	add    $0x10,%esp
8010282d:	85 c0                	test   %eax,%eax
8010282f:	74 cf                	je     80102800 <kalloc+0x30>
    kmem.freelist = r->next;
80102831:	8b 10                	mov    (%eax),%edx
    kmem.num_free_pages-=1;
80102833:	83 2d 98 26 11 80 01 	subl   $0x1,0x80112698
    kmem.freelist = r->next;
8010283a:	89 15 9c 26 11 80    	mov    %edx,0x8011269c
  if(kmem.use_lock)
80102840:	8b 15 94 26 11 80    	mov    0x80112694,%edx
80102846:	85 d2                	test   %edx,%edx
80102848:	74 ae                	je     801027f8 <kalloc+0x28>
    release(&kmem.lock);
8010284a:	83 ec 0c             	sub    $0xc,%esp
8010284d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102850:	68 60 26 11 80       	push   $0x80112660
80102855:	e8 96 1f 00 00       	call   801047f0 <release>
  if(r){
8010285a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
8010285d:	83 c4 10             	add    $0x10,%esp
}
80102860:	c9                   	leave  
80102861:	c3                   	ret    
    release(&kmem.lock);
80102862:	83 ec 0c             	sub    $0xc,%esp
80102865:	68 60 26 11 80       	push   $0x80112660
8010286a:	e8 81 1f 00 00       	call   801047f0 <release>
8010286f:	83 c4 10             	add    $0x10,%esp
80102872:	eb 95                	jmp    80102809 <kalloc+0x39>
80102874:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010287b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010287f:	90                   	nop

80102880 <num_of_FreePages>:
uint 
num_of_FreePages(void)
{
80102880:	55                   	push   %ebp
80102881:	89 e5                	mov    %esp,%ebp
80102883:	53                   	push   %ebx
80102884:	83 ec 10             	sub    $0x10,%esp
  acquire(&kmem.lock);
80102887:	68 60 26 11 80       	push   $0x80112660
8010288c:	e8 bf 1f 00 00       	call   80104850 <acquire>

  uint num_free_pages = kmem.num_free_pages;
80102891:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
  
  release(&kmem.lock);
80102897:	c7 04 24 60 26 11 80 	movl   $0x80112660,(%esp)
8010289e:	e8 4d 1f 00 00       	call   801047f0 <release>
  
  return num_free_pages;
}
801028a3:	89 d8                	mov    %ebx,%eax
801028a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028a8:	c9                   	leave  
801028a9:	c3                   	ret    
801028aa:	66 90                	xchg   %ax,%ax
801028ac:	66 90                	xchg   %ax,%ax
801028ae:	66 90                	xchg   %ax,%ax

801028b0 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028b0:	ba 64 00 00 00       	mov    $0x64,%edx
801028b5:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801028b6:	a8 01                	test   $0x1,%al
801028b8:	0f 84 c2 00 00 00    	je     80102980 <kbdgetc+0xd0>
{
801028be:	55                   	push   %ebp
801028bf:	ba 60 00 00 00       	mov    $0x60,%edx
801028c4:	89 e5                	mov    %esp,%ebp
801028c6:	53                   	push   %ebx
801028c7:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
801028c8:	8b 1d a0 26 11 80    	mov    0x801126a0,%ebx
  data = inb(KBDATAP);
801028ce:	0f b6 c8             	movzbl %al,%ecx
  if(data == 0xE0){
801028d1:	3c e0                	cmp    $0xe0,%al
801028d3:	74 5b                	je     80102930 <kbdgetc+0x80>
    return 0;
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801028d5:	89 da                	mov    %ebx,%edx
801028d7:	83 e2 40             	and    $0x40,%edx
  } else if(data & 0x80){
801028da:	84 c0                	test   %al,%al
801028dc:	78 62                	js     80102940 <kbdgetc+0x90>
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801028de:	85 d2                	test   %edx,%edx
801028e0:	74 09                	je     801028eb <kbdgetc+0x3b>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028e2:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
801028e5:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
801028e8:	0f b6 c8             	movzbl %al,%ecx
  }

  shift |= shiftcode[data];
801028eb:	0f b6 91 c0 7b 10 80 	movzbl -0x7fef8440(%ecx),%edx
  shift ^= togglecode[data];
801028f2:	0f b6 81 c0 7a 10 80 	movzbl -0x7fef8540(%ecx),%eax
  shift |= shiftcode[data];
801028f9:	09 da                	or     %ebx,%edx
  shift ^= togglecode[data];
801028fb:	31 c2                	xor    %eax,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
801028fd:	89 d0                	mov    %edx,%eax
  shift ^= togglecode[data];
801028ff:	89 15 a0 26 11 80    	mov    %edx,0x801126a0
  c = charcode[shift & (CTL | SHIFT)][data];
80102905:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
80102908:	83 e2 08             	and    $0x8,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010290b:	8b 04 85 a0 7a 10 80 	mov    -0x7fef8560(,%eax,4),%eax
80102912:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
80102916:	74 0b                	je     80102923 <kbdgetc+0x73>
    if('a' <= c && c <= 'z')
80102918:	8d 50 9f             	lea    -0x61(%eax),%edx
8010291b:	83 fa 19             	cmp    $0x19,%edx
8010291e:	77 48                	ja     80102968 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102920:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102923:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102926:	c9                   	leave  
80102927:	c3                   	ret    
80102928:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010292f:	90                   	nop
    shift |= E0ESC;
80102930:	83 cb 40             	or     $0x40,%ebx
    return 0;
80102933:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
80102935:	89 1d a0 26 11 80    	mov    %ebx,0x801126a0
}
8010293b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010293e:	c9                   	leave  
8010293f:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102940:	83 e0 7f             	and    $0x7f,%eax
80102943:	85 d2                	test   %edx,%edx
80102945:	0f 44 c8             	cmove  %eax,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
80102948:	0f b6 81 c0 7b 10 80 	movzbl -0x7fef8440(%ecx),%eax
8010294f:	83 c8 40             	or     $0x40,%eax
80102952:	0f b6 c0             	movzbl %al,%eax
80102955:	f7 d0                	not    %eax
80102957:	21 d8                	and    %ebx,%eax
}
80102959:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    shift &= ~(shiftcode[data] | E0ESC);
8010295c:	a3 a0 26 11 80       	mov    %eax,0x801126a0
    return 0;
80102961:	31 c0                	xor    %eax,%eax
}
80102963:	c9                   	leave  
80102964:	c3                   	ret    
80102965:	8d 76 00             	lea    0x0(%esi),%esi
    else if('A' <= c && c <= 'Z')
80102968:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
8010296b:	8d 50 20             	lea    0x20(%eax),%edx
}
8010296e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102971:	c9                   	leave  
      c += 'a' - 'A';
80102972:	83 f9 1a             	cmp    $0x1a,%ecx
80102975:	0f 42 c2             	cmovb  %edx,%eax
}
80102978:	c3                   	ret    
80102979:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80102980:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102985:	c3                   	ret    
80102986:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010298d:	8d 76 00             	lea    0x0(%esi),%esi

80102990 <kbdintr>:

void
kbdintr(void)
{
80102990:	55                   	push   %ebp
80102991:	89 e5                	mov    %esp,%ebp
80102993:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102996:	68 b0 28 10 80       	push   $0x801028b0
8010299b:	e8 10 e0 ff ff       	call   801009b0 <consoleintr>
}
801029a0:	83 c4 10             	add    $0x10,%esp
801029a3:	c9                   	leave  
801029a4:	c3                   	ret    
801029a5:	66 90                	xchg   %ax,%ax
801029a7:	66 90                	xchg   %ax,%ax
801029a9:	66 90                	xchg   %ax,%ax
801029ab:	66 90                	xchg   %ax,%ax
801029ad:	66 90                	xchg   %ax,%ax
801029af:	90                   	nop

801029b0 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
801029b0:	a1 a4 26 11 80       	mov    0x801126a4,%eax
801029b5:	85 c0                	test   %eax,%eax
801029b7:	0f 84 cb 00 00 00    	je     80102a88 <lapicinit+0xd8>
  lapic[index] = value;
801029bd:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
801029c4:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029c7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029ca:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
801029d1:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029d4:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029d7:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
801029de:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
801029e1:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029e4:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
801029eb:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
801029ee:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029f1:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
801029f8:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801029fb:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029fe:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102a05:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102a08:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a0b:	8b 50 30             	mov    0x30(%eax),%edx
80102a0e:	c1 ea 10             	shr    $0x10,%edx
80102a11:	81 e2 fc 00 00 00    	and    $0xfc,%edx
80102a17:	75 77                	jne    80102a90 <lapicinit+0xe0>
  lapic[index] = value;
80102a19:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102a20:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a23:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a26:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102a2d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a30:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a33:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102a3a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a3d:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a40:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102a47:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a4a:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a4d:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102a54:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a57:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a5a:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
80102a61:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
80102a64:	8b 50 20             	mov    0x20(%eax),%edx
80102a67:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102a6e:	66 90                	xchg   %ax,%ax
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102a70:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
80102a76:	80 e6 10             	and    $0x10,%dh
80102a79:	75 f5                	jne    80102a70 <lapicinit+0xc0>
  lapic[index] = value;
80102a7b:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102a82:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a85:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102a88:	c3                   	ret    
80102a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
80102a90:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102a97:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102a9a:	8b 50 20             	mov    0x20(%eax),%edx
}
80102a9d:	e9 77 ff ff ff       	jmp    80102a19 <lapicinit+0x69>
80102aa2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102ab0 <lapicid>:

int
lapicid(void)
{
  if (!lapic)
80102ab0:	a1 a4 26 11 80       	mov    0x801126a4,%eax
80102ab5:	85 c0                	test   %eax,%eax
80102ab7:	74 07                	je     80102ac0 <lapicid+0x10>
    return 0;
  return lapic[ID] >> 24;
80102ab9:	8b 40 20             	mov    0x20(%eax),%eax
80102abc:	c1 e8 18             	shr    $0x18,%eax
80102abf:	c3                   	ret    
    return 0;
80102ac0:	31 c0                	xor    %eax,%eax
}
80102ac2:	c3                   	ret    
80102ac3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102aca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102ad0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102ad0:	a1 a4 26 11 80       	mov    0x801126a4,%eax
80102ad5:	85 c0                	test   %eax,%eax
80102ad7:	74 0d                	je     80102ae6 <lapiceoi+0x16>
  lapic[index] = value;
80102ad9:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102ae0:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102ae3:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102ae6:	c3                   	ret    
80102ae7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102aee:	66 90                	xchg   %ax,%ax

80102af0 <microdelay>:
// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
}
80102af0:	c3                   	ret    
80102af1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102af8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102aff:	90                   	nop

80102b00 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b00:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b01:	b8 0f 00 00 00       	mov    $0xf,%eax
80102b06:	ba 70 00 00 00       	mov    $0x70,%edx
80102b0b:	89 e5                	mov    %esp,%ebp
80102b0d:	53                   	push   %ebx
80102b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102b14:	ee                   	out    %al,(%dx)
80102b15:	b8 0a 00 00 00       	mov    $0xa,%eax
80102b1a:	ba 71 00 00 00       	mov    $0x71,%edx
80102b1f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102b20:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b22:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102b25:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
80102b2b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
80102b2d:	c1 e9 0c             	shr    $0xc,%ecx
  lapicw(ICRHI, apicid<<24);
80102b30:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
80102b32:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
80102b35:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102b38:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
80102b3e:	a1 a4 26 11 80       	mov    0x801126a4,%eax
80102b43:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b49:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b4c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102b53:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b56:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b59:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102b60:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b63:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b66:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b6c:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b6f:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b75:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b78:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b7e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b81:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b87:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
80102b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b8d:	c9                   	leave  
80102b8e:	c3                   	ret    
80102b8f:	90                   	nop

80102b90 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102b90:	55                   	push   %ebp
80102b91:	b8 0b 00 00 00       	mov    $0xb,%eax
80102b96:	ba 70 00 00 00       	mov    $0x70,%edx
80102b9b:	89 e5                	mov    %esp,%ebp
80102b9d:	57                   	push   %edi
80102b9e:	56                   	push   %esi
80102b9f:	53                   	push   %ebx
80102ba0:	83 ec 4c             	sub    $0x4c,%esp
80102ba3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ba4:	ba 71 00 00 00       	mov    $0x71,%edx
80102ba9:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
80102baa:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bad:	bb 70 00 00 00       	mov    $0x70,%ebx
80102bb2:	88 45 b3             	mov    %al,-0x4d(%ebp)
80102bb5:	8d 76 00             	lea    0x0(%esi),%esi
80102bb8:	31 c0                	xor    %eax,%eax
80102bba:	89 da                	mov    %ebx,%edx
80102bbc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bbd:	b9 71 00 00 00       	mov    $0x71,%ecx
80102bc2:	89 ca                	mov    %ecx,%edx
80102bc4:	ec                   	in     (%dx),%al
80102bc5:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bc8:	89 da                	mov    %ebx,%edx
80102bca:	b8 02 00 00 00       	mov    $0x2,%eax
80102bcf:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bd0:	89 ca                	mov    %ecx,%edx
80102bd2:	ec                   	in     (%dx),%al
80102bd3:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bd6:	89 da                	mov    %ebx,%edx
80102bd8:	b8 04 00 00 00       	mov    $0x4,%eax
80102bdd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bde:	89 ca                	mov    %ecx,%edx
80102be0:	ec                   	in     (%dx),%al
80102be1:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102be4:	89 da                	mov    %ebx,%edx
80102be6:	b8 07 00 00 00       	mov    $0x7,%eax
80102beb:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bec:	89 ca                	mov    %ecx,%edx
80102bee:	ec                   	in     (%dx),%al
80102bef:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bf2:	89 da                	mov    %ebx,%edx
80102bf4:	b8 08 00 00 00       	mov    $0x8,%eax
80102bf9:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bfa:	89 ca                	mov    %ecx,%edx
80102bfc:	ec                   	in     (%dx),%al
80102bfd:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bff:	89 da                	mov    %ebx,%edx
80102c01:	b8 09 00 00 00       	mov    $0x9,%eax
80102c06:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c07:	89 ca                	mov    %ecx,%edx
80102c09:	ec                   	in     (%dx),%al
80102c0a:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c0c:	89 da                	mov    %ebx,%edx
80102c0e:	b8 0a 00 00 00       	mov    $0xa,%eax
80102c13:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c14:	89 ca                	mov    %ecx,%edx
80102c16:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102c17:	84 c0                	test   %al,%al
80102c19:	78 9d                	js     80102bb8 <cmostime+0x28>
  return inb(CMOS_RETURN);
80102c1b:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102c1f:	89 fa                	mov    %edi,%edx
80102c21:	0f b6 fa             	movzbl %dl,%edi
80102c24:	89 f2                	mov    %esi,%edx
80102c26:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102c29:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102c2d:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c30:	89 da                	mov    %ebx,%edx
80102c32:	89 7d c8             	mov    %edi,-0x38(%ebp)
80102c35:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102c38:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102c3c:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102c3f:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102c42:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102c46:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102c49:	31 c0                	xor    %eax,%eax
80102c4b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c4c:	89 ca                	mov    %ecx,%edx
80102c4e:	ec                   	in     (%dx),%al
80102c4f:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c52:	89 da                	mov    %ebx,%edx
80102c54:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102c57:	b8 02 00 00 00       	mov    $0x2,%eax
80102c5c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c5d:	89 ca                	mov    %ecx,%edx
80102c5f:	ec                   	in     (%dx),%al
80102c60:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c63:	89 da                	mov    %ebx,%edx
80102c65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102c68:	b8 04 00 00 00       	mov    $0x4,%eax
80102c6d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c6e:	89 ca                	mov    %ecx,%edx
80102c70:	ec                   	in     (%dx),%al
80102c71:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c74:	89 da                	mov    %ebx,%edx
80102c76:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102c79:	b8 07 00 00 00       	mov    $0x7,%eax
80102c7e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c7f:	89 ca                	mov    %ecx,%edx
80102c81:	ec                   	in     (%dx),%al
80102c82:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c85:	89 da                	mov    %ebx,%edx
80102c87:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102c8a:	b8 08 00 00 00       	mov    $0x8,%eax
80102c8f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c90:	89 ca                	mov    %ecx,%edx
80102c92:	ec                   	in     (%dx),%al
80102c93:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c96:	89 da                	mov    %ebx,%edx
80102c98:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102c9b:	b8 09 00 00 00       	mov    $0x9,%eax
80102ca0:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ca1:	89 ca                	mov    %ecx,%edx
80102ca3:	ec                   	in     (%dx),%al
80102ca4:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102ca7:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102caa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102cad:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102cb0:	6a 18                	push   $0x18
80102cb2:	50                   	push   %eax
80102cb3:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102cb6:	50                   	push   %eax
80102cb7:	e8 a4 1c 00 00       	call   80104960 <memcmp>
80102cbc:	83 c4 10             	add    $0x10,%esp
80102cbf:	85 c0                	test   %eax,%eax
80102cc1:	0f 85 f1 fe ff ff    	jne    80102bb8 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102cc7:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
80102ccb:	75 78                	jne    80102d45 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102ccd:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102cd0:	89 c2                	mov    %eax,%edx
80102cd2:	83 e0 0f             	and    $0xf,%eax
80102cd5:	c1 ea 04             	shr    $0x4,%edx
80102cd8:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102cdb:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102cde:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102ce1:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102ce4:	89 c2                	mov    %eax,%edx
80102ce6:	83 e0 0f             	and    $0xf,%eax
80102ce9:	c1 ea 04             	shr    $0x4,%edx
80102cec:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102cef:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102cf2:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102cf5:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102cf8:	89 c2                	mov    %eax,%edx
80102cfa:	83 e0 0f             	and    $0xf,%eax
80102cfd:	c1 ea 04             	shr    $0x4,%edx
80102d00:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d03:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d06:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102d09:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102d0c:	89 c2                	mov    %eax,%edx
80102d0e:	83 e0 0f             	and    $0xf,%eax
80102d11:	c1 ea 04             	shr    $0x4,%edx
80102d14:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d17:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d1a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102d1d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102d20:	89 c2                	mov    %eax,%edx
80102d22:	83 e0 0f             	and    $0xf,%eax
80102d25:	c1 ea 04             	shr    $0x4,%edx
80102d28:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d2b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d2e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102d31:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102d34:	89 c2                	mov    %eax,%edx
80102d36:	83 e0 0f             	and    $0xf,%eax
80102d39:	c1 ea 04             	shr    $0x4,%edx
80102d3c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d3f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d42:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102d45:	8b 75 08             	mov    0x8(%ebp),%esi
80102d48:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102d4b:	89 06                	mov    %eax,(%esi)
80102d4d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102d50:	89 46 04             	mov    %eax,0x4(%esi)
80102d53:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102d56:	89 46 08             	mov    %eax,0x8(%esi)
80102d59:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102d5c:	89 46 0c             	mov    %eax,0xc(%esi)
80102d5f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102d62:	89 46 10             	mov    %eax,0x10(%esi)
80102d65:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102d68:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102d6b:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102d72:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d75:	5b                   	pop    %ebx
80102d76:	5e                   	pop    %esi
80102d77:	5f                   	pop    %edi
80102d78:	5d                   	pop    %ebp
80102d79:	c3                   	ret    
80102d7a:	66 90                	xchg   %ax,%ax
80102d7c:	66 90                	xchg   %ax,%ax
80102d7e:	66 90                	xchg   %ax,%ax

80102d80 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102d80:	8b 0d 08 27 11 80    	mov    0x80112708,%ecx
80102d86:	85 c9                	test   %ecx,%ecx
80102d88:	0f 8e 8a 00 00 00    	jle    80102e18 <install_trans+0x98>
{
80102d8e:	55                   	push   %ebp
80102d8f:	89 e5                	mov    %esp,%ebp
80102d91:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102d92:	31 ff                	xor    %edi,%edi
{
80102d94:	56                   	push   %esi
80102d95:	53                   	push   %ebx
80102d96:	83 ec 0c             	sub    $0xc,%esp
80102d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102da0:	a1 f4 26 11 80       	mov    0x801126f4,%eax
80102da5:	83 ec 08             	sub    $0x8,%esp
80102da8:	01 f8                	add    %edi,%eax
80102daa:	83 c0 01             	add    $0x1,%eax
80102dad:	50                   	push   %eax
80102dae:	ff 35 04 27 11 80    	push   0x80112704
80102db4:	e8 d7 d3 ff ff       	call   80100190 <bread>
80102db9:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102dbb:	58                   	pop    %eax
80102dbc:	5a                   	pop    %edx
80102dbd:	ff 34 bd 0c 27 11 80 	push   -0x7feed8f4(,%edi,4)
80102dc4:	ff 35 04 27 11 80    	push   0x80112704
  for (tail = 0; tail < log.lh.n; tail++) {
80102dca:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102dcd:	e8 be d3 ff ff       	call   80100190 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102dd2:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102dd5:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102dd7:	8d 46 5c             	lea    0x5c(%esi),%eax
80102dda:	68 00 02 00 00       	push   $0x200
80102ddf:	50                   	push   %eax
80102de0:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102de3:	50                   	push   %eax
80102de4:	e8 c7 1b 00 00       	call   801049b0 <memmove>
    bwrite(dbuf);  // write dst to disk
80102de9:	89 1c 24             	mov    %ebx,(%esp)
80102dec:	e8 df d3 ff ff       	call   801001d0 <bwrite>
    brelse(lbuf);
80102df1:	89 34 24             	mov    %esi,(%esp)
80102df4:	e8 17 d4 ff ff       	call   80100210 <brelse>
    brelse(dbuf);
80102df9:	89 1c 24             	mov    %ebx,(%esp)
80102dfc:	e8 0f d4 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102e01:	83 c4 10             	add    $0x10,%esp
80102e04:	39 3d 08 27 11 80    	cmp    %edi,0x80112708
80102e0a:	7f 94                	jg     80102da0 <install_trans+0x20>
  }
}
80102e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e0f:	5b                   	pop    %ebx
80102e10:	5e                   	pop    %esi
80102e11:	5f                   	pop    %edi
80102e12:	5d                   	pop    %ebp
80102e13:	c3                   	ret    
80102e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102e18:	c3                   	ret    
80102e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102e20 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102e20:	55                   	push   %ebp
80102e21:	89 e5                	mov    %esp,%ebp
80102e23:	53                   	push   %ebx
80102e24:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102e27:	ff 35 f4 26 11 80    	push   0x801126f4
80102e2d:	ff 35 04 27 11 80    	push   0x80112704
80102e33:	e8 58 d3 ff ff       	call   80100190 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102e38:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102e3b:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102e3d:	a1 08 27 11 80       	mov    0x80112708,%eax
80102e42:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102e45:	85 c0                	test   %eax,%eax
80102e47:	7e 19                	jle    80102e62 <write_head+0x42>
80102e49:	31 d2                	xor    %edx,%edx
80102e4b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102e4f:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102e50:	8b 0c 95 0c 27 11 80 	mov    -0x7feed8f4(,%edx,4),%ecx
80102e57:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102e5b:	83 c2 01             	add    $0x1,%edx
80102e5e:	39 d0                	cmp    %edx,%eax
80102e60:	75 ee                	jne    80102e50 <write_head+0x30>
  }
  bwrite(buf);
80102e62:	83 ec 0c             	sub    $0xc,%esp
80102e65:	53                   	push   %ebx
80102e66:	e8 65 d3 ff ff       	call   801001d0 <bwrite>
  brelse(buf);
80102e6b:	89 1c 24             	mov    %ebx,(%esp)
80102e6e:	e8 9d d3 ff ff       	call   80100210 <brelse>
}
80102e73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e76:	83 c4 10             	add    $0x10,%esp
80102e79:	c9                   	leave  
80102e7a:	c3                   	ret    
80102e7b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102e7f:	90                   	nop

80102e80 <initlog>:
{
80102e80:	55                   	push   %ebp
80102e81:	89 e5                	mov    %esp,%ebp
80102e83:	53                   	push   %ebx
80102e84:	83 ec 3c             	sub    $0x3c,%esp
80102e87:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102e8a:	68 c0 7c 10 80       	push   $0x80107cc0
80102e8f:	68 c0 26 11 80       	push   $0x801126c0
80102e94:	e8 e7 17 00 00       	call   80104680 <initlock>
  readsb(dev, &sb);
80102e99:	58                   	pop    %eax
80102e9a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80102e9d:	5a                   	pop    %edx
80102e9e:	50                   	push   %eax
80102e9f:	53                   	push   %ebx
80102ea0:	e8 ab e7 ff ff       	call   80101650 <readsb>
  log.start = sb.logstart;
80102ea5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102ea8:	59                   	pop    %ecx
  log.dev = dev;
80102ea9:	89 1d 04 27 11 80    	mov    %ebx,0x80112704
  log.size = sb.nlog;
80102eaf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  log.start = sb.logstart;
80102eb2:	a3 f4 26 11 80       	mov    %eax,0x801126f4
  log.size = sb.nlog;
80102eb7:	89 15 f8 26 11 80    	mov    %edx,0x801126f8
  struct buf *buf = bread(log.dev, log.start);
80102ebd:	5a                   	pop    %edx
80102ebe:	50                   	push   %eax
80102ebf:	53                   	push   %ebx
80102ec0:	e8 cb d2 ff ff       	call   80100190 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102ec5:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102ec8:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102ecb:	89 1d 08 27 11 80    	mov    %ebx,0x80112708
  for (i = 0; i < log.lh.n; i++) {
80102ed1:	85 db                	test   %ebx,%ebx
80102ed3:	7e 1d                	jle    80102ef2 <initlog+0x72>
80102ed5:	31 d2                	xor    %edx,%edx
80102ed7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102ede:	66 90                	xchg   %ax,%ax
    log.lh.block[i] = lh->block[i];
80102ee0:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102ee4:	89 0c 95 0c 27 11 80 	mov    %ecx,-0x7feed8f4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102eeb:	83 c2 01             	add    $0x1,%edx
80102eee:	39 d3                	cmp    %edx,%ebx
80102ef0:	75 ee                	jne    80102ee0 <initlog+0x60>
  brelse(buf);
80102ef2:	83 ec 0c             	sub    $0xc,%esp
80102ef5:	50                   	push   %eax
80102ef6:	e8 15 d3 ff ff       	call   80100210 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102efb:	e8 80 fe ff ff       	call   80102d80 <install_trans>
  log.lh.n = 0;
80102f00:	c7 05 08 27 11 80 00 	movl   $0x0,0x80112708
80102f07:	00 00 00 
  write_head(); // clear the log
80102f0a:	e8 11 ff ff ff       	call   80102e20 <write_head>
}
80102f0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102f12:	83 c4 10             	add    $0x10,%esp
80102f15:	c9                   	leave  
80102f16:	c3                   	ret    
80102f17:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102f1e:	66 90                	xchg   %ax,%ax

80102f20 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102f20:	55                   	push   %ebp
80102f21:	89 e5                	mov    %esp,%ebp
80102f23:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102f26:	68 c0 26 11 80       	push   $0x801126c0
80102f2b:	e8 20 19 00 00       	call   80104850 <acquire>
80102f30:	83 c4 10             	add    $0x10,%esp
80102f33:	eb 18                	jmp    80102f4d <begin_op+0x2d>
80102f35:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102f38:	83 ec 08             	sub    $0x8,%esp
80102f3b:	68 c0 26 11 80       	push   $0x801126c0
80102f40:	68 c0 26 11 80       	push   $0x801126c0
80102f45:	e8 46 13 00 00       	call   80104290 <sleep>
80102f4a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102f4d:	a1 00 27 11 80       	mov    0x80112700,%eax
80102f52:	85 c0                	test   %eax,%eax
80102f54:	75 e2                	jne    80102f38 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102f56:	a1 fc 26 11 80       	mov    0x801126fc,%eax
80102f5b:	8b 15 08 27 11 80    	mov    0x80112708,%edx
80102f61:	83 c0 01             	add    $0x1,%eax
80102f64:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102f67:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102f6a:	83 fa 1e             	cmp    $0x1e,%edx
80102f6d:	7f c9                	jg     80102f38 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102f6f:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102f72:	a3 fc 26 11 80       	mov    %eax,0x801126fc
      release(&log.lock);
80102f77:	68 c0 26 11 80       	push   $0x801126c0
80102f7c:	e8 6f 18 00 00       	call   801047f0 <release>
      break;
    }
  }
}
80102f81:	83 c4 10             	add    $0x10,%esp
80102f84:	c9                   	leave  
80102f85:	c3                   	ret    
80102f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102f8d:	8d 76 00             	lea    0x0(%esi),%esi

80102f90 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102f90:	55                   	push   %ebp
80102f91:	89 e5                	mov    %esp,%ebp
80102f93:	57                   	push   %edi
80102f94:	56                   	push   %esi
80102f95:	53                   	push   %ebx
80102f96:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102f99:	68 c0 26 11 80       	push   $0x801126c0
80102f9e:	e8 ad 18 00 00       	call   80104850 <acquire>
  log.outstanding -= 1;
80102fa3:	a1 fc 26 11 80       	mov    0x801126fc,%eax
  if(log.committing)
80102fa8:	8b 35 00 27 11 80    	mov    0x80112700,%esi
80102fae:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102fb1:	8d 58 ff             	lea    -0x1(%eax),%ebx
80102fb4:	89 1d fc 26 11 80    	mov    %ebx,0x801126fc
  if(log.committing)
80102fba:	85 f6                	test   %esi,%esi
80102fbc:	0f 85 22 01 00 00    	jne    801030e4 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
80102fc2:	85 db                	test   %ebx,%ebx
80102fc4:	0f 85 f6 00 00 00    	jne    801030c0 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
80102fca:	c7 05 00 27 11 80 01 	movl   $0x1,0x80112700
80102fd1:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102fd4:	83 ec 0c             	sub    $0xc,%esp
80102fd7:	68 c0 26 11 80       	push   $0x801126c0
80102fdc:	e8 0f 18 00 00       	call   801047f0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102fe1:	8b 0d 08 27 11 80    	mov    0x80112708,%ecx
80102fe7:	83 c4 10             	add    $0x10,%esp
80102fea:	85 c9                	test   %ecx,%ecx
80102fec:	7f 42                	jg     80103030 <end_op+0xa0>
    acquire(&log.lock);
80102fee:	83 ec 0c             	sub    $0xc,%esp
80102ff1:	68 c0 26 11 80       	push   $0x801126c0
80102ff6:	e8 55 18 00 00       	call   80104850 <acquire>
    wakeup(&log);
80102ffb:	c7 04 24 c0 26 11 80 	movl   $0x801126c0,(%esp)
    log.committing = 0;
80103002:	c7 05 00 27 11 80 00 	movl   $0x0,0x80112700
80103009:	00 00 00 
    wakeup(&log);
8010300c:	e8 3f 13 00 00       	call   80104350 <wakeup>
    release(&log.lock);
80103011:	c7 04 24 c0 26 11 80 	movl   $0x801126c0,(%esp)
80103018:	e8 d3 17 00 00       	call   801047f0 <release>
8010301d:	83 c4 10             	add    $0x10,%esp
}
80103020:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103023:	5b                   	pop    %ebx
80103024:	5e                   	pop    %esi
80103025:	5f                   	pop    %edi
80103026:	5d                   	pop    %ebp
80103027:	c3                   	ret    
80103028:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010302f:	90                   	nop
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103030:	a1 f4 26 11 80       	mov    0x801126f4,%eax
80103035:	83 ec 08             	sub    $0x8,%esp
80103038:	01 d8                	add    %ebx,%eax
8010303a:	83 c0 01             	add    $0x1,%eax
8010303d:	50                   	push   %eax
8010303e:	ff 35 04 27 11 80    	push   0x80112704
80103044:	e8 47 d1 ff ff       	call   80100190 <bread>
80103049:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010304b:	58                   	pop    %eax
8010304c:	5a                   	pop    %edx
8010304d:	ff 34 9d 0c 27 11 80 	push   -0x7feed8f4(,%ebx,4)
80103054:	ff 35 04 27 11 80    	push   0x80112704
  for (tail = 0; tail < log.lh.n; tail++) {
8010305a:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010305d:	e8 2e d1 ff ff       	call   80100190 <bread>
    memmove(to->data, from->data, BSIZE);
80103062:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103065:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80103067:	8d 40 5c             	lea    0x5c(%eax),%eax
8010306a:	68 00 02 00 00       	push   $0x200
8010306f:	50                   	push   %eax
80103070:	8d 46 5c             	lea    0x5c(%esi),%eax
80103073:	50                   	push   %eax
80103074:	e8 37 19 00 00       	call   801049b0 <memmove>
    bwrite(to);  // write the log
80103079:	89 34 24             	mov    %esi,(%esp)
8010307c:	e8 4f d1 ff ff       	call   801001d0 <bwrite>
    brelse(from);
80103081:	89 3c 24             	mov    %edi,(%esp)
80103084:	e8 87 d1 ff ff       	call   80100210 <brelse>
    brelse(to);
80103089:	89 34 24             	mov    %esi,(%esp)
8010308c:	e8 7f d1 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80103091:	83 c4 10             	add    $0x10,%esp
80103094:	3b 1d 08 27 11 80    	cmp    0x80112708,%ebx
8010309a:	7c 94                	jl     80103030 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
8010309c:	e8 7f fd ff ff       	call   80102e20 <write_head>
    install_trans(); // Now install writes to home locations
801030a1:	e8 da fc ff ff       	call   80102d80 <install_trans>
    log.lh.n = 0;
801030a6:	c7 05 08 27 11 80 00 	movl   $0x0,0x80112708
801030ad:	00 00 00 
    write_head();    // Erase the transaction from the log
801030b0:	e8 6b fd ff ff       	call   80102e20 <write_head>
801030b5:	e9 34 ff ff ff       	jmp    80102fee <end_op+0x5e>
801030ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
801030c0:	83 ec 0c             	sub    $0xc,%esp
801030c3:	68 c0 26 11 80       	push   $0x801126c0
801030c8:	e8 83 12 00 00       	call   80104350 <wakeup>
  release(&log.lock);
801030cd:	c7 04 24 c0 26 11 80 	movl   $0x801126c0,(%esp)
801030d4:	e8 17 17 00 00       	call   801047f0 <release>
801030d9:	83 c4 10             	add    $0x10,%esp
}
801030dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030df:	5b                   	pop    %ebx
801030e0:	5e                   	pop    %esi
801030e1:	5f                   	pop    %edi
801030e2:	5d                   	pop    %ebp
801030e3:	c3                   	ret    
    panic("log.committing");
801030e4:	83 ec 0c             	sub    $0xc,%esp
801030e7:	68 c4 7c 10 80       	push   $0x80107cc4
801030ec:	e8 bf d3 ff ff       	call   801004b0 <panic>
801030f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801030f8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801030ff:	90                   	nop

80103100 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103100:	55                   	push   %ebp
80103101:	89 e5                	mov    %esp,%ebp
80103103:	53                   	push   %ebx
80103104:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103107:	8b 15 08 27 11 80    	mov    0x80112708,%edx
{
8010310d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103110:	83 fa 1d             	cmp    $0x1d,%edx
80103113:	0f 8f 85 00 00 00    	jg     8010319e <log_write+0x9e>
80103119:	a1 f8 26 11 80       	mov    0x801126f8,%eax
8010311e:	83 e8 01             	sub    $0x1,%eax
80103121:	39 c2                	cmp    %eax,%edx
80103123:	7d 79                	jge    8010319e <log_write+0x9e>
    panic("too big a transaction");
  if (log.outstanding < 1)
80103125:	a1 fc 26 11 80       	mov    0x801126fc,%eax
8010312a:	85 c0                	test   %eax,%eax
8010312c:	7e 7d                	jle    801031ab <log_write+0xab>
    panic("log_write outside of trans");

  acquire(&log.lock);
8010312e:	83 ec 0c             	sub    $0xc,%esp
80103131:	68 c0 26 11 80       	push   $0x801126c0
80103136:	e8 15 17 00 00       	call   80104850 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010313b:	8b 15 08 27 11 80    	mov    0x80112708,%edx
80103141:	83 c4 10             	add    $0x10,%esp
80103144:	85 d2                	test   %edx,%edx
80103146:	7e 4a                	jle    80103192 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103148:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
8010314b:	31 c0                	xor    %eax,%eax
8010314d:	eb 08                	jmp    80103157 <log_write+0x57>
8010314f:	90                   	nop
80103150:	83 c0 01             	add    $0x1,%eax
80103153:	39 c2                	cmp    %eax,%edx
80103155:	74 29                	je     80103180 <log_write+0x80>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103157:	39 0c 85 0c 27 11 80 	cmp    %ecx,-0x7feed8f4(,%eax,4)
8010315e:	75 f0                	jne    80103150 <log_write+0x50>
      break;
  }
  log.lh.block[i] = b->blockno;
80103160:	89 0c 85 0c 27 11 80 	mov    %ecx,-0x7feed8f4(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80103167:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
8010316a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
8010316d:	c7 45 08 c0 26 11 80 	movl   $0x801126c0,0x8(%ebp)
}
80103174:	c9                   	leave  
  release(&log.lock);
80103175:	e9 76 16 00 00       	jmp    801047f0 <release>
8010317a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
80103180:	89 0c 95 0c 27 11 80 	mov    %ecx,-0x7feed8f4(,%edx,4)
    log.lh.n++;
80103187:	83 c2 01             	add    $0x1,%edx
8010318a:	89 15 08 27 11 80    	mov    %edx,0x80112708
80103190:	eb d5                	jmp    80103167 <log_write+0x67>
  log.lh.block[i] = b->blockno;
80103192:	8b 43 08             	mov    0x8(%ebx),%eax
80103195:	a3 0c 27 11 80       	mov    %eax,0x8011270c
  if (i == log.lh.n)
8010319a:	75 cb                	jne    80103167 <log_write+0x67>
8010319c:	eb e9                	jmp    80103187 <log_write+0x87>
    panic("too big a transaction");
8010319e:	83 ec 0c             	sub    $0xc,%esp
801031a1:	68 d3 7c 10 80       	push   $0x80107cd3
801031a6:	e8 05 d3 ff ff       	call   801004b0 <panic>
    panic("log_write outside of trans");
801031ab:	83 ec 0c             	sub    $0xc,%esp
801031ae:	68 e9 7c 10 80       	push   $0x80107ce9
801031b3:	e8 f8 d2 ff ff       	call   801004b0 <panic>
801031b8:	66 90                	xchg   %ax,%ax
801031ba:	66 90                	xchg   %ax,%ax
801031bc:	66 90                	xchg   %ax,%ax
801031be:	66 90                	xchg   %ax,%ax

801031c0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801031c0:	55                   	push   %ebp
801031c1:	89 e5                	mov    %esp,%ebp
801031c3:	53                   	push   %ebx
801031c4:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801031c7:	e8 54 09 00 00       	call   80103b20 <cpuid>
801031cc:	89 c3                	mov    %eax,%ebx
801031ce:	e8 4d 09 00 00       	call   80103b20 <cpuid>
801031d3:	83 ec 04             	sub    $0x4,%esp
801031d6:	53                   	push   %ebx
801031d7:	50                   	push   %eax
801031d8:	68 04 7d 10 80       	push   $0x80107d04
801031dd:	e8 ee d5 ff ff       	call   801007d0 <cprintf>
  idtinit();       // load idt register
801031e2:	e8 c9 29 00 00       	call   80105bb0 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801031e7:	e8 d4 08 00 00       	call   80103ac0 <mycpu>
801031ec:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801031ee:	b8 01 00 00 00       	mov    $0x1,%eax
801031f3:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
801031fa:	e8 71 0c 00 00       	call   80103e70 <scheduler>
801031ff:	90                   	nop

80103200 <mpenter>:
{
80103200:	55                   	push   %ebp
80103201:	89 e5                	mov    %esp,%ebp
80103203:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103206:	e8 75 3b 00 00       	call   80106d80 <switchkvm>
  seginit();
8010320b:	e8 50 3a 00 00       	call   80106c60 <seginit>
  lapicinit();
80103210:	e8 9b f7 ff ff       	call   801029b0 <lapicinit>
  mpmain();
80103215:	e8 a6 ff ff ff       	call   801031c0 <mpmain>
8010321a:	66 90                	xchg   %ax,%ax
8010321c:	66 90                	xchg   %ax,%ax
8010321e:	66 90                	xchg   %ax,%ax

80103220 <main>:
{
80103220:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103224:	83 e4 f0             	and    $0xfffffff0,%esp
80103227:	ff 71 fc             	push   -0x4(%ecx)
8010322a:	55                   	push   %ebp
8010322b:	89 e5                	mov    %esp,%ebp
8010322d:	53                   	push   %ebx
8010322e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010322f:	83 ec 08             	sub    $0x8,%esp
80103232:	68 00 00 40 80       	push   $0x80400000
80103237:	68 60 6f 11 80       	push   $0x80116f60
8010323c:	e8 1f f5 ff ff       	call   80102760 <kinit1>
  kvmalloc();      // kernel page table
80103241:	e8 3a 40 00 00       	call   80107280 <kvmalloc>
  mpinit();        // detect other processors
80103246:	e8 85 01 00 00       	call   801033d0 <mpinit>
  lapicinit();     // interrupt controller
8010324b:	e8 60 f7 ff ff       	call   801029b0 <lapicinit>
  seginit();       // segment descriptors
80103250:	e8 0b 3a 00 00       	call   80106c60 <seginit>
  picinit();       // disable pic
80103255:	e8 76 03 00 00       	call   801035d0 <picinit>
  ioapicinit();    // another interrupt controller
8010325a:	e8 a1 f2 ff ff       	call   80102500 <ioapicinit>
  consoleinit();   // console hardware
8010325f:	e8 2c d9 ff ff       	call   80100b90 <consoleinit>
  uartinit();      // serial port
80103264:	e8 57 2c 00 00       	call   80105ec0 <uartinit>
  pinit();         // process table
80103269:	e8 32 08 00 00       	call   80103aa0 <pinit>
  tvinit();        // trap vectors
8010326e:	e8 bd 28 00 00       	call   80105b30 <tvinit>
  binit();         // buffer cache
80103273:	e8 88 ce ff ff       	call   80100100 <binit>
  fileinit();      // file table
80103278:	e8 c3 dc ff ff       	call   80100f40 <fileinit>
  ideinit();       // disk 
8010327d:	e8 6e f0 ff ff       	call   801022f0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103282:	83 c4 0c             	add    $0xc,%esp
80103285:	68 8a 00 00 00       	push   $0x8a
8010328a:	68 8c b4 10 80       	push   $0x8010b48c
8010328f:	68 00 70 00 80       	push   $0x80007000
80103294:	e8 17 17 00 00       	call   801049b0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103299:	83 c4 10             	add    $0x10,%esp
8010329c:	69 05 a4 27 11 80 b0 	imul   $0xb0,0x801127a4,%eax
801032a3:	00 00 00 
801032a6:	05 c0 27 11 80       	add    $0x801127c0,%eax
801032ab:	3d c0 27 11 80       	cmp    $0x801127c0,%eax
801032b0:	76 7e                	jbe    80103330 <main+0x110>
801032b2:	bb c0 27 11 80       	mov    $0x801127c0,%ebx
801032b7:	eb 20                	jmp    801032d9 <main+0xb9>
801032b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801032c0:	69 05 a4 27 11 80 b0 	imul   $0xb0,0x801127a4,%eax
801032c7:	00 00 00 
801032ca:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801032d0:	05 c0 27 11 80       	add    $0x801127c0,%eax
801032d5:	39 c3                	cmp    %eax,%ebx
801032d7:	73 57                	jae    80103330 <main+0x110>
    if(c == mycpu())  // We've started already.
801032d9:	e8 e2 07 00 00       	call   80103ac0 <mycpu>
801032de:	39 c3                	cmp    %eax,%ebx
801032e0:	74 de                	je     801032c0 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801032e2:	e8 e9 f4 ff ff       	call   801027d0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
801032e7:	83 ec 08             	sub    $0x8,%esp
    *(void(**)(void))(code-8) = mpenter;
801032ea:	c7 05 f8 6f 00 80 00 	movl   $0x80103200,0x80006ff8
801032f1:	32 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801032f4:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
801032fb:	a0 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
801032fe:	05 00 10 00 00       	add    $0x1000,%eax
80103303:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
80103308:	0f b6 03             	movzbl (%ebx),%eax
8010330b:	68 00 70 00 00       	push   $0x7000
80103310:	50                   	push   %eax
80103311:	e8 ea f7 ff ff       	call   80102b00 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103316:	83 c4 10             	add    $0x10,%esp
80103319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103320:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103326:	85 c0                	test   %eax,%eax
80103328:	74 f6                	je     80103320 <main+0x100>
8010332a:	eb 94                	jmp    801032c0 <main+0xa0>
8010332c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103330:	83 ec 08             	sub    $0x8,%esp
80103333:	68 00 00 40 80       	push   $0x80400000
80103338:	68 00 00 40 80       	push   $0x80400000
8010333d:	e8 be f3 ff ff       	call   80102700 <kinit2>
  userinit();      // first user process
80103342:	e8 29 08 00 00       	call   80103b70 <userinit>
  mpmain();        // finish this processor's setup
80103347:	e8 74 fe ff ff       	call   801031c0 <mpmain>
8010334c:	66 90                	xchg   %ax,%ax
8010334e:	66 90                	xchg   %ax,%ax

80103350 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103350:	55                   	push   %ebp
80103351:	89 e5                	mov    %esp,%ebp
80103353:	57                   	push   %edi
80103354:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80103355:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
8010335b:	53                   	push   %ebx
  e = addr+len;
8010335c:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
8010335f:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
80103362:	39 de                	cmp    %ebx,%esi
80103364:	72 10                	jb     80103376 <mpsearch1+0x26>
80103366:	eb 50                	jmp    801033b8 <mpsearch1+0x68>
80103368:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010336f:	90                   	nop
80103370:	89 fe                	mov    %edi,%esi
80103372:	39 fb                	cmp    %edi,%ebx
80103374:	76 42                	jbe    801033b8 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103376:	83 ec 04             	sub    $0x4,%esp
80103379:	8d 7e 10             	lea    0x10(%esi),%edi
8010337c:	6a 04                	push   $0x4
8010337e:	68 18 7d 10 80       	push   $0x80107d18
80103383:	56                   	push   %esi
80103384:	e8 d7 15 00 00       	call   80104960 <memcmp>
80103389:	83 c4 10             	add    $0x10,%esp
8010338c:	85 c0                	test   %eax,%eax
8010338e:	75 e0                	jne    80103370 <mpsearch1+0x20>
80103390:	89 f2                	mov    %esi,%edx
80103392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
80103398:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
8010339b:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
8010339e:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801033a0:	39 fa                	cmp    %edi,%edx
801033a2:	75 f4                	jne    80103398 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801033a4:	84 c0                	test   %al,%al
801033a6:	75 c8                	jne    80103370 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801033a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801033ab:	89 f0                	mov    %esi,%eax
801033ad:	5b                   	pop    %ebx
801033ae:	5e                   	pop    %esi
801033af:	5f                   	pop    %edi
801033b0:	5d                   	pop    %ebp
801033b1:	c3                   	ret    
801033b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801033b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801033bb:	31 f6                	xor    %esi,%esi
}
801033bd:	5b                   	pop    %ebx
801033be:	89 f0                	mov    %esi,%eax
801033c0:	5e                   	pop    %esi
801033c1:	5f                   	pop    %edi
801033c2:	5d                   	pop    %ebp
801033c3:	c3                   	ret    
801033c4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801033cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801033cf:	90                   	nop

801033d0 <mpinit>:
  return conf;
}

void
mpinit(void)
{
801033d0:	55                   	push   %ebp
801033d1:	89 e5                	mov    %esp,%ebp
801033d3:	57                   	push   %edi
801033d4:	56                   	push   %esi
801033d5:	53                   	push   %ebx
801033d6:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801033d9:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
801033e0:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
801033e7:	c1 e0 08             	shl    $0x8,%eax
801033ea:	09 d0                	or     %edx,%eax
801033ec:	c1 e0 04             	shl    $0x4,%eax
801033ef:	75 1b                	jne    8010340c <mpinit+0x3c>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801033f1:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
801033f8:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
801033ff:	c1 e0 08             	shl    $0x8,%eax
80103402:	09 d0                	or     %edx,%eax
80103404:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103407:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010340c:	ba 00 04 00 00       	mov    $0x400,%edx
80103411:	e8 3a ff ff ff       	call   80103350 <mpsearch1>
80103416:	89 c3                	mov    %eax,%ebx
80103418:	85 c0                	test   %eax,%eax
8010341a:	0f 84 40 01 00 00    	je     80103560 <mpinit+0x190>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103420:	8b 73 04             	mov    0x4(%ebx),%esi
80103423:	85 f6                	test   %esi,%esi
80103425:	0f 84 25 01 00 00    	je     80103550 <mpinit+0x180>
  if(memcmp(conf, "PCMP", 4) != 0)
8010342b:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010342e:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
  if(memcmp(conf, "PCMP", 4) != 0)
80103434:	6a 04                	push   $0x4
80103436:	68 1d 7d 10 80       	push   $0x80107d1d
8010343b:	50                   	push   %eax
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010343c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010343f:	e8 1c 15 00 00       	call   80104960 <memcmp>
80103444:	83 c4 10             	add    $0x10,%esp
80103447:	85 c0                	test   %eax,%eax
80103449:	0f 85 01 01 00 00    	jne    80103550 <mpinit+0x180>
  if(conf->version != 1 && conf->version != 4)
8010344f:	0f b6 86 06 00 00 80 	movzbl -0x7ffffffa(%esi),%eax
80103456:	3c 01                	cmp    $0x1,%al
80103458:	74 08                	je     80103462 <mpinit+0x92>
8010345a:	3c 04                	cmp    $0x4,%al
8010345c:	0f 85 ee 00 00 00    	jne    80103550 <mpinit+0x180>
  if(sum((uchar*)conf, conf->length) != 0)
80103462:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
  for(i=0; i<len; i++)
80103469:	66 85 d2             	test   %dx,%dx
8010346c:	74 22                	je     80103490 <mpinit+0xc0>
8010346e:	8d 3c 32             	lea    (%edx,%esi,1),%edi
80103471:	89 f0                	mov    %esi,%eax
  sum = 0;
80103473:	31 d2                	xor    %edx,%edx
80103475:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
80103478:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
  for(i=0; i<len; i++)
8010347f:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
80103482:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
80103484:	39 c7                	cmp    %eax,%edi
80103486:	75 f0                	jne    80103478 <mpinit+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
80103488:	84 d2                	test   %dl,%dl
8010348a:	0f 85 c0 00 00 00    	jne    80103550 <mpinit+0x180>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80103490:	8b 86 24 00 00 80    	mov    -0x7fffffdc(%esi),%eax
80103496:	a3 a4 26 11 80       	mov    %eax,0x801126a4
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010349b:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
801034a2:	8d 86 2c 00 00 80    	lea    -0x7fffffd4(%esi),%eax
  ismp = 1;
801034a8:	be 01 00 00 00       	mov    $0x1,%esi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801034ad:	03 55 e4             	add    -0x1c(%ebp),%edx
801034b0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801034b3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801034b7:	90                   	nop
801034b8:	39 d0                	cmp    %edx,%eax
801034ba:	73 15                	jae    801034d1 <mpinit+0x101>
    switch(*p){
801034bc:	0f b6 08             	movzbl (%eax),%ecx
801034bf:	80 f9 02             	cmp    $0x2,%cl
801034c2:	74 4c                	je     80103510 <mpinit+0x140>
801034c4:	77 3a                	ja     80103500 <mpinit+0x130>
801034c6:	84 c9                	test   %cl,%cl
801034c8:	74 56                	je     80103520 <mpinit+0x150>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801034ca:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801034cd:	39 d0                	cmp    %edx,%eax
801034cf:	72 eb                	jb     801034bc <mpinit+0xec>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
801034d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801034d4:	85 f6                	test   %esi,%esi
801034d6:	0f 84 d9 00 00 00    	je     801035b5 <mpinit+0x1e5>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
801034dc:	80 7b 0c 00          	cmpb   $0x0,0xc(%ebx)
801034e0:	74 15                	je     801034f7 <mpinit+0x127>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801034e2:	b8 70 00 00 00       	mov    $0x70,%eax
801034e7:	ba 22 00 00 00       	mov    $0x22,%edx
801034ec:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801034ed:	ba 23 00 00 00       	mov    $0x23,%edx
801034f2:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801034f3:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801034f6:	ee                   	out    %al,(%dx)
  }
}
801034f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801034fa:	5b                   	pop    %ebx
801034fb:	5e                   	pop    %esi
801034fc:	5f                   	pop    %edi
801034fd:	5d                   	pop    %ebp
801034fe:	c3                   	ret    
801034ff:	90                   	nop
    switch(*p){
80103500:	83 e9 03             	sub    $0x3,%ecx
80103503:	80 f9 01             	cmp    $0x1,%cl
80103506:	76 c2                	jbe    801034ca <mpinit+0xfa>
80103508:	31 f6                	xor    %esi,%esi
8010350a:	eb ac                	jmp    801034b8 <mpinit+0xe8>
8010350c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103510:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
80103514:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
80103517:	88 0d a0 27 11 80    	mov    %cl,0x801127a0
      continue;
8010351d:	eb 99                	jmp    801034b8 <mpinit+0xe8>
8010351f:	90                   	nop
      if(ncpu < NCPU) {
80103520:	8b 0d a4 27 11 80    	mov    0x801127a4,%ecx
80103526:	83 f9 07             	cmp    $0x7,%ecx
80103529:	7f 19                	jg     80103544 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010352b:	69 f9 b0 00 00 00    	imul   $0xb0,%ecx,%edi
80103531:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
80103535:	83 c1 01             	add    $0x1,%ecx
80103538:	89 0d a4 27 11 80    	mov    %ecx,0x801127a4
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010353e:	88 9f c0 27 11 80    	mov    %bl,-0x7feed840(%edi)
      p += sizeof(struct mpproc);
80103544:	83 c0 14             	add    $0x14,%eax
      continue;
80103547:	e9 6c ff ff ff       	jmp    801034b8 <mpinit+0xe8>
8010354c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    panic("Expect to run on an SMP");
80103550:	83 ec 0c             	sub    $0xc,%esp
80103553:	68 22 7d 10 80       	push   $0x80107d22
80103558:	e8 53 cf ff ff       	call   801004b0 <panic>
8010355d:	8d 76 00             	lea    0x0(%esi),%esi
{
80103560:	bb 00 00 0f 80       	mov    $0x800f0000,%ebx
80103565:	eb 13                	jmp    8010357a <mpinit+0x1aa>
80103567:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010356e:	66 90                	xchg   %ax,%ax
  for(p = addr; p < e; p += sizeof(struct mp))
80103570:	89 f3                	mov    %esi,%ebx
80103572:	81 fe 00 00 10 80    	cmp    $0x80100000,%esi
80103578:	74 d6                	je     80103550 <mpinit+0x180>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010357a:	83 ec 04             	sub    $0x4,%esp
8010357d:	8d 73 10             	lea    0x10(%ebx),%esi
80103580:	6a 04                	push   $0x4
80103582:	68 18 7d 10 80       	push   $0x80107d18
80103587:	53                   	push   %ebx
80103588:	e8 d3 13 00 00       	call   80104960 <memcmp>
8010358d:	83 c4 10             	add    $0x10,%esp
80103590:	85 c0                	test   %eax,%eax
80103592:	75 dc                	jne    80103570 <mpinit+0x1a0>
80103594:	89 da                	mov    %ebx,%edx
80103596:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010359d:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
801035a0:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
801035a3:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
801035a6:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801035a8:	39 d6                	cmp    %edx,%esi
801035aa:	75 f4                	jne    801035a0 <mpinit+0x1d0>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801035ac:	84 c0                	test   %al,%al
801035ae:	75 c0                	jne    80103570 <mpinit+0x1a0>
801035b0:	e9 6b fe ff ff       	jmp    80103420 <mpinit+0x50>
    panic("Didn't find a suitable machine");
801035b5:	83 ec 0c             	sub    $0xc,%esp
801035b8:	68 3c 7d 10 80       	push   $0x80107d3c
801035bd:	e8 ee ce ff ff       	call   801004b0 <panic>
801035c2:	66 90                	xchg   %ax,%ax
801035c4:	66 90                	xchg   %ax,%ax
801035c6:	66 90                	xchg   %ax,%ax
801035c8:	66 90                	xchg   %ax,%ax
801035ca:	66 90                	xchg   %ax,%ax
801035cc:	66 90                	xchg   %ax,%ax
801035ce:	66 90                	xchg   %ax,%ax

801035d0 <picinit>:
801035d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801035d5:	ba 21 00 00 00       	mov    $0x21,%edx
801035da:	ee                   	out    %al,(%dx)
801035db:	ba a1 00 00 00       	mov    $0xa1,%edx
801035e0:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
801035e1:	c3                   	ret    
801035e2:	66 90                	xchg   %ax,%ax
801035e4:	66 90                	xchg   %ax,%ax
801035e6:	66 90                	xchg   %ax,%ax
801035e8:	66 90                	xchg   %ax,%ax
801035ea:	66 90                	xchg   %ax,%ax
801035ec:	66 90                	xchg   %ax,%ax
801035ee:	66 90                	xchg   %ax,%ax

801035f0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801035f0:	55                   	push   %ebp
801035f1:	89 e5                	mov    %esp,%ebp
801035f3:	57                   	push   %edi
801035f4:	56                   	push   %esi
801035f5:	53                   	push   %ebx
801035f6:	83 ec 0c             	sub    $0xc,%esp
801035f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801035fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
801035ff:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103605:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010360b:	e8 50 d9 ff ff       	call   80100f60 <filealloc>
80103610:	89 03                	mov    %eax,(%ebx)
80103612:	85 c0                	test   %eax,%eax
80103614:	0f 84 a8 00 00 00    	je     801036c2 <pipealloc+0xd2>
8010361a:	e8 41 d9 ff ff       	call   80100f60 <filealloc>
8010361f:	89 06                	mov    %eax,(%esi)
80103621:	85 c0                	test   %eax,%eax
80103623:	0f 84 87 00 00 00    	je     801036b0 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103629:	e8 a2 f1 ff ff       	call   801027d0 <kalloc>
8010362e:	89 c7                	mov    %eax,%edi
80103630:	85 c0                	test   %eax,%eax
80103632:	0f 84 b0 00 00 00    	je     801036e8 <pipealloc+0xf8>
    goto bad;
  p->readopen = 1;
80103638:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010363f:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
80103642:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
80103645:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010364c:	00 00 00 
  p->nwrite = 0;
8010364f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103656:	00 00 00 
  p->nread = 0;
80103659:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103660:	00 00 00 
  initlock(&p->lock, "pipe");
80103663:	68 5b 7d 10 80       	push   $0x80107d5b
80103668:	50                   	push   %eax
80103669:	e8 12 10 00 00       	call   80104680 <initlock>
  (*f0)->type = FD_PIPE;
8010366e:	8b 03                	mov    (%ebx),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
80103670:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103673:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103679:	8b 03                	mov    (%ebx),%eax
8010367b:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010367f:	8b 03                	mov    (%ebx),%eax
80103681:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103685:	8b 03                	mov    (%ebx),%eax
80103687:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010368a:	8b 06                	mov    (%esi),%eax
8010368c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103692:	8b 06                	mov    (%esi),%eax
80103694:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103698:	8b 06                	mov    (%esi),%eax
8010369a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010369e:	8b 06                	mov    (%esi),%eax
801036a0:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
801036a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801036a6:	31 c0                	xor    %eax,%eax
}
801036a8:	5b                   	pop    %ebx
801036a9:	5e                   	pop    %esi
801036aa:	5f                   	pop    %edi
801036ab:	5d                   	pop    %ebp
801036ac:	c3                   	ret    
801036ad:	8d 76 00             	lea    0x0(%esi),%esi
  if(*f0)
801036b0:	8b 03                	mov    (%ebx),%eax
801036b2:	85 c0                	test   %eax,%eax
801036b4:	74 1e                	je     801036d4 <pipealloc+0xe4>
    fileclose(*f0);
801036b6:	83 ec 0c             	sub    $0xc,%esp
801036b9:	50                   	push   %eax
801036ba:	e8 61 d9 ff ff       	call   80101020 <fileclose>
801036bf:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801036c2:	8b 06                	mov    (%esi),%eax
801036c4:	85 c0                	test   %eax,%eax
801036c6:	74 0c                	je     801036d4 <pipealloc+0xe4>
    fileclose(*f1);
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 4f d9 ff ff       	call   80101020 <fileclose>
801036d1:	83 c4 10             	add    $0x10,%esp
}
801036d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
801036d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036dc:	5b                   	pop    %ebx
801036dd:	5e                   	pop    %esi
801036de:	5f                   	pop    %edi
801036df:	5d                   	pop    %ebp
801036e0:	c3                   	ret    
801036e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
801036e8:	8b 03                	mov    (%ebx),%eax
801036ea:	85 c0                	test   %eax,%eax
801036ec:	75 c8                	jne    801036b6 <pipealloc+0xc6>
801036ee:	eb d2                	jmp    801036c2 <pipealloc+0xd2>

801036f0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036f0:	55                   	push   %ebp
801036f1:	89 e5                	mov    %esp,%ebp
801036f3:	56                   	push   %esi
801036f4:	53                   	push   %ebx
801036f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
801036f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
801036fb:	83 ec 0c             	sub    $0xc,%esp
801036fe:	53                   	push   %ebx
801036ff:	e8 4c 11 00 00       	call   80104850 <acquire>
  if(writable){
80103704:	83 c4 10             	add    $0x10,%esp
80103707:	85 f6                	test   %esi,%esi
80103709:	74 65                	je     80103770 <pipeclose+0x80>
    p->writeopen = 0;
    wakeup(&p->nread);
8010370b:	83 ec 0c             	sub    $0xc,%esp
8010370e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
80103714:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010371b:	00 00 00 
    wakeup(&p->nread);
8010371e:	50                   	push   %eax
8010371f:	e8 2c 0c 00 00       	call   80104350 <wakeup>
80103724:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103727:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010372d:	85 d2                	test   %edx,%edx
8010372f:	75 0a                	jne    8010373b <pipeclose+0x4b>
80103731:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103737:	85 c0                	test   %eax,%eax
80103739:	74 15                	je     80103750 <pipeclose+0x60>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010373b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010373e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103741:	5b                   	pop    %ebx
80103742:	5e                   	pop    %esi
80103743:	5d                   	pop    %ebp
    release(&p->lock);
80103744:	e9 a7 10 00 00       	jmp    801047f0 <release>
80103749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    release(&p->lock);
80103750:	83 ec 0c             	sub    $0xc,%esp
80103753:	53                   	push   %ebx
80103754:	e8 97 10 00 00       	call   801047f0 <release>
    kfree((char*)p);
80103759:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010375c:	83 c4 10             	add    $0x10,%esp
}
8010375f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103762:	5b                   	pop    %ebx
80103763:	5e                   	pop    %esi
80103764:	5d                   	pop    %ebp
    kfree((char*)p);
80103765:	e9 86 ee ff ff       	jmp    801025f0 <kfree>
8010376a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&p->nwrite);
80103770:	83 ec 0c             	sub    $0xc,%esp
80103773:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
80103779:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103780:	00 00 00 
    wakeup(&p->nwrite);
80103783:	50                   	push   %eax
80103784:	e8 c7 0b 00 00       	call   80104350 <wakeup>
80103789:	83 c4 10             	add    $0x10,%esp
8010378c:	eb 99                	jmp    80103727 <pipeclose+0x37>
8010378e:	66 90                	xchg   %ax,%ax

80103790 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103790:	55                   	push   %ebp
80103791:	89 e5                	mov    %esp,%ebp
80103793:	57                   	push   %edi
80103794:	56                   	push   %esi
80103795:	53                   	push   %ebx
80103796:	83 ec 28             	sub    $0x28,%esp
80103799:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010379c:	53                   	push   %ebx
8010379d:	e8 ae 10 00 00       	call   80104850 <acquire>
  for(i = 0; i < n; i++){
801037a2:	8b 45 10             	mov    0x10(%ebp),%eax
801037a5:	83 c4 10             	add    $0x10,%esp
801037a8:	85 c0                	test   %eax,%eax
801037aa:	0f 8e c0 00 00 00    	jle    80103870 <pipewrite+0xe0>
801037b0:	8b 45 0c             	mov    0xc(%ebp),%eax
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037b3:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801037b9:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
801037bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801037c2:	03 45 10             	add    0x10(%ebp),%eax
801037c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037c8:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037ce:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037d4:	89 ca                	mov    %ecx,%edx
801037d6:	05 00 02 00 00       	add    $0x200,%eax
801037db:	39 c1                	cmp    %eax,%ecx
801037dd:	74 3f                	je     8010381e <pipewrite+0x8e>
801037df:	eb 67                	jmp    80103848 <pipewrite+0xb8>
801037e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->readopen == 0 || myproc()->killed){
801037e8:	e8 53 03 00 00       	call   80103b40 <myproc>
801037ed:	8b 48 28             	mov    0x28(%eax),%ecx
801037f0:	85 c9                	test   %ecx,%ecx
801037f2:	75 34                	jne    80103828 <pipewrite+0x98>
      wakeup(&p->nread);
801037f4:	83 ec 0c             	sub    $0xc,%esp
801037f7:	57                   	push   %edi
801037f8:	e8 53 0b 00 00       	call   80104350 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037fd:	58                   	pop    %eax
801037fe:	5a                   	pop    %edx
801037ff:	53                   	push   %ebx
80103800:	56                   	push   %esi
80103801:	e8 8a 0a 00 00       	call   80104290 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103806:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010380c:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103812:	83 c4 10             	add    $0x10,%esp
80103815:	05 00 02 00 00       	add    $0x200,%eax
8010381a:	39 c2                	cmp    %eax,%edx
8010381c:	75 2a                	jne    80103848 <pipewrite+0xb8>
      if(p->readopen == 0 || myproc()->killed){
8010381e:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103824:	85 c0                	test   %eax,%eax
80103826:	75 c0                	jne    801037e8 <pipewrite+0x58>
        release(&p->lock);
80103828:	83 ec 0c             	sub    $0xc,%esp
8010382b:	53                   	push   %ebx
8010382c:	e8 bf 0f 00 00       	call   801047f0 <release>
        return -1;
80103831:	83 c4 10             	add    $0x10,%esp
80103834:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103839:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010383c:	5b                   	pop    %ebx
8010383d:	5e                   	pop    %esi
8010383e:	5f                   	pop    %edi
8010383f:	5d                   	pop    %ebp
80103840:	c3                   	ret    
80103841:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103848:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010384b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010384e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103854:	89 8b 38 02 00 00    	mov    %ecx,0x238(%ebx)
8010385a:	0f b6 06             	movzbl (%esi),%eax
  for(i = 0; i < n; i++){
8010385d:	83 c6 01             	add    $0x1,%esi
80103860:	89 75 e4             	mov    %esi,-0x1c(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103863:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103867:	3b 75 e0             	cmp    -0x20(%ebp),%esi
8010386a:	0f 85 58 ff ff ff    	jne    801037c8 <pipewrite+0x38>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103870:	83 ec 0c             	sub    $0xc,%esp
80103873:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103879:	50                   	push   %eax
8010387a:	e8 d1 0a 00 00       	call   80104350 <wakeup>
  release(&p->lock);
8010387f:	89 1c 24             	mov    %ebx,(%esp)
80103882:	e8 69 0f 00 00       	call   801047f0 <release>
  return n;
80103887:	8b 45 10             	mov    0x10(%ebp),%eax
8010388a:	83 c4 10             	add    $0x10,%esp
8010388d:	eb aa                	jmp    80103839 <pipewrite+0xa9>
8010388f:	90                   	nop

80103890 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103890:	55                   	push   %ebp
80103891:	89 e5                	mov    %esp,%ebp
80103893:	57                   	push   %edi
80103894:	56                   	push   %esi
80103895:	53                   	push   %ebx
80103896:	83 ec 18             	sub    $0x18,%esp
80103899:	8b 75 08             	mov    0x8(%ebp),%esi
8010389c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
8010389f:	56                   	push   %esi
801038a0:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
801038a6:	e8 a5 0f 00 00       	call   80104850 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038ab:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
801038b1:	83 c4 10             	add    $0x10,%esp
801038b4:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
801038ba:	74 2f                	je     801038eb <piperead+0x5b>
801038bc:	eb 37                	jmp    801038f5 <piperead+0x65>
801038be:	66 90                	xchg   %ax,%ax
    if(myproc()->killed){
801038c0:	e8 7b 02 00 00       	call   80103b40 <myproc>
801038c5:	8b 48 28             	mov    0x28(%eax),%ecx
801038c8:	85 c9                	test   %ecx,%ecx
801038ca:	0f 85 80 00 00 00    	jne    80103950 <piperead+0xc0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038d0:	83 ec 08             	sub    $0x8,%esp
801038d3:	56                   	push   %esi
801038d4:	53                   	push   %ebx
801038d5:	e8 b6 09 00 00       	call   80104290 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038da:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
801038e0:	83 c4 10             	add    $0x10,%esp
801038e3:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
801038e9:	75 0a                	jne    801038f5 <piperead+0x65>
801038eb:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
801038f1:	85 c0                	test   %eax,%eax
801038f3:	75 cb                	jne    801038c0 <piperead+0x30>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038f5:	8b 55 10             	mov    0x10(%ebp),%edx
801038f8:	31 db                	xor    %ebx,%ebx
801038fa:	85 d2                	test   %edx,%edx
801038fc:	7f 20                	jg     8010391e <piperead+0x8e>
801038fe:	eb 2c                	jmp    8010392c <piperead+0x9c>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103900:	8d 48 01             	lea    0x1(%eax),%ecx
80103903:	25 ff 01 00 00       	and    $0x1ff,%eax
80103908:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
8010390e:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
80103913:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103916:	83 c3 01             	add    $0x1,%ebx
80103919:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010391c:	74 0e                	je     8010392c <piperead+0x9c>
    if(p->nread == p->nwrite)
8010391e:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103924:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
8010392a:	75 d4                	jne    80103900 <piperead+0x70>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010392c:	83 ec 0c             	sub    $0xc,%esp
8010392f:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103935:	50                   	push   %eax
80103936:	e8 15 0a 00 00       	call   80104350 <wakeup>
  release(&p->lock);
8010393b:	89 34 24             	mov    %esi,(%esp)
8010393e:	e8 ad 0e 00 00       	call   801047f0 <release>
  return i;
80103943:	83 c4 10             	add    $0x10,%esp
}
80103946:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103949:	89 d8                	mov    %ebx,%eax
8010394b:	5b                   	pop    %ebx
8010394c:	5e                   	pop    %esi
8010394d:	5f                   	pop    %edi
8010394e:	5d                   	pop    %ebp
8010394f:	c3                   	ret    
      release(&p->lock);
80103950:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80103953:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
80103958:	56                   	push   %esi
80103959:	e8 92 0e 00 00       	call   801047f0 <release>
      return -1;
8010395e:	83 c4 10             	add    $0x10,%esp
}
80103961:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103964:	89 d8                	mov    %ebx,%eax
80103966:	5b                   	pop    %ebx
80103967:	5e                   	pop    %esi
80103968:	5f                   	pop    %edi
80103969:	5d                   	pop    %ebp
8010396a:	c3                   	ret    
8010396b:	66 90                	xchg   %ax,%ax
8010396d:	66 90                	xchg   %ax,%ax
8010396f:	90                   	nop

80103970 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103970:	55                   	push   %ebp
80103971:	89 e5                	mov    %esp,%ebp
80103973:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103974:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
{
80103979:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
8010397c:	68 40 2d 11 80       	push   $0x80112d40
80103981:	e8 ca 0e 00 00       	call   80104850 <acquire>
80103986:	83 c4 10             	add    $0x10,%esp
80103989:	eb 14                	jmp    8010399f <allocproc+0x2f>
8010398b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010398f:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103990:	83 eb 80             	sub    $0xffffff80,%ebx
80103993:	81 fb 74 4d 11 80    	cmp    $0x80114d74,%ebx
80103999:	0f 84 81 00 00 00    	je     80103a20 <allocproc+0xb0>
    if(p->state == UNUSED)
8010399f:	8b 43 10             	mov    0x10(%ebx),%eax
801039a2:	85 c0                	test   %eax,%eax
801039a4:	75 ea                	jne    80103990 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
801039a6:	a1 04 b0 10 80       	mov    0x8010b004,%eax

  release(&ptable.lock);
801039ab:	83 ec 0c             	sub    $0xc,%esp
  p->state = EMBRYO;
801039ae:	c7 43 10 01 00 00 00 	movl   $0x1,0x10(%ebx)
  p->pid = nextpid++;
801039b5:	89 43 14             	mov    %eax,0x14(%ebx)
801039b8:	8d 50 01             	lea    0x1(%eax),%edx
  release(&ptable.lock);
801039bb:	68 40 2d 11 80       	push   $0x80112d40
  p->pid = nextpid++;
801039c0:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
  release(&ptable.lock);
801039c6:	e8 25 0e 00 00       	call   801047f0 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801039cb:	e8 00 ee ff ff       	call   801027d0 <kalloc>
801039d0:	83 c4 10             	add    $0x10,%esp
801039d3:	89 43 0c             	mov    %eax,0xc(%ebx)
801039d6:	85 c0                	test   %eax,%eax
801039d8:	74 5f                	je     80103a39 <allocproc+0xc9>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801039da:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
801039e0:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
801039e3:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
801039e8:	89 53 1c             	mov    %edx,0x1c(%ebx)
  *(uint*)sp = (uint)trapret;
801039eb:	c7 40 14 22 5b 10 80 	movl   $0x80105b22,0x14(%eax)
  p->context = (struct context*)sp;
801039f2:	89 43 20             	mov    %eax,0x20(%ebx)
  memset(p->context, 0, sizeof *p->context);
801039f5:	6a 14                	push   $0x14
801039f7:	6a 00                	push   $0x0
801039f9:	50                   	push   %eax
801039fa:	e8 11 0f 00 00       	call   80104910 <memset>
  p->context->eip = (uint)forkret;
801039ff:	8b 43 20             	mov    0x20(%ebx),%eax
  p->rss+=PGSIZE;
  return p;
80103a02:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103a05:	c7 40 10 50 3a 10 80 	movl   $0x80103a50,0x10(%eax)
}
80103a0c:	89 d8                	mov    %ebx,%eax
  p->rss+=PGSIZE;
80103a0e:	81 43 04 00 10 00 00 	addl   $0x1000,0x4(%ebx)
}
80103a15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a18:	c9                   	leave  
80103a19:	c3                   	ret    
80103a1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
80103a20:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80103a23:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
80103a25:	68 40 2d 11 80       	push   $0x80112d40
80103a2a:	e8 c1 0d 00 00       	call   801047f0 <release>
}
80103a2f:	89 d8                	mov    %ebx,%eax
  return 0;
80103a31:	83 c4 10             	add    $0x10,%esp
}
80103a34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a37:	c9                   	leave  
80103a38:	c3                   	ret    
    p->state = UNUSED;
80103a39:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return 0;
80103a40:	31 db                	xor    %ebx,%ebx
}
80103a42:	89 d8                	mov    %ebx,%eax
80103a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a47:	c9                   	leave  
80103a48:	c3                   	ret    
80103a49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103a50 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80103a50:	55                   	push   %ebp
80103a51:	89 e5                	mov    %esp,%ebp
80103a53:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80103a56:	68 40 2d 11 80       	push   $0x80112d40
80103a5b:	e8 90 0d 00 00       	call   801047f0 <release>

  if (first) {
80103a60:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80103a65:	83 c4 10             	add    $0x10,%esp
80103a68:	85 c0                	test   %eax,%eax
80103a6a:	75 04                	jne    80103a70 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
80103a6c:	c9                   	leave  
80103a6d:	c3                   	ret    
80103a6e:	66 90                	xchg   %ax,%ax
    first = 0;
80103a70:	c7 05 00 b0 10 80 00 	movl   $0x0,0x8010b000
80103a77:	00 00 00 
    iinit(ROOTDEV);
80103a7a:	83 ec 0c             	sub    $0xc,%esp
80103a7d:	6a 01                	push   $0x1
80103a7f:	e8 0c dc ff ff       	call   80101690 <iinit>
    initlog(ROOTDEV);
80103a84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103a8b:	e8 f0 f3 ff ff       	call   80102e80 <initlog>
}
80103a90:	83 c4 10             	add    $0x10,%esp
80103a93:	c9                   	leave  
80103a94:	c3                   	ret    
80103a95:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103aa0 <pinit>:
{
80103aa0:	55                   	push   %ebp
80103aa1:	89 e5                	mov    %esp,%ebp
80103aa3:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103aa6:	68 60 7d 10 80       	push   $0x80107d60
80103aab:	68 40 2d 11 80       	push   $0x80112d40
80103ab0:	e8 cb 0b 00 00       	call   80104680 <initlock>
}
80103ab5:	83 c4 10             	add    $0x10,%esp
80103ab8:	c9                   	leave  
80103ab9:	c3                   	ret    
80103aba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103ac0 <mycpu>:
{
80103ac0:	55                   	push   %ebp
80103ac1:	89 e5                	mov    %esp,%ebp
80103ac3:	56                   	push   %esi
80103ac4:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103ac5:	9c                   	pushf  
80103ac6:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103ac7:	f6 c4 02             	test   $0x2,%ah
80103aca:	75 46                	jne    80103b12 <mycpu+0x52>
  apicid = lapicid();
80103acc:	e8 df ef ff ff       	call   80102ab0 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103ad1:	8b 35 a4 27 11 80    	mov    0x801127a4,%esi
80103ad7:	85 f6                	test   %esi,%esi
80103ad9:	7e 2a                	jle    80103b05 <mycpu+0x45>
80103adb:	31 d2                	xor    %edx,%edx
80103add:	eb 08                	jmp    80103ae7 <mycpu+0x27>
80103adf:	90                   	nop
80103ae0:	83 c2 01             	add    $0x1,%edx
80103ae3:	39 f2                	cmp    %esi,%edx
80103ae5:	74 1e                	je     80103b05 <mycpu+0x45>
    if (cpus[i].apicid == apicid)
80103ae7:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103aed:	0f b6 99 c0 27 11 80 	movzbl -0x7feed840(%ecx),%ebx
80103af4:	39 c3                	cmp    %eax,%ebx
80103af6:	75 e8                	jne    80103ae0 <mycpu+0x20>
}
80103af8:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
80103afb:	8d 81 c0 27 11 80    	lea    -0x7feed840(%ecx),%eax
}
80103b01:	5b                   	pop    %ebx
80103b02:	5e                   	pop    %esi
80103b03:	5d                   	pop    %ebp
80103b04:	c3                   	ret    
  panic("unknown apicid\n");
80103b05:	83 ec 0c             	sub    $0xc,%esp
80103b08:	68 67 7d 10 80       	push   $0x80107d67
80103b0d:	e8 9e c9 ff ff       	call   801004b0 <panic>
    panic("mycpu called with interrupts enabled\n");
80103b12:	83 ec 0c             	sub    $0xc,%esp
80103b15:	68 50 7e 10 80       	push   $0x80107e50
80103b1a:	e8 91 c9 ff ff       	call   801004b0 <panic>
80103b1f:	90                   	nop

80103b20 <cpuid>:
cpuid() {
80103b20:	55                   	push   %ebp
80103b21:	89 e5                	mov    %esp,%ebp
80103b23:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b26:	e8 95 ff ff ff       	call   80103ac0 <mycpu>
}
80103b2b:	c9                   	leave  
  return mycpu()-cpus;
80103b2c:	2d c0 27 11 80       	sub    $0x801127c0,%eax
80103b31:	c1 f8 04             	sar    $0x4,%eax
80103b34:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b3a:	c3                   	ret    
80103b3b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103b3f:	90                   	nop

80103b40 <myproc>:
myproc(void) {
80103b40:	55                   	push   %ebp
80103b41:	89 e5                	mov    %esp,%ebp
80103b43:	53                   	push   %ebx
80103b44:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103b47:	e8 b4 0b 00 00       	call   80104700 <pushcli>
  c = mycpu();
80103b4c:	e8 6f ff ff ff       	call   80103ac0 <mycpu>
  p = c->proc;
80103b51:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103b57:	e8 f4 0b 00 00       	call   80104750 <popcli>
}
80103b5c:	89 d8                	mov    %ebx,%eax
80103b5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b61:	c9                   	leave  
80103b62:	c3                   	ret    
80103b63:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103b6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103b70 <userinit>:
{
80103b70:	55                   	push   %ebp
80103b71:	89 e5                	mov    %esp,%ebp
80103b73:	53                   	push   %ebx
80103b74:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103b77:	e8 f4 fd ff ff       	call   80103970 <allocproc>
80103b7c:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103b7e:	a3 74 4d 11 80       	mov    %eax,0x80114d74
  if((p->pgdir = setupkvm()) == 0)
80103b83:	e8 78 36 00 00       	call   80107200 <setupkvm>
80103b88:	89 43 08             	mov    %eax,0x8(%ebx)
80103b8b:	85 c0                	test   %eax,%eax
80103b8d:	0f 84 bd 00 00 00    	je     80103c50 <userinit+0xe0>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b93:	83 ec 04             	sub    $0x4,%esp
80103b96:	68 2c 00 00 00       	push   $0x2c
80103b9b:	68 60 b4 10 80       	push   $0x8010b460
80103ba0:	50                   	push   %eax
80103ba1:	e8 fa 32 00 00       	call   80106ea0 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103ba6:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103ba9:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103baf:	6a 4c                	push   $0x4c
80103bb1:	6a 00                	push   $0x0
80103bb3:	ff 73 1c             	push   0x1c(%ebx)
80103bb6:	e8 55 0d 00 00       	call   80104910 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bbb:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103bbe:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103bc3:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bc6:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bcb:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bcf:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103bd2:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bd6:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103bd9:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103bdd:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103be1:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103be4:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103be8:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103bec:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103bef:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103bf6:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103bf9:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c00:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103c03:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c0a:	8d 43 70             	lea    0x70(%ebx),%eax
80103c0d:	6a 10                	push   $0x10
80103c0f:	68 90 7d 10 80       	push   $0x80107d90
80103c14:	50                   	push   %eax
80103c15:	e8 b6 0e 00 00       	call   80104ad0 <safestrcpy>
  p->cwd = namei("/");
80103c1a:	c7 04 24 99 7d 10 80 	movl   $0x80107d99,(%esp)
80103c21:	e8 aa e5 ff ff       	call   801021d0 <namei>
80103c26:	89 43 6c             	mov    %eax,0x6c(%ebx)
  acquire(&ptable.lock);
80103c29:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103c30:	e8 1b 0c 00 00       	call   80104850 <acquire>
  p->state = RUNNABLE;
80103c35:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  release(&ptable.lock);
80103c3c:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103c43:	e8 a8 0b 00 00       	call   801047f0 <release>
}
80103c48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c4b:	83 c4 10             	add    $0x10,%esp
80103c4e:	c9                   	leave  
80103c4f:	c3                   	ret    
    panic("userinit: out of memory?");
80103c50:	83 ec 0c             	sub    $0xc,%esp
80103c53:	68 77 7d 10 80       	push   $0x80107d77
80103c58:	e8 53 c8 ff ff       	call   801004b0 <panic>
80103c5d:	8d 76 00             	lea    0x0(%esi),%esi

80103c60 <growproc>:
{
80103c60:	55                   	push   %ebp
80103c61:	89 e5                	mov    %esp,%ebp
80103c63:	56                   	push   %esi
80103c64:	53                   	push   %ebx
80103c65:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103c68:	e8 93 0a 00 00       	call   80104700 <pushcli>
  c = mycpu();
80103c6d:	e8 4e fe ff ff       	call   80103ac0 <mycpu>
  p = c->proc;
80103c72:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103c78:	e8 d3 0a 00 00       	call   80104750 <popcli>
  sz = curproc->sz;
80103c7d:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103c7f:	85 f6                	test   %esi,%esi
80103c81:	7f 1d                	jg     80103ca0 <growproc+0x40>
  } else if(n < 0){
80103c83:	75 3b                	jne    80103cc0 <growproc+0x60>
  switchuvm(curproc);
80103c85:	83 ec 0c             	sub    $0xc,%esp
  curproc->sz = sz;
80103c88:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103c8a:	53                   	push   %ebx
80103c8b:	e8 00 31 00 00       	call   80106d90 <switchuvm>
  return 0;
80103c90:	83 c4 10             	add    $0x10,%esp
80103c93:	31 c0                	xor    %eax,%eax
}
80103c95:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c98:	5b                   	pop    %ebx
80103c99:	5e                   	pop    %esi
80103c9a:	5d                   	pop    %ebp
80103c9b:	c3                   	ret    
80103c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ca0:	83 ec 04             	sub    $0x4,%esp
80103ca3:	01 c6                	add    %eax,%esi
80103ca5:	56                   	push   %esi
80103ca6:	50                   	push   %eax
80103ca7:	ff 73 08             	push   0x8(%ebx)
80103caa:	e8 61 33 00 00       	call   80107010 <allocuvm>
80103caf:	83 c4 10             	add    $0x10,%esp
80103cb2:	85 c0                	test   %eax,%eax
80103cb4:	75 cf                	jne    80103c85 <growproc+0x25>
      return -1;
80103cb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cbb:	eb d8                	jmp    80103c95 <growproc+0x35>
80103cbd:	8d 76 00             	lea    0x0(%esi),%esi
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cc0:	83 ec 04             	sub    $0x4,%esp
80103cc3:	01 c6                	add    %eax,%esi
80103cc5:	56                   	push   %esi
80103cc6:	50                   	push   %eax
80103cc7:	ff 73 08             	push   0x8(%ebx)
80103cca:	e8 81 34 00 00       	call   80107150 <deallocuvm>
80103ccf:	83 c4 10             	add    $0x10,%esp
80103cd2:	85 c0                	test   %eax,%eax
80103cd4:	75 af                	jne    80103c85 <growproc+0x25>
80103cd6:	eb de                	jmp    80103cb6 <growproc+0x56>
80103cd8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103cdf:	90                   	nop

80103ce0 <fork>:
{
80103ce0:	55                   	push   %ebp
80103ce1:	89 e5                	mov    %esp,%ebp
80103ce3:	57                   	push   %edi
80103ce4:	56                   	push   %esi
80103ce5:	53                   	push   %ebx
80103ce6:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103ce9:	e8 12 0a 00 00       	call   80104700 <pushcli>
  c = mycpu();
80103cee:	e8 cd fd ff ff       	call   80103ac0 <mycpu>
  p = c->proc;
80103cf3:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103cf9:	e8 52 0a 00 00       	call   80104750 <popcli>
  if((np = allocproc()) == 0){
80103cfe:	e8 6d fc ff ff       	call   80103970 <allocproc>
80103d03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103d06:	85 c0                	test   %eax,%eax
80103d08:	0f 84 bf 00 00 00    	je     80103dcd <fork+0xed>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz,np)) == 0){
80103d0e:	83 ec 04             	sub    $0x4,%esp
80103d11:	89 c7                	mov    %eax,%edi
80103d13:	50                   	push   %eax
80103d14:	ff 33                	push   (%ebx)
80103d16:	ff 73 08             	push   0x8(%ebx)
80103d19:	e8 d2 35 00 00       	call   801072f0 <copyuvm>
80103d1e:	83 c4 10             	add    $0x10,%esp
80103d21:	89 47 08             	mov    %eax,0x8(%edi)
80103d24:	85 c0                	test   %eax,%eax
80103d26:	0f 84 a8 00 00 00    	je     80103dd4 <fork+0xf4>
  np->sz = curproc->sz;
80103d2c:	8b 03                	mov    (%ebx),%eax
80103d2e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103d31:	89 01                	mov    %eax,(%ecx)
  *np->tf = *curproc->tf;
80103d33:	8b 79 1c             	mov    0x1c(%ecx),%edi
  np->parent = curproc;
80103d36:	89 c8                	mov    %ecx,%eax
80103d38:	89 59 18             	mov    %ebx,0x18(%ecx)
  *np->tf = *curproc->tf;
80103d3b:	b9 13 00 00 00       	mov    $0x13,%ecx
80103d40:	8b 73 1c             	mov    0x1c(%ebx),%esi
80103d43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103d45:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103d47:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d4a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103d51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[i])
80103d58:	8b 44 b3 2c          	mov    0x2c(%ebx,%esi,4),%eax
80103d5c:	85 c0                	test   %eax,%eax
80103d5e:	74 13                	je     80103d73 <fork+0x93>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103d60:	83 ec 0c             	sub    $0xc,%esp
80103d63:	50                   	push   %eax
80103d64:	e8 67 d2 ff ff       	call   80100fd0 <filedup>
80103d69:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103d6c:	83 c4 10             	add    $0x10,%esp
80103d6f:	89 44 b2 2c          	mov    %eax,0x2c(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
80103d73:	83 c6 01             	add    $0x1,%esi
80103d76:	83 fe 10             	cmp    $0x10,%esi
80103d79:	75 dd                	jne    80103d58 <fork+0x78>
  np->cwd = idup(curproc->cwd);
80103d7b:	83 ec 0c             	sub    $0xc,%esp
80103d7e:	ff 73 6c             	push   0x6c(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103d81:	83 c3 70             	add    $0x70,%ebx
  np->cwd = idup(curproc->cwd);
80103d84:	e8 f7 da ff ff       	call   80101880 <idup>
80103d89:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103d8c:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
80103d8f:	89 47 6c             	mov    %eax,0x6c(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103d92:	8d 47 70             	lea    0x70(%edi),%eax
80103d95:	6a 10                	push   $0x10
80103d97:	53                   	push   %ebx
80103d98:	50                   	push   %eax
80103d99:	e8 32 0d 00 00       	call   80104ad0 <safestrcpy>
  pid = np->pid;
80103d9e:	8b 5f 14             	mov    0x14(%edi),%ebx
  acquire(&ptable.lock);
80103da1:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103da8:	e8 a3 0a 00 00       	call   80104850 <acquire>
  np->state = RUNNABLE;
80103dad:	c7 47 10 03 00 00 00 	movl   $0x3,0x10(%edi)
  release(&ptable.lock);
80103db4:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103dbb:	e8 30 0a 00 00       	call   801047f0 <release>
  return pid;
80103dc0:	83 c4 10             	add    $0x10,%esp
}
80103dc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103dc6:	89 d8                	mov    %ebx,%eax
80103dc8:	5b                   	pop    %ebx
80103dc9:	5e                   	pop    %esi
80103dca:	5f                   	pop    %edi
80103dcb:	5d                   	pop    %ebp
80103dcc:	c3                   	ret    
    return -1;
80103dcd:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103dd2:	eb ef                	jmp    80103dc3 <fork+0xe3>
    kfree(np->kstack);
80103dd4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103dd7:	83 ec 0c             	sub    $0xc,%esp
80103dda:	ff 73 0c             	push   0xc(%ebx)
80103ddd:	e8 0e e8 ff ff       	call   801025f0 <kfree>
    np->kstack = 0;
80103de2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103de9:	83 c4 10             	add    $0x10,%esp
    np->state = UNUSED;
80103dec:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return -1;
80103df3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103df8:	eb c9                	jmp    80103dc3 <fork+0xe3>
80103dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103e00 <print_rss>:
{
80103e00:	55                   	push   %ebp
80103e01:	89 e5                	mov    %esp,%ebp
80103e03:	53                   	push   %ebx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103e04:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
{
80103e09:	83 ec 10             	sub    $0x10,%esp
  cprintf("PrintingRSS\n");
80103e0c:	68 9b 7d 10 80       	push   $0x80107d9b
80103e11:	e8 ba c9 ff ff       	call   801007d0 <cprintf>
  acquire(&ptable.lock);
80103e16:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80103e1d:	e8 2e 0a 00 00       	call   80104850 <acquire>
80103e22:	83 c4 10             	add    $0x10,%esp
80103e25:	8d 76 00             	lea    0x0(%esi),%esi
    if((p->state == UNUSED))
80103e28:	8b 43 10             	mov    0x10(%ebx),%eax
80103e2b:	85 c0                	test   %eax,%eax
80103e2d:	74 14                	je     80103e43 <print_rss+0x43>
    cprintf("((P)) id: %d, state: %d, rss: %d\n",p->pid,p->state,p->rss);
80103e2f:	ff 73 04             	push   0x4(%ebx)
80103e32:	50                   	push   %eax
80103e33:	ff 73 14             	push   0x14(%ebx)
80103e36:	68 78 7e 10 80       	push   $0x80107e78
80103e3b:	e8 90 c9 ff ff       	call   801007d0 <cprintf>
80103e40:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103e43:	83 eb 80             	sub    $0xffffff80,%ebx
80103e46:	81 fb 74 4d 11 80    	cmp    $0x80114d74,%ebx
80103e4c:	75 da                	jne    80103e28 <print_rss+0x28>
  release(&ptable.lock);
80103e4e:	83 ec 0c             	sub    $0xc,%esp
80103e51:	68 40 2d 11 80       	push   $0x80112d40
80103e56:	e8 95 09 00 00       	call   801047f0 <release>
}
80103e5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e5e:	83 c4 10             	add    $0x10,%esp
80103e61:	c9                   	leave  
80103e62:	c3                   	ret    
80103e63:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103e70 <scheduler>:
{
80103e70:	55                   	push   %ebp
80103e71:	89 e5                	mov    %esp,%ebp
80103e73:	57                   	push   %edi
80103e74:	56                   	push   %esi
80103e75:	53                   	push   %ebx
80103e76:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80103e79:	e8 42 fc ff ff       	call   80103ac0 <mycpu>
  c->proc = 0;
80103e7e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103e85:	00 00 00 
  struct cpu *c = mycpu();
80103e88:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103e8a:	8d 78 04             	lea    0x4(%eax),%edi
80103e8d:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103e90:	fb                   	sti    
    acquire(&ptable.lock);
80103e91:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e94:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
    acquire(&ptable.lock);
80103e99:	68 40 2d 11 80       	push   $0x80112d40
80103e9e:	e8 ad 09 00 00       	call   80104850 <acquire>
80103ea3:	83 c4 10             	add    $0x10,%esp
80103ea6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103ead:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->state != RUNNABLE)
80103eb0:	83 7b 10 03          	cmpl   $0x3,0x10(%ebx)
80103eb4:	75 33                	jne    80103ee9 <scheduler+0x79>
      switchuvm(p);
80103eb6:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80103eb9:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103ebf:	53                   	push   %ebx
80103ec0:	e8 cb 2e 00 00       	call   80106d90 <switchuvm>
      swtch(&(c->scheduler), p->context);
80103ec5:	58                   	pop    %eax
80103ec6:	5a                   	pop    %edx
80103ec7:	ff 73 20             	push   0x20(%ebx)
80103eca:	57                   	push   %edi
      p->state = RUNNING;
80103ecb:	c7 43 10 04 00 00 00 	movl   $0x4,0x10(%ebx)
      swtch(&(c->scheduler), p->context);
80103ed2:	e8 54 0c 00 00       	call   80104b2b <swtch>
      switchkvm();
80103ed7:	e8 a4 2e 00 00       	call   80106d80 <switchkvm>
      c->proc = 0;
80103edc:	83 c4 10             	add    $0x10,%esp
80103edf:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103ee6:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ee9:	83 eb 80             	sub    $0xffffff80,%ebx
80103eec:	81 fb 74 4d 11 80    	cmp    $0x80114d74,%ebx
80103ef2:	75 bc                	jne    80103eb0 <scheduler+0x40>
    release(&ptable.lock);
80103ef4:	83 ec 0c             	sub    $0xc,%esp
80103ef7:	68 40 2d 11 80       	push   $0x80112d40
80103efc:	e8 ef 08 00 00       	call   801047f0 <release>
    sti();
80103f01:	83 c4 10             	add    $0x10,%esp
80103f04:	eb 8a                	jmp    80103e90 <scheduler+0x20>
80103f06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103f0d:	8d 76 00             	lea    0x0(%esi),%esi

80103f10 <sched>:
{
80103f10:	55                   	push   %ebp
80103f11:	89 e5                	mov    %esp,%ebp
80103f13:	56                   	push   %esi
80103f14:	53                   	push   %ebx
  pushcli();
80103f15:	e8 e6 07 00 00       	call   80104700 <pushcli>
  c = mycpu();
80103f1a:	e8 a1 fb ff ff       	call   80103ac0 <mycpu>
  p = c->proc;
80103f1f:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103f25:	e8 26 08 00 00       	call   80104750 <popcli>
  if(!holding(&ptable.lock))
80103f2a:	83 ec 0c             	sub    $0xc,%esp
80103f2d:	68 40 2d 11 80       	push   $0x80112d40
80103f32:	e8 79 08 00 00       	call   801047b0 <holding>
80103f37:	83 c4 10             	add    $0x10,%esp
80103f3a:	85 c0                	test   %eax,%eax
80103f3c:	74 4f                	je     80103f8d <sched+0x7d>
  if(mycpu()->ncli != 1)
80103f3e:	e8 7d fb ff ff       	call   80103ac0 <mycpu>
80103f43:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103f4a:	75 68                	jne    80103fb4 <sched+0xa4>
  if(p->state == RUNNING)
80103f4c:	83 7b 10 04          	cmpl   $0x4,0x10(%ebx)
80103f50:	74 55                	je     80103fa7 <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103f52:	9c                   	pushf  
80103f53:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103f54:	f6 c4 02             	test   $0x2,%ah
80103f57:	75 41                	jne    80103f9a <sched+0x8a>
  intena = mycpu()->intena;
80103f59:	e8 62 fb ff ff       	call   80103ac0 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
80103f5e:	83 c3 20             	add    $0x20,%ebx
  intena = mycpu()->intena;
80103f61:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103f67:	e8 54 fb ff ff       	call   80103ac0 <mycpu>
80103f6c:	83 ec 08             	sub    $0x8,%esp
80103f6f:	ff 70 04             	push   0x4(%eax)
80103f72:	53                   	push   %ebx
80103f73:	e8 b3 0b 00 00       	call   80104b2b <swtch>
  mycpu()->intena = intena;
80103f78:	e8 43 fb ff ff       	call   80103ac0 <mycpu>
}
80103f7d:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80103f80:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103f86:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f89:	5b                   	pop    %ebx
80103f8a:	5e                   	pop    %esi
80103f8b:	5d                   	pop    %ebp
80103f8c:	c3                   	ret    
    panic("sched ptable.lock");
80103f8d:	83 ec 0c             	sub    $0xc,%esp
80103f90:	68 a8 7d 10 80       	push   $0x80107da8
80103f95:	e8 16 c5 ff ff       	call   801004b0 <panic>
    panic("sched interruptible");
80103f9a:	83 ec 0c             	sub    $0xc,%esp
80103f9d:	68 d4 7d 10 80       	push   $0x80107dd4
80103fa2:	e8 09 c5 ff ff       	call   801004b0 <panic>
    panic("sched running");
80103fa7:	83 ec 0c             	sub    $0xc,%esp
80103faa:	68 c6 7d 10 80       	push   $0x80107dc6
80103faf:	e8 fc c4 ff ff       	call   801004b0 <panic>
    panic("sched locks");
80103fb4:	83 ec 0c             	sub    $0xc,%esp
80103fb7:	68 ba 7d 10 80       	push   $0x80107dba
80103fbc:	e8 ef c4 ff ff       	call   801004b0 <panic>
80103fc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103fc8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103fcf:	90                   	nop

80103fd0 <exit>:
{
80103fd0:	55                   	push   %ebp
80103fd1:	89 e5                	mov    %esp,%ebp
80103fd3:	57                   	push   %edi
80103fd4:	56                   	push   %esi
80103fd5:	53                   	push   %ebx
80103fd6:	83 ec 0c             	sub    $0xc,%esp
  struct proc *curproc = myproc();
80103fd9:	e8 62 fb ff ff       	call   80103b40 <myproc>
  if(curproc == initproc)
80103fde:	39 05 74 4d 11 80    	cmp    %eax,0x80114d74
80103fe4:	0f 84 fd 00 00 00    	je     801040e7 <exit+0x117>
80103fea:	89 c3                	mov    %eax,%ebx
80103fec:	8d 70 2c             	lea    0x2c(%eax),%esi
80103fef:	8d 78 6c             	lea    0x6c(%eax),%edi
80103ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[fd]){
80103ff8:	8b 06                	mov    (%esi),%eax
80103ffa:	85 c0                	test   %eax,%eax
80103ffc:	74 12                	je     80104010 <exit+0x40>
      fileclose(curproc->ofile[fd]);
80103ffe:	83 ec 0c             	sub    $0xc,%esp
80104001:	50                   	push   %eax
80104002:	e8 19 d0 ff ff       	call   80101020 <fileclose>
      curproc->ofile[fd] = 0;
80104007:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010400d:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80104010:	83 c6 04             	add    $0x4,%esi
80104013:	39 f7                	cmp    %esi,%edi
80104015:	75 e1                	jne    80103ff8 <exit+0x28>
  begin_op();
80104017:	e8 04 ef ff ff       	call   80102f20 <begin_op>
  iput(curproc->cwd);
8010401c:	83 ec 0c             	sub    $0xc,%esp
8010401f:	ff 73 6c             	push   0x6c(%ebx)
80104022:	e8 b9 d9 ff ff       	call   801019e0 <iput>
  end_op();
80104027:	e8 64 ef ff ff       	call   80102f90 <end_op>
  curproc->cwd = 0;
8010402c:	c7 43 6c 00 00 00 00 	movl   $0x0,0x6c(%ebx)
  acquire(&ptable.lock);
80104033:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
8010403a:	e8 11 08 00 00       	call   80104850 <acquire>
  wakeup1(curproc->parent);
8010403f:	8b 53 18             	mov    0x18(%ebx),%edx
80104042:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104045:	b8 74 2d 11 80       	mov    $0x80112d74,%eax
8010404a:	eb 0e                	jmp    8010405a <exit+0x8a>
8010404c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104050:	83 e8 80             	sub    $0xffffff80,%eax
80104053:	3d 74 4d 11 80       	cmp    $0x80114d74,%eax
80104058:	74 1c                	je     80104076 <exit+0xa6>
    if(p->state == SLEEPING && p->chan == chan)
8010405a:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
8010405e:	75 f0                	jne    80104050 <exit+0x80>
80104060:	3b 50 24             	cmp    0x24(%eax),%edx
80104063:	75 eb                	jne    80104050 <exit+0x80>
      p->state = RUNNABLE;
80104065:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010406c:	83 e8 80             	sub    $0xffffff80,%eax
8010406f:	3d 74 4d 11 80       	cmp    $0x80114d74,%eax
80104074:	75 e4                	jne    8010405a <exit+0x8a>
      p->parent = initproc;
80104076:	8b 0d 74 4d 11 80    	mov    0x80114d74,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010407c:	ba 74 2d 11 80       	mov    $0x80112d74,%edx
80104081:	eb 10                	jmp    80104093 <exit+0xc3>
80104083:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104087:	90                   	nop
80104088:	83 ea 80             	sub    $0xffffff80,%edx
8010408b:	81 fa 74 4d 11 80    	cmp    $0x80114d74,%edx
80104091:	74 3b                	je     801040ce <exit+0xfe>
    if(p->parent == curproc){
80104093:	39 5a 18             	cmp    %ebx,0x18(%edx)
80104096:	75 f0                	jne    80104088 <exit+0xb8>
      if(p->state == ZOMBIE)
80104098:	83 7a 10 05          	cmpl   $0x5,0x10(%edx)
      p->parent = initproc;
8010409c:	89 4a 18             	mov    %ecx,0x18(%edx)
      if(p->state == ZOMBIE)
8010409f:	75 e7                	jne    80104088 <exit+0xb8>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040a1:	b8 74 2d 11 80       	mov    $0x80112d74,%eax
801040a6:	eb 12                	jmp    801040ba <exit+0xea>
801040a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801040af:	90                   	nop
801040b0:	83 e8 80             	sub    $0xffffff80,%eax
801040b3:	3d 74 4d 11 80       	cmp    $0x80114d74,%eax
801040b8:	74 ce                	je     80104088 <exit+0xb8>
    if(p->state == SLEEPING && p->chan == chan)
801040ba:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
801040be:	75 f0                	jne    801040b0 <exit+0xe0>
801040c0:	3b 48 24             	cmp    0x24(%eax),%ecx
801040c3:	75 eb                	jne    801040b0 <exit+0xe0>
      p->state = RUNNABLE;
801040c5:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
801040cc:	eb e2                	jmp    801040b0 <exit+0xe0>
  curproc->state = ZOMBIE;
801040ce:	c7 43 10 05 00 00 00 	movl   $0x5,0x10(%ebx)
  sched();
801040d5:	e8 36 fe ff ff       	call   80103f10 <sched>
  panic("zombie exit");
801040da:	83 ec 0c             	sub    $0xc,%esp
801040dd:	68 f5 7d 10 80       	push   $0x80107df5
801040e2:	e8 c9 c3 ff ff       	call   801004b0 <panic>
    panic("init exiting");
801040e7:	83 ec 0c             	sub    $0xc,%esp
801040ea:	68 e8 7d 10 80       	push   $0x80107de8
801040ef:	e8 bc c3 ff ff       	call   801004b0 <panic>
801040f4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801040fb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801040ff:	90                   	nop

80104100 <wait>:
{
80104100:	55                   	push   %ebp
80104101:	89 e5                	mov    %esp,%ebp
80104103:	56                   	push   %esi
80104104:	53                   	push   %ebx
  pushcli();
80104105:	e8 f6 05 00 00       	call   80104700 <pushcli>
  c = mycpu();
8010410a:	e8 b1 f9 ff ff       	call   80103ac0 <mycpu>
  p = c->proc;
8010410f:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80104115:	e8 36 06 00 00       	call   80104750 <popcli>
  acquire(&ptable.lock);
8010411a:	83 ec 0c             	sub    $0xc,%esp
8010411d:	68 40 2d 11 80       	push   $0x80112d40
80104122:	e8 29 07 00 00       	call   80104850 <acquire>
80104127:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010412a:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010412c:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
80104131:	eb 10                	jmp    80104143 <wait+0x43>
80104133:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104137:	90                   	nop
80104138:	83 eb 80             	sub    $0xffffff80,%ebx
8010413b:	81 fb 74 4d 11 80    	cmp    $0x80114d74,%ebx
80104141:	74 1b                	je     8010415e <wait+0x5e>
      if(p->parent != curproc)
80104143:	39 73 18             	cmp    %esi,0x18(%ebx)
80104146:	75 f0                	jne    80104138 <wait+0x38>
      if(p->state == ZOMBIE){
80104148:	83 7b 10 05          	cmpl   $0x5,0x10(%ebx)
8010414c:	74 62                	je     801041b0 <wait+0xb0>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010414e:	83 eb 80             	sub    $0xffffff80,%ebx
      havekids = 1;
80104151:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104156:	81 fb 74 4d 11 80    	cmp    $0x80114d74,%ebx
8010415c:	75 e5                	jne    80104143 <wait+0x43>
    if(!havekids || curproc->killed){
8010415e:	85 c0                	test   %eax,%eax
80104160:	0f 84 a9 00 00 00    	je     8010420f <wait+0x10f>
80104166:	8b 46 28             	mov    0x28(%esi),%eax
80104169:	85 c0                	test   %eax,%eax
8010416b:	0f 85 9e 00 00 00    	jne    8010420f <wait+0x10f>
  pushcli();
80104171:	e8 8a 05 00 00       	call   80104700 <pushcli>
  c = mycpu();
80104176:	e8 45 f9 ff ff       	call   80103ac0 <mycpu>
  p = c->proc;
8010417b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104181:	e8 ca 05 00 00       	call   80104750 <popcli>
  if(p == 0)
80104186:	85 db                	test   %ebx,%ebx
80104188:	0f 84 98 00 00 00    	je     80104226 <wait+0x126>
  p->chan = chan;
8010418e:	89 73 24             	mov    %esi,0x24(%ebx)
  p->state = SLEEPING;
80104191:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
80104198:	e8 73 fd ff ff       	call   80103f10 <sched>
  p->chan = 0;
8010419d:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
}
801041a4:	eb 84                	jmp    8010412a <wait+0x2a>
801041a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801041ad:	8d 76 00             	lea    0x0(%esi),%esi
        clean_swap(p->pgdir);
801041b0:	83 ec 0c             	sub    $0xc,%esp
801041b3:	ff 73 08             	push   0x8(%ebx)
801041b6:	e8 55 35 00 00       	call   80107710 <clean_swap>
        kfree(p->kstack);
801041bb:	5a                   	pop    %edx
        pid = p->pid;
801041bc:	8b 73 14             	mov    0x14(%ebx),%esi
        kfree(p->kstack);
801041bf:	ff 73 0c             	push   0xc(%ebx)
801041c2:	e8 29 e4 ff ff       	call   801025f0 <kfree>
        p->kstack = 0;
801041c7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        freevm(p->pgdir);
801041ce:	59                   	pop    %ecx
801041cf:	ff 73 08             	push   0x8(%ebx)
801041d2:	e8 a9 2f 00 00       	call   80107180 <freevm>
        p->pid = 0;
801041d7:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->parent = 0;
801041de:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->name[0] = 0;
801041e5:	c6 43 70 00          	movb   $0x0,0x70(%ebx)
        p->killed = 0;
801041e9:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
        p->state = UNUSED;
801041f0:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        release(&ptable.lock);
801041f7:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801041fe:	e8 ed 05 00 00       	call   801047f0 <release>
        return pid;
80104203:	83 c4 10             	add    $0x10,%esp
}
80104206:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104209:	89 f0                	mov    %esi,%eax
8010420b:	5b                   	pop    %ebx
8010420c:	5e                   	pop    %esi
8010420d:	5d                   	pop    %ebp
8010420e:	c3                   	ret    
      release(&ptable.lock);
8010420f:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80104212:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
80104217:	68 40 2d 11 80       	push   $0x80112d40
8010421c:	e8 cf 05 00 00       	call   801047f0 <release>
      return -1;
80104221:	83 c4 10             	add    $0x10,%esp
80104224:	eb e0                	jmp    80104206 <wait+0x106>
    panic("sleep");
80104226:	83 ec 0c             	sub    $0xc,%esp
80104229:	68 01 7e 10 80       	push   $0x80107e01
8010422e:	e8 7d c2 ff ff       	call   801004b0 <panic>
80104233:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010423a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104240 <yield>:
{
80104240:	55                   	push   %ebp
80104241:	89 e5                	mov    %esp,%ebp
80104243:	53                   	push   %ebx
80104244:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104247:	68 40 2d 11 80       	push   $0x80112d40
8010424c:	e8 ff 05 00 00       	call   80104850 <acquire>
  pushcli();
80104251:	e8 aa 04 00 00       	call   80104700 <pushcli>
  c = mycpu();
80104256:	e8 65 f8 ff ff       	call   80103ac0 <mycpu>
  p = c->proc;
8010425b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104261:	e8 ea 04 00 00       	call   80104750 <popcli>
  myproc()->state = RUNNABLE;
80104266:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  sched();
8010426d:	e8 9e fc ff ff       	call   80103f10 <sched>
  release(&ptable.lock);
80104272:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
80104279:	e8 72 05 00 00       	call   801047f0 <release>
}
8010427e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104281:	83 c4 10             	add    $0x10,%esp
80104284:	c9                   	leave  
80104285:	c3                   	ret    
80104286:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010428d:	8d 76 00             	lea    0x0(%esi),%esi

80104290 <sleep>:
{
80104290:	55                   	push   %ebp
80104291:	89 e5                	mov    %esp,%ebp
80104293:	57                   	push   %edi
80104294:	56                   	push   %esi
80104295:	53                   	push   %ebx
80104296:	83 ec 0c             	sub    $0xc,%esp
80104299:	8b 7d 08             	mov    0x8(%ebp),%edi
8010429c:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
8010429f:	e8 5c 04 00 00       	call   80104700 <pushcli>
  c = mycpu();
801042a4:	e8 17 f8 ff ff       	call   80103ac0 <mycpu>
  p = c->proc;
801042a9:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801042af:	e8 9c 04 00 00       	call   80104750 <popcli>
  if(p == 0)
801042b4:	85 db                	test   %ebx,%ebx
801042b6:	0f 84 87 00 00 00    	je     80104343 <sleep+0xb3>
  if(lk == 0)
801042bc:	85 f6                	test   %esi,%esi
801042be:	74 76                	je     80104336 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801042c0:	81 fe 40 2d 11 80    	cmp    $0x80112d40,%esi
801042c6:	74 50                	je     80104318 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
801042c8:	83 ec 0c             	sub    $0xc,%esp
801042cb:	68 40 2d 11 80       	push   $0x80112d40
801042d0:	e8 7b 05 00 00       	call   80104850 <acquire>
    release(lk);
801042d5:	89 34 24             	mov    %esi,(%esp)
801042d8:	e8 13 05 00 00       	call   801047f0 <release>
  p->chan = chan;
801042dd:	89 7b 24             	mov    %edi,0x24(%ebx)
  p->state = SLEEPING;
801042e0:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
801042e7:	e8 24 fc ff ff       	call   80103f10 <sched>
  p->chan = 0;
801042ec:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
    release(&ptable.lock);
801042f3:	c7 04 24 40 2d 11 80 	movl   $0x80112d40,(%esp)
801042fa:	e8 f1 04 00 00       	call   801047f0 <release>
    acquire(lk);
801042ff:	89 75 08             	mov    %esi,0x8(%ebp)
80104302:	83 c4 10             	add    $0x10,%esp
}
80104305:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104308:	5b                   	pop    %ebx
80104309:	5e                   	pop    %esi
8010430a:	5f                   	pop    %edi
8010430b:	5d                   	pop    %ebp
    acquire(lk);
8010430c:	e9 3f 05 00 00       	jmp    80104850 <acquire>
80104311:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  p->chan = chan;
80104318:	89 7b 24             	mov    %edi,0x24(%ebx)
  p->state = SLEEPING;
8010431b:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
80104322:	e8 e9 fb ff ff       	call   80103f10 <sched>
  p->chan = 0;
80104327:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
}
8010432e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104331:	5b                   	pop    %ebx
80104332:	5e                   	pop    %esi
80104333:	5f                   	pop    %edi
80104334:	5d                   	pop    %ebp
80104335:	c3                   	ret    
    panic("sleep without lk");
80104336:	83 ec 0c             	sub    $0xc,%esp
80104339:	68 07 7e 10 80       	push   $0x80107e07
8010433e:	e8 6d c1 ff ff       	call   801004b0 <panic>
    panic("sleep");
80104343:	83 ec 0c             	sub    $0xc,%esp
80104346:	68 01 7e 10 80       	push   $0x80107e01
8010434b:	e8 60 c1 ff ff       	call   801004b0 <panic>

80104350 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104350:	55                   	push   %ebp
80104351:	89 e5                	mov    %esp,%ebp
80104353:	53                   	push   %ebx
80104354:	83 ec 10             	sub    $0x10,%esp
80104357:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010435a:	68 40 2d 11 80       	push   $0x80112d40
8010435f:	e8 ec 04 00 00       	call   80104850 <acquire>
80104364:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104367:	b8 74 2d 11 80       	mov    $0x80112d74,%eax
8010436c:	eb 0c                	jmp    8010437a <wakeup+0x2a>
8010436e:	66 90                	xchg   %ax,%ax
80104370:	83 e8 80             	sub    $0xffffff80,%eax
80104373:	3d 74 4d 11 80       	cmp    $0x80114d74,%eax
80104378:	74 1c                	je     80104396 <wakeup+0x46>
    if(p->state == SLEEPING && p->chan == chan)
8010437a:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
8010437e:	75 f0                	jne    80104370 <wakeup+0x20>
80104380:	3b 58 24             	cmp    0x24(%eax),%ebx
80104383:	75 eb                	jne    80104370 <wakeup+0x20>
      p->state = RUNNABLE;
80104385:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010438c:	83 e8 80             	sub    $0xffffff80,%eax
8010438f:	3d 74 4d 11 80       	cmp    $0x80114d74,%eax
80104394:	75 e4                	jne    8010437a <wakeup+0x2a>
  wakeup1(chan);
  release(&ptable.lock);
80104396:	c7 45 08 40 2d 11 80 	movl   $0x80112d40,0x8(%ebp)
}
8010439d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043a0:	c9                   	leave  
  release(&ptable.lock);
801043a1:	e9 4a 04 00 00       	jmp    801047f0 <release>
801043a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801043ad:	8d 76 00             	lea    0x0(%esi),%esi

801043b0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801043b0:	55                   	push   %ebp
801043b1:	89 e5                	mov    %esp,%ebp
801043b3:	53                   	push   %ebx
801043b4:	83 ec 10             	sub    $0x10,%esp
801043b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801043ba:	68 40 2d 11 80       	push   $0x80112d40
801043bf:	e8 8c 04 00 00       	call   80104850 <acquire>
801043c4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043c7:	b8 74 2d 11 80       	mov    $0x80112d74,%eax
801043cc:	eb 0c                	jmp    801043da <kill+0x2a>
801043ce:	66 90                	xchg   %ax,%ax
801043d0:	83 e8 80             	sub    $0xffffff80,%eax
801043d3:	3d 74 4d 11 80       	cmp    $0x80114d74,%eax
801043d8:	74 36                	je     80104410 <kill+0x60>
    if(p->pid == pid){
801043da:	39 58 14             	cmp    %ebx,0x14(%eax)
801043dd:	75 f1                	jne    801043d0 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801043df:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
      p->killed = 1;
801043e3:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      if(p->state == SLEEPING)
801043ea:	75 07                	jne    801043f3 <kill+0x43>
        p->state = RUNNABLE;
801043ec:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
      release(&ptable.lock);
801043f3:	83 ec 0c             	sub    $0xc,%esp
801043f6:	68 40 2d 11 80       	push   $0x80112d40
801043fb:	e8 f0 03 00 00       	call   801047f0 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
80104400:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0;
80104403:	83 c4 10             	add    $0x10,%esp
80104406:	31 c0                	xor    %eax,%eax
}
80104408:	c9                   	leave  
80104409:	c3                   	ret    
8010440a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
80104410:	83 ec 0c             	sub    $0xc,%esp
80104413:	68 40 2d 11 80       	push   $0x80112d40
80104418:	e8 d3 03 00 00       	call   801047f0 <release>
}
8010441d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80104420:	83 c4 10             	add    $0x10,%esp
80104423:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104428:	c9                   	leave  
80104429:	c3                   	ret    
8010442a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104430 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104430:	55                   	push   %ebp
80104431:	89 e5                	mov    %esp,%ebp
80104433:	57                   	push   %edi
80104434:	56                   	push   %esi
80104435:	8d 75 e8             	lea    -0x18(%ebp),%esi
80104438:	53                   	push   %ebx
80104439:	bb e4 2d 11 80       	mov    $0x80112de4,%ebx
8010443e:	83 ec 3c             	sub    $0x3c,%esp
80104441:	eb 24                	jmp    80104467 <procdump+0x37>
80104443:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104447:	90                   	nop
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104448:	83 ec 0c             	sub    $0xc,%esp
8010444b:	68 07 82 10 80       	push   $0x80108207
80104450:	e8 7b c3 ff ff       	call   801007d0 <cprintf>
80104455:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104458:	83 eb 80             	sub    $0xffffff80,%ebx
8010445b:	81 fb e4 4d 11 80    	cmp    $0x80114de4,%ebx
80104461:	0f 84 81 00 00 00    	je     801044e8 <procdump+0xb8>
    if(p->state == UNUSED)
80104467:	8b 43 a0             	mov    -0x60(%ebx),%eax
8010446a:	85 c0                	test   %eax,%eax
8010446c:	74 ea                	je     80104458 <procdump+0x28>
      state = "???";
8010446e:	ba 18 7e 10 80       	mov    $0x80107e18,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104473:	83 f8 05             	cmp    $0x5,%eax
80104476:	77 11                	ja     80104489 <procdump+0x59>
80104478:	8b 14 85 9c 7e 10 80 	mov    -0x7fef8164(,%eax,4),%edx
      state = "???";
8010447f:	b8 18 7e 10 80       	mov    $0x80107e18,%eax
80104484:	85 d2                	test   %edx,%edx
80104486:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
80104489:	53                   	push   %ebx
8010448a:	52                   	push   %edx
8010448b:	ff 73 a4             	push   -0x5c(%ebx)
8010448e:	68 1c 7e 10 80       	push   $0x80107e1c
80104493:	e8 38 c3 ff ff       	call   801007d0 <cprintf>
    if(p->state == SLEEPING){
80104498:	83 c4 10             	add    $0x10,%esp
8010449b:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
8010449f:	75 a7                	jne    80104448 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801044a1:	83 ec 08             	sub    $0x8,%esp
801044a4:	8d 45 c0             	lea    -0x40(%ebp),%eax
801044a7:	8d 7d c0             	lea    -0x40(%ebp),%edi
801044aa:	50                   	push   %eax
801044ab:	8b 43 b0             	mov    -0x50(%ebx),%eax
801044ae:	8b 40 0c             	mov    0xc(%eax),%eax
801044b1:	83 c0 08             	add    $0x8,%eax
801044b4:	50                   	push   %eax
801044b5:	e8 e6 01 00 00       	call   801046a0 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801044ba:	83 c4 10             	add    $0x10,%esp
801044bd:	8d 76 00             	lea    0x0(%esi),%esi
801044c0:	8b 17                	mov    (%edi),%edx
801044c2:	85 d2                	test   %edx,%edx
801044c4:	74 82                	je     80104448 <procdump+0x18>
        cprintf(" %p", pc[i]);
801044c6:	83 ec 08             	sub    $0x8,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801044c9:	83 c7 04             	add    $0x4,%edi
        cprintf(" %p", pc[i]);
801044cc:	52                   	push   %edx
801044cd:	68 61 78 10 80       	push   $0x80107861
801044d2:	e8 f9 c2 ff ff       	call   801007d0 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801044d7:	83 c4 10             	add    $0x10,%esp
801044da:	39 fe                	cmp    %edi,%esi
801044dc:	75 e2                	jne    801044c0 <procdump+0x90>
801044de:	e9 65 ff ff ff       	jmp    80104448 <procdump+0x18>
801044e3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801044e7:	90                   	nop
  }
}
801044e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801044eb:	5b                   	pop    %ebx
801044ec:	5e                   	pop    %esi
801044ed:	5f                   	pop    %edi
801044ee:	5d                   	pop    %ebp
801044ef:	c3                   	ret    

801044f0 <victim_proc>:

struct proc * victim_proc(){
801044f0:	55                   	push   %ebp
801044f1:	89 e5                	mov    %esp,%ebp
801044f3:	53                   	push   %ebx
    struct proc *p;
    uint max_rss = 0;
    struct proc *victim_proc = ptable.proc;
801044f4:	bb 74 2d 11 80       	mov    $0x80112d74,%ebx
struct proc * victim_proc(){
801044f9:	83 ec 10             	sub    $0x10,%esp
    acquire(&ptable.lock);
801044fc:	68 40 2d 11 80       	push   $0x80112d40
80104501:	e8 4a 03 00 00       	call   80104850 <acquire>
80104506:	83 c4 10             	add    $0x10,%esp
    uint max_rss = 0;
80104509:	31 c9                	xor    %ecx,%ecx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010450b:	89 d8                	mov    %ebx,%eax
8010450d:	eb 16                	jmp    80104525 <victim_proc+0x35>
8010450f:	90                   	nop
        if(p->rss > max_rss || (p->rss==max_rss && p->pid< victim_proc->pid)){
80104510:	75 09                	jne    8010451b <victim_proc+0x2b>
80104512:	8b 53 14             	mov    0x14(%ebx),%edx
80104515:	39 50 14             	cmp    %edx,0x14(%eax)
80104518:	0f 4c d8             	cmovl  %eax,%ebx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010451b:	83 e8 80             	sub    $0xffffff80,%eax
8010451e:	3d 74 4d 11 80       	cmp    $0x80114d74,%eax
80104523:	74 15                	je     8010453a <victim_proc+0x4a>
        if(p->rss > max_rss || (p->rss==max_rss && p->pid< victim_proc->pid)){
80104525:	8b 50 04             	mov    0x4(%eax),%edx
80104528:	39 ca                	cmp    %ecx,%edx
8010452a:	76 e4                	jbe    80104510 <victim_proc+0x20>
8010452c:	89 c3                	mov    %eax,%ebx
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010452e:	83 e8 80             	sub    $0xffffff80,%eax
80104531:	89 d1                	mov    %edx,%ecx
80104533:	3d 74 4d 11 80       	cmp    $0x80114d74,%eax
80104538:	75 eb                	jne    80104525 <victim_proc+0x35>
            victim_proc = p;
            max_rss = p->rss;
        }
    }
    release(&ptable.lock);
8010453a:	83 ec 0c             	sub    $0xc,%esp
8010453d:	68 40 2d 11 80       	push   $0x80112d40
80104542:	e8 a9 02 00 00       	call   801047f0 <release>
    return victim_proc;
}
80104547:	89 d8                	mov    %ebx,%eax
80104549:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010454c:	c9                   	leave  
8010454d:	c3                   	ret    
8010454e:	66 90                	xchg   %ax,%ax

80104550 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104550:	55                   	push   %ebp
80104551:	89 e5                	mov    %esp,%ebp
80104553:	53                   	push   %ebx
80104554:	83 ec 0c             	sub    $0xc,%esp
80104557:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010455a:	68 b4 7e 10 80       	push   $0x80107eb4
8010455f:	8d 43 04             	lea    0x4(%ebx),%eax
80104562:	50                   	push   %eax
80104563:	e8 18 01 00 00       	call   80104680 <initlock>
  lk->name = name;
80104568:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
8010456b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
80104571:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
80104574:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
8010457b:	89 43 38             	mov    %eax,0x38(%ebx)
}
8010457e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104581:	c9                   	leave  
80104582:	c3                   	ret    
80104583:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010458a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104590 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104590:	55                   	push   %ebp
80104591:	89 e5                	mov    %esp,%ebp
80104593:	56                   	push   %esi
80104594:	53                   	push   %ebx
80104595:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104598:	8d 73 04             	lea    0x4(%ebx),%esi
8010459b:	83 ec 0c             	sub    $0xc,%esp
8010459e:	56                   	push   %esi
8010459f:	e8 ac 02 00 00       	call   80104850 <acquire>
  while (lk->locked) {
801045a4:	8b 13                	mov    (%ebx),%edx
801045a6:	83 c4 10             	add    $0x10,%esp
801045a9:	85 d2                	test   %edx,%edx
801045ab:	74 16                	je     801045c3 <acquiresleep+0x33>
801045ad:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
801045b0:	83 ec 08             	sub    $0x8,%esp
801045b3:	56                   	push   %esi
801045b4:	53                   	push   %ebx
801045b5:	e8 d6 fc ff ff       	call   80104290 <sleep>
  while (lk->locked) {
801045ba:	8b 03                	mov    (%ebx),%eax
801045bc:	83 c4 10             	add    $0x10,%esp
801045bf:	85 c0                	test   %eax,%eax
801045c1:	75 ed                	jne    801045b0 <acquiresleep+0x20>
  }
  lk->locked = 1;
801045c3:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
801045c9:	e8 72 f5 ff ff       	call   80103b40 <myproc>
801045ce:	8b 40 14             	mov    0x14(%eax),%eax
801045d1:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
801045d4:	89 75 08             	mov    %esi,0x8(%ebp)
}
801045d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801045da:	5b                   	pop    %ebx
801045db:	5e                   	pop    %esi
801045dc:	5d                   	pop    %ebp
  release(&lk->lk);
801045dd:	e9 0e 02 00 00       	jmp    801047f0 <release>
801045e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801045e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801045f0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801045f0:	55                   	push   %ebp
801045f1:	89 e5                	mov    %esp,%ebp
801045f3:	56                   	push   %esi
801045f4:	53                   	push   %ebx
801045f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801045f8:	8d 73 04             	lea    0x4(%ebx),%esi
801045fb:	83 ec 0c             	sub    $0xc,%esp
801045fe:	56                   	push   %esi
801045ff:	e8 4c 02 00 00       	call   80104850 <acquire>
  lk->locked = 0;
80104604:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010460a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104611:	89 1c 24             	mov    %ebx,(%esp)
80104614:	e8 37 fd ff ff       	call   80104350 <wakeup>
  release(&lk->lk);
80104619:	89 75 08             	mov    %esi,0x8(%ebp)
8010461c:	83 c4 10             	add    $0x10,%esp
}
8010461f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104622:	5b                   	pop    %ebx
80104623:	5e                   	pop    %esi
80104624:	5d                   	pop    %ebp
  release(&lk->lk);
80104625:	e9 c6 01 00 00       	jmp    801047f0 <release>
8010462a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104630 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104630:	55                   	push   %ebp
80104631:	89 e5                	mov    %esp,%ebp
80104633:	57                   	push   %edi
80104634:	31 ff                	xor    %edi,%edi
80104636:	56                   	push   %esi
80104637:	53                   	push   %ebx
80104638:	83 ec 18             	sub    $0x18,%esp
8010463b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
8010463e:	8d 73 04             	lea    0x4(%ebx),%esi
80104641:	56                   	push   %esi
80104642:	e8 09 02 00 00       	call   80104850 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80104647:	8b 03                	mov    (%ebx),%eax
80104649:	83 c4 10             	add    $0x10,%esp
8010464c:	85 c0                	test   %eax,%eax
8010464e:	75 18                	jne    80104668 <holdingsleep+0x38>
  release(&lk->lk);
80104650:	83 ec 0c             	sub    $0xc,%esp
80104653:	56                   	push   %esi
80104654:	e8 97 01 00 00       	call   801047f0 <release>
  return r;
}
80104659:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010465c:	89 f8                	mov    %edi,%eax
8010465e:	5b                   	pop    %ebx
8010465f:	5e                   	pop    %esi
80104660:	5f                   	pop    %edi
80104661:	5d                   	pop    %ebp
80104662:	c3                   	ret    
80104663:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104667:	90                   	nop
  r = lk->locked && (lk->pid == myproc()->pid);
80104668:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
8010466b:	e8 d0 f4 ff ff       	call   80103b40 <myproc>
80104670:	39 58 14             	cmp    %ebx,0x14(%eax)
80104673:	0f 94 c0             	sete   %al
80104676:	0f b6 c0             	movzbl %al,%eax
80104679:	89 c7                	mov    %eax,%edi
8010467b:	eb d3                	jmp    80104650 <holdingsleep+0x20>
8010467d:	66 90                	xchg   %ax,%ax
8010467f:	90                   	nop

80104680 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104680:	55                   	push   %ebp
80104681:	89 e5                	mov    %esp,%ebp
80104683:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104686:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
80104689:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
8010468f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
80104692:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104699:	5d                   	pop    %ebp
8010469a:	c3                   	ret    
8010469b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010469f:	90                   	nop

801046a0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801046a0:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801046a1:	31 d2                	xor    %edx,%edx
{
801046a3:	89 e5                	mov    %esp,%ebp
801046a5:	53                   	push   %ebx
  ebp = (uint*)v - 2;
801046a6:	8b 45 08             	mov    0x8(%ebp),%eax
{
801046a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
801046ac:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
801046af:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801046b0:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
801046b6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801046bc:	77 1a                	ja     801046d8 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
801046be:	8b 58 04             	mov    0x4(%eax),%ebx
801046c1:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
801046c4:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
801046c7:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
801046c9:	83 fa 0a             	cmp    $0xa,%edx
801046cc:	75 e2                	jne    801046b0 <getcallerpcs+0x10>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
801046ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801046d1:	c9                   	leave  
801046d2:	c3                   	ret    
801046d3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801046d7:	90                   	nop
  for(; i < 10; i++)
801046d8:	8d 04 91             	lea    (%ecx,%edx,4),%eax
801046db:	8d 51 28             	lea    0x28(%ecx),%edx
801046de:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
801046e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801046e6:	83 c0 04             	add    $0x4,%eax
801046e9:	39 d0                	cmp    %edx,%eax
801046eb:	75 f3                	jne    801046e0 <getcallerpcs+0x40>
}
801046ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801046f0:	c9                   	leave  
801046f1:	c3                   	ret    
801046f2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801046f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104700 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104700:	55                   	push   %ebp
80104701:	89 e5                	mov    %esp,%ebp
80104703:	53                   	push   %ebx
80104704:	83 ec 04             	sub    $0x4,%esp
80104707:	9c                   	pushf  
80104708:	5b                   	pop    %ebx
  asm volatile("cli");
80104709:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
8010470a:	e8 b1 f3 ff ff       	call   80103ac0 <mycpu>
8010470f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104715:	85 c0                	test   %eax,%eax
80104717:	74 17                	je     80104730 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80104719:	e8 a2 f3 ff ff       	call   80103ac0 <mycpu>
8010471e:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
  
}
80104725:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104728:	c9                   	leave  
80104729:	c3                   	ret    
8010472a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    mycpu()->intena = eflags & FL_IF;
80104730:	e8 8b f3 ff ff       	call   80103ac0 <mycpu>
80104735:	81 e3 00 02 00 00    	and    $0x200,%ebx
8010473b:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80104741:	eb d6                	jmp    80104719 <pushcli+0x19>
80104743:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010474a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104750 <popcli>:

void
popcli(void)
{
80104750:	55                   	push   %ebp
80104751:	89 e5                	mov    %esp,%ebp
80104753:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104756:	9c                   	pushf  
80104757:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104758:	f6 c4 02             	test   $0x2,%ah
8010475b:	75 35                	jne    80104792 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
8010475d:	e8 5e f3 ff ff       	call   80103ac0 <mycpu>
80104762:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
80104769:	78 34                	js     8010479f <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010476b:	e8 50 f3 ff ff       	call   80103ac0 <mycpu>
80104770:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104776:	85 d2                	test   %edx,%edx
80104778:	74 06                	je     80104780 <popcli+0x30>
    sti();
}
8010477a:	c9                   	leave  
8010477b:	c3                   	ret    
8010477c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104780:	e8 3b f3 ff ff       	call   80103ac0 <mycpu>
80104785:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010478b:	85 c0                	test   %eax,%eax
8010478d:	74 eb                	je     8010477a <popcli+0x2a>
  asm volatile("sti");
8010478f:	fb                   	sti    
}
80104790:	c9                   	leave  
80104791:	c3                   	ret    
    panic("popcli - interruptible");
80104792:	83 ec 0c             	sub    $0xc,%esp
80104795:	68 bf 7e 10 80       	push   $0x80107ebf
8010479a:	e8 11 bd ff ff       	call   801004b0 <panic>
    panic("popcli");
8010479f:	83 ec 0c             	sub    $0xc,%esp
801047a2:	68 d6 7e 10 80       	push   $0x80107ed6
801047a7:	e8 04 bd ff ff       	call   801004b0 <panic>
801047ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801047b0 <holding>:
{
801047b0:	55                   	push   %ebp
801047b1:	89 e5                	mov    %esp,%ebp
801047b3:	56                   	push   %esi
801047b4:	53                   	push   %ebx
801047b5:	8b 75 08             	mov    0x8(%ebp),%esi
801047b8:	31 db                	xor    %ebx,%ebx
  pushcli();
801047ba:	e8 41 ff ff ff       	call   80104700 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801047bf:	8b 06                	mov    (%esi),%eax
801047c1:	85 c0                	test   %eax,%eax
801047c3:	75 0b                	jne    801047d0 <holding+0x20>
  popcli();
801047c5:	e8 86 ff ff ff       	call   80104750 <popcli>
}
801047ca:	89 d8                	mov    %ebx,%eax
801047cc:	5b                   	pop    %ebx
801047cd:	5e                   	pop    %esi
801047ce:	5d                   	pop    %ebp
801047cf:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
801047d0:	8b 5e 08             	mov    0x8(%esi),%ebx
801047d3:	e8 e8 f2 ff ff       	call   80103ac0 <mycpu>
801047d8:	39 c3                	cmp    %eax,%ebx
801047da:	0f 94 c3             	sete   %bl
  popcli();
801047dd:	e8 6e ff ff ff       	call   80104750 <popcli>
  r = lock->locked && lock->cpu == mycpu();
801047e2:	0f b6 db             	movzbl %bl,%ebx
}
801047e5:	89 d8                	mov    %ebx,%eax
801047e7:	5b                   	pop    %ebx
801047e8:	5e                   	pop    %esi
801047e9:	5d                   	pop    %ebp
801047ea:	c3                   	ret    
801047eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801047ef:	90                   	nop

801047f0 <release>:
{
801047f0:	55                   	push   %ebp
801047f1:	89 e5                	mov    %esp,%ebp
801047f3:	56                   	push   %esi
801047f4:	53                   	push   %ebx
801047f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
801047f8:	e8 03 ff ff ff       	call   80104700 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801047fd:	8b 03                	mov    (%ebx),%eax
801047ff:	85 c0                	test   %eax,%eax
80104801:	75 15                	jne    80104818 <release+0x28>
  popcli();
80104803:	e8 48 ff ff ff       	call   80104750 <popcli>
    panic("release");
80104808:	83 ec 0c             	sub    $0xc,%esp
8010480b:	68 dd 7e 10 80       	push   $0x80107edd
80104810:	e8 9b bc ff ff       	call   801004b0 <panic>
80104815:	8d 76 00             	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80104818:	8b 73 08             	mov    0x8(%ebx),%esi
8010481b:	e8 a0 f2 ff ff       	call   80103ac0 <mycpu>
80104820:	39 c6                	cmp    %eax,%esi
80104822:	75 df                	jne    80104803 <release+0x13>
  popcli();
80104824:	e8 27 ff ff ff       	call   80104750 <popcli>
  lk->pcs[0] = 0;
80104829:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104830:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80104837:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010483c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
80104842:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104845:	5b                   	pop    %ebx
80104846:	5e                   	pop    %esi
80104847:	5d                   	pop    %ebp
  popcli();
80104848:	e9 03 ff ff ff       	jmp    80104750 <popcli>
8010484d:	8d 76 00             	lea    0x0(%esi),%esi

80104850 <acquire>:
{
80104850:	55                   	push   %ebp
80104851:	89 e5                	mov    %esp,%ebp
80104853:	53                   	push   %ebx
80104854:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104857:	e8 a4 fe ff ff       	call   80104700 <pushcli>
  if(holding(lk))
8010485c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
8010485f:	e8 9c fe ff ff       	call   80104700 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104864:	8b 03                	mov    (%ebx),%eax
80104866:	85 c0                	test   %eax,%eax
80104868:	75 7e                	jne    801048e8 <acquire+0x98>
  popcli();
8010486a:	e8 e1 fe ff ff       	call   80104750 <popcli>
  asm volatile("lock; xchgl %0, %1" :
8010486f:	b9 01 00 00 00       	mov    $0x1,%ecx
80104874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(xchg(&lk->locked, 1) != 0)
80104878:	8b 55 08             	mov    0x8(%ebp),%edx
8010487b:	89 c8                	mov    %ecx,%eax
8010487d:	f0 87 02             	lock xchg %eax,(%edx)
80104880:	85 c0                	test   %eax,%eax
80104882:	75 f4                	jne    80104878 <acquire+0x28>
  __sync_synchronize();
80104884:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104889:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010488c:	e8 2f f2 ff ff       	call   80103ac0 <mycpu>
  getcallerpcs(&lk, lk->pcs);
80104891:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ebp = (uint*)v - 2;
80104894:	89 ea                	mov    %ebp,%edx
  lk->cpu = mycpu();
80104896:	89 43 08             	mov    %eax,0x8(%ebx)
  for(i = 0; i < 10; i++){
80104899:	31 c0                	xor    %eax,%eax
8010489b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010489f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801048a0:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
801048a6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801048ac:	77 1a                	ja     801048c8 <acquire+0x78>
    pcs[i] = ebp[1];     // saved %eip
801048ae:	8b 5a 04             	mov    0x4(%edx),%ebx
801048b1:	89 5c 81 0c          	mov    %ebx,0xc(%ecx,%eax,4)
  for(i = 0; i < 10; i++){
801048b5:	83 c0 01             	add    $0x1,%eax
    ebp = (uint*)ebp[0]; // saved %ebp
801048b8:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
801048ba:	83 f8 0a             	cmp    $0xa,%eax
801048bd:	75 e1                	jne    801048a0 <acquire+0x50>
}
801048bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048c2:	c9                   	leave  
801048c3:	c3                   	ret    
801048c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(; i < 10; i++)
801048c8:	8d 44 81 0c          	lea    0xc(%ecx,%eax,4),%eax
801048cc:	8d 51 34             	lea    0x34(%ecx),%edx
801048cf:	90                   	nop
    pcs[i] = 0;
801048d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801048d6:	83 c0 04             	add    $0x4,%eax
801048d9:	39 c2                	cmp    %eax,%edx
801048db:	75 f3                	jne    801048d0 <acquire+0x80>
}
801048dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048e0:	c9                   	leave  
801048e1:	c3                   	ret    
801048e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
801048e8:	8b 5b 08             	mov    0x8(%ebx),%ebx
801048eb:	e8 d0 f1 ff ff       	call   80103ac0 <mycpu>
801048f0:	39 c3                	cmp    %eax,%ebx
801048f2:	0f 85 72 ff ff ff    	jne    8010486a <acquire+0x1a>
  popcli();
801048f8:	e8 53 fe ff ff       	call   80104750 <popcli>
    panic("acquire");
801048fd:	83 ec 0c             	sub    $0xc,%esp
80104900:	68 e5 7e 10 80       	push   $0x80107ee5
80104905:	e8 a6 bb ff ff       	call   801004b0 <panic>
8010490a:	66 90                	xchg   %ax,%ax
8010490c:	66 90                	xchg   %ax,%ax
8010490e:	66 90                	xchg   %ax,%ax

80104910 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104910:	55                   	push   %ebp
80104911:	89 e5                	mov    %esp,%ebp
80104913:	57                   	push   %edi
80104914:	8b 55 08             	mov    0x8(%ebp),%edx
80104917:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010491a:	53                   	push   %ebx
8010491b:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
8010491e:	89 d7                	mov    %edx,%edi
80104920:	09 cf                	or     %ecx,%edi
80104922:	83 e7 03             	and    $0x3,%edi
80104925:	75 29                	jne    80104950 <memset+0x40>
    c &= 0xFF;
80104927:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010492a:	c1 e0 18             	shl    $0x18,%eax
8010492d:	89 fb                	mov    %edi,%ebx
8010492f:	c1 e9 02             	shr    $0x2,%ecx
80104932:	c1 e3 10             	shl    $0x10,%ebx
80104935:	09 d8                	or     %ebx,%eax
80104937:	09 f8                	or     %edi,%eax
80104939:	c1 e7 08             	shl    $0x8,%edi
8010493c:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
8010493e:	89 d7                	mov    %edx,%edi
80104940:	fc                   	cld    
80104941:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80104943:	5b                   	pop    %ebx
80104944:	89 d0                	mov    %edx,%eax
80104946:	5f                   	pop    %edi
80104947:	5d                   	pop    %ebp
80104948:	c3                   	ret    
80104949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("cld; rep stosb" :
80104950:	89 d7                	mov    %edx,%edi
80104952:	fc                   	cld    
80104953:	f3 aa                	rep stos %al,%es:(%edi)
80104955:	5b                   	pop    %ebx
80104956:	89 d0                	mov    %edx,%eax
80104958:	5f                   	pop    %edi
80104959:	5d                   	pop    %ebp
8010495a:	c3                   	ret    
8010495b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010495f:	90                   	nop

80104960 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104960:	55                   	push   %ebp
80104961:	89 e5                	mov    %esp,%ebp
80104963:	56                   	push   %esi
80104964:	8b 75 10             	mov    0x10(%ebp),%esi
80104967:	8b 55 08             	mov    0x8(%ebp),%edx
8010496a:	53                   	push   %ebx
8010496b:	8b 45 0c             	mov    0xc(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010496e:	85 f6                	test   %esi,%esi
80104970:	74 2e                	je     801049a0 <memcmp+0x40>
80104972:	01 c6                	add    %eax,%esi
80104974:	eb 14                	jmp    8010498a <memcmp+0x2a>
80104976:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010497d:	8d 76 00             	lea    0x0(%esi),%esi
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104980:	83 c0 01             	add    $0x1,%eax
80104983:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104986:	39 f0                	cmp    %esi,%eax
80104988:	74 16                	je     801049a0 <memcmp+0x40>
    if(*s1 != *s2)
8010498a:	0f b6 0a             	movzbl (%edx),%ecx
8010498d:	0f b6 18             	movzbl (%eax),%ebx
80104990:	38 d9                	cmp    %bl,%cl
80104992:	74 ec                	je     80104980 <memcmp+0x20>
      return *s1 - *s2;
80104994:	0f b6 c1             	movzbl %cl,%eax
80104997:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104999:	5b                   	pop    %ebx
8010499a:	5e                   	pop    %esi
8010499b:	5d                   	pop    %ebp
8010499c:	c3                   	ret    
8010499d:	8d 76 00             	lea    0x0(%esi),%esi
801049a0:	5b                   	pop    %ebx
  return 0;
801049a1:	31 c0                	xor    %eax,%eax
}
801049a3:	5e                   	pop    %esi
801049a4:	5d                   	pop    %ebp
801049a5:	c3                   	ret    
801049a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801049ad:	8d 76 00             	lea    0x0(%esi),%esi

801049b0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801049b0:	55                   	push   %ebp
801049b1:	89 e5                	mov    %esp,%ebp
801049b3:	57                   	push   %edi
801049b4:	8b 55 08             	mov    0x8(%ebp),%edx
801049b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
801049ba:	56                   	push   %esi
801049bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801049be:	39 d6                	cmp    %edx,%esi
801049c0:	73 26                	jae    801049e8 <memmove+0x38>
801049c2:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
801049c5:	39 fa                	cmp    %edi,%edx
801049c7:	73 1f                	jae    801049e8 <memmove+0x38>
801049c9:	8d 41 ff             	lea    -0x1(%ecx),%eax
    s += n;
    d += n;
    while(n-- > 0)
801049cc:	85 c9                	test   %ecx,%ecx
801049ce:	74 0c                	je     801049dc <memmove+0x2c>
      *--d = *--s;
801049d0:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
801049d4:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
801049d7:	83 e8 01             	sub    $0x1,%eax
801049da:	73 f4                	jae    801049d0 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;
  return dst;
}
801049dc:	5e                   	pop    %esi
801049dd:	89 d0                	mov    %edx,%eax
801049df:	5f                   	pop    %edi
801049e0:	5d                   	pop    %ebp
801049e1:	c3                   	ret    
801049e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(n-- > 0)
801049e8:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
801049eb:	89 d7                	mov    %edx,%edi
801049ed:	85 c9                	test   %ecx,%ecx
801049ef:	74 eb                	je     801049dc <memmove+0x2c>
801049f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
801049f8:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
801049f9:	39 c6                	cmp    %eax,%esi
801049fb:	75 fb                	jne    801049f8 <memmove+0x48>
}
801049fd:	5e                   	pop    %esi
801049fe:	89 d0                	mov    %edx,%eax
80104a00:	5f                   	pop    %edi
80104a01:	5d                   	pop    %ebp
80104a02:	c3                   	ret    
80104a03:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104a10 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80104a10:	eb 9e                	jmp    801049b0 <memmove>
80104a12:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104a20 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104a20:	55                   	push   %ebp
80104a21:	89 e5                	mov    %esp,%ebp
80104a23:	56                   	push   %esi
80104a24:	8b 75 10             	mov    0x10(%ebp),%esi
80104a27:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a2a:	53                   	push   %ebx
80104a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(n > 0 && *p && *p == *q)
80104a2e:	85 f6                	test   %esi,%esi
80104a30:	74 2e                	je     80104a60 <strncmp+0x40>
80104a32:	01 d6                	add    %edx,%esi
80104a34:	eb 18                	jmp    80104a4e <strncmp+0x2e>
80104a36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a3d:	8d 76 00             	lea    0x0(%esi),%esi
80104a40:	38 d8                	cmp    %bl,%al
80104a42:	75 14                	jne    80104a58 <strncmp+0x38>
    n--, p++, q++;
80104a44:	83 c2 01             	add    $0x1,%edx
80104a47:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104a4a:	39 f2                	cmp    %esi,%edx
80104a4c:	74 12                	je     80104a60 <strncmp+0x40>
80104a4e:	0f b6 01             	movzbl (%ecx),%eax
80104a51:	0f b6 1a             	movzbl (%edx),%ebx
80104a54:	84 c0                	test   %al,%al
80104a56:	75 e8                	jne    80104a40 <strncmp+0x20>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
80104a58:	29 d8                	sub    %ebx,%eax
}
80104a5a:	5b                   	pop    %ebx
80104a5b:	5e                   	pop    %esi
80104a5c:	5d                   	pop    %ebp
80104a5d:	c3                   	ret    
80104a5e:	66 90                	xchg   %ax,%ax
80104a60:	5b                   	pop    %ebx
    return 0;
80104a61:	31 c0                	xor    %eax,%eax
}
80104a63:	5e                   	pop    %esi
80104a64:	5d                   	pop    %ebp
80104a65:	c3                   	ret    
80104a66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a6d:	8d 76 00             	lea    0x0(%esi),%esi

80104a70 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104a70:	55                   	push   %ebp
80104a71:	89 e5                	mov    %esp,%ebp
80104a73:	57                   	push   %edi
80104a74:	56                   	push   %esi
80104a75:	8b 75 08             	mov    0x8(%ebp),%esi
80104a78:	53                   	push   %ebx
80104a79:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104a7c:	89 f0                	mov    %esi,%eax
80104a7e:	eb 15                	jmp    80104a95 <strncpy+0x25>
80104a80:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104a84:	8b 7d 0c             	mov    0xc(%ebp),%edi
80104a87:	83 c0 01             	add    $0x1,%eax
80104a8a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
80104a8e:	88 50 ff             	mov    %dl,-0x1(%eax)
80104a91:	84 d2                	test   %dl,%dl
80104a93:	74 09                	je     80104a9e <strncpy+0x2e>
80104a95:	89 cb                	mov    %ecx,%ebx
80104a97:	83 e9 01             	sub    $0x1,%ecx
80104a9a:	85 db                	test   %ebx,%ebx
80104a9c:	7f e2                	jg     80104a80 <strncpy+0x10>
    ;
  while(n-- > 0)
80104a9e:	89 c2                	mov    %eax,%edx
80104aa0:	85 c9                	test   %ecx,%ecx
80104aa2:	7e 17                	jle    80104abb <strncpy+0x4b>
80104aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104aa8:	83 c2 01             	add    $0x1,%edx
80104aab:	89 c1                	mov    %eax,%ecx
80104aad:	c6 42 ff 00          	movb   $0x0,-0x1(%edx)
  while(n-- > 0)
80104ab1:	29 d1                	sub    %edx,%ecx
80104ab3:	8d 4c 0b ff          	lea    -0x1(%ebx,%ecx,1),%ecx
80104ab7:	85 c9                	test   %ecx,%ecx
80104ab9:	7f ed                	jg     80104aa8 <strncpy+0x38>
  return os;
}
80104abb:	5b                   	pop    %ebx
80104abc:	89 f0                	mov    %esi,%eax
80104abe:	5e                   	pop    %esi
80104abf:	5f                   	pop    %edi
80104ac0:	5d                   	pop    %ebp
80104ac1:	c3                   	ret    
80104ac2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ac9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104ad0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104ad0:	55                   	push   %ebp
80104ad1:	89 e5                	mov    %esp,%ebp
80104ad3:	56                   	push   %esi
80104ad4:	8b 55 10             	mov    0x10(%ebp),%edx
80104ad7:	8b 75 08             	mov    0x8(%ebp),%esi
80104ada:	53                   	push   %ebx
80104adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80104ade:	85 d2                	test   %edx,%edx
80104ae0:	7e 25                	jle    80104b07 <safestrcpy+0x37>
80104ae2:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
80104ae6:	89 f2                	mov    %esi,%edx
80104ae8:	eb 16                	jmp    80104b00 <safestrcpy+0x30>
80104aea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104af0:	0f b6 08             	movzbl (%eax),%ecx
80104af3:	83 c0 01             	add    $0x1,%eax
80104af6:	83 c2 01             	add    $0x1,%edx
80104af9:	88 4a ff             	mov    %cl,-0x1(%edx)
80104afc:	84 c9                	test   %cl,%cl
80104afe:	74 04                	je     80104b04 <safestrcpy+0x34>
80104b00:	39 d8                	cmp    %ebx,%eax
80104b02:	75 ec                	jne    80104af0 <safestrcpy+0x20>
    ;
  *s = 0;
80104b04:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80104b07:	89 f0                	mov    %esi,%eax
80104b09:	5b                   	pop    %ebx
80104b0a:	5e                   	pop    %esi
80104b0b:	5d                   	pop    %ebp
80104b0c:	c3                   	ret    
80104b0d:	8d 76 00             	lea    0x0(%esi),%esi

80104b10 <strlen>:

int
strlen(const char *s)
{
80104b10:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104b11:	31 c0                	xor    %eax,%eax
{
80104b13:	89 e5                	mov    %esp,%ebp
80104b15:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104b18:	80 3a 00             	cmpb   $0x0,(%edx)
80104b1b:	74 0c                	je     80104b29 <strlen+0x19>
80104b1d:	8d 76 00             	lea    0x0(%esi),%esi
80104b20:	83 c0 01             	add    $0x1,%eax
80104b23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104b27:	75 f7                	jne    80104b20 <strlen+0x10>
    ;
  return n;
}
80104b29:	5d                   	pop    %ebp
80104b2a:	c3                   	ret    

80104b2b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104b2b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104b2f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104b33:	55                   	push   %ebp
  pushl %ebx
80104b34:	53                   	push   %ebx
  pushl %esi
80104b35:	56                   	push   %esi
  pushl %edi
80104b36:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104b37:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104b39:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80104b3b:	5f                   	pop    %edi
  popl %esi
80104b3c:	5e                   	pop    %esi
  popl %ebx
80104b3d:	5b                   	pop    %ebx
  popl %ebp
80104b3e:	5d                   	pop    %ebp
  ret
80104b3f:	c3                   	ret    

80104b40 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104b40:	55                   	push   %ebp
80104b41:	89 e5                	mov    %esp,%ebp
80104b43:	53                   	push   %ebx
80104b44:	83 ec 04             	sub    $0x4,%esp
80104b47:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80104b4a:	e8 f1 ef ff ff       	call   80103b40 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104b4f:	8b 00                	mov    (%eax),%eax
80104b51:	39 d8                	cmp    %ebx,%eax
80104b53:	76 1b                	jbe    80104b70 <fetchint+0x30>
80104b55:	8d 53 04             	lea    0x4(%ebx),%edx
80104b58:	39 d0                	cmp    %edx,%eax
80104b5a:	72 14                	jb     80104b70 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
80104b5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b5f:	8b 13                	mov    (%ebx),%edx
80104b61:	89 10                	mov    %edx,(%eax)
  return 0;
80104b63:	31 c0                	xor    %eax,%eax
}
80104b65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b68:	c9                   	leave  
80104b69:	c3                   	ret    
80104b6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80104b70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b75:	eb ee                	jmp    80104b65 <fetchint+0x25>
80104b77:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b7e:	66 90                	xchg   %ax,%ax

80104b80 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104b80:	55                   	push   %ebp
80104b81:	89 e5                	mov    %esp,%ebp
80104b83:	53                   	push   %ebx
80104b84:	83 ec 04             	sub    $0x4,%esp
80104b87:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104b8a:	e8 b1 ef ff ff       	call   80103b40 <myproc>

  if(addr >= curproc->sz)
80104b8f:	39 18                	cmp    %ebx,(%eax)
80104b91:	76 2d                	jbe    80104bc0 <fetchstr+0x40>
    return -1;
  *pp = (char*)addr;
80104b93:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b96:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104b98:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104b9a:	39 d3                	cmp    %edx,%ebx
80104b9c:	73 22                	jae    80104bc0 <fetchstr+0x40>
80104b9e:	89 d8                	mov    %ebx,%eax
80104ba0:	eb 0d                	jmp    80104baf <fetchstr+0x2f>
80104ba2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104ba8:	83 c0 01             	add    $0x1,%eax
80104bab:	39 c2                	cmp    %eax,%edx
80104bad:	76 11                	jbe    80104bc0 <fetchstr+0x40>
    if(*s == 0)
80104baf:	80 38 00             	cmpb   $0x0,(%eax)
80104bb2:	75 f4                	jne    80104ba8 <fetchstr+0x28>
      return s - *pp;
80104bb4:	29 d8                	sub    %ebx,%eax
  }
  return -1;
}
80104bb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bb9:	c9                   	leave  
80104bba:	c3                   	ret    
80104bbb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104bbf:	90                   	nop
80104bc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return -1;
80104bc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104bc8:	c9                   	leave  
80104bc9:	c3                   	ret    
80104bca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104bd0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104bd0:	55                   	push   %ebp
80104bd1:	89 e5                	mov    %esp,%ebp
80104bd3:	56                   	push   %esi
80104bd4:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104bd5:	e8 66 ef ff ff       	call   80103b40 <myproc>
80104bda:	8b 55 08             	mov    0x8(%ebp),%edx
80104bdd:	8b 40 1c             	mov    0x1c(%eax),%eax
80104be0:	8b 40 44             	mov    0x44(%eax),%eax
80104be3:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104be6:	e8 55 ef ff ff       	call   80103b40 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104beb:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104bee:	8b 00                	mov    (%eax),%eax
80104bf0:	39 c6                	cmp    %eax,%esi
80104bf2:	73 1c                	jae    80104c10 <argint+0x40>
80104bf4:	8d 53 08             	lea    0x8(%ebx),%edx
80104bf7:	39 d0                	cmp    %edx,%eax
80104bf9:	72 15                	jb     80104c10 <argint+0x40>
  *ip = *(int*)(addr);
80104bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bfe:	8b 53 04             	mov    0x4(%ebx),%edx
80104c01:	89 10                	mov    %edx,(%eax)
  return 0;
80104c03:	31 c0                	xor    %eax,%eax
}
80104c05:	5b                   	pop    %ebx
80104c06:	5e                   	pop    %esi
80104c07:	5d                   	pop    %ebp
80104c08:	c3                   	ret    
80104c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104c10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104c15:	eb ee                	jmp    80104c05 <argint+0x35>
80104c17:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c1e:	66 90                	xchg   %ax,%ax

80104c20 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104c20:	55                   	push   %ebp
80104c21:	89 e5                	mov    %esp,%ebp
80104c23:	57                   	push   %edi
80104c24:	56                   	push   %esi
80104c25:	53                   	push   %ebx
80104c26:	83 ec 0c             	sub    $0xc,%esp
  int i;
  struct proc *curproc = myproc();
80104c29:	e8 12 ef ff ff       	call   80103b40 <myproc>
80104c2e:	89 c6                	mov    %eax,%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104c30:	e8 0b ef ff ff       	call   80103b40 <myproc>
80104c35:	8b 55 08             	mov    0x8(%ebp),%edx
80104c38:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c3b:	8b 40 44             	mov    0x44(%eax),%eax
80104c3e:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104c41:	e8 fa ee ff ff       	call   80103b40 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104c46:	8d 7b 04             	lea    0x4(%ebx),%edi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104c49:	8b 00                	mov    (%eax),%eax
80104c4b:	39 c7                	cmp    %eax,%edi
80104c4d:	73 31                	jae    80104c80 <argptr+0x60>
80104c4f:	8d 4b 08             	lea    0x8(%ebx),%ecx
80104c52:	39 c8                	cmp    %ecx,%eax
80104c54:	72 2a                	jb     80104c80 <argptr+0x60>
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104c56:	8b 55 10             	mov    0x10(%ebp),%edx
  *ip = *(int*)(addr);
80104c59:	8b 43 04             	mov    0x4(%ebx),%eax
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104c5c:	85 d2                	test   %edx,%edx
80104c5e:	78 20                	js     80104c80 <argptr+0x60>
80104c60:	8b 16                	mov    (%esi),%edx
80104c62:	39 c2                	cmp    %eax,%edx
80104c64:	76 1a                	jbe    80104c80 <argptr+0x60>
80104c66:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104c69:	01 c3                	add    %eax,%ebx
80104c6b:	39 da                	cmp    %ebx,%edx
80104c6d:	72 11                	jb     80104c80 <argptr+0x60>
    return -1;
  *pp = (char*)i;
80104c6f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c72:	89 02                	mov    %eax,(%edx)
  return 0;
80104c74:	31 c0                	xor    %eax,%eax
}
80104c76:	83 c4 0c             	add    $0xc,%esp
80104c79:	5b                   	pop    %ebx
80104c7a:	5e                   	pop    %esi
80104c7b:	5f                   	pop    %edi
80104c7c:	5d                   	pop    %ebp
80104c7d:	c3                   	ret    
80104c7e:	66 90                	xchg   %ax,%ax
    return -1;
80104c80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c85:	eb ef                	jmp    80104c76 <argptr+0x56>
80104c87:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c8e:	66 90                	xchg   %ax,%ax

80104c90 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104c90:	55                   	push   %ebp
80104c91:	89 e5                	mov    %esp,%ebp
80104c93:	56                   	push   %esi
80104c94:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104c95:	e8 a6 ee ff ff       	call   80103b40 <myproc>
80104c9a:	8b 55 08             	mov    0x8(%ebp),%edx
80104c9d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ca0:	8b 40 44             	mov    0x44(%eax),%eax
80104ca3:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104ca6:	e8 95 ee ff ff       	call   80103b40 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104cab:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104cae:	8b 00                	mov    (%eax),%eax
80104cb0:	39 c6                	cmp    %eax,%esi
80104cb2:	73 44                	jae    80104cf8 <argstr+0x68>
80104cb4:	8d 53 08             	lea    0x8(%ebx),%edx
80104cb7:	39 d0                	cmp    %edx,%eax
80104cb9:	72 3d                	jb     80104cf8 <argstr+0x68>
  *ip = *(int*)(addr);
80104cbb:	8b 5b 04             	mov    0x4(%ebx),%ebx
  struct proc *curproc = myproc();
80104cbe:	e8 7d ee ff ff       	call   80103b40 <myproc>
  if(addr >= curproc->sz)
80104cc3:	3b 18                	cmp    (%eax),%ebx
80104cc5:	73 31                	jae    80104cf8 <argstr+0x68>
  *pp = (char*)addr;
80104cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cca:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104ccc:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104cce:	39 d3                	cmp    %edx,%ebx
80104cd0:	73 26                	jae    80104cf8 <argstr+0x68>
80104cd2:	89 d8                	mov    %ebx,%eax
80104cd4:	eb 11                	jmp    80104ce7 <argstr+0x57>
80104cd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104cdd:	8d 76 00             	lea    0x0(%esi),%esi
80104ce0:	83 c0 01             	add    $0x1,%eax
80104ce3:	39 c2                	cmp    %eax,%edx
80104ce5:	76 11                	jbe    80104cf8 <argstr+0x68>
    if(*s == 0)
80104ce7:	80 38 00             	cmpb   $0x0,(%eax)
80104cea:	75 f4                	jne    80104ce0 <argstr+0x50>
      return s - *pp;
80104cec:	29 d8                	sub    %ebx,%eax
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}
80104cee:	5b                   	pop    %ebx
80104cef:	5e                   	pop    %esi
80104cf0:	5d                   	pop    %ebp
80104cf1:	c3                   	ret    
80104cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104cf8:	5b                   	pop    %ebx
    return -1;
80104cf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cfe:	5e                   	pop    %esi
80104cff:	5d                   	pop    %ebp
80104d00:	c3                   	ret    
80104d01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d08:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d0f:	90                   	nop

80104d10 <syscall>:
[SYS_getNumFreePages]   sys_getNumFreePages,
};

void
syscall(void)
{
80104d10:	55                   	push   %ebp
80104d11:	89 e5                	mov    %esp,%ebp
80104d13:	53                   	push   %ebx
80104d14:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104d17:	e8 24 ee ff ff       	call   80103b40 <myproc>
80104d1c:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104d1e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d21:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104d24:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d27:	83 fa 16             	cmp    $0x16,%edx
80104d2a:	77 24                	ja     80104d50 <syscall+0x40>
80104d2c:	8b 14 85 20 7f 10 80 	mov    -0x7fef80e0(,%eax,4),%edx
80104d33:	85 d2                	test   %edx,%edx
80104d35:	74 19                	je     80104d50 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
80104d37:	ff d2                	call   *%edx
80104d39:	89 c2                	mov    %eax,%edx
80104d3b:	8b 43 1c             	mov    0x1c(%ebx),%eax
80104d3e:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104d41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d44:	c9                   	leave  
80104d45:	c3                   	ret    
80104d46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d4d:	8d 76 00             	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
80104d50:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80104d51:	8d 43 70             	lea    0x70(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80104d54:	50                   	push   %eax
80104d55:	ff 73 14             	push   0x14(%ebx)
80104d58:	68 ed 7e 10 80       	push   $0x80107eed
80104d5d:	e8 6e ba ff ff       	call   801007d0 <cprintf>
    curproc->tf->eax = -1;
80104d62:	8b 43 1c             	mov    0x1c(%ebx),%eax
80104d65:	83 c4 10             	add    $0x10,%esp
80104d68:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
80104d6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d72:	c9                   	leave  
80104d73:	c3                   	ret    
80104d74:	66 90                	xchg   %ax,%ax
80104d76:	66 90                	xchg   %ax,%ax
80104d78:	66 90                	xchg   %ax,%ax
80104d7a:	66 90                	xchg   %ax,%ax
80104d7c:	66 90                	xchg   %ax,%ax
80104d7e:	66 90                	xchg   %ax,%ax

80104d80 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104d80:	55                   	push   %ebp
80104d81:	89 e5                	mov    %esp,%ebp
80104d83:	57                   	push   %edi
80104d84:	56                   	push   %esi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104d85:	8d 7d da             	lea    -0x26(%ebp),%edi
{
80104d88:	53                   	push   %ebx
80104d89:	83 ec 34             	sub    $0x34,%esp
80104d8c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104d8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
80104d92:	57                   	push   %edi
80104d93:	50                   	push   %eax
{
80104d94:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104d97:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  if((dp = nameiparent(path, name)) == 0)
80104d9a:	e8 51 d4 ff ff       	call   801021f0 <nameiparent>
80104d9f:	83 c4 10             	add    $0x10,%esp
80104da2:	85 c0                	test   %eax,%eax
80104da4:	0f 84 46 01 00 00    	je     80104ef0 <create+0x170>
    return 0;
  ilock(dp);
80104daa:	83 ec 0c             	sub    $0xc,%esp
80104dad:	89 c3                	mov    %eax,%ebx
80104daf:	50                   	push   %eax
80104db0:	e8 fb ca ff ff       	call   801018b0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104db5:	83 c4 0c             	add    $0xc,%esp
80104db8:	6a 00                	push   $0x0
80104dba:	57                   	push   %edi
80104dbb:	53                   	push   %ebx
80104dbc:	e8 4f d0 ff ff       	call   80101e10 <dirlookup>
80104dc1:	83 c4 10             	add    $0x10,%esp
80104dc4:	89 c6                	mov    %eax,%esi
80104dc6:	85 c0                	test   %eax,%eax
80104dc8:	74 56                	je     80104e20 <create+0xa0>
    iunlockput(dp);
80104dca:	83 ec 0c             	sub    $0xc,%esp
80104dcd:	53                   	push   %ebx
80104dce:	e8 6d cd ff ff       	call   80101b40 <iunlockput>
    ilock(ip);
80104dd3:	89 34 24             	mov    %esi,(%esp)
80104dd6:	e8 d5 ca ff ff       	call   801018b0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104ddb:	83 c4 10             	add    $0x10,%esp
80104dde:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104de3:	75 1b                	jne    80104e00 <create+0x80>
80104de5:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
80104dea:	75 14                	jne    80104e00 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104dec:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104def:	89 f0                	mov    %esi,%eax
80104df1:	5b                   	pop    %ebx
80104df2:	5e                   	pop    %esi
80104df3:	5f                   	pop    %edi
80104df4:	5d                   	pop    %ebp
80104df5:	c3                   	ret    
80104df6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104dfd:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80104e00:	83 ec 0c             	sub    $0xc,%esp
80104e03:	56                   	push   %esi
    return 0;
80104e04:	31 f6                	xor    %esi,%esi
    iunlockput(ip);
80104e06:	e8 35 cd ff ff       	call   80101b40 <iunlockput>
    return 0;
80104e0b:	83 c4 10             	add    $0x10,%esp
}
80104e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104e11:	89 f0                	mov    %esi,%eax
80104e13:	5b                   	pop    %ebx
80104e14:	5e                   	pop    %esi
80104e15:	5f                   	pop    %edi
80104e16:	5d                   	pop    %ebp
80104e17:	c3                   	ret    
80104e18:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104e1f:	90                   	nop
  if((ip = ialloc(dp->dev, type)) == 0)
80104e20:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80104e24:	83 ec 08             	sub    $0x8,%esp
80104e27:	50                   	push   %eax
80104e28:	ff 33                	push   (%ebx)
80104e2a:	e8 11 c9 ff ff       	call   80101740 <ialloc>
80104e2f:	83 c4 10             	add    $0x10,%esp
80104e32:	89 c6                	mov    %eax,%esi
80104e34:	85 c0                	test   %eax,%eax
80104e36:	0f 84 cd 00 00 00    	je     80104f09 <create+0x189>
  ilock(ip);
80104e3c:	83 ec 0c             	sub    $0xc,%esp
80104e3f:	50                   	push   %eax
80104e40:	e8 6b ca ff ff       	call   801018b0 <ilock>
  ip->major = major;
80104e45:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104e49:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
80104e4d:	0f b7 45 cc          	movzwl -0x34(%ebp),%eax
80104e51:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80104e55:	b8 01 00 00 00       	mov    $0x1,%eax
80104e5a:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
80104e5e:	89 34 24             	mov    %esi,(%esp)
80104e61:	e8 9a c9 ff ff       	call   80101800 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104e66:	83 c4 10             	add    $0x10,%esp
80104e69:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104e6e:	74 30                	je     80104ea0 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80104e70:	83 ec 04             	sub    $0x4,%esp
80104e73:	ff 76 04             	push   0x4(%esi)
80104e76:	57                   	push   %edi
80104e77:	53                   	push   %ebx
80104e78:	e8 93 d2 ff ff       	call   80102110 <dirlink>
80104e7d:	83 c4 10             	add    $0x10,%esp
80104e80:	85 c0                	test   %eax,%eax
80104e82:	78 78                	js     80104efc <create+0x17c>
  iunlockput(dp);
80104e84:	83 ec 0c             	sub    $0xc,%esp
80104e87:	53                   	push   %ebx
80104e88:	e8 b3 cc ff ff       	call   80101b40 <iunlockput>
  return ip;
80104e8d:	83 c4 10             	add    $0x10,%esp
}
80104e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104e93:	89 f0                	mov    %esi,%eax
80104e95:	5b                   	pop    %ebx
80104e96:	5e                   	pop    %esi
80104e97:	5f                   	pop    %edi
80104e98:	5d                   	pop    %ebp
80104e99:	c3                   	ret    
80104e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
80104ea0:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
80104ea3:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
80104ea8:	53                   	push   %ebx
80104ea9:	e8 52 c9 ff ff       	call   80101800 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104eae:	83 c4 0c             	add    $0xc,%esp
80104eb1:	ff 76 04             	push   0x4(%esi)
80104eb4:	68 9c 7f 10 80       	push   $0x80107f9c
80104eb9:	56                   	push   %esi
80104eba:	e8 51 d2 ff ff       	call   80102110 <dirlink>
80104ebf:	83 c4 10             	add    $0x10,%esp
80104ec2:	85 c0                	test   %eax,%eax
80104ec4:	78 18                	js     80104ede <create+0x15e>
80104ec6:	83 ec 04             	sub    $0x4,%esp
80104ec9:	ff 73 04             	push   0x4(%ebx)
80104ecc:	68 9b 7f 10 80       	push   $0x80107f9b
80104ed1:	56                   	push   %esi
80104ed2:	e8 39 d2 ff ff       	call   80102110 <dirlink>
80104ed7:	83 c4 10             	add    $0x10,%esp
80104eda:	85 c0                	test   %eax,%eax
80104edc:	79 92                	jns    80104e70 <create+0xf0>
      panic("create dots");
80104ede:	83 ec 0c             	sub    $0xc,%esp
80104ee1:	68 8f 7f 10 80       	push   $0x80107f8f
80104ee6:	e8 c5 b5 ff ff       	call   801004b0 <panic>
80104eeb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104eef:	90                   	nop
}
80104ef0:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80104ef3:	31 f6                	xor    %esi,%esi
}
80104ef5:	5b                   	pop    %ebx
80104ef6:	89 f0                	mov    %esi,%eax
80104ef8:	5e                   	pop    %esi
80104ef9:	5f                   	pop    %edi
80104efa:	5d                   	pop    %ebp
80104efb:	c3                   	ret    
    panic("create: dirlink");
80104efc:	83 ec 0c             	sub    $0xc,%esp
80104eff:	68 9e 7f 10 80       	push   $0x80107f9e
80104f04:	e8 a7 b5 ff ff       	call   801004b0 <panic>
    panic("create: ialloc");
80104f09:	83 ec 0c             	sub    $0xc,%esp
80104f0c:	68 80 7f 10 80       	push   $0x80107f80
80104f11:	e8 9a b5 ff ff       	call   801004b0 <panic>
80104f16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f1d:	8d 76 00             	lea    0x0(%esi),%esi

80104f20 <sys_dup>:
{
80104f20:	55                   	push   %ebp
80104f21:	89 e5                	mov    %esp,%ebp
80104f23:	56                   	push   %esi
80104f24:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104f25:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80104f28:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104f2b:	50                   	push   %eax
80104f2c:	6a 00                	push   $0x0
80104f2e:	e8 9d fc ff ff       	call   80104bd0 <argint>
80104f33:	83 c4 10             	add    $0x10,%esp
80104f36:	85 c0                	test   %eax,%eax
80104f38:	78 36                	js     80104f70 <sys_dup+0x50>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104f3a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104f3e:	77 30                	ja     80104f70 <sys_dup+0x50>
80104f40:	e8 fb eb ff ff       	call   80103b40 <myproc>
80104f45:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f48:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
80104f4c:	85 f6                	test   %esi,%esi
80104f4e:	74 20                	je     80104f70 <sys_dup+0x50>
  struct proc *curproc = myproc();
80104f50:	e8 eb eb ff ff       	call   80103b40 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80104f55:	31 db                	xor    %ebx,%ebx
80104f57:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f5e:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80104f60:	8b 54 98 2c          	mov    0x2c(%eax,%ebx,4),%edx
80104f64:	85 d2                	test   %edx,%edx
80104f66:	74 18                	je     80104f80 <sys_dup+0x60>
  for(fd = 0; fd < NOFILE; fd++){
80104f68:	83 c3 01             	add    $0x1,%ebx
80104f6b:	83 fb 10             	cmp    $0x10,%ebx
80104f6e:	75 f0                	jne    80104f60 <sys_dup+0x40>
}
80104f70:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
80104f73:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80104f78:	89 d8                	mov    %ebx,%eax
80104f7a:	5b                   	pop    %ebx
80104f7b:	5e                   	pop    %esi
80104f7c:	5d                   	pop    %ebp
80104f7d:	c3                   	ret    
80104f7e:	66 90                	xchg   %ax,%ax
  filedup(f);
80104f80:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
80104f83:	89 74 98 2c          	mov    %esi,0x2c(%eax,%ebx,4)
  filedup(f);
80104f87:	56                   	push   %esi
80104f88:	e8 43 c0 ff ff       	call   80100fd0 <filedup>
  return fd;
80104f8d:	83 c4 10             	add    $0x10,%esp
}
80104f90:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104f93:	89 d8                	mov    %ebx,%eax
80104f95:	5b                   	pop    %ebx
80104f96:	5e                   	pop    %esi
80104f97:	5d                   	pop    %ebp
80104f98:	c3                   	ret    
80104f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104fa0 <sys_read>:
{
80104fa0:	55                   	push   %ebp
80104fa1:	89 e5                	mov    %esp,%ebp
80104fa3:	56                   	push   %esi
80104fa4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80104fa5:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80104fa8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104fab:	53                   	push   %ebx
80104fac:	6a 00                	push   $0x0
80104fae:	e8 1d fc ff ff       	call   80104bd0 <argint>
80104fb3:	83 c4 10             	add    $0x10,%esp
80104fb6:	85 c0                	test   %eax,%eax
80104fb8:	78 5e                	js     80105018 <sys_read+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104fba:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104fbe:	77 58                	ja     80105018 <sys_read+0x78>
80104fc0:	e8 7b eb ff ff       	call   80103b40 <myproc>
80104fc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fc8:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
80104fcc:	85 f6                	test   %esi,%esi
80104fce:	74 48                	je     80105018 <sys_read+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104fd0:	83 ec 08             	sub    $0x8,%esp
80104fd3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fd6:	50                   	push   %eax
80104fd7:	6a 02                	push   $0x2
80104fd9:	e8 f2 fb ff ff       	call   80104bd0 <argint>
80104fde:	83 c4 10             	add    $0x10,%esp
80104fe1:	85 c0                	test   %eax,%eax
80104fe3:	78 33                	js     80105018 <sys_read+0x78>
80104fe5:	83 ec 04             	sub    $0x4,%esp
80104fe8:	ff 75 f0             	push   -0x10(%ebp)
80104feb:	53                   	push   %ebx
80104fec:	6a 01                	push   $0x1
80104fee:	e8 2d fc ff ff       	call   80104c20 <argptr>
80104ff3:	83 c4 10             	add    $0x10,%esp
80104ff6:	85 c0                	test   %eax,%eax
80104ff8:	78 1e                	js     80105018 <sys_read+0x78>
  return fileread(f, p, n);
80104ffa:	83 ec 04             	sub    $0x4,%esp
80104ffd:	ff 75 f0             	push   -0x10(%ebp)
80105000:	ff 75 f4             	push   -0xc(%ebp)
80105003:	56                   	push   %esi
80105004:	e8 47 c1 ff ff       	call   80101150 <fileread>
80105009:	83 c4 10             	add    $0x10,%esp
}
8010500c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010500f:	5b                   	pop    %ebx
80105010:	5e                   	pop    %esi
80105011:	5d                   	pop    %ebp
80105012:	c3                   	ret    
80105013:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105017:	90                   	nop
    return -1;
80105018:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010501d:	eb ed                	jmp    8010500c <sys_read+0x6c>
8010501f:	90                   	nop

80105020 <sys_write>:
{
80105020:	55                   	push   %ebp
80105021:	89 e5                	mov    %esp,%ebp
80105023:	56                   	push   %esi
80105024:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105025:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105028:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010502b:	53                   	push   %ebx
8010502c:	6a 00                	push   $0x0
8010502e:	e8 9d fb ff ff       	call   80104bd0 <argint>
80105033:	83 c4 10             	add    $0x10,%esp
80105036:	85 c0                	test   %eax,%eax
80105038:	78 5e                	js     80105098 <sys_write+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010503a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010503e:	77 58                	ja     80105098 <sys_write+0x78>
80105040:	e8 fb ea ff ff       	call   80103b40 <myproc>
80105045:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105048:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
8010504c:	85 f6                	test   %esi,%esi
8010504e:	74 48                	je     80105098 <sys_write+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105050:	83 ec 08             	sub    $0x8,%esp
80105053:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105056:	50                   	push   %eax
80105057:	6a 02                	push   $0x2
80105059:	e8 72 fb ff ff       	call   80104bd0 <argint>
8010505e:	83 c4 10             	add    $0x10,%esp
80105061:	85 c0                	test   %eax,%eax
80105063:	78 33                	js     80105098 <sys_write+0x78>
80105065:	83 ec 04             	sub    $0x4,%esp
80105068:	ff 75 f0             	push   -0x10(%ebp)
8010506b:	53                   	push   %ebx
8010506c:	6a 01                	push   $0x1
8010506e:	e8 ad fb ff ff       	call   80104c20 <argptr>
80105073:	83 c4 10             	add    $0x10,%esp
80105076:	85 c0                	test   %eax,%eax
80105078:	78 1e                	js     80105098 <sys_write+0x78>
  return filewrite(f, p, n);
8010507a:	83 ec 04             	sub    $0x4,%esp
8010507d:	ff 75 f0             	push   -0x10(%ebp)
80105080:	ff 75 f4             	push   -0xc(%ebp)
80105083:	56                   	push   %esi
80105084:	e8 57 c1 ff ff       	call   801011e0 <filewrite>
80105089:	83 c4 10             	add    $0x10,%esp
}
8010508c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010508f:	5b                   	pop    %ebx
80105090:	5e                   	pop    %esi
80105091:	5d                   	pop    %ebp
80105092:	c3                   	ret    
80105093:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105097:	90                   	nop
    return -1;
80105098:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010509d:	eb ed                	jmp    8010508c <sys_write+0x6c>
8010509f:	90                   	nop

801050a0 <sys_close>:
{
801050a0:	55                   	push   %ebp
801050a1:	89 e5                	mov    %esp,%ebp
801050a3:	56                   	push   %esi
801050a4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
801050a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
801050a8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801050ab:	50                   	push   %eax
801050ac:	6a 00                	push   $0x0
801050ae:	e8 1d fb ff ff       	call   80104bd0 <argint>
801050b3:	83 c4 10             	add    $0x10,%esp
801050b6:	85 c0                	test   %eax,%eax
801050b8:	78 3e                	js     801050f8 <sys_close+0x58>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801050ba:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801050be:	77 38                	ja     801050f8 <sys_close+0x58>
801050c0:	e8 7b ea ff ff       	call   80103b40 <myproc>
801050c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050c8:	8d 5a 08             	lea    0x8(%edx),%ebx
801050cb:	8b 74 98 0c          	mov    0xc(%eax,%ebx,4),%esi
801050cf:	85 f6                	test   %esi,%esi
801050d1:	74 25                	je     801050f8 <sys_close+0x58>
  myproc()->ofile[fd] = 0;
801050d3:	e8 68 ea ff ff       	call   80103b40 <myproc>
  fileclose(f);
801050d8:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
801050db:	c7 44 98 0c 00 00 00 	movl   $0x0,0xc(%eax,%ebx,4)
801050e2:	00 
  fileclose(f);
801050e3:	56                   	push   %esi
801050e4:	e8 37 bf ff ff       	call   80101020 <fileclose>
  return 0;
801050e9:	83 c4 10             	add    $0x10,%esp
801050ec:	31 c0                	xor    %eax,%eax
}
801050ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
801050f1:	5b                   	pop    %ebx
801050f2:	5e                   	pop    %esi
801050f3:	5d                   	pop    %ebp
801050f4:	c3                   	ret    
801050f5:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
801050f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050fd:	eb ef                	jmp    801050ee <sys_close+0x4e>
801050ff:	90                   	nop

80105100 <sys_fstat>:
{
80105100:	55                   	push   %ebp
80105101:	89 e5                	mov    %esp,%ebp
80105103:	56                   	push   %esi
80105104:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105105:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105108:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010510b:	53                   	push   %ebx
8010510c:	6a 00                	push   $0x0
8010510e:	e8 bd fa ff ff       	call   80104bd0 <argint>
80105113:	83 c4 10             	add    $0x10,%esp
80105116:	85 c0                	test   %eax,%eax
80105118:	78 46                	js     80105160 <sys_fstat+0x60>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010511a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010511e:	77 40                	ja     80105160 <sys_fstat+0x60>
80105120:	e8 1b ea ff ff       	call   80103b40 <myproc>
80105125:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105128:	8b 74 90 2c          	mov    0x2c(%eax,%edx,4),%esi
8010512c:	85 f6                	test   %esi,%esi
8010512e:	74 30                	je     80105160 <sys_fstat+0x60>
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105130:	83 ec 04             	sub    $0x4,%esp
80105133:	6a 14                	push   $0x14
80105135:	53                   	push   %ebx
80105136:	6a 01                	push   $0x1
80105138:	e8 e3 fa ff ff       	call   80104c20 <argptr>
8010513d:	83 c4 10             	add    $0x10,%esp
80105140:	85 c0                	test   %eax,%eax
80105142:	78 1c                	js     80105160 <sys_fstat+0x60>
  return filestat(f, st);
80105144:	83 ec 08             	sub    $0x8,%esp
80105147:	ff 75 f4             	push   -0xc(%ebp)
8010514a:	56                   	push   %esi
8010514b:	e8 b0 bf ff ff       	call   80101100 <filestat>
80105150:	83 c4 10             	add    $0x10,%esp
}
80105153:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105156:	5b                   	pop    %ebx
80105157:	5e                   	pop    %esi
80105158:	5d                   	pop    %ebp
80105159:	c3                   	ret    
8010515a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105160:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105165:	eb ec                	jmp    80105153 <sys_fstat+0x53>
80105167:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010516e:	66 90                	xchg   %ax,%ax

80105170 <sys_link>:
{
80105170:	55                   	push   %ebp
80105171:	89 e5                	mov    %esp,%ebp
80105173:	57                   	push   %edi
80105174:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105175:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105178:	53                   	push   %ebx
80105179:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010517c:	50                   	push   %eax
8010517d:	6a 00                	push   $0x0
8010517f:	e8 0c fb ff ff       	call   80104c90 <argstr>
80105184:	83 c4 10             	add    $0x10,%esp
80105187:	85 c0                	test   %eax,%eax
80105189:	0f 88 fb 00 00 00    	js     8010528a <sys_link+0x11a>
8010518f:	83 ec 08             	sub    $0x8,%esp
80105192:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105195:	50                   	push   %eax
80105196:	6a 01                	push   $0x1
80105198:	e8 f3 fa ff ff       	call   80104c90 <argstr>
8010519d:	83 c4 10             	add    $0x10,%esp
801051a0:	85 c0                	test   %eax,%eax
801051a2:	0f 88 e2 00 00 00    	js     8010528a <sys_link+0x11a>
  begin_op();
801051a8:	e8 73 dd ff ff       	call   80102f20 <begin_op>
  if((ip = namei(old)) == 0){
801051ad:	83 ec 0c             	sub    $0xc,%esp
801051b0:	ff 75 d4             	push   -0x2c(%ebp)
801051b3:	e8 18 d0 ff ff       	call   801021d0 <namei>
801051b8:	83 c4 10             	add    $0x10,%esp
801051bb:	89 c3                	mov    %eax,%ebx
801051bd:	85 c0                	test   %eax,%eax
801051bf:	0f 84 e4 00 00 00    	je     801052a9 <sys_link+0x139>
  ilock(ip);
801051c5:	83 ec 0c             	sub    $0xc,%esp
801051c8:	50                   	push   %eax
801051c9:	e8 e2 c6 ff ff       	call   801018b0 <ilock>
  if(ip->type == T_DIR){
801051ce:	83 c4 10             	add    $0x10,%esp
801051d1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801051d6:	0f 84 b5 00 00 00    	je     80105291 <sys_link+0x121>
  iupdate(ip);
801051dc:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
801051df:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
801051e4:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
801051e7:	53                   	push   %ebx
801051e8:	e8 13 c6 ff ff       	call   80101800 <iupdate>
  iunlock(ip);
801051ed:	89 1c 24             	mov    %ebx,(%esp)
801051f0:	e8 9b c7 ff ff       	call   80101990 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801051f5:	58                   	pop    %eax
801051f6:	5a                   	pop    %edx
801051f7:	57                   	push   %edi
801051f8:	ff 75 d0             	push   -0x30(%ebp)
801051fb:	e8 f0 cf ff ff       	call   801021f0 <nameiparent>
80105200:	83 c4 10             	add    $0x10,%esp
80105203:	89 c6                	mov    %eax,%esi
80105205:	85 c0                	test   %eax,%eax
80105207:	74 5b                	je     80105264 <sys_link+0xf4>
  ilock(dp);
80105209:	83 ec 0c             	sub    $0xc,%esp
8010520c:	50                   	push   %eax
8010520d:	e8 9e c6 ff ff       	call   801018b0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105212:	8b 03                	mov    (%ebx),%eax
80105214:	83 c4 10             	add    $0x10,%esp
80105217:	39 06                	cmp    %eax,(%esi)
80105219:	75 3d                	jne    80105258 <sys_link+0xe8>
8010521b:	83 ec 04             	sub    $0x4,%esp
8010521e:	ff 73 04             	push   0x4(%ebx)
80105221:	57                   	push   %edi
80105222:	56                   	push   %esi
80105223:	e8 e8 ce ff ff       	call   80102110 <dirlink>
80105228:	83 c4 10             	add    $0x10,%esp
8010522b:	85 c0                	test   %eax,%eax
8010522d:	78 29                	js     80105258 <sys_link+0xe8>
  iunlockput(dp);
8010522f:	83 ec 0c             	sub    $0xc,%esp
80105232:	56                   	push   %esi
80105233:	e8 08 c9 ff ff       	call   80101b40 <iunlockput>
  iput(ip);
80105238:	89 1c 24             	mov    %ebx,(%esp)
8010523b:	e8 a0 c7 ff ff       	call   801019e0 <iput>
  end_op();
80105240:	e8 4b dd ff ff       	call   80102f90 <end_op>
  return 0;
80105245:	83 c4 10             	add    $0x10,%esp
80105248:	31 c0                	xor    %eax,%eax
}
8010524a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010524d:	5b                   	pop    %ebx
8010524e:	5e                   	pop    %esi
8010524f:	5f                   	pop    %edi
80105250:	5d                   	pop    %ebp
80105251:	c3                   	ret    
80105252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105258:	83 ec 0c             	sub    $0xc,%esp
8010525b:	56                   	push   %esi
8010525c:	e8 df c8 ff ff       	call   80101b40 <iunlockput>
    goto bad;
80105261:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105264:	83 ec 0c             	sub    $0xc,%esp
80105267:	53                   	push   %ebx
80105268:	e8 43 c6 ff ff       	call   801018b0 <ilock>
  ip->nlink--;
8010526d:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80105272:	89 1c 24             	mov    %ebx,(%esp)
80105275:	e8 86 c5 ff ff       	call   80101800 <iupdate>
  iunlockput(ip);
8010527a:	89 1c 24             	mov    %ebx,(%esp)
8010527d:	e8 be c8 ff ff       	call   80101b40 <iunlockput>
  end_op();
80105282:	e8 09 dd ff ff       	call   80102f90 <end_op>
  return -1;
80105287:	83 c4 10             	add    $0x10,%esp
8010528a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010528f:	eb b9                	jmp    8010524a <sys_link+0xda>
    iunlockput(ip);
80105291:	83 ec 0c             	sub    $0xc,%esp
80105294:	53                   	push   %ebx
80105295:	e8 a6 c8 ff ff       	call   80101b40 <iunlockput>
    end_op();
8010529a:	e8 f1 dc ff ff       	call   80102f90 <end_op>
    return -1;
8010529f:	83 c4 10             	add    $0x10,%esp
801052a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052a7:	eb a1                	jmp    8010524a <sys_link+0xda>
    end_op();
801052a9:	e8 e2 dc ff ff       	call   80102f90 <end_op>
    return -1;
801052ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b3:	eb 95                	jmp    8010524a <sys_link+0xda>
801052b5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801052bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801052c0 <sys_unlink>:
{
801052c0:	55                   	push   %ebp
801052c1:	89 e5                	mov    %esp,%ebp
801052c3:	57                   	push   %edi
801052c4:	56                   	push   %esi
  if(argstr(0, &path) < 0)
801052c5:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
801052c8:	53                   	push   %ebx
801052c9:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
801052cc:	50                   	push   %eax
801052cd:	6a 00                	push   $0x0
801052cf:	e8 bc f9 ff ff       	call   80104c90 <argstr>
801052d4:	83 c4 10             	add    $0x10,%esp
801052d7:	85 c0                	test   %eax,%eax
801052d9:	0f 88 7a 01 00 00    	js     80105459 <sys_unlink+0x199>
  begin_op();
801052df:	e8 3c dc ff ff       	call   80102f20 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801052e4:	8d 5d ca             	lea    -0x36(%ebp),%ebx
801052e7:	83 ec 08             	sub    $0x8,%esp
801052ea:	53                   	push   %ebx
801052eb:	ff 75 c0             	push   -0x40(%ebp)
801052ee:	e8 fd ce ff ff       	call   801021f0 <nameiparent>
801052f3:	83 c4 10             	add    $0x10,%esp
801052f6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
801052f9:	85 c0                	test   %eax,%eax
801052fb:	0f 84 62 01 00 00    	je     80105463 <sys_unlink+0x1a3>
  ilock(dp);
80105301:	8b 7d b4             	mov    -0x4c(%ebp),%edi
80105304:	83 ec 0c             	sub    $0xc,%esp
80105307:	57                   	push   %edi
80105308:	e8 a3 c5 ff ff       	call   801018b0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010530d:	58                   	pop    %eax
8010530e:	5a                   	pop    %edx
8010530f:	68 9c 7f 10 80       	push   $0x80107f9c
80105314:	53                   	push   %ebx
80105315:	e8 d6 ca ff ff       	call   80101df0 <namecmp>
8010531a:	83 c4 10             	add    $0x10,%esp
8010531d:	85 c0                	test   %eax,%eax
8010531f:	0f 84 fb 00 00 00    	je     80105420 <sys_unlink+0x160>
80105325:	83 ec 08             	sub    $0x8,%esp
80105328:	68 9b 7f 10 80       	push   $0x80107f9b
8010532d:	53                   	push   %ebx
8010532e:	e8 bd ca ff ff       	call   80101df0 <namecmp>
80105333:	83 c4 10             	add    $0x10,%esp
80105336:	85 c0                	test   %eax,%eax
80105338:	0f 84 e2 00 00 00    	je     80105420 <sys_unlink+0x160>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010533e:	83 ec 04             	sub    $0x4,%esp
80105341:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105344:	50                   	push   %eax
80105345:	53                   	push   %ebx
80105346:	57                   	push   %edi
80105347:	e8 c4 ca ff ff       	call   80101e10 <dirlookup>
8010534c:	83 c4 10             	add    $0x10,%esp
8010534f:	89 c3                	mov    %eax,%ebx
80105351:	85 c0                	test   %eax,%eax
80105353:	0f 84 c7 00 00 00    	je     80105420 <sys_unlink+0x160>
  ilock(ip);
80105359:	83 ec 0c             	sub    $0xc,%esp
8010535c:	50                   	push   %eax
8010535d:	e8 4e c5 ff ff       	call   801018b0 <ilock>
  if(ip->nlink < 1)
80105362:	83 c4 10             	add    $0x10,%esp
80105365:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010536a:	0f 8e 1c 01 00 00    	jle    8010548c <sys_unlink+0x1cc>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105370:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105375:	8d 7d d8             	lea    -0x28(%ebp),%edi
80105378:	74 66                	je     801053e0 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
8010537a:	83 ec 04             	sub    $0x4,%esp
8010537d:	6a 10                	push   $0x10
8010537f:	6a 00                	push   $0x0
80105381:	57                   	push   %edi
80105382:	e8 89 f5 ff ff       	call   80104910 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105387:	6a 10                	push   $0x10
80105389:	ff 75 c4             	push   -0x3c(%ebp)
8010538c:	57                   	push   %edi
8010538d:	ff 75 b4             	push   -0x4c(%ebp)
80105390:	e8 2b c9 ff ff       	call   80101cc0 <writei>
80105395:	83 c4 20             	add    $0x20,%esp
80105398:	83 f8 10             	cmp    $0x10,%eax
8010539b:	0f 85 de 00 00 00    	jne    8010547f <sys_unlink+0x1bf>
  if(ip->type == T_DIR){
801053a1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801053a6:	0f 84 94 00 00 00    	je     80105440 <sys_unlink+0x180>
  iunlockput(dp);
801053ac:	83 ec 0c             	sub    $0xc,%esp
801053af:	ff 75 b4             	push   -0x4c(%ebp)
801053b2:	e8 89 c7 ff ff       	call   80101b40 <iunlockput>
  ip->nlink--;
801053b7:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
801053bc:	89 1c 24             	mov    %ebx,(%esp)
801053bf:	e8 3c c4 ff ff       	call   80101800 <iupdate>
  iunlockput(ip);
801053c4:	89 1c 24             	mov    %ebx,(%esp)
801053c7:	e8 74 c7 ff ff       	call   80101b40 <iunlockput>
  end_op();
801053cc:	e8 bf db ff ff       	call   80102f90 <end_op>
  return 0;
801053d1:	83 c4 10             	add    $0x10,%esp
801053d4:	31 c0                	xor    %eax,%eax
}
801053d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801053d9:	5b                   	pop    %ebx
801053da:	5e                   	pop    %esi
801053db:	5f                   	pop    %edi
801053dc:	5d                   	pop    %ebp
801053dd:	c3                   	ret    
801053de:	66 90                	xchg   %ax,%ax
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801053e0:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
801053e4:	76 94                	jbe    8010537a <sys_unlink+0xba>
801053e6:	be 20 00 00 00       	mov    $0x20,%esi
801053eb:	eb 0b                	jmp    801053f8 <sys_unlink+0x138>
801053ed:	8d 76 00             	lea    0x0(%esi),%esi
801053f0:	83 c6 10             	add    $0x10,%esi
801053f3:	3b 73 58             	cmp    0x58(%ebx),%esi
801053f6:	73 82                	jae    8010537a <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801053f8:	6a 10                	push   $0x10
801053fa:	56                   	push   %esi
801053fb:	57                   	push   %edi
801053fc:	53                   	push   %ebx
801053fd:	e8 be c7 ff ff       	call   80101bc0 <readi>
80105402:	83 c4 10             	add    $0x10,%esp
80105405:	83 f8 10             	cmp    $0x10,%eax
80105408:	75 68                	jne    80105472 <sys_unlink+0x1b2>
    if(de.inum != 0)
8010540a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010540f:	74 df                	je     801053f0 <sys_unlink+0x130>
    iunlockput(ip);
80105411:	83 ec 0c             	sub    $0xc,%esp
80105414:	53                   	push   %ebx
80105415:	e8 26 c7 ff ff       	call   80101b40 <iunlockput>
    goto bad;
8010541a:	83 c4 10             	add    $0x10,%esp
8010541d:	8d 76 00             	lea    0x0(%esi),%esi
  iunlockput(dp);
80105420:	83 ec 0c             	sub    $0xc,%esp
80105423:	ff 75 b4             	push   -0x4c(%ebp)
80105426:	e8 15 c7 ff ff       	call   80101b40 <iunlockput>
  end_op();
8010542b:	e8 60 db ff ff       	call   80102f90 <end_op>
  return -1;
80105430:	83 c4 10             	add    $0x10,%esp
80105433:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105438:	eb 9c                	jmp    801053d6 <sys_unlink+0x116>
8010543a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    dp->nlink--;
80105440:	8b 45 b4             	mov    -0x4c(%ebp),%eax
    iupdate(dp);
80105443:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
80105446:	66 83 68 56 01       	subw   $0x1,0x56(%eax)
    iupdate(dp);
8010544b:	50                   	push   %eax
8010544c:	e8 af c3 ff ff       	call   80101800 <iupdate>
80105451:	83 c4 10             	add    $0x10,%esp
80105454:	e9 53 ff ff ff       	jmp    801053ac <sys_unlink+0xec>
    return -1;
80105459:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545e:	e9 73 ff ff ff       	jmp    801053d6 <sys_unlink+0x116>
    end_op();
80105463:	e8 28 db ff ff       	call   80102f90 <end_op>
    return -1;
80105468:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010546d:	e9 64 ff ff ff       	jmp    801053d6 <sys_unlink+0x116>
      panic("isdirempty: readi");
80105472:	83 ec 0c             	sub    $0xc,%esp
80105475:	68 c0 7f 10 80       	push   $0x80107fc0
8010547a:	e8 31 b0 ff ff       	call   801004b0 <panic>
    panic("unlink: writei");
8010547f:	83 ec 0c             	sub    $0xc,%esp
80105482:	68 d2 7f 10 80       	push   $0x80107fd2
80105487:	e8 24 b0 ff ff       	call   801004b0 <panic>
    panic("unlink: nlink < 1");
8010548c:	83 ec 0c             	sub    $0xc,%esp
8010548f:	68 ae 7f 10 80       	push   $0x80107fae
80105494:	e8 17 b0 ff ff       	call   801004b0 <panic>
80105499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801054a0 <sys_open>:

int
sys_open(void)
{
801054a0:	55                   	push   %ebp
801054a1:	89 e5                	mov    %esp,%ebp
801054a3:	57                   	push   %edi
801054a4:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801054a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
801054a8:	53                   	push   %ebx
801054a9:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801054ac:	50                   	push   %eax
801054ad:	6a 00                	push   $0x0
801054af:	e8 dc f7 ff ff       	call   80104c90 <argstr>
801054b4:	83 c4 10             	add    $0x10,%esp
801054b7:	85 c0                	test   %eax,%eax
801054b9:	0f 88 8e 00 00 00    	js     8010554d <sys_open+0xad>
801054bf:	83 ec 08             	sub    $0x8,%esp
801054c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801054c5:	50                   	push   %eax
801054c6:	6a 01                	push   $0x1
801054c8:	e8 03 f7 ff ff       	call   80104bd0 <argint>
801054cd:	83 c4 10             	add    $0x10,%esp
801054d0:	85 c0                	test   %eax,%eax
801054d2:	78 79                	js     8010554d <sys_open+0xad>
    return -1;

  begin_op();
801054d4:	e8 47 da ff ff       	call   80102f20 <begin_op>

  if(omode & O_CREATE){
801054d9:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
801054dd:	75 79                	jne    80105558 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
801054df:	83 ec 0c             	sub    $0xc,%esp
801054e2:	ff 75 e0             	push   -0x20(%ebp)
801054e5:	e8 e6 cc ff ff       	call   801021d0 <namei>
801054ea:	83 c4 10             	add    $0x10,%esp
801054ed:	89 c6                	mov    %eax,%esi
801054ef:	85 c0                	test   %eax,%eax
801054f1:	0f 84 7e 00 00 00    	je     80105575 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
801054f7:	83 ec 0c             	sub    $0xc,%esp
801054fa:	50                   	push   %eax
801054fb:	e8 b0 c3 ff ff       	call   801018b0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105500:	83 c4 10             	add    $0x10,%esp
80105503:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80105508:	0f 84 c2 00 00 00    	je     801055d0 <sys_open+0x130>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010550e:	e8 4d ba ff ff       	call   80100f60 <filealloc>
80105513:	89 c7                	mov    %eax,%edi
80105515:	85 c0                	test   %eax,%eax
80105517:	74 23                	je     8010553c <sys_open+0x9c>
  struct proc *curproc = myproc();
80105519:	e8 22 e6 ff ff       	call   80103b40 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010551e:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
80105520:	8b 54 98 2c          	mov    0x2c(%eax,%ebx,4),%edx
80105524:	85 d2                	test   %edx,%edx
80105526:	74 60                	je     80105588 <sys_open+0xe8>
  for(fd = 0; fd < NOFILE; fd++){
80105528:	83 c3 01             	add    $0x1,%ebx
8010552b:	83 fb 10             	cmp    $0x10,%ebx
8010552e:	75 f0                	jne    80105520 <sys_open+0x80>
    if(f)
      fileclose(f);
80105530:	83 ec 0c             	sub    $0xc,%esp
80105533:	57                   	push   %edi
80105534:	e8 e7 ba ff ff       	call   80101020 <fileclose>
80105539:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010553c:	83 ec 0c             	sub    $0xc,%esp
8010553f:	56                   	push   %esi
80105540:	e8 fb c5 ff ff       	call   80101b40 <iunlockput>
    end_op();
80105545:	e8 46 da ff ff       	call   80102f90 <end_op>
    return -1;
8010554a:	83 c4 10             	add    $0x10,%esp
8010554d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105552:	eb 6d                	jmp    801055c1 <sys_open+0x121>
80105554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
80105558:	83 ec 0c             	sub    $0xc,%esp
8010555b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010555e:	31 c9                	xor    %ecx,%ecx
80105560:	ba 02 00 00 00       	mov    $0x2,%edx
80105565:	6a 00                	push   $0x0
80105567:	e8 14 f8 ff ff       	call   80104d80 <create>
    if(ip == 0){
8010556c:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
8010556f:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80105571:	85 c0                	test   %eax,%eax
80105573:	75 99                	jne    8010550e <sys_open+0x6e>
      end_op();
80105575:	e8 16 da ff ff       	call   80102f90 <end_op>
      return -1;
8010557a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010557f:	eb 40                	jmp    801055c1 <sys_open+0x121>
80105581:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
80105588:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
8010558b:	89 7c 98 2c          	mov    %edi,0x2c(%eax,%ebx,4)
  iunlock(ip);
8010558f:	56                   	push   %esi
80105590:	e8 fb c3 ff ff       	call   80101990 <iunlock>
  end_op();
80105595:	e8 f6 d9 ff ff       	call   80102f90 <end_op>

  f->type = FD_INODE;
8010559a:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
801055a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801055a3:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
801055a6:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
801055a9:	89 d0                	mov    %edx,%eax
  f->off = 0;
801055ab:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
801055b2:	f7 d0                	not    %eax
801055b4:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801055b7:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
801055ba:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801055bd:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
801055c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801055c4:	89 d8                	mov    %ebx,%eax
801055c6:	5b                   	pop    %ebx
801055c7:	5e                   	pop    %esi
801055c8:	5f                   	pop    %edi
801055c9:	5d                   	pop    %ebp
801055ca:	c3                   	ret    
801055cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801055cf:	90                   	nop
    if(ip->type == T_DIR && omode != O_RDONLY){
801055d0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801055d3:	85 c9                	test   %ecx,%ecx
801055d5:	0f 84 33 ff ff ff    	je     8010550e <sys_open+0x6e>
801055db:	e9 5c ff ff ff       	jmp    8010553c <sys_open+0x9c>

801055e0 <sys_mkdir>:

int
sys_mkdir(void)
{
801055e0:	55                   	push   %ebp
801055e1:	89 e5                	mov    %esp,%ebp
801055e3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801055e6:	e8 35 d9 ff ff       	call   80102f20 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801055eb:	83 ec 08             	sub    $0x8,%esp
801055ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055f1:	50                   	push   %eax
801055f2:	6a 00                	push   $0x0
801055f4:	e8 97 f6 ff ff       	call   80104c90 <argstr>
801055f9:	83 c4 10             	add    $0x10,%esp
801055fc:	85 c0                	test   %eax,%eax
801055fe:	78 30                	js     80105630 <sys_mkdir+0x50>
80105600:	83 ec 0c             	sub    $0xc,%esp
80105603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105606:	31 c9                	xor    %ecx,%ecx
80105608:	ba 01 00 00 00       	mov    $0x1,%edx
8010560d:	6a 00                	push   $0x0
8010560f:	e8 6c f7 ff ff       	call   80104d80 <create>
80105614:	83 c4 10             	add    $0x10,%esp
80105617:	85 c0                	test   %eax,%eax
80105619:	74 15                	je     80105630 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010561b:	83 ec 0c             	sub    $0xc,%esp
8010561e:	50                   	push   %eax
8010561f:	e8 1c c5 ff ff       	call   80101b40 <iunlockput>
  end_op();
80105624:	e8 67 d9 ff ff       	call   80102f90 <end_op>
  return 0;
80105629:	83 c4 10             	add    $0x10,%esp
8010562c:	31 c0                	xor    %eax,%eax
}
8010562e:	c9                   	leave  
8010562f:	c3                   	ret    
    end_op();
80105630:	e8 5b d9 ff ff       	call   80102f90 <end_op>
    return -1;
80105635:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010563a:	c9                   	leave  
8010563b:	c3                   	ret    
8010563c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105640 <sys_mknod>:

int
sys_mknod(void)
{
80105640:	55                   	push   %ebp
80105641:	89 e5                	mov    %esp,%ebp
80105643:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105646:	e8 d5 d8 ff ff       	call   80102f20 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010564b:	83 ec 08             	sub    $0x8,%esp
8010564e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105651:	50                   	push   %eax
80105652:	6a 00                	push   $0x0
80105654:	e8 37 f6 ff ff       	call   80104c90 <argstr>
80105659:	83 c4 10             	add    $0x10,%esp
8010565c:	85 c0                	test   %eax,%eax
8010565e:	78 60                	js     801056c0 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105660:	83 ec 08             	sub    $0x8,%esp
80105663:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105666:	50                   	push   %eax
80105667:	6a 01                	push   $0x1
80105669:	e8 62 f5 ff ff       	call   80104bd0 <argint>
  if((argstr(0, &path)) < 0 ||
8010566e:	83 c4 10             	add    $0x10,%esp
80105671:	85 c0                	test   %eax,%eax
80105673:	78 4b                	js     801056c0 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105675:	83 ec 08             	sub    $0x8,%esp
80105678:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010567b:	50                   	push   %eax
8010567c:	6a 02                	push   $0x2
8010567e:	e8 4d f5 ff ff       	call   80104bd0 <argint>
     argint(1, &major) < 0 ||
80105683:	83 c4 10             	add    $0x10,%esp
80105686:	85 c0                	test   %eax,%eax
80105688:	78 36                	js     801056c0 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010568a:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
8010568e:	83 ec 0c             	sub    $0xc,%esp
80105691:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80105695:	ba 03 00 00 00       	mov    $0x3,%edx
8010569a:	50                   	push   %eax
8010569b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010569e:	e8 dd f6 ff ff       	call   80104d80 <create>
     argint(2, &minor) < 0 ||
801056a3:	83 c4 10             	add    $0x10,%esp
801056a6:	85 c0                	test   %eax,%eax
801056a8:	74 16                	je     801056c0 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
801056aa:	83 ec 0c             	sub    $0xc,%esp
801056ad:	50                   	push   %eax
801056ae:	e8 8d c4 ff ff       	call   80101b40 <iunlockput>
  end_op();
801056b3:	e8 d8 d8 ff ff       	call   80102f90 <end_op>
  return 0;
801056b8:	83 c4 10             	add    $0x10,%esp
801056bb:	31 c0                	xor    %eax,%eax
}
801056bd:	c9                   	leave  
801056be:	c3                   	ret    
801056bf:	90                   	nop
    end_op();
801056c0:	e8 cb d8 ff ff       	call   80102f90 <end_op>
    return -1;
801056c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056ca:	c9                   	leave  
801056cb:	c3                   	ret    
801056cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801056d0 <sys_chdir>:

int
sys_chdir(void)
{
801056d0:	55                   	push   %ebp
801056d1:	89 e5                	mov    %esp,%ebp
801056d3:	56                   	push   %esi
801056d4:	53                   	push   %ebx
801056d5:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801056d8:	e8 63 e4 ff ff       	call   80103b40 <myproc>
801056dd:	89 c6                	mov    %eax,%esi
  
  begin_op();
801056df:	e8 3c d8 ff ff       	call   80102f20 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801056e4:	83 ec 08             	sub    $0x8,%esp
801056e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056ea:	50                   	push   %eax
801056eb:	6a 00                	push   $0x0
801056ed:	e8 9e f5 ff ff       	call   80104c90 <argstr>
801056f2:	83 c4 10             	add    $0x10,%esp
801056f5:	85 c0                	test   %eax,%eax
801056f7:	78 77                	js     80105770 <sys_chdir+0xa0>
801056f9:	83 ec 0c             	sub    $0xc,%esp
801056fc:	ff 75 f4             	push   -0xc(%ebp)
801056ff:	e8 cc ca ff ff       	call   801021d0 <namei>
80105704:	83 c4 10             	add    $0x10,%esp
80105707:	89 c3                	mov    %eax,%ebx
80105709:	85 c0                	test   %eax,%eax
8010570b:	74 63                	je     80105770 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
8010570d:	83 ec 0c             	sub    $0xc,%esp
80105710:	50                   	push   %eax
80105711:	e8 9a c1 ff ff       	call   801018b0 <ilock>
  if(ip->type != T_DIR){
80105716:	83 c4 10             	add    $0x10,%esp
80105719:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010571e:	75 30                	jne    80105750 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105720:	83 ec 0c             	sub    $0xc,%esp
80105723:	53                   	push   %ebx
80105724:	e8 67 c2 ff ff       	call   80101990 <iunlock>
  iput(curproc->cwd);
80105729:	58                   	pop    %eax
8010572a:	ff 76 6c             	push   0x6c(%esi)
8010572d:	e8 ae c2 ff ff       	call   801019e0 <iput>
  end_op();
80105732:	e8 59 d8 ff ff       	call   80102f90 <end_op>
  curproc->cwd = ip;
80105737:	89 5e 6c             	mov    %ebx,0x6c(%esi)
  return 0;
8010573a:	83 c4 10             	add    $0x10,%esp
8010573d:	31 c0                	xor    %eax,%eax
}
8010573f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105742:	5b                   	pop    %ebx
80105743:	5e                   	pop    %esi
80105744:	5d                   	pop    %ebp
80105745:	c3                   	ret    
80105746:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010574d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80105750:	83 ec 0c             	sub    $0xc,%esp
80105753:	53                   	push   %ebx
80105754:	e8 e7 c3 ff ff       	call   80101b40 <iunlockput>
    end_op();
80105759:	e8 32 d8 ff ff       	call   80102f90 <end_op>
    return -1;
8010575e:	83 c4 10             	add    $0x10,%esp
80105761:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105766:	eb d7                	jmp    8010573f <sys_chdir+0x6f>
80105768:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010576f:	90                   	nop
    end_op();
80105770:	e8 1b d8 ff ff       	call   80102f90 <end_op>
    return -1;
80105775:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010577a:	eb c3                	jmp    8010573f <sys_chdir+0x6f>
8010577c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105780 <sys_exec>:

int
sys_exec(void)
{
80105780:	55                   	push   %ebp
80105781:	89 e5                	mov    %esp,%ebp
80105783:	57                   	push   %edi
80105784:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105785:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
8010578b:	53                   	push   %ebx
8010578c:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105792:	50                   	push   %eax
80105793:	6a 00                	push   $0x0
80105795:	e8 f6 f4 ff ff       	call   80104c90 <argstr>
8010579a:	83 c4 10             	add    $0x10,%esp
8010579d:	85 c0                	test   %eax,%eax
8010579f:	0f 88 87 00 00 00    	js     8010582c <sys_exec+0xac>
801057a5:	83 ec 08             	sub    $0x8,%esp
801057a8:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
801057ae:	50                   	push   %eax
801057af:	6a 01                	push   $0x1
801057b1:	e8 1a f4 ff ff       	call   80104bd0 <argint>
801057b6:	83 c4 10             	add    $0x10,%esp
801057b9:	85 c0                	test   %eax,%eax
801057bb:	78 6f                	js     8010582c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801057bd:	83 ec 04             	sub    $0x4,%esp
801057c0:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  for(i=0;; i++){
801057c6:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
801057c8:	68 80 00 00 00       	push   $0x80
801057cd:	6a 00                	push   $0x0
801057cf:	56                   	push   %esi
801057d0:	e8 3b f1 ff ff       	call   80104910 <memset>
801057d5:	83 c4 10             	add    $0x10,%esp
801057d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801057df:	90                   	nop
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801057e0:	83 ec 08             	sub    $0x8,%esp
801057e3:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
801057e9:	8d 3c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edi
801057f0:	50                   	push   %eax
801057f1:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
801057f7:	01 f8                	add    %edi,%eax
801057f9:	50                   	push   %eax
801057fa:	e8 41 f3 ff ff       	call   80104b40 <fetchint>
801057ff:	83 c4 10             	add    $0x10,%esp
80105802:	85 c0                	test   %eax,%eax
80105804:	78 26                	js     8010582c <sys_exec+0xac>
      return -1;
    if(uarg == 0){
80105806:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
8010580c:	85 c0                	test   %eax,%eax
8010580e:	74 30                	je     80105840 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105810:	83 ec 08             	sub    $0x8,%esp
80105813:	8d 14 3e             	lea    (%esi,%edi,1),%edx
80105816:	52                   	push   %edx
80105817:	50                   	push   %eax
80105818:	e8 63 f3 ff ff       	call   80104b80 <fetchstr>
8010581d:	83 c4 10             	add    $0x10,%esp
80105820:	85 c0                	test   %eax,%eax
80105822:	78 08                	js     8010582c <sys_exec+0xac>
  for(i=0;; i++){
80105824:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105827:	83 fb 20             	cmp    $0x20,%ebx
8010582a:	75 b4                	jne    801057e0 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
8010582c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
8010582f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105834:	5b                   	pop    %ebx
80105835:	5e                   	pop    %esi
80105836:	5f                   	pop    %edi
80105837:	5d                   	pop    %ebp
80105838:	c3                   	ret    
80105839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      argv[i] = 0;
80105840:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105847:	00 00 00 00 
  return exec(path, argv);
8010584b:	83 ec 08             	sub    $0x8,%esp
8010584e:	56                   	push   %esi
8010584f:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
80105855:	e8 86 b3 ff ff       	call   80100be0 <exec>
8010585a:	83 c4 10             	add    $0x10,%esp
}
8010585d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105860:	5b                   	pop    %ebx
80105861:	5e                   	pop    %esi
80105862:	5f                   	pop    %edi
80105863:	5d                   	pop    %ebp
80105864:	c3                   	ret    
80105865:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010586c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105870 <sys_pipe>:

int
sys_pipe(void)
{
80105870:	55                   	push   %ebp
80105871:	89 e5                	mov    %esp,%ebp
80105873:	57                   	push   %edi
80105874:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105875:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105878:	53                   	push   %ebx
80105879:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010587c:	6a 08                	push   $0x8
8010587e:	50                   	push   %eax
8010587f:	6a 00                	push   $0x0
80105881:	e8 9a f3 ff ff       	call   80104c20 <argptr>
80105886:	83 c4 10             	add    $0x10,%esp
80105889:	85 c0                	test   %eax,%eax
8010588b:	78 4a                	js     801058d7 <sys_pipe+0x67>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
8010588d:	83 ec 08             	sub    $0x8,%esp
80105890:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105893:	50                   	push   %eax
80105894:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105897:	50                   	push   %eax
80105898:	e8 53 dd ff ff       	call   801035f0 <pipealloc>
8010589d:	83 c4 10             	add    $0x10,%esp
801058a0:	85 c0                	test   %eax,%eax
801058a2:	78 33                	js     801058d7 <sys_pipe+0x67>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801058a4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
801058a7:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
801058a9:	e8 92 e2 ff ff       	call   80103b40 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801058ae:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
801058b0:	8b 74 98 2c          	mov    0x2c(%eax,%ebx,4),%esi
801058b4:	85 f6                	test   %esi,%esi
801058b6:	74 28                	je     801058e0 <sys_pipe+0x70>
  for(fd = 0; fd < NOFILE; fd++){
801058b8:	83 c3 01             	add    $0x1,%ebx
801058bb:	83 fb 10             	cmp    $0x10,%ebx
801058be:	75 f0                	jne    801058b0 <sys_pipe+0x40>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
801058c0:	83 ec 0c             	sub    $0xc,%esp
801058c3:	ff 75 e0             	push   -0x20(%ebp)
801058c6:	e8 55 b7 ff ff       	call   80101020 <fileclose>
    fileclose(wf);
801058cb:	58                   	pop    %eax
801058cc:	ff 75 e4             	push   -0x1c(%ebp)
801058cf:	e8 4c b7 ff ff       	call   80101020 <fileclose>
    return -1;
801058d4:	83 c4 10             	add    $0x10,%esp
801058d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058dc:	eb 53                	jmp    80105931 <sys_pipe+0xc1>
801058de:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
801058e0:	8d 73 08             	lea    0x8(%ebx),%esi
801058e3:	89 7c b0 0c          	mov    %edi,0xc(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801058e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
801058ea:	e8 51 e2 ff ff       	call   80103b40 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801058ef:	31 d2                	xor    %edx,%edx
801058f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
801058f8:	8b 4c 90 2c          	mov    0x2c(%eax,%edx,4),%ecx
801058fc:	85 c9                	test   %ecx,%ecx
801058fe:	74 20                	je     80105920 <sys_pipe+0xb0>
  for(fd = 0; fd < NOFILE; fd++){
80105900:	83 c2 01             	add    $0x1,%edx
80105903:	83 fa 10             	cmp    $0x10,%edx
80105906:	75 f0                	jne    801058f8 <sys_pipe+0x88>
      myproc()->ofile[fd0] = 0;
80105908:	e8 33 e2 ff ff       	call   80103b40 <myproc>
8010590d:	c7 44 b0 0c 00 00 00 	movl   $0x0,0xc(%eax,%esi,4)
80105914:	00 
80105915:	eb a9                	jmp    801058c0 <sys_pipe+0x50>
80105917:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010591e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105920:	89 7c 90 2c          	mov    %edi,0x2c(%eax,%edx,4)
  }
  fd[0] = fd0;
80105924:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105927:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80105929:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010592c:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
8010592f:	31 c0                	xor    %eax,%eax
}
80105931:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105934:	5b                   	pop    %ebx
80105935:	5e                   	pop    %esi
80105936:	5f                   	pop    %edi
80105937:	5d                   	pop    %ebp
80105938:	c3                   	ret    
80105939:	66 90                	xchg   %ax,%ax
8010593b:	66 90                	xchg   %ax,%ax
8010593d:	66 90                	xchg   %ax,%ax
8010593f:	90                   	nop

80105940 <sys_getNumFreePages>:


int
sys_getNumFreePages(void)
{
  return num_of_FreePages();  
80105940:	e9 3b cf ff ff       	jmp    80102880 <num_of_FreePages>
80105945:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010594c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105950 <sys_getrss>:
}

int 
sys_getrss()
{
80105950:	55                   	push   %ebp
80105951:	89 e5                	mov    %esp,%ebp
80105953:	83 ec 08             	sub    $0x8,%esp
  print_rss();
80105956:	e8 a5 e4 ff ff       	call   80103e00 <print_rss>
  return 0;
}
8010595b:	31 c0                	xor    %eax,%eax
8010595d:	c9                   	leave  
8010595e:	c3                   	ret    
8010595f:	90                   	nop

80105960 <sys_fork>:

int
sys_fork(void)
{
  return fork();
80105960:	e9 7b e3 ff ff       	jmp    80103ce0 <fork>
80105965:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010596c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105970 <sys_exit>:
}

int
sys_exit(void)
{
80105970:	55                   	push   %ebp
80105971:	89 e5                	mov    %esp,%ebp
80105973:	83 ec 08             	sub    $0x8,%esp
  exit();
80105976:	e8 55 e6 ff ff       	call   80103fd0 <exit>
  return 0;  // not reached
}
8010597b:	31 c0                	xor    %eax,%eax
8010597d:	c9                   	leave  
8010597e:	c3                   	ret    
8010597f:	90                   	nop

80105980 <sys_wait>:

int
sys_wait(void)
{
  return wait();
80105980:	e9 7b e7 ff ff       	jmp    80104100 <wait>
80105985:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010598c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105990 <sys_kill>:
}

int
sys_kill(void)
{
80105990:	55                   	push   %ebp
80105991:	89 e5                	mov    %esp,%ebp
80105993:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105996:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105999:	50                   	push   %eax
8010599a:	6a 00                	push   $0x0
8010599c:	e8 2f f2 ff ff       	call   80104bd0 <argint>
801059a1:	83 c4 10             	add    $0x10,%esp
801059a4:	85 c0                	test   %eax,%eax
801059a6:	78 18                	js     801059c0 <sys_kill+0x30>
    return -1;
  return kill(pid);
801059a8:	83 ec 0c             	sub    $0xc,%esp
801059ab:	ff 75 f4             	push   -0xc(%ebp)
801059ae:	e8 fd e9 ff ff       	call   801043b0 <kill>
801059b3:	83 c4 10             	add    $0x10,%esp
}
801059b6:	c9                   	leave  
801059b7:	c3                   	ret    
801059b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801059bf:	90                   	nop
801059c0:	c9                   	leave  
    return -1;
801059c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059c6:	c3                   	ret    
801059c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801059ce:	66 90                	xchg   %ax,%ax

801059d0 <sys_getpid>:

int
sys_getpid(void)
{
801059d0:	55                   	push   %ebp
801059d1:	89 e5                	mov    %esp,%ebp
801059d3:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801059d6:	e8 65 e1 ff ff       	call   80103b40 <myproc>
801059db:	8b 40 14             	mov    0x14(%eax),%eax
}
801059de:	c9                   	leave  
801059df:	c3                   	ret    

801059e0 <sys_sbrk>:

int
sys_sbrk(void)
{
801059e0:	55                   	push   %ebp
801059e1:	89 e5                	mov    %esp,%ebp
801059e3:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
801059e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
801059e7:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
801059ea:	50                   	push   %eax
801059eb:	6a 00                	push   $0x0
801059ed:	e8 de f1 ff ff       	call   80104bd0 <argint>
801059f2:	83 c4 10             	add    $0x10,%esp
801059f5:	85 c0                	test   %eax,%eax
801059f7:	78 27                	js     80105a20 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
801059f9:	e8 42 e1 ff ff       	call   80103b40 <myproc>
  if(growproc(n) < 0)
801059fe:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80105a01:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105a03:	ff 75 f4             	push   -0xc(%ebp)
80105a06:	e8 55 e2 ff ff       	call   80103c60 <growproc>
80105a0b:	83 c4 10             	add    $0x10,%esp
80105a0e:	85 c0                	test   %eax,%eax
80105a10:	78 0e                	js     80105a20 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105a12:	89 d8                	mov    %ebx,%eax
80105a14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105a17:	c9                   	leave  
80105a18:	c3                   	ret    
80105a19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105a20:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105a25:	eb eb                	jmp    80105a12 <sys_sbrk+0x32>
80105a27:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a2e:	66 90                	xchg   %ax,%ax

80105a30 <sys_sleep>:

int
sys_sleep(void)
{
80105a30:	55                   	push   %ebp
80105a31:	89 e5                	mov    %esp,%ebp
80105a33:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105a34:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105a37:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105a3a:	50                   	push   %eax
80105a3b:	6a 00                	push   $0x0
80105a3d:	e8 8e f1 ff ff       	call   80104bd0 <argint>
80105a42:	83 c4 10             	add    $0x10,%esp
80105a45:	85 c0                	test   %eax,%eax
80105a47:	0f 88 8a 00 00 00    	js     80105ad7 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105a4d:	83 ec 0c             	sub    $0xc,%esp
80105a50:	68 a0 4d 11 80       	push   $0x80114da0
80105a55:	e8 f6 ed ff ff       	call   80104850 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105a5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
80105a5d:	8b 1d 80 4d 11 80    	mov    0x80114d80,%ebx
  while(ticks - ticks0 < n){
80105a63:	83 c4 10             	add    $0x10,%esp
80105a66:	85 d2                	test   %edx,%edx
80105a68:	75 27                	jne    80105a91 <sys_sleep+0x61>
80105a6a:	eb 54                	jmp    80105ac0 <sys_sleep+0x90>
80105a6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105a70:	83 ec 08             	sub    $0x8,%esp
80105a73:	68 a0 4d 11 80       	push   $0x80114da0
80105a78:	68 80 4d 11 80       	push   $0x80114d80
80105a7d:	e8 0e e8 ff ff       	call   80104290 <sleep>
  while(ticks - ticks0 < n){
80105a82:	a1 80 4d 11 80       	mov    0x80114d80,%eax
80105a87:	83 c4 10             	add    $0x10,%esp
80105a8a:	29 d8                	sub    %ebx,%eax
80105a8c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105a8f:	73 2f                	jae    80105ac0 <sys_sleep+0x90>
    if(myproc()->killed){
80105a91:	e8 aa e0 ff ff       	call   80103b40 <myproc>
80105a96:	8b 40 28             	mov    0x28(%eax),%eax
80105a99:	85 c0                	test   %eax,%eax
80105a9b:	74 d3                	je     80105a70 <sys_sleep+0x40>
      release(&tickslock);
80105a9d:	83 ec 0c             	sub    $0xc,%esp
80105aa0:	68 a0 4d 11 80       	push   $0x80114da0
80105aa5:	e8 46 ed ff ff       	call   801047f0 <release>
  }
  release(&tickslock);
  return 0;
}
80105aaa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return -1;
80105aad:	83 c4 10             	add    $0x10,%esp
80105ab0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ab5:	c9                   	leave  
80105ab6:	c3                   	ret    
80105ab7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105abe:	66 90                	xchg   %ax,%ax
  release(&tickslock);
80105ac0:	83 ec 0c             	sub    $0xc,%esp
80105ac3:	68 a0 4d 11 80       	push   $0x80114da0
80105ac8:	e8 23 ed ff ff       	call   801047f0 <release>
  return 0;
80105acd:	83 c4 10             	add    $0x10,%esp
80105ad0:	31 c0                	xor    %eax,%eax
}
80105ad2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105ad5:	c9                   	leave  
80105ad6:	c3                   	ret    
    return -1;
80105ad7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adc:	eb f4                	jmp    80105ad2 <sys_sleep+0xa2>
80105ade:	66 90                	xchg   %ax,%ax

80105ae0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105ae0:	55                   	push   %ebp
80105ae1:	89 e5                	mov    %esp,%ebp
80105ae3:	53                   	push   %ebx
80105ae4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105ae7:	68 a0 4d 11 80       	push   $0x80114da0
80105aec:	e8 5f ed ff ff       	call   80104850 <acquire>
  xticks = ticks;
80105af1:	8b 1d 80 4d 11 80    	mov    0x80114d80,%ebx
  release(&tickslock);
80105af7:	c7 04 24 a0 4d 11 80 	movl   $0x80114da0,(%esp)
80105afe:	e8 ed ec ff ff       	call   801047f0 <release>
  return xticks;
}
80105b03:	89 d8                	mov    %ebx,%eax
80105b05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105b08:	c9                   	leave  
80105b09:	c3                   	ret    

80105b0a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105b0a:	1e                   	push   %ds
  pushl %es
80105b0b:	06                   	push   %es
  pushl %fs
80105b0c:	0f a0                	push   %fs
  pushl %gs
80105b0e:	0f a8                	push   %gs
  pushal
80105b10:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105b11:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105b15:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105b17:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105b19:	54                   	push   %esp
  call trap
80105b1a:	e8 c1 00 00 00       	call   80105be0 <trap>
  addl $4, %esp
80105b1f:	83 c4 04             	add    $0x4,%esp

80105b22 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105b22:	61                   	popa   
  popl %gs
80105b23:	0f a9                	pop    %gs
  popl %fs
80105b25:	0f a1                	pop    %fs
  popl %es
80105b27:	07                   	pop    %es
  popl %ds
80105b28:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105b29:	83 c4 08             	add    $0x8,%esp
  iret
80105b2c:	cf                   	iret   
80105b2d:	66 90                	xchg   %ax,%ax
80105b2f:	90                   	nop

80105b30 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105b30:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80105b31:	31 c0                	xor    %eax,%eax
{
80105b33:	89 e5                	mov    %esp,%ebp
80105b35:	83 ec 08             	sub    $0x8,%esp
80105b38:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105b3f:	90                   	nop
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105b40:	8b 14 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%edx
80105b47:	c7 04 c5 e2 4d 11 80 	movl   $0x8e000008,-0x7feeb21e(,%eax,8)
80105b4e:	08 00 00 8e 
80105b52:	66 89 14 c5 e0 4d 11 	mov    %dx,-0x7feeb220(,%eax,8)
80105b59:	80 
80105b5a:	c1 ea 10             	shr    $0x10,%edx
80105b5d:	66 89 14 c5 e6 4d 11 	mov    %dx,-0x7feeb21a(,%eax,8)
80105b64:	80 
  for(i = 0; i < 256; i++)
80105b65:	83 c0 01             	add    $0x1,%eax
80105b68:	3d 00 01 00 00       	cmp    $0x100,%eax
80105b6d:	75 d1                	jne    80105b40 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
80105b6f:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105b72:	a1 08 b1 10 80       	mov    0x8010b108,%eax
80105b77:	c7 05 e2 4f 11 80 08 	movl   $0xef000008,0x80114fe2
80105b7e:	00 00 ef 
  initlock(&tickslock, "time");
80105b81:	68 e1 7f 10 80       	push   $0x80107fe1
80105b86:	68 a0 4d 11 80       	push   $0x80114da0
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105b8b:	66 a3 e0 4f 11 80    	mov    %ax,0x80114fe0
80105b91:	c1 e8 10             	shr    $0x10,%eax
80105b94:	66 a3 e6 4f 11 80    	mov    %ax,0x80114fe6
  initlock(&tickslock, "time");
80105b9a:	e8 e1 ea ff ff       	call   80104680 <initlock>
}
80105b9f:	83 c4 10             	add    $0x10,%esp
80105ba2:	c9                   	leave  
80105ba3:	c3                   	ret    
80105ba4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105bab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105baf:	90                   	nop

80105bb0 <idtinit>:

void
idtinit(void)
{
80105bb0:	55                   	push   %ebp
  pd[0] = size-1;
80105bb1:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80105bb6:	89 e5                	mov    %esp,%ebp
80105bb8:	83 ec 10             	sub    $0x10,%esp
80105bbb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105bbf:	b8 e0 4d 11 80       	mov    $0x80114de0,%eax
80105bc4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105bc8:	c1 e8 10             	shr    $0x10,%eax
80105bcb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105bcf:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105bd2:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105bd5:	c9                   	leave  
80105bd6:	c3                   	ret    
80105bd7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105bde:	66 90                	xchg   %ax,%ax

80105be0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105be0:	55                   	push   %ebp
80105be1:	89 e5                	mov    %esp,%ebp
80105be3:	57                   	push   %edi
80105be4:	56                   	push   %esi
80105be5:	53                   	push   %ebx
80105be6:	83 ec 1c             	sub    $0x1c,%esp
80105be9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105bec:	8b 43 30             	mov    0x30(%ebx),%eax
80105bef:	83 f8 40             	cmp    $0x40,%eax
80105bf2:	0f 84 30 01 00 00    	je     80105d28 <trap+0x148>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105bf8:	83 e8 0e             	sub    $0xe,%eax
80105bfb:	83 f8 31             	cmp    $0x31,%eax
80105bfe:	0f 87 8c 00 00 00    	ja     80105c90 <trap+0xb0>
80105c04:	ff 24 85 88 80 10 80 	jmp    *-0x7fef7f78(,%eax,4)
80105c0b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105c0f:	90                   	nop
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105c10:	e8 0b df ff ff       	call   80103b20 <cpuid>
80105c15:	85 c0                	test   %eax,%eax
80105c17:	0f 84 13 02 00 00    	je     80105e30 <trap+0x250>
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
80105c1d:	e8 ae ce ff ff       	call   80102ad0 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105c22:	e8 19 df ff ff       	call   80103b40 <myproc>
80105c27:	85 c0                	test   %eax,%eax
80105c29:	74 1d                	je     80105c48 <trap+0x68>
80105c2b:	e8 10 df ff ff       	call   80103b40 <myproc>
80105c30:	8b 50 28             	mov    0x28(%eax),%edx
80105c33:	85 d2                	test   %edx,%edx
80105c35:	74 11                	je     80105c48 <trap+0x68>
80105c37:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105c3b:	83 e0 03             	and    $0x3,%eax
80105c3e:	66 83 f8 03          	cmp    $0x3,%ax
80105c42:	0f 84 c8 01 00 00    	je     80105e10 <trap+0x230>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105c48:	e8 f3 de ff ff       	call   80103b40 <myproc>
80105c4d:	85 c0                	test   %eax,%eax
80105c4f:	74 0f                	je     80105c60 <trap+0x80>
80105c51:	e8 ea de ff ff       	call   80103b40 <myproc>
80105c56:	83 78 10 04          	cmpl   $0x4,0x10(%eax)
80105c5a:	0f 84 b0 00 00 00    	je     80105d10 <trap+0x130>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105c60:	e8 db de ff ff       	call   80103b40 <myproc>
80105c65:	85 c0                	test   %eax,%eax
80105c67:	74 1d                	je     80105c86 <trap+0xa6>
80105c69:	e8 d2 de ff ff       	call   80103b40 <myproc>
80105c6e:	8b 40 28             	mov    0x28(%eax),%eax
80105c71:	85 c0                	test   %eax,%eax
80105c73:	74 11                	je     80105c86 <trap+0xa6>
80105c75:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105c79:	83 e0 03             	and    $0x3,%eax
80105c7c:	66 83 f8 03          	cmp    $0x3,%ax
80105c80:	0f 84 cf 00 00 00    	je     80105d55 <trap+0x175>
    exit();
80105c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105c89:	5b                   	pop    %ebx
80105c8a:	5e                   	pop    %esi
80105c8b:	5f                   	pop    %edi
80105c8c:	5d                   	pop    %ebp
80105c8d:	c3                   	ret    
80105c8e:	66 90                	xchg   %ax,%ax
    if(myproc() == 0 || (tf->cs&3) == 0){
80105c90:	e8 ab de ff ff       	call   80103b40 <myproc>
80105c95:	8b 7b 38             	mov    0x38(%ebx),%edi
80105c98:	85 c0                	test   %eax,%eax
80105c9a:	0f 84 c4 01 00 00    	je     80105e64 <trap+0x284>
80105ca0:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105ca4:	0f 84 ba 01 00 00    	je     80105e64 <trap+0x284>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105caa:	0f 20 d1             	mov    %cr2,%ecx
80105cad:	89 4d d8             	mov    %ecx,-0x28(%ebp)
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105cb0:	e8 6b de ff ff       	call   80103b20 <cpuid>
80105cb5:	8b 73 30             	mov    0x30(%ebx),%esi
80105cb8:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105cbb:	8b 43 34             	mov    0x34(%ebx),%eax
80105cbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            myproc()->pid, myproc()->name, tf->trapno,
80105cc1:	e8 7a de ff ff       	call   80103b40 <myproc>
80105cc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105cc9:	e8 72 de ff ff       	call   80103b40 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105cce:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105cd1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105cd4:	51                   	push   %ecx
80105cd5:	57                   	push   %edi
80105cd6:	52                   	push   %edx
80105cd7:	ff 75 e4             	push   -0x1c(%ebp)
80105cda:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
80105cdb:	8b 75 e0             	mov    -0x20(%ebp),%esi
80105cde:	83 c6 70             	add    $0x70,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105ce1:	56                   	push   %esi
80105ce2:	ff 70 14             	push   0x14(%eax)
80105ce5:	68 44 80 10 80       	push   $0x80108044
80105cea:	e8 e1 aa ff ff       	call   801007d0 <cprintf>
    myproc()->killed = 1;
80105cef:	83 c4 20             	add    $0x20,%esp
80105cf2:	e8 49 de ff ff       	call   80103b40 <myproc>
80105cf7:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105cfe:	e8 3d de ff ff       	call   80103b40 <myproc>
80105d03:	85 c0                	test   %eax,%eax
80105d05:	0f 85 20 ff ff ff    	jne    80105c2b <trap+0x4b>
80105d0b:	e9 38 ff ff ff       	jmp    80105c48 <trap+0x68>
  if(myproc() && myproc()->state == RUNNING &&
80105d10:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105d14:	0f 85 46 ff ff ff    	jne    80105c60 <trap+0x80>
    yield();
80105d1a:	e8 21 e5 ff ff       	call   80104240 <yield>
80105d1f:	e9 3c ff ff ff       	jmp    80105c60 <trap+0x80>
80105d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed)
80105d28:	e8 13 de ff ff       	call   80103b40 <myproc>
80105d2d:	8b 70 28             	mov    0x28(%eax),%esi
80105d30:	85 f6                	test   %esi,%esi
80105d32:	0f 85 e8 00 00 00    	jne    80105e20 <trap+0x240>
    myproc()->tf = tf;
80105d38:	e8 03 de ff ff       	call   80103b40 <myproc>
80105d3d:	89 58 1c             	mov    %ebx,0x1c(%eax)
    syscall();
80105d40:	e8 cb ef ff ff       	call   80104d10 <syscall>
    if(myproc()->killed)
80105d45:	e8 f6 dd ff ff       	call   80103b40 <myproc>
80105d4a:	8b 48 28             	mov    0x28(%eax),%ecx
80105d4d:	85 c9                	test   %ecx,%ecx
80105d4f:	0f 84 31 ff ff ff    	je     80105c86 <trap+0xa6>
80105d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d58:	5b                   	pop    %ebx
80105d59:	5e                   	pop    %esi
80105d5a:	5f                   	pop    %edi
80105d5b:	5d                   	pop    %ebp
      exit();
80105d5c:	e9 6f e2 ff ff       	jmp    80103fd0 <exit>
80105d61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105d68:	8b 7b 38             	mov    0x38(%ebx),%edi
80105d6b:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80105d6f:	e8 ac dd ff ff       	call   80103b20 <cpuid>
80105d74:	57                   	push   %edi
80105d75:	56                   	push   %esi
80105d76:	50                   	push   %eax
80105d77:	68 ec 7f 10 80       	push   $0x80107fec
80105d7c:	e8 4f aa ff ff       	call   801007d0 <cprintf>
    lapiceoi();
80105d81:	e8 4a cd ff ff       	call   80102ad0 <lapiceoi>
    break;
80105d86:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105d89:	e8 b2 dd ff ff       	call   80103b40 <myproc>
80105d8e:	85 c0                	test   %eax,%eax
80105d90:	0f 85 95 fe ff ff    	jne    80105c2b <trap+0x4b>
80105d96:	e9 ad fe ff ff       	jmp    80105c48 <trap+0x68>
80105d9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105d9f:	90                   	nop
    kbdintr();
80105da0:	e8 eb cb ff ff       	call   80102990 <kbdintr>
    lapiceoi();
80105da5:	e8 26 cd ff ff       	call   80102ad0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105daa:	e8 91 dd ff ff       	call   80103b40 <myproc>
80105daf:	85 c0                	test   %eax,%eax
80105db1:	0f 85 74 fe ff ff    	jne    80105c2b <trap+0x4b>
80105db7:	e9 8c fe ff ff       	jmp    80105c48 <trap+0x68>
80105dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    uartintr();
80105dc0:	e8 3b 02 00 00       	call   80106000 <uartintr>
    lapiceoi();
80105dc5:	e8 06 cd ff ff       	call   80102ad0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105dca:	e8 71 dd ff ff       	call   80103b40 <myproc>
80105dcf:	85 c0                	test   %eax,%eax
80105dd1:	0f 85 54 fe ff ff    	jne    80105c2b <trap+0x4b>
80105dd7:	e9 6c fe ff ff       	jmp    80105c48 <trap+0x68>
80105ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ideintr();
80105de0:	e8 8b c5 ff ff       	call   80102370 <ideintr>
80105de5:	e9 33 fe ff ff       	jmp    80105c1d <trap+0x3d>
80105dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    page_fault();
80105df0:	e8 7b 19 00 00       	call   80107770 <page_fault>
    lapiceoi();
80105df5:	e8 d6 cc ff ff       	call   80102ad0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105dfa:	e8 41 dd ff ff       	call   80103b40 <myproc>
80105dff:	85 c0                	test   %eax,%eax
80105e01:	0f 85 24 fe ff ff    	jne    80105c2b <trap+0x4b>
80105e07:	e9 3c fe ff ff       	jmp    80105c48 <trap+0x68>
80105e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    exit();
80105e10:	e8 bb e1 ff ff       	call   80103fd0 <exit>
80105e15:	e9 2e fe ff ff       	jmp    80105c48 <trap+0x68>
80105e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
80105e20:	e8 ab e1 ff ff       	call   80103fd0 <exit>
80105e25:	e9 0e ff ff ff       	jmp    80105d38 <trap+0x158>
80105e2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      acquire(&tickslock);
80105e30:	83 ec 0c             	sub    $0xc,%esp
80105e33:	68 a0 4d 11 80       	push   $0x80114da0
80105e38:	e8 13 ea ff ff       	call   80104850 <acquire>
      wakeup(&ticks);
80105e3d:	c7 04 24 80 4d 11 80 	movl   $0x80114d80,(%esp)
      ticks++;
80105e44:	83 05 80 4d 11 80 01 	addl   $0x1,0x80114d80
      wakeup(&ticks);
80105e4b:	e8 00 e5 ff ff       	call   80104350 <wakeup>
      release(&tickslock);
80105e50:	c7 04 24 a0 4d 11 80 	movl   $0x80114da0,(%esp)
80105e57:	e8 94 e9 ff ff       	call   801047f0 <release>
80105e5c:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80105e5f:	e9 b9 fd ff ff       	jmp    80105c1d <trap+0x3d>
80105e64:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105e67:	e8 b4 dc ff ff       	call   80103b20 <cpuid>
80105e6c:	83 ec 0c             	sub    $0xc,%esp
80105e6f:	56                   	push   %esi
80105e70:	57                   	push   %edi
80105e71:	50                   	push   %eax
80105e72:	ff 73 30             	push   0x30(%ebx)
80105e75:	68 10 80 10 80       	push   $0x80108010
80105e7a:	e8 51 a9 ff ff       	call   801007d0 <cprintf>
      panic("trap");
80105e7f:	83 c4 14             	add    $0x14,%esp
80105e82:	68 e6 7f 10 80       	push   $0x80107fe6
80105e87:	e8 24 a6 ff ff       	call   801004b0 <panic>
80105e8c:	66 90                	xchg   %ax,%ax
80105e8e:	66 90                	xchg   %ax,%ax

80105e90 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105e90:	a1 e0 55 11 80       	mov    0x801155e0,%eax
80105e95:	85 c0                	test   %eax,%eax
80105e97:	74 17                	je     80105eb0 <uartgetc+0x20>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105e99:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105e9e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105e9f:	a8 01                	test   $0x1,%al
80105ea1:	74 0d                	je     80105eb0 <uartgetc+0x20>
80105ea3:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105ea8:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105ea9:	0f b6 c0             	movzbl %al,%eax
80105eac:	c3                   	ret    
80105ead:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105eb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105eb5:	c3                   	ret    
80105eb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105ebd:	8d 76 00             	lea    0x0(%esi),%esi

80105ec0 <uartinit>:
{
80105ec0:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105ec1:	31 c9                	xor    %ecx,%ecx
80105ec3:	89 c8                	mov    %ecx,%eax
80105ec5:	89 e5                	mov    %esp,%ebp
80105ec7:	57                   	push   %edi
80105ec8:	bf fa 03 00 00       	mov    $0x3fa,%edi
80105ecd:	56                   	push   %esi
80105ece:	89 fa                	mov    %edi,%edx
80105ed0:	53                   	push   %ebx
80105ed1:	83 ec 1c             	sub    $0x1c,%esp
80105ed4:	ee                   	out    %al,(%dx)
80105ed5:	be fb 03 00 00       	mov    $0x3fb,%esi
80105eda:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105edf:	89 f2                	mov    %esi,%edx
80105ee1:	ee                   	out    %al,(%dx)
80105ee2:	b8 0c 00 00 00       	mov    $0xc,%eax
80105ee7:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105eec:	ee                   	out    %al,(%dx)
80105eed:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105ef2:	89 c8                	mov    %ecx,%eax
80105ef4:	89 da                	mov    %ebx,%edx
80105ef6:	ee                   	out    %al,(%dx)
80105ef7:	b8 03 00 00 00       	mov    $0x3,%eax
80105efc:	89 f2                	mov    %esi,%edx
80105efe:	ee                   	out    %al,(%dx)
80105eff:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105f04:	89 c8                	mov    %ecx,%eax
80105f06:	ee                   	out    %al,(%dx)
80105f07:	b8 01 00 00 00       	mov    $0x1,%eax
80105f0c:	89 da                	mov    %ebx,%edx
80105f0e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105f0f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105f14:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105f15:	3c ff                	cmp    $0xff,%al
80105f17:	74 78                	je     80105f91 <uartinit+0xd1>
  uart = 1;
80105f19:	c7 05 e0 55 11 80 01 	movl   $0x1,0x801155e0
80105f20:	00 00 00 
80105f23:	89 fa                	mov    %edi,%edx
80105f25:	ec                   	in     (%dx),%al
80105f26:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105f2b:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105f2c:	83 ec 08             	sub    $0x8,%esp
  for(p="xv6...\n"; *p; p++)
80105f2f:	bf 50 81 10 80       	mov    $0x80108150,%edi
80105f34:	be fd 03 00 00       	mov    $0x3fd,%esi
  ioapicenable(IRQ_COM1, 0);
80105f39:	6a 00                	push   $0x0
80105f3b:	6a 04                	push   $0x4
80105f3d:	e8 6e c6 ff ff       	call   801025b0 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105f42:	c6 45 e7 78          	movb   $0x78,-0x19(%ebp)
  ioapicenable(IRQ_COM1, 0);
80105f46:	83 c4 10             	add    $0x10,%esp
80105f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(!uart)
80105f50:	a1 e0 55 11 80       	mov    0x801155e0,%eax
80105f55:	bb 80 00 00 00       	mov    $0x80,%ebx
80105f5a:	85 c0                	test   %eax,%eax
80105f5c:	75 14                	jne    80105f72 <uartinit+0xb2>
80105f5e:	eb 23                	jmp    80105f83 <uartinit+0xc3>
    microdelay(10);
80105f60:	83 ec 0c             	sub    $0xc,%esp
80105f63:	6a 0a                	push   $0xa
80105f65:	e8 86 cb ff ff       	call   80102af0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105f6a:	83 c4 10             	add    $0x10,%esp
80105f6d:	83 eb 01             	sub    $0x1,%ebx
80105f70:	74 07                	je     80105f79 <uartinit+0xb9>
80105f72:	89 f2                	mov    %esi,%edx
80105f74:	ec                   	in     (%dx),%al
80105f75:	a8 20                	test   $0x20,%al
80105f77:	74 e7                	je     80105f60 <uartinit+0xa0>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105f79:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
80105f7d:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105f82:	ee                   	out    %al,(%dx)
  for(p="xv6...\n"; *p; p++)
80105f83:	0f b6 47 01          	movzbl 0x1(%edi),%eax
80105f87:	83 c7 01             	add    $0x1,%edi
80105f8a:	88 45 e7             	mov    %al,-0x19(%ebp)
80105f8d:	84 c0                	test   %al,%al
80105f8f:	75 bf                	jne    80105f50 <uartinit+0x90>
}
80105f91:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f94:	5b                   	pop    %ebx
80105f95:	5e                   	pop    %esi
80105f96:	5f                   	pop    %edi
80105f97:	5d                   	pop    %ebp
80105f98:	c3                   	ret    
80105f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105fa0 <uartputc>:
  if(!uart)
80105fa0:	a1 e0 55 11 80       	mov    0x801155e0,%eax
80105fa5:	85 c0                	test   %eax,%eax
80105fa7:	74 47                	je     80105ff0 <uartputc+0x50>
{
80105fa9:	55                   	push   %ebp
80105faa:	89 e5                	mov    %esp,%ebp
80105fac:	56                   	push   %esi
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105fad:	be fd 03 00 00       	mov    $0x3fd,%esi
80105fb2:	53                   	push   %ebx
80105fb3:	bb 80 00 00 00       	mov    $0x80,%ebx
80105fb8:	eb 18                	jmp    80105fd2 <uartputc+0x32>
80105fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    microdelay(10);
80105fc0:	83 ec 0c             	sub    $0xc,%esp
80105fc3:	6a 0a                	push   $0xa
80105fc5:	e8 26 cb ff ff       	call   80102af0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105fca:	83 c4 10             	add    $0x10,%esp
80105fcd:	83 eb 01             	sub    $0x1,%ebx
80105fd0:	74 07                	je     80105fd9 <uartputc+0x39>
80105fd2:	89 f2                	mov    %esi,%edx
80105fd4:	ec                   	in     (%dx),%al
80105fd5:	a8 20                	test   $0x20,%al
80105fd7:	74 e7                	je     80105fc0 <uartputc+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80105fdc:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105fe1:	ee                   	out    %al,(%dx)
}
80105fe2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105fe5:	5b                   	pop    %ebx
80105fe6:	5e                   	pop    %esi
80105fe7:	5d                   	pop    %ebp
80105fe8:	c3                   	ret    
80105fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105ff0:	c3                   	ret    
80105ff1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105ff8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105fff:	90                   	nop

80106000 <uartintr>:

void
uartintr(void)
{
80106000:	55                   	push   %ebp
80106001:	89 e5                	mov    %esp,%ebp
80106003:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80106006:	68 90 5e 10 80       	push   $0x80105e90
8010600b:	e8 a0 a9 ff ff       	call   801009b0 <consoleintr>
}
80106010:	83 c4 10             	add    $0x10,%esp
80106013:	c9                   	leave  
80106014:	c3                   	ret    

80106015 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106015:	6a 00                	push   $0x0
  pushl $0
80106017:	6a 00                	push   $0x0
  jmp alltraps
80106019:	e9 ec fa ff ff       	jmp    80105b0a <alltraps>

8010601e <vector1>:
.globl vector1
vector1:
  pushl $0
8010601e:	6a 00                	push   $0x0
  pushl $1
80106020:	6a 01                	push   $0x1
  jmp alltraps
80106022:	e9 e3 fa ff ff       	jmp    80105b0a <alltraps>

80106027 <vector2>:
.globl vector2
vector2:
  pushl $0
80106027:	6a 00                	push   $0x0
  pushl $2
80106029:	6a 02                	push   $0x2
  jmp alltraps
8010602b:	e9 da fa ff ff       	jmp    80105b0a <alltraps>

80106030 <vector3>:
.globl vector3
vector3:
  pushl $0
80106030:	6a 00                	push   $0x0
  pushl $3
80106032:	6a 03                	push   $0x3
  jmp alltraps
80106034:	e9 d1 fa ff ff       	jmp    80105b0a <alltraps>

80106039 <vector4>:
.globl vector4
vector4:
  pushl $0
80106039:	6a 00                	push   $0x0
  pushl $4
8010603b:	6a 04                	push   $0x4
  jmp alltraps
8010603d:	e9 c8 fa ff ff       	jmp    80105b0a <alltraps>

80106042 <vector5>:
.globl vector5
vector5:
  pushl $0
80106042:	6a 00                	push   $0x0
  pushl $5
80106044:	6a 05                	push   $0x5
  jmp alltraps
80106046:	e9 bf fa ff ff       	jmp    80105b0a <alltraps>

8010604b <vector6>:
.globl vector6
vector6:
  pushl $0
8010604b:	6a 00                	push   $0x0
  pushl $6
8010604d:	6a 06                	push   $0x6
  jmp alltraps
8010604f:	e9 b6 fa ff ff       	jmp    80105b0a <alltraps>

80106054 <vector7>:
.globl vector7
vector7:
  pushl $0
80106054:	6a 00                	push   $0x0
  pushl $7
80106056:	6a 07                	push   $0x7
  jmp alltraps
80106058:	e9 ad fa ff ff       	jmp    80105b0a <alltraps>

8010605d <vector8>:
.globl vector8
vector8:
  pushl $8
8010605d:	6a 08                	push   $0x8
  jmp alltraps
8010605f:	e9 a6 fa ff ff       	jmp    80105b0a <alltraps>

80106064 <vector9>:
.globl vector9
vector9:
  pushl $0
80106064:	6a 00                	push   $0x0
  pushl $9
80106066:	6a 09                	push   $0x9
  jmp alltraps
80106068:	e9 9d fa ff ff       	jmp    80105b0a <alltraps>

8010606d <vector10>:
.globl vector10
vector10:
  pushl $10
8010606d:	6a 0a                	push   $0xa
  jmp alltraps
8010606f:	e9 96 fa ff ff       	jmp    80105b0a <alltraps>

80106074 <vector11>:
.globl vector11
vector11:
  pushl $11
80106074:	6a 0b                	push   $0xb
  jmp alltraps
80106076:	e9 8f fa ff ff       	jmp    80105b0a <alltraps>

8010607b <vector12>:
.globl vector12
vector12:
  pushl $12
8010607b:	6a 0c                	push   $0xc
  jmp alltraps
8010607d:	e9 88 fa ff ff       	jmp    80105b0a <alltraps>

80106082 <vector13>:
.globl vector13
vector13:
  pushl $13
80106082:	6a 0d                	push   $0xd
  jmp alltraps
80106084:	e9 81 fa ff ff       	jmp    80105b0a <alltraps>

80106089 <vector14>:
.globl vector14
vector14:
  pushl $14
80106089:	6a 0e                	push   $0xe
  jmp alltraps
8010608b:	e9 7a fa ff ff       	jmp    80105b0a <alltraps>

80106090 <vector15>:
.globl vector15
vector15:
  pushl $0
80106090:	6a 00                	push   $0x0
  pushl $15
80106092:	6a 0f                	push   $0xf
  jmp alltraps
80106094:	e9 71 fa ff ff       	jmp    80105b0a <alltraps>

80106099 <vector16>:
.globl vector16
vector16:
  pushl $0
80106099:	6a 00                	push   $0x0
  pushl $16
8010609b:	6a 10                	push   $0x10
  jmp alltraps
8010609d:	e9 68 fa ff ff       	jmp    80105b0a <alltraps>

801060a2 <vector17>:
.globl vector17
vector17:
  pushl $17
801060a2:	6a 11                	push   $0x11
  jmp alltraps
801060a4:	e9 61 fa ff ff       	jmp    80105b0a <alltraps>

801060a9 <vector18>:
.globl vector18
vector18:
  pushl $0
801060a9:	6a 00                	push   $0x0
  pushl $18
801060ab:	6a 12                	push   $0x12
  jmp alltraps
801060ad:	e9 58 fa ff ff       	jmp    80105b0a <alltraps>

801060b2 <vector19>:
.globl vector19
vector19:
  pushl $0
801060b2:	6a 00                	push   $0x0
  pushl $19
801060b4:	6a 13                	push   $0x13
  jmp alltraps
801060b6:	e9 4f fa ff ff       	jmp    80105b0a <alltraps>

801060bb <vector20>:
.globl vector20
vector20:
  pushl $0
801060bb:	6a 00                	push   $0x0
  pushl $20
801060bd:	6a 14                	push   $0x14
  jmp alltraps
801060bf:	e9 46 fa ff ff       	jmp    80105b0a <alltraps>

801060c4 <vector21>:
.globl vector21
vector21:
  pushl $0
801060c4:	6a 00                	push   $0x0
  pushl $21
801060c6:	6a 15                	push   $0x15
  jmp alltraps
801060c8:	e9 3d fa ff ff       	jmp    80105b0a <alltraps>

801060cd <vector22>:
.globl vector22
vector22:
  pushl $0
801060cd:	6a 00                	push   $0x0
  pushl $22
801060cf:	6a 16                	push   $0x16
  jmp alltraps
801060d1:	e9 34 fa ff ff       	jmp    80105b0a <alltraps>

801060d6 <vector23>:
.globl vector23
vector23:
  pushl $0
801060d6:	6a 00                	push   $0x0
  pushl $23
801060d8:	6a 17                	push   $0x17
  jmp alltraps
801060da:	e9 2b fa ff ff       	jmp    80105b0a <alltraps>

801060df <vector24>:
.globl vector24
vector24:
  pushl $0
801060df:	6a 00                	push   $0x0
  pushl $24
801060e1:	6a 18                	push   $0x18
  jmp alltraps
801060e3:	e9 22 fa ff ff       	jmp    80105b0a <alltraps>

801060e8 <vector25>:
.globl vector25
vector25:
  pushl $0
801060e8:	6a 00                	push   $0x0
  pushl $25
801060ea:	6a 19                	push   $0x19
  jmp alltraps
801060ec:	e9 19 fa ff ff       	jmp    80105b0a <alltraps>

801060f1 <vector26>:
.globl vector26
vector26:
  pushl $0
801060f1:	6a 00                	push   $0x0
  pushl $26
801060f3:	6a 1a                	push   $0x1a
  jmp alltraps
801060f5:	e9 10 fa ff ff       	jmp    80105b0a <alltraps>

801060fa <vector27>:
.globl vector27
vector27:
  pushl $0
801060fa:	6a 00                	push   $0x0
  pushl $27
801060fc:	6a 1b                	push   $0x1b
  jmp alltraps
801060fe:	e9 07 fa ff ff       	jmp    80105b0a <alltraps>

80106103 <vector28>:
.globl vector28
vector28:
  pushl $0
80106103:	6a 00                	push   $0x0
  pushl $28
80106105:	6a 1c                	push   $0x1c
  jmp alltraps
80106107:	e9 fe f9 ff ff       	jmp    80105b0a <alltraps>

8010610c <vector29>:
.globl vector29
vector29:
  pushl $0
8010610c:	6a 00                	push   $0x0
  pushl $29
8010610e:	6a 1d                	push   $0x1d
  jmp alltraps
80106110:	e9 f5 f9 ff ff       	jmp    80105b0a <alltraps>

80106115 <vector30>:
.globl vector30
vector30:
  pushl $0
80106115:	6a 00                	push   $0x0
  pushl $30
80106117:	6a 1e                	push   $0x1e
  jmp alltraps
80106119:	e9 ec f9 ff ff       	jmp    80105b0a <alltraps>

8010611e <vector31>:
.globl vector31
vector31:
  pushl $0
8010611e:	6a 00                	push   $0x0
  pushl $31
80106120:	6a 1f                	push   $0x1f
  jmp alltraps
80106122:	e9 e3 f9 ff ff       	jmp    80105b0a <alltraps>

80106127 <vector32>:
.globl vector32
vector32:
  pushl $0
80106127:	6a 00                	push   $0x0
  pushl $32
80106129:	6a 20                	push   $0x20
  jmp alltraps
8010612b:	e9 da f9 ff ff       	jmp    80105b0a <alltraps>

80106130 <vector33>:
.globl vector33
vector33:
  pushl $0
80106130:	6a 00                	push   $0x0
  pushl $33
80106132:	6a 21                	push   $0x21
  jmp alltraps
80106134:	e9 d1 f9 ff ff       	jmp    80105b0a <alltraps>

80106139 <vector34>:
.globl vector34
vector34:
  pushl $0
80106139:	6a 00                	push   $0x0
  pushl $34
8010613b:	6a 22                	push   $0x22
  jmp alltraps
8010613d:	e9 c8 f9 ff ff       	jmp    80105b0a <alltraps>

80106142 <vector35>:
.globl vector35
vector35:
  pushl $0
80106142:	6a 00                	push   $0x0
  pushl $35
80106144:	6a 23                	push   $0x23
  jmp alltraps
80106146:	e9 bf f9 ff ff       	jmp    80105b0a <alltraps>

8010614b <vector36>:
.globl vector36
vector36:
  pushl $0
8010614b:	6a 00                	push   $0x0
  pushl $36
8010614d:	6a 24                	push   $0x24
  jmp alltraps
8010614f:	e9 b6 f9 ff ff       	jmp    80105b0a <alltraps>

80106154 <vector37>:
.globl vector37
vector37:
  pushl $0
80106154:	6a 00                	push   $0x0
  pushl $37
80106156:	6a 25                	push   $0x25
  jmp alltraps
80106158:	e9 ad f9 ff ff       	jmp    80105b0a <alltraps>

8010615d <vector38>:
.globl vector38
vector38:
  pushl $0
8010615d:	6a 00                	push   $0x0
  pushl $38
8010615f:	6a 26                	push   $0x26
  jmp alltraps
80106161:	e9 a4 f9 ff ff       	jmp    80105b0a <alltraps>

80106166 <vector39>:
.globl vector39
vector39:
  pushl $0
80106166:	6a 00                	push   $0x0
  pushl $39
80106168:	6a 27                	push   $0x27
  jmp alltraps
8010616a:	e9 9b f9 ff ff       	jmp    80105b0a <alltraps>

8010616f <vector40>:
.globl vector40
vector40:
  pushl $0
8010616f:	6a 00                	push   $0x0
  pushl $40
80106171:	6a 28                	push   $0x28
  jmp alltraps
80106173:	e9 92 f9 ff ff       	jmp    80105b0a <alltraps>

80106178 <vector41>:
.globl vector41
vector41:
  pushl $0
80106178:	6a 00                	push   $0x0
  pushl $41
8010617a:	6a 29                	push   $0x29
  jmp alltraps
8010617c:	e9 89 f9 ff ff       	jmp    80105b0a <alltraps>

80106181 <vector42>:
.globl vector42
vector42:
  pushl $0
80106181:	6a 00                	push   $0x0
  pushl $42
80106183:	6a 2a                	push   $0x2a
  jmp alltraps
80106185:	e9 80 f9 ff ff       	jmp    80105b0a <alltraps>

8010618a <vector43>:
.globl vector43
vector43:
  pushl $0
8010618a:	6a 00                	push   $0x0
  pushl $43
8010618c:	6a 2b                	push   $0x2b
  jmp alltraps
8010618e:	e9 77 f9 ff ff       	jmp    80105b0a <alltraps>

80106193 <vector44>:
.globl vector44
vector44:
  pushl $0
80106193:	6a 00                	push   $0x0
  pushl $44
80106195:	6a 2c                	push   $0x2c
  jmp alltraps
80106197:	e9 6e f9 ff ff       	jmp    80105b0a <alltraps>

8010619c <vector45>:
.globl vector45
vector45:
  pushl $0
8010619c:	6a 00                	push   $0x0
  pushl $45
8010619e:	6a 2d                	push   $0x2d
  jmp alltraps
801061a0:	e9 65 f9 ff ff       	jmp    80105b0a <alltraps>

801061a5 <vector46>:
.globl vector46
vector46:
  pushl $0
801061a5:	6a 00                	push   $0x0
  pushl $46
801061a7:	6a 2e                	push   $0x2e
  jmp alltraps
801061a9:	e9 5c f9 ff ff       	jmp    80105b0a <alltraps>

801061ae <vector47>:
.globl vector47
vector47:
  pushl $0
801061ae:	6a 00                	push   $0x0
  pushl $47
801061b0:	6a 2f                	push   $0x2f
  jmp alltraps
801061b2:	e9 53 f9 ff ff       	jmp    80105b0a <alltraps>

801061b7 <vector48>:
.globl vector48
vector48:
  pushl $0
801061b7:	6a 00                	push   $0x0
  pushl $48
801061b9:	6a 30                	push   $0x30
  jmp alltraps
801061bb:	e9 4a f9 ff ff       	jmp    80105b0a <alltraps>

801061c0 <vector49>:
.globl vector49
vector49:
  pushl $0
801061c0:	6a 00                	push   $0x0
  pushl $49
801061c2:	6a 31                	push   $0x31
  jmp alltraps
801061c4:	e9 41 f9 ff ff       	jmp    80105b0a <alltraps>

801061c9 <vector50>:
.globl vector50
vector50:
  pushl $0
801061c9:	6a 00                	push   $0x0
  pushl $50
801061cb:	6a 32                	push   $0x32
  jmp alltraps
801061cd:	e9 38 f9 ff ff       	jmp    80105b0a <alltraps>

801061d2 <vector51>:
.globl vector51
vector51:
  pushl $0
801061d2:	6a 00                	push   $0x0
  pushl $51
801061d4:	6a 33                	push   $0x33
  jmp alltraps
801061d6:	e9 2f f9 ff ff       	jmp    80105b0a <alltraps>

801061db <vector52>:
.globl vector52
vector52:
  pushl $0
801061db:	6a 00                	push   $0x0
  pushl $52
801061dd:	6a 34                	push   $0x34
  jmp alltraps
801061df:	e9 26 f9 ff ff       	jmp    80105b0a <alltraps>

801061e4 <vector53>:
.globl vector53
vector53:
  pushl $0
801061e4:	6a 00                	push   $0x0
  pushl $53
801061e6:	6a 35                	push   $0x35
  jmp alltraps
801061e8:	e9 1d f9 ff ff       	jmp    80105b0a <alltraps>

801061ed <vector54>:
.globl vector54
vector54:
  pushl $0
801061ed:	6a 00                	push   $0x0
  pushl $54
801061ef:	6a 36                	push   $0x36
  jmp alltraps
801061f1:	e9 14 f9 ff ff       	jmp    80105b0a <alltraps>

801061f6 <vector55>:
.globl vector55
vector55:
  pushl $0
801061f6:	6a 00                	push   $0x0
  pushl $55
801061f8:	6a 37                	push   $0x37
  jmp alltraps
801061fa:	e9 0b f9 ff ff       	jmp    80105b0a <alltraps>

801061ff <vector56>:
.globl vector56
vector56:
  pushl $0
801061ff:	6a 00                	push   $0x0
  pushl $56
80106201:	6a 38                	push   $0x38
  jmp alltraps
80106203:	e9 02 f9 ff ff       	jmp    80105b0a <alltraps>

80106208 <vector57>:
.globl vector57
vector57:
  pushl $0
80106208:	6a 00                	push   $0x0
  pushl $57
8010620a:	6a 39                	push   $0x39
  jmp alltraps
8010620c:	e9 f9 f8 ff ff       	jmp    80105b0a <alltraps>

80106211 <vector58>:
.globl vector58
vector58:
  pushl $0
80106211:	6a 00                	push   $0x0
  pushl $58
80106213:	6a 3a                	push   $0x3a
  jmp alltraps
80106215:	e9 f0 f8 ff ff       	jmp    80105b0a <alltraps>

8010621a <vector59>:
.globl vector59
vector59:
  pushl $0
8010621a:	6a 00                	push   $0x0
  pushl $59
8010621c:	6a 3b                	push   $0x3b
  jmp alltraps
8010621e:	e9 e7 f8 ff ff       	jmp    80105b0a <alltraps>

80106223 <vector60>:
.globl vector60
vector60:
  pushl $0
80106223:	6a 00                	push   $0x0
  pushl $60
80106225:	6a 3c                	push   $0x3c
  jmp alltraps
80106227:	e9 de f8 ff ff       	jmp    80105b0a <alltraps>

8010622c <vector61>:
.globl vector61
vector61:
  pushl $0
8010622c:	6a 00                	push   $0x0
  pushl $61
8010622e:	6a 3d                	push   $0x3d
  jmp alltraps
80106230:	e9 d5 f8 ff ff       	jmp    80105b0a <alltraps>

80106235 <vector62>:
.globl vector62
vector62:
  pushl $0
80106235:	6a 00                	push   $0x0
  pushl $62
80106237:	6a 3e                	push   $0x3e
  jmp alltraps
80106239:	e9 cc f8 ff ff       	jmp    80105b0a <alltraps>

8010623e <vector63>:
.globl vector63
vector63:
  pushl $0
8010623e:	6a 00                	push   $0x0
  pushl $63
80106240:	6a 3f                	push   $0x3f
  jmp alltraps
80106242:	e9 c3 f8 ff ff       	jmp    80105b0a <alltraps>

80106247 <vector64>:
.globl vector64
vector64:
  pushl $0
80106247:	6a 00                	push   $0x0
  pushl $64
80106249:	6a 40                	push   $0x40
  jmp alltraps
8010624b:	e9 ba f8 ff ff       	jmp    80105b0a <alltraps>

80106250 <vector65>:
.globl vector65
vector65:
  pushl $0
80106250:	6a 00                	push   $0x0
  pushl $65
80106252:	6a 41                	push   $0x41
  jmp alltraps
80106254:	e9 b1 f8 ff ff       	jmp    80105b0a <alltraps>

80106259 <vector66>:
.globl vector66
vector66:
  pushl $0
80106259:	6a 00                	push   $0x0
  pushl $66
8010625b:	6a 42                	push   $0x42
  jmp alltraps
8010625d:	e9 a8 f8 ff ff       	jmp    80105b0a <alltraps>

80106262 <vector67>:
.globl vector67
vector67:
  pushl $0
80106262:	6a 00                	push   $0x0
  pushl $67
80106264:	6a 43                	push   $0x43
  jmp alltraps
80106266:	e9 9f f8 ff ff       	jmp    80105b0a <alltraps>

8010626b <vector68>:
.globl vector68
vector68:
  pushl $0
8010626b:	6a 00                	push   $0x0
  pushl $68
8010626d:	6a 44                	push   $0x44
  jmp alltraps
8010626f:	e9 96 f8 ff ff       	jmp    80105b0a <alltraps>

80106274 <vector69>:
.globl vector69
vector69:
  pushl $0
80106274:	6a 00                	push   $0x0
  pushl $69
80106276:	6a 45                	push   $0x45
  jmp alltraps
80106278:	e9 8d f8 ff ff       	jmp    80105b0a <alltraps>

8010627d <vector70>:
.globl vector70
vector70:
  pushl $0
8010627d:	6a 00                	push   $0x0
  pushl $70
8010627f:	6a 46                	push   $0x46
  jmp alltraps
80106281:	e9 84 f8 ff ff       	jmp    80105b0a <alltraps>

80106286 <vector71>:
.globl vector71
vector71:
  pushl $0
80106286:	6a 00                	push   $0x0
  pushl $71
80106288:	6a 47                	push   $0x47
  jmp alltraps
8010628a:	e9 7b f8 ff ff       	jmp    80105b0a <alltraps>

8010628f <vector72>:
.globl vector72
vector72:
  pushl $0
8010628f:	6a 00                	push   $0x0
  pushl $72
80106291:	6a 48                	push   $0x48
  jmp alltraps
80106293:	e9 72 f8 ff ff       	jmp    80105b0a <alltraps>

80106298 <vector73>:
.globl vector73
vector73:
  pushl $0
80106298:	6a 00                	push   $0x0
  pushl $73
8010629a:	6a 49                	push   $0x49
  jmp alltraps
8010629c:	e9 69 f8 ff ff       	jmp    80105b0a <alltraps>

801062a1 <vector74>:
.globl vector74
vector74:
  pushl $0
801062a1:	6a 00                	push   $0x0
  pushl $74
801062a3:	6a 4a                	push   $0x4a
  jmp alltraps
801062a5:	e9 60 f8 ff ff       	jmp    80105b0a <alltraps>

801062aa <vector75>:
.globl vector75
vector75:
  pushl $0
801062aa:	6a 00                	push   $0x0
  pushl $75
801062ac:	6a 4b                	push   $0x4b
  jmp alltraps
801062ae:	e9 57 f8 ff ff       	jmp    80105b0a <alltraps>

801062b3 <vector76>:
.globl vector76
vector76:
  pushl $0
801062b3:	6a 00                	push   $0x0
  pushl $76
801062b5:	6a 4c                	push   $0x4c
  jmp alltraps
801062b7:	e9 4e f8 ff ff       	jmp    80105b0a <alltraps>

801062bc <vector77>:
.globl vector77
vector77:
  pushl $0
801062bc:	6a 00                	push   $0x0
  pushl $77
801062be:	6a 4d                	push   $0x4d
  jmp alltraps
801062c0:	e9 45 f8 ff ff       	jmp    80105b0a <alltraps>

801062c5 <vector78>:
.globl vector78
vector78:
  pushl $0
801062c5:	6a 00                	push   $0x0
  pushl $78
801062c7:	6a 4e                	push   $0x4e
  jmp alltraps
801062c9:	e9 3c f8 ff ff       	jmp    80105b0a <alltraps>

801062ce <vector79>:
.globl vector79
vector79:
  pushl $0
801062ce:	6a 00                	push   $0x0
  pushl $79
801062d0:	6a 4f                	push   $0x4f
  jmp alltraps
801062d2:	e9 33 f8 ff ff       	jmp    80105b0a <alltraps>

801062d7 <vector80>:
.globl vector80
vector80:
  pushl $0
801062d7:	6a 00                	push   $0x0
  pushl $80
801062d9:	6a 50                	push   $0x50
  jmp alltraps
801062db:	e9 2a f8 ff ff       	jmp    80105b0a <alltraps>

801062e0 <vector81>:
.globl vector81
vector81:
  pushl $0
801062e0:	6a 00                	push   $0x0
  pushl $81
801062e2:	6a 51                	push   $0x51
  jmp alltraps
801062e4:	e9 21 f8 ff ff       	jmp    80105b0a <alltraps>

801062e9 <vector82>:
.globl vector82
vector82:
  pushl $0
801062e9:	6a 00                	push   $0x0
  pushl $82
801062eb:	6a 52                	push   $0x52
  jmp alltraps
801062ed:	e9 18 f8 ff ff       	jmp    80105b0a <alltraps>

801062f2 <vector83>:
.globl vector83
vector83:
  pushl $0
801062f2:	6a 00                	push   $0x0
  pushl $83
801062f4:	6a 53                	push   $0x53
  jmp alltraps
801062f6:	e9 0f f8 ff ff       	jmp    80105b0a <alltraps>

801062fb <vector84>:
.globl vector84
vector84:
  pushl $0
801062fb:	6a 00                	push   $0x0
  pushl $84
801062fd:	6a 54                	push   $0x54
  jmp alltraps
801062ff:	e9 06 f8 ff ff       	jmp    80105b0a <alltraps>

80106304 <vector85>:
.globl vector85
vector85:
  pushl $0
80106304:	6a 00                	push   $0x0
  pushl $85
80106306:	6a 55                	push   $0x55
  jmp alltraps
80106308:	e9 fd f7 ff ff       	jmp    80105b0a <alltraps>

8010630d <vector86>:
.globl vector86
vector86:
  pushl $0
8010630d:	6a 00                	push   $0x0
  pushl $86
8010630f:	6a 56                	push   $0x56
  jmp alltraps
80106311:	e9 f4 f7 ff ff       	jmp    80105b0a <alltraps>

80106316 <vector87>:
.globl vector87
vector87:
  pushl $0
80106316:	6a 00                	push   $0x0
  pushl $87
80106318:	6a 57                	push   $0x57
  jmp alltraps
8010631a:	e9 eb f7 ff ff       	jmp    80105b0a <alltraps>

8010631f <vector88>:
.globl vector88
vector88:
  pushl $0
8010631f:	6a 00                	push   $0x0
  pushl $88
80106321:	6a 58                	push   $0x58
  jmp alltraps
80106323:	e9 e2 f7 ff ff       	jmp    80105b0a <alltraps>

80106328 <vector89>:
.globl vector89
vector89:
  pushl $0
80106328:	6a 00                	push   $0x0
  pushl $89
8010632a:	6a 59                	push   $0x59
  jmp alltraps
8010632c:	e9 d9 f7 ff ff       	jmp    80105b0a <alltraps>

80106331 <vector90>:
.globl vector90
vector90:
  pushl $0
80106331:	6a 00                	push   $0x0
  pushl $90
80106333:	6a 5a                	push   $0x5a
  jmp alltraps
80106335:	e9 d0 f7 ff ff       	jmp    80105b0a <alltraps>

8010633a <vector91>:
.globl vector91
vector91:
  pushl $0
8010633a:	6a 00                	push   $0x0
  pushl $91
8010633c:	6a 5b                	push   $0x5b
  jmp alltraps
8010633e:	e9 c7 f7 ff ff       	jmp    80105b0a <alltraps>

80106343 <vector92>:
.globl vector92
vector92:
  pushl $0
80106343:	6a 00                	push   $0x0
  pushl $92
80106345:	6a 5c                	push   $0x5c
  jmp alltraps
80106347:	e9 be f7 ff ff       	jmp    80105b0a <alltraps>

8010634c <vector93>:
.globl vector93
vector93:
  pushl $0
8010634c:	6a 00                	push   $0x0
  pushl $93
8010634e:	6a 5d                	push   $0x5d
  jmp alltraps
80106350:	e9 b5 f7 ff ff       	jmp    80105b0a <alltraps>

80106355 <vector94>:
.globl vector94
vector94:
  pushl $0
80106355:	6a 00                	push   $0x0
  pushl $94
80106357:	6a 5e                	push   $0x5e
  jmp alltraps
80106359:	e9 ac f7 ff ff       	jmp    80105b0a <alltraps>

8010635e <vector95>:
.globl vector95
vector95:
  pushl $0
8010635e:	6a 00                	push   $0x0
  pushl $95
80106360:	6a 5f                	push   $0x5f
  jmp alltraps
80106362:	e9 a3 f7 ff ff       	jmp    80105b0a <alltraps>

80106367 <vector96>:
.globl vector96
vector96:
  pushl $0
80106367:	6a 00                	push   $0x0
  pushl $96
80106369:	6a 60                	push   $0x60
  jmp alltraps
8010636b:	e9 9a f7 ff ff       	jmp    80105b0a <alltraps>

80106370 <vector97>:
.globl vector97
vector97:
  pushl $0
80106370:	6a 00                	push   $0x0
  pushl $97
80106372:	6a 61                	push   $0x61
  jmp alltraps
80106374:	e9 91 f7 ff ff       	jmp    80105b0a <alltraps>

80106379 <vector98>:
.globl vector98
vector98:
  pushl $0
80106379:	6a 00                	push   $0x0
  pushl $98
8010637b:	6a 62                	push   $0x62
  jmp alltraps
8010637d:	e9 88 f7 ff ff       	jmp    80105b0a <alltraps>

80106382 <vector99>:
.globl vector99
vector99:
  pushl $0
80106382:	6a 00                	push   $0x0
  pushl $99
80106384:	6a 63                	push   $0x63
  jmp alltraps
80106386:	e9 7f f7 ff ff       	jmp    80105b0a <alltraps>

8010638b <vector100>:
.globl vector100
vector100:
  pushl $0
8010638b:	6a 00                	push   $0x0
  pushl $100
8010638d:	6a 64                	push   $0x64
  jmp alltraps
8010638f:	e9 76 f7 ff ff       	jmp    80105b0a <alltraps>

80106394 <vector101>:
.globl vector101
vector101:
  pushl $0
80106394:	6a 00                	push   $0x0
  pushl $101
80106396:	6a 65                	push   $0x65
  jmp alltraps
80106398:	e9 6d f7 ff ff       	jmp    80105b0a <alltraps>

8010639d <vector102>:
.globl vector102
vector102:
  pushl $0
8010639d:	6a 00                	push   $0x0
  pushl $102
8010639f:	6a 66                	push   $0x66
  jmp alltraps
801063a1:	e9 64 f7 ff ff       	jmp    80105b0a <alltraps>

801063a6 <vector103>:
.globl vector103
vector103:
  pushl $0
801063a6:	6a 00                	push   $0x0
  pushl $103
801063a8:	6a 67                	push   $0x67
  jmp alltraps
801063aa:	e9 5b f7 ff ff       	jmp    80105b0a <alltraps>

801063af <vector104>:
.globl vector104
vector104:
  pushl $0
801063af:	6a 00                	push   $0x0
  pushl $104
801063b1:	6a 68                	push   $0x68
  jmp alltraps
801063b3:	e9 52 f7 ff ff       	jmp    80105b0a <alltraps>

801063b8 <vector105>:
.globl vector105
vector105:
  pushl $0
801063b8:	6a 00                	push   $0x0
  pushl $105
801063ba:	6a 69                	push   $0x69
  jmp alltraps
801063bc:	e9 49 f7 ff ff       	jmp    80105b0a <alltraps>

801063c1 <vector106>:
.globl vector106
vector106:
  pushl $0
801063c1:	6a 00                	push   $0x0
  pushl $106
801063c3:	6a 6a                	push   $0x6a
  jmp alltraps
801063c5:	e9 40 f7 ff ff       	jmp    80105b0a <alltraps>

801063ca <vector107>:
.globl vector107
vector107:
  pushl $0
801063ca:	6a 00                	push   $0x0
  pushl $107
801063cc:	6a 6b                	push   $0x6b
  jmp alltraps
801063ce:	e9 37 f7 ff ff       	jmp    80105b0a <alltraps>

801063d3 <vector108>:
.globl vector108
vector108:
  pushl $0
801063d3:	6a 00                	push   $0x0
  pushl $108
801063d5:	6a 6c                	push   $0x6c
  jmp alltraps
801063d7:	e9 2e f7 ff ff       	jmp    80105b0a <alltraps>

801063dc <vector109>:
.globl vector109
vector109:
  pushl $0
801063dc:	6a 00                	push   $0x0
  pushl $109
801063de:	6a 6d                	push   $0x6d
  jmp alltraps
801063e0:	e9 25 f7 ff ff       	jmp    80105b0a <alltraps>

801063e5 <vector110>:
.globl vector110
vector110:
  pushl $0
801063e5:	6a 00                	push   $0x0
  pushl $110
801063e7:	6a 6e                	push   $0x6e
  jmp alltraps
801063e9:	e9 1c f7 ff ff       	jmp    80105b0a <alltraps>

801063ee <vector111>:
.globl vector111
vector111:
  pushl $0
801063ee:	6a 00                	push   $0x0
  pushl $111
801063f0:	6a 6f                	push   $0x6f
  jmp alltraps
801063f2:	e9 13 f7 ff ff       	jmp    80105b0a <alltraps>

801063f7 <vector112>:
.globl vector112
vector112:
  pushl $0
801063f7:	6a 00                	push   $0x0
  pushl $112
801063f9:	6a 70                	push   $0x70
  jmp alltraps
801063fb:	e9 0a f7 ff ff       	jmp    80105b0a <alltraps>

80106400 <vector113>:
.globl vector113
vector113:
  pushl $0
80106400:	6a 00                	push   $0x0
  pushl $113
80106402:	6a 71                	push   $0x71
  jmp alltraps
80106404:	e9 01 f7 ff ff       	jmp    80105b0a <alltraps>

80106409 <vector114>:
.globl vector114
vector114:
  pushl $0
80106409:	6a 00                	push   $0x0
  pushl $114
8010640b:	6a 72                	push   $0x72
  jmp alltraps
8010640d:	e9 f8 f6 ff ff       	jmp    80105b0a <alltraps>

80106412 <vector115>:
.globl vector115
vector115:
  pushl $0
80106412:	6a 00                	push   $0x0
  pushl $115
80106414:	6a 73                	push   $0x73
  jmp alltraps
80106416:	e9 ef f6 ff ff       	jmp    80105b0a <alltraps>

8010641b <vector116>:
.globl vector116
vector116:
  pushl $0
8010641b:	6a 00                	push   $0x0
  pushl $116
8010641d:	6a 74                	push   $0x74
  jmp alltraps
8010641f:	e9 e6 f6 ff ff       	jmp    80105b0a <alltraps>

80106424 <vector117>:
.globl vector117
vector117:
  pushl $0
80106424:	6a 00                	push   $0x0
  pushl $117
80106426:	6a 75                	push   $0x75
  jmp alltraps
80106428:	e9 dd f6 ff ff       	jmp    80105b0a <alltraps>

8010642d <vector118>:
.globl vector118
vector118:
  pushl $0
8010642d:	6a 00                	push   $0x0
  pushl $118
8010642f:	6a 76                	push   $0x76
  jmp alltraps
80106431:	e9 d4 f6 ff ff       	jmp    80105b0a <alltraps>

80106436 <vector119>:
.globl vector119
vector119:
  pushl $0
80106436:	6a 00                	push   $0x0
  pushl $119
80106438:	6a 77                	push   $0x77
  jmp alltraps
8010643a:	e9 cb f6 ff ff       	jmp    80105b0a <alltraps>

8010643f <vector120>:
.globl vector120
vector120:
  pushl $0
8010643f:	6a 00                	push   $0x0
  pushl $120
80106441:	6a 78                	push   $0x78
  jmp alltraps
80106443:	e9 c2 f6 ff ff       	jmp    80105b0a <alltraps>

80106448 <vector121>:
.globl vector121
vector121:
  pushl $0
80106448:	6a 00                	push   $0x0
  pushl $121
8010644a:	6a 79                	push   $0x79
  jmp alltraps
8010644c:	e9 b9 f6 ff ff       	jmp    80105b0a <alltraps>

80106451 <vector122>:
.globl vector122
vector122:
  pushl $0
80106451:	6a 00                	push   $0x0
  pushl $122
80106453:	6a 7a                	push   $0x7a
  jmp alltraps
80106455:	e9 b0 f6 ff ff       	jmp    80105b0a <alltraps>

8010645a <vector123>:
.globl vector123
vector123:
  pushl $0
8010645a:	6a 00                	push   $0x0
  pushl $123
8010645c:	6a 7b                	push   $0x7b
  jmp alltraps
8010645e:	e9 a7 f6 ff ff       	jmp    80105b0a <alltraps>

80106463 <vector124>:
.globl vector124
vector124:
  pushl $0
80106463:	6a 00                	push   $0x0
  pushl $124
80106465:	6a 7c                	push   $0x7c
  jmp alltraps
80106467:	e9 9e f6 ff ff       	jmp    80105b0a <alltraps>

8010646c <vector125>:
.globl vector125
vector125:
  pushl $0
8010646c:	6a 00                	push   $0x0
  pushl $125
8010646e:	6a 7d                	push   $0x7d
  jmp alltraps
80106470:	e9 95 f6 ff ff       	jmp    80105b0a <alltraps>

80106475 <vector126>:
.globl vector126
vector126:
  pushl $0
80106475:	6a 00                	push   $0x0
  pushl $126
80106477:	6a 7e                	push   $0x7e
  jmp alltraps
80106479:	e9 8c f6 ff ff       	jmp    80105b0a <alltraps>

8010647e <vector127>:
.globl vector127
vector127:
  pushl $0
8010647e:	6a 00                	push   $0x0
  pushl $127
80106480:	6a 7f                	push   $0x7f
  jmp alltraps
80106482:	e9 83 f6 ff ff       	jmp    80105b0a <alltraps>

80106487 <vector128>:
.globl vector128
vector128:
  pushl $0
80106487:	6a 00                	push   $0x0
  pushl $128
80106489:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010648e:	e9 77 f6 ff ff       	jmp    80105b0a <alltraps>

80106493 <vector129>:
.globl vector129
vector129:
  pushl $0
80106493:	6a 00                	push   $0x0
  pushl $129
80106495:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010649a:	e9 6b f6 ff ff       	jmp    80105b0a <alltraps>

8010649f <vector130>:
.globl vector130
vector130:
  pushl $0
8010649f:	6a 00                	push   $0x0
  pushl $130
801064a1:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801064a6:	e9 5f f6 ff ff       	jmp    80105b0a <alltraps>

801064ab <vector131>:
.globl vector131
vector131:
  pushl $0
801064ab:	6a 00                	push   $0x0
  pushl $131
801064ad:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801064b2:	e9 53 f6 ff ff       	jmp    80105b0a <alltraps>

801064b7 <vector132>:
.globl vector132
vector132:
  pushl $0
801064b7:	6a 00                	push   $0x0
  pushl $132
801064b9:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801064be:	e9 47 f6 ff ff       	jmp    80105b0a <alltraps>

801064c3 <vector133>:
.globl vector133
vector133:
  pushl $0
801064c3:	6a 00                	push   $0x0
  pushl $133
801064c5:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801064ca:	e9 3b f6 ff ff       	jmp    80105b0a <alltraps>

801064cf <vector134>:
.globl vector134
vector134:
  pushl $0
801064cf:	6a 00                	push   $0x0
  pushl $134
801064d1:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801064d6:	e9 2f f6 ff ff       	jmp    80105b0a <alltraps>

801064db <vector135>:
.globl vector135
vector135:
  pushl $0
801064db:	6a 00                	push   $0x0
  pushl $135
801064dd:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801064e2:	e9 23 f6 ff ff       	jmp    80105b0a <alltraps>

801064e7 <vector136>:
.globl vector136
vector136:
  pushl $0
801064e7:	6a 00                	push   $0x0
  pushl $136
801064e9:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801064ee:	e9 17 f6 ff ff       	jmp    80105b0a <alltraps>

801064f3 <vector137>:
.globl vector137
vector137:
  pushl $0
801064f3:	6a 00                	push   $0x0
  pushl $137
801064f5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801064fa:	e9 0b f6 ff ff       	jmp    80105b0a <alltraps>

801064ff <vector138>:
.globl vector138
vector138:
  pushl $0
801064ff:	6a 00                	push   $0x0
  pushl $138
80106501:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106506:	e9 ff f5 ff ff       	jmp    80105b0a <alltraps>

8010650b <vector139>:
.globl vector139
vector139:
  pushl $0
8010650b:	6a 00                	push   $0x0
  pushl $139
8010650d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106512:	e9 f3 f5 ff ff       	jmp    80105b0a <alltraps>

80106517 <vector140>:
.globl vector140
vector140:
  pushl $0
80106517:	6a 00                	push   $0x0
  pushl $140
80106519:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010651e:	e9 e7 f5 ff ff       	jmp    80105b0a <alltraps>

80106523 <vector141>:
.globl vector141
vector141:
  pushl $0
80106523:	6a 00                	push   $0x0
  pushl $141
80106525:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010652a:	e9 db f5 ff ff       	jmp    80105b0a <alltraps>

8010652f <vector142>:
.globl vector142
vector142:
  pushl $0
8010652f:	6a 00                	push   $0x0
  pushl $142
80106531:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106536:	e9 cf f5 ff ff       	jmp    80105b0a <alltraps>

8010653b <vector143>:
.globl vector143
vector143:
  pushl $0
8010653b:	6a 00                	push   $0x0
  pushl $143
8010653d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106542:	e9 c3 f5 ff ff       	jmp    80105b0a <alltraps>

80106547 <vector144>:
.globl vector144
vector144:
  pushl $0
80106547:	6a 00                	push   $0x0
  pushl $144
80106549:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010654e:	e9 b7 f5 ff ff       	jmp    80105b0a <alltraps>

80106553 <vector145>:
.globl vector145
vector145:
  pushl $0
80106553:	6a 00                	push   $0x0
  pushl $145
80106555:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010655a:	e9 ab f5 ff ff       	jmp    80105b0a <alltraps>

8010655f <vector146>:
.globl vector146
vector146:
  pushl $0
8010655f:	6a 00                	push   $0x0
  pushl $146
80106561:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106566:	e9 9f f5 ff ff       	jmp    80105b0a <alltraps>

8010656b <vector147>:
.globl vector147
vector147:
  pushl $0
8010656b:	6a 00                	push   $0x0
  pushl $147
8010656d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106572:	e9 93 f5 ff ff       	jmp    80105b0a <alltraps>

80106577 <vector148>:
.globl vector148
vector148:
  pushl $0
80106577:	6a 00                	push   $0x0
  pushl $148
80106579:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010657e:	e9 87 f5 ff ff       	jmp    80105b0a <alltraps>

80106583 <vector149>:
.globl vector149
vector149:
  pushl $0
80106583:	6a 00                	push   $0x0
  pushl $149
80106585:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010658a:	e9 7b f5 ff ff       	jmp    80105b0a <alltraps>

8010658f <vector150>:
.globl vector150
vector150:
  pushl $0
8010658f:	6a 00                	push   $0x0
  pushl $150
80106591:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106596:	e9 6f f5 ff ff       	jmp    80105b0a <alltraps>

8010659b <vector151>:
.globl vector151
vector151:
  pushl $0
8010659b:	6a 00                	push   $0x0
  pushl $151
8010659d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801065a2:	e9 63 f5 ff ff       	jmp    80105b0a <alltraps>

801065a7 <vector152>:
.globl vector152
vector152:
  pushl $0
801065a7:	6a 00                	push   $0x0
  pushl $152
801065a9:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801065ae:	e9 57 f5 ff ff       	jmp    80105b0a <alltraps>

801065b3 <vector153>:
.globl vector153
vector153:
  pushl $0
801065b3:	6a 00                	push   $0x0
  pushl $153
801065b5:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801065ba:	e9 4b f5 ff ff       	jmp    80105b0a <alltraps>

801065bf <vector154>:
.globl vector154
vector154:
  pushl $0
801065bf:	6a 00                	push   $0x0
  pushl $154
801065c1:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801065c6:	e9 3f f5 ff ff       	jmp    80105b0a <alltraps>

801065cb <vector155>:
.globl vector155
vector155:
  pushl $0
801065cb:	6a 00                	push   $0x0
  pushl $155
801065cd:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801065d2:	e9 33 f5 ff ff       	jmp    80105b0a <alltraps>

801065d7 <vector156>:
.globl vector156
vector156:
  pushl $0
801065d7:	6a 00                	push   $0x0
  pushl $156
801065d9:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801065de:	e9 27 f5 ff ff       	jmp    80105b0a <alltraps>

801065e3 <vector157>:
.globl vector157
vector157:
  pushl $0
801065e3:	6a 00                	push   $0x0
  pushl $157
801065e5:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801065ea:	e9 1b f5 ff ff       	jmp    80105b0a <alltraps>

801065ef <vector158>:
.globl vector158
vector158:
  pushl $0
801065ef:	6a 00                	push   $0x0
  pushl $158
801065f1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801065f6:	e9 0f f5 ff ff       	jmp    80105b0a <alltraps>

801065fb <vector159>:
.globl vector159
vector159:
  pushl $0
801065fb:	6a 00                	push   $0x0
  pushl $159
801065fd:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106602:	e9 03 f5 ff ff       	jmp    80105b0a <alltraps>

80106607 <vector160>:
.globl vector160
vector160:
  pushl $0
80106607:	6a 00                	push   $0x0
  pushl $160
80106609:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010660e:	e9 f7 f4 ff ff       	jmp    80105b0a <alltraps>

80106613 <vector161>:
.globl vector161
vector161:
  pushl $0
80106613:	6a 00                	push   $0x0
  pushl $161
80106615:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010661a:	e9 eb f4 ff ff       	jmp    80105b0a <alltraps>

8010661f <vector162>:
.globl vector162
vector162:
  pushl $0
8010661f:	6a 00                	push   $0x0
  pushl $162
80106621:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106626:	e9 df f4 ff ff       	jmp    80105b0a <alltraps>

8010662b <vector163>:
.globl vector163
vector163:
  pushl $0
8010662b:	6a 00                	push   $0x0
  pushl $163
8010662d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106632:	e9 d3 f4 ff ff       	jmp    80105b0a <alltraps>

80106637 <vector164>:
.globl vector164
vector164:
  pushl $0
80106637:	6a 00                	push   $0x0
  pushl $164
80106639:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010663e:	e9 c7 f4 ff ff       	jmp    80105b0a <alltraps>

80106643 <vector165>:
.globl vector165
vector165:
  pushl $0
80106643:	6a 00                	push   $0x0
  pushl $165
80106645:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010664a:	e9 bb f4 ff ff       	jmp    80105b0a <alltraps>

8010664f <vector166>:
.globl vector166
vector166:
  pushl $0
8010664f:	6a 00                	push   $0x0
  pushl $166
80106651:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106656:	e9 af f4 ff ff       	jmp    80105b0a <alltraps>

8010665b <vector167>:
.globl vector167
vector167:
  pushl $0
8010665b:	6a 00                	push   $0x0
  pushl $167
8010665d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106662:	e9 a3 f4 ff ff       	jmp    80105b0a <alltraps>

80106667 <vector168>:
.globl vector168
vector168:
  pushl $0
80106667:	6a 00                	push   $0x0
  pushl $168
80106669:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010666e:	e9 97 f4 ff ff       	jmp    80105b0a <alltraps>

80106673 <vector169>:
.globl vector169
vector169:
  pushl $0
80106673:	6a 00                	push   $0x0
  pushl $169
80106675:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010667a:	e9 8b f4 ff ff       	jmp    80105b0a <alltraps>

8010667f <vector170>:
.globl vector170
vector170:
  pushl $0
8010667f:	6a 00                	push   $0x0
  pushl $170
80106681:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106686:	e9 7f f4 ff ff       	jmp    80105b0a <alltraps>

8010668b <vector171>:
.globl vector171
vector171:
  pushl $0
8010668b:	6a 00                	push   $0x0
  pushl $171
8010668d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106692:	e9 73 f4 ff ff       	jmp    80105b0a <alltraps>

80106697 <vector172>:
.globl vector172
vector172:
  pushl $0
80106697:	6a 00                	push   $0x0
  pushl $172
80106699:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010669e:	e9 67 f4 ff ff       	jmp    80105b0a <alltraps>

801066a3 <vector173>:
.globl vector173
vector173:
  pushl $0
801066a3:	6a 00                	push   $0x0
  pushl $173
801066a5:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801066aa:	e9 5b f4 ff ff       	jmp    80105b0a <alltraps>

801066af <vector174>:
.globl vector174
vector174:
  pushl $0
801066af:	6a 00                	push   $0x0
  pushl $174
801066b1:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801066b6:	e9 4f f4 ff ff       	jmp    80105b0a <alltraps>

801066bb <vector175>:
.globl vector175
vector175:
  pushl $0
801066bb:	6a 00                	push   $0x0
  pushl $175
801066bd:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801066c2:	e9 43 f4 ff ff       	jmp    80105b0a <alltraps>

801066c7 <vector176>:
.globl vector176
vector176:
  pushl $0
801066c7:	6a 00                	push   $0x0
  pushl $176
801066c9:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801066ce:	e9 37 f4 ff ff       	jmp    80105b0a <alltraps>

801066d3 <vector177>:
.globl vector177
vector177:
  pushl $0
801066d3:	6a 00                	push   $0x0
  pushl $177
801066d5:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801066da:	e9 2b f4 ff ff       	jmp    80105b0a <alltraps>

801066df <vector178>:
.globl vector178
vector178:
  pushl $0
801066df:	6a 00                	push   $0x0
  pushl $178
801066e1:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801066e6:	e9 1f f4 ff ff       	jmp    80105b0a <alltraps>

801066eb <vector179>:
.globl vector179
vector179:
  pushl $0
801066eb:	6a 00                	push   $0x0
  pushl $179
801066ed:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801066f2:	e9 13 f4 ff ff       	jmp    80105b0a <alltraps>

801066f7 <vector180>:
.globl vector180
vector180:
  pushl $0
801066f7:	6a 00                	push   $0x0
  pushl $180
801066f9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801066fe:	e9 07 f4 ff ff       	jmp    80105b0a <alltraps>

80106703 <vector181>:
.globl vector181
vector181:
  pushl $0
80106703:	6a 00                	push   $0x0
  pushl $181
80106705:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010670a:	e9 fb f3 ff ff       	jmp    80105b0a <alltraps>

8010670f <vector182>:
.globl vector182
vector182:
  pushl $0
8010670f:	6a 00                	push   $0x0
  pushl $182
80106711:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106716:	e9 ef f3 ff ff       	jmp    80105b0a <alltraps>

8010671b <vector183>:
.globl vector183
vector183:
  pushl $0
8010671b:	6a 00                	push   $0x0
  pushl $183
8010671d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106722:	e9 e3 f3 ff ff       	jmp    80105b0a <alltraps>

80106727 <vector184>:
.globl vector184
vector184:
  pushl $0
80106727:	6a 00                	push   $0x0
  pushl $184
80106729:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010672e:	e9 d7 f3 ff ff       	jmp    80105b0a <alltraps>

80106733 <vector185>:
.globl vector185
vector185:
  pushl $0
80106733:	6a 00                	push   $0x0
  pushl $185
80106735:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010673a:	e9 cb f3 ff ff       	jmp    80105b0a <alltraps>

8010673f <vector186>:
.globl vector186
vector186:
  pushl $0
8010673f:	6a 00                	push   $0x0
  pushl $186
80106741:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106746:	e9 bf f3 ff ff       	jmp    80105b0a <alltraps>

8010674b <vector187>:
.globl vector187
vector187:
  pushl $0
8010674b:	6a 00                	push   $0x0
  pushl $187
8010674d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106752:	e9 b3 f3 ff ff       	jmp    80105b0a <alltraps>

80106757 <vector188>:
.globl vector188
vector188:
  pushl $0
80106757:	6a 00                	push   $0x0
  pushl $188
80106759:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010675e:	e9 a7 f3 ff ff       	jmp    80105b0a <alltraps>

80106763 <vector189>:
.globl vector189
vector189:
  pushl $0
80106763:	6a 00                	push   $0x0
  pushl $189
80106765:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010676a:	e9 9b f3 ff ff       	jmp    80105b0a <alltraps>

8010676f <vector190>:
.globl vector190
vector190:
  pushl $0
8010676f:	6a 00                	push   $0x0
  pushl $190
80106771:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106776:	e9 8f f3 ff ff       	jmp    80105b0a <alltraps>

8010677b <vector191>:
.globl vector191
vector191:
  pushl $0
8010677b:	6a 00                	push   $0x0
  pushl $191
8010677d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106782:	e9 83 f3 ff ff       	jmp    80105b0a <alltraps>

80106787 <vector192>:
.globl vector192
vector192:
  pushl $0
80106787:	6a 00                	push   $0x0
  pushl $192
80106789:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010678e:	e9 77 f3 ff ff       	jmp    80105b0a <alltraps>

80106793 <vector193>:
.globl vector193
vector193:
  pushl $0
80106793:	6a 00                	push   $0x0
  pushl $193
80106795:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010679a:	e9 6b f3 ff ff       	jmp    80105b0a <alltraps>

8010679f <vector194>:
.globl vector194
vector194:
  pushl $0
8010679f:	6a 00                	push   $0x0
  pushl $194
801067a1:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801067a6:	e9 5f f3 ff ff       	jmp    80105b0a <alltraps>

801067ab <vector195>:
.globl vector195
vector195:
  pushl $0
801067ab:	6a 00                	push   $0x0
  pushl $195
801067ad:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801067b2:	e9 53 f3 ff ff       	jmp    80105b0a <alltraps>

801067b7 <vector196>:
.globl vector196
vector196:
  pushl $0
801067b7:	6a 00                	push   $0x0
  pushl $196
801067b9:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801067be:	e9 47 f3 ff ff       	jmp    80105b0a <alltraps>

801067c3 <vector197>:
.globl vector197
vector197:
  pushl $0
801067c3:	6a 00                	push   $0x0
  pushl $197
801067c5:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801067ca:	e9 3b f3 ff ff       	jmp    80105b0a <alltraps>

801067cf <vector198>:
.globl vector198
vector198:
  pushl $0
801067cf:	6a 00                	push   $0x0
  pushl $198
801067d1:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801067d6:	e9 2f f3 ff ff       	jmp    80105b0a <alltraps>

801067db <vector199>:
.globl vector199
vector199:
  pushl $0
801067db:	6a 00                	push   $0x0
  pushl $199
801067dd:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801067e2:	e9 23 f3 ff ff       	jmp    80105b0a <alltraps>

801067e7 <vector200>:
.globl vector200
vector200:
  pushl $0
801067e7:	6a 00                	push   $0x0
  pushl $200
801067e9:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801067ee:	e9 17 f3 ff ff       	jmp    80105b0a <alltraps>

801067f3 <vector201>:
.globl vector201
vector201:
  pushl $0
801067f3:	6a 00                	push   $0x0
  pushl $201
801067f5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801067fa:	e9 0b f3 ff ff       	jmp    80105b0a <alltraps>

801067ff <vector202>:
.globl vector202
vector202:
  pushl $0
801067ff:	6a 00                	push   $0x0
  pushl $202
80106801:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106806:	e9 ff f2 ff ff       	jmp    80105b0a <alltraps>

8010680b <vector203>:
.globl vector203
vector203:
  pushl $0
8010680b:	6a 00                	push   $0x0
  pushl $203
8010680d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106812:	e9 f3 f2 ff ff       	jmp    80105b0a <alltraps>

80106817 <vector204>:
.globl vector204
vector204:
  pushl $0
80106817:	6a 00                	push   $0x0
  pushl $204
80106819:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010681e:	e9 e7 f2 ff ff       	jmp    80105b0a <alltraps>

80106823 <vector205>:
.globl vector205
vector205:
  pushl $0
80106823:	6a 00                	push   $0x0
  pushl $205
80106825:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010682a:	e9 db f2 ff ff       	jmp    80105b0a <alltraps>

8010682f <vector206>:
.globl vector206
vector206:
  pushl $0
8010682f:	6a 00                	push   $0x0
  pushl $206
80106831:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106836:	e9 cf f2 ff ff       	jmp    80105b0a <alltraps>

8010683b <vector207>:
.globl vector207
vector207:
  pushl $0
8010683b:	6a 00                	push   $0x0
  pushl $207
8010683d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106842:	e9 c3 f2 ff ff       	jmp    80105b0a <alltraps>

80106847 <vector208>:
.globl vector208
vector208:
  pushl $0
80106847:	6a 00                	push   $0x0
  pushl $208
80106849:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010684e:	e9 b7 f2 ff ff       	jmp    80105b0a <alltraps>

80106853 <vector209>:
.globl vector209
vector209:
  pushl $0
80106853:	6a 00                	push   $0x0
  pushl $209
80106855:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010685a:	e9 ab f2 ff ff       	jmp    80105b0a <alltraps>

8010685f <vector210>:
.globl vector210
vector210:
  pushl $0
8010685f:	6a 00                	push   $0x0
  pushl $210
80106861:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106866:	e9 9f f2 ff ff       	jmp    80105b0a <alltraps>

8010686b <vector211>:
.globl vector211
vector211:
  pushl $0
8010686b:	6a 00                	push   $0x0
  pushl $211
8010686d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106872:	e9 93 f2 ff ff       	jmp    80105b0a <alltraps>

80106877 <vector212>:
.globl vector212
vector212:
  pushl $0
80106877:	6a 00                	push   $0x0
  pushl $212
80106879:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010687e:	e9 87 f2 ff ff       	jmp    80105b0a <alltraps>

80106883 <vector213>:
.globl vector213
vector213:
  pushl $0
80106883:	6a 00                	push   $0x0
  pushl $213
80106885:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010688a:	e9 7b f2 ff ff       	jmp    80105b0a <alltraps>

8010688f <vector214>:
.globl vector214
vector214:
  pushl $0
8010688f:	6a 00                	push   $0x0
  pushl $214
80106891:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106896:	e9 6f f2 ff ff       	jmp    80105b0a <alltraps>

8010689b <vector215>:
.globl vector215
vector215:
  pushl $0
8010689b:	6a 00                	push   $0x0
  pushl $215
8010689d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801068a2:	e9 63 f2 ff ff       	jmp    80105b0a <alltraps>

801068a7 <vector216>:
.globl vector216
vector216:
  pushl $0
801068a7:	6a 00                	push   $0x0
  pushl $216
801068a9:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801068ae:	e9 57 f2 ff ff       	jmp    80105b0a <alltraps>

801068b3 <vector217>:
.globl vector217
vector217:
  pushl $0
801068b3:	6a 00                	push   $0x0
  pushl $217
801068b5:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801068ba:	e9 4b f2 ff ff       	jmp    80105b0a <alltraps>

801068bf <vector218>:
.globl vector218
vector218:
  pushl $0
801068bf:	6a 00                	push   $0x0
  pushl $218
801068c1:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801068c6:	e9 3f f2 ff ff       	jmp    80105b0a <alltraps>

801068cb <vector219>:
.globl vector219
vector219:
  pushl $0
801068cb:	6a 00                	push   $0x0
  pushl $219
801068cd:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801068d2:	e9 33 f2 ff ff       	jmp    80105b0a <alltraps>

801068d7 <vector220>:
.globl vector220
vector220:
  pushl $0
801068d7:	6a 00                	push   $0x0
  pushl $220
801068d9:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801068de:	e9 27 f2 ff ff       	jmp    80105b0a <alltraps>

801068e3 <vector221>:
.globl vector221
vector221:
  pushl $0
801068e3:	6a 00                	push   $0x0
  pushl $221
801068e5:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801068ea:	e9 1b f2 ff ff       	jmp    80105b0a <alltraps>

801068ef <vector222>:
.globl vector222
vector222:
  pushl $0
801068ef:	6a 00                	push   $0x0
  pushl $222
801068f1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801068f6:	e9 0f f2 ff ff       	jmp    80105b0a <alltraps>

801068fb <vector223>:
.globl vector223
vector223:
  pushl $0
801068fb:	6a 00                	push   $0x0
  pushl $223
801068fd:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106902:	e9 03 f2 ff ff       	jmp    80105b0a <alltraps>

80106907 <vector224>:
.globl vector224
vector224:
  pushl $0
80106907:	6a 00                	push   $0x0
  pushl $224
80106909:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010690e:	e9 f7 f1 ff ff       	jmp    80105b0a <alltraps>

80106913 <vector225>:
.globl vector225
vector225:
  pushl $0
80106913:	6a 00                	push   $0x0
  pushl $225
80106915:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010691a:	e9 eb f1 ff ff       	jmp    80105b0a <alltraps>

8010691f <vector226>:
.globl vector226
vector226:
  pushl $0
8010691f:	6a 00                	push   $0x0
  pushl $226
80106921:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106926:	e9 df f1 ff ff       	jmp    80105b0a <alltraps>

8010692b <vector227>:
.globl vector227
vector227:
  pushl $0
8010692b:	6a 00                	push   $0x0
  pushl $227
8010692d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106932:	e9 d3 f1 ff ff       	jmp    80105b0a <alltraps>

80106937 <vector228>:
.globl vector228
vector228:
  pushl $0
80106937:	6a 00                	push   $0x0
  pushl $228
80106939:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010693e:	e9 c7 f1 ff ff       	jmp    80105b0a <alltraps>

80106943 <vector229>:
.globl vector229
vector229:
  pushl $0
80106943:	6a 00                	push   $0x0
  pushl $229
80106945:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010694a:	e9 bb f1 ff ff       	jmp    80105b0a <alltraps>

8010694f <vector230>:
.globl vector230
vector230:
  pushl $0
8010694f:	6a 00                	push   $0x0
  pushl $230
80106951:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106956:	e9 af f1 ff ff       	jmp    80105b0a <alltraps>

8010695b <vector231>:
.globl vector231
vector231:
  pushl $0
8010695b:	6a 00                	push   $0x0
  pushl $231
8010695d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106962:	e9 a3 f1 ff ff       	jmp    80105b0a <alltraps>

80106967 <vector232>:
.globl vector232
vector232:
  pushl $0
80106967:	6a 00                	push   $0x0
  pushl $232
80106969:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010696e:	e9 97 f1 ff ff       	jmp    80105b0a <alltraps>

80106973 <vector233>:
.globl vector233
vector233:
  pushl $0
80106973:	6a 00                	push   $0x0
  pushl $233
80106975:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010697a:	e9 8b f1 ff ff       	jmp    80105b0a <alltraps>

8010697f <vector234>:
.globl vector234
vector234:
  pushl $0
8010697f:	6a 00                	push   $0x0
  pushl $234
80106981:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106986:	e9 7f f1 ff ff       	jmp    80105b0a <alltraps>

8010698b <vector235>:
.globl vector235
vector235:
  pushl $0
8010698b:	6a 00                	push   $0x0
  pushl $235
8010698d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106992:	e9 73 f1 ff ff       	jmp    80105b0a <alltraps>

80106997 <vector236>:
.globl vector236
vector236:
  pushl $0
80106997:	6a 00                	push   $0x0
  pushl $236
80106999:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010699e:	e9 67 f1 ff ff       	jmp    80105b0a <alltraps>

801069a3 <vector237>:
.globl vector237
vector237:
  pushl $0
801069a3:	6a 00                	push   $0x0
  pushl $237
801069a5:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801069aa:	e9 5b f1 ff ff       	jmp    80105b0a <alltraps>

801069af <vector238>:
.globl vector238
vector238:
  pushl $0
801069af:	6a 00                	push   $0x0
  pushl $238
801069b1:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801069b6:	e9 4f f1 ff ff       	jmp    80105b0a <alltraps>

801069bb <vector239>:
.globl vector239
vector239:
  pushl $0
801069bb:	6a 00                	push   $0x0
  pushl $239
801069bd:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801069c2:	e9 43 f1 ff ff       	jmp    80105b0a <alltraps>

801069c7 <vector240>:
.globl vector240
vector240:
  pushl $0
801069c7:	6a 00                	push   $0x0
  pushl $240
801069c9:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801069ce:	e9 37 f1 ff ff       	jmp    80105b0a <alltraps>

801069d3 <vector241>:
.globl vector241
vector241:
  pushl $0
801069d3:	6a 00                	push   $0x0
  pushl $241
801069d5:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801069da:	e9 2b f1 ff ff       	jmp    80105b0a <alltraps>

801069df <vector242>:
.globl vector242
vector242:
  pushl $0
801069df:	6a 00                	push   $0x0
  pushl $242
801069e1:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801069e6:	e9 1f f1 ff ff       	jmp    80105b0a <alltraps>

801069eb <vector243>:
.globl vector243
vector243:
  pushl $0
801069eb:	6a 00                	push   $0x0
  pushl $243
801069ed:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801069f2:	e9 13 f1 ff ff       	jmp    80105b0a <alltraps>

801069f7 <vector244>:
.globl vector244
vector244:
  pushl $0
801069f7:	6a 00                	push   $0x0
  pushl $244
801069f9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801069fe:	e9 07 f1 ff ff       	jmp    80105b0a <alltraps>

80106a03 <vector245>:
.globl vector245
vector245:
  pushl $0
80106a03:	6a 00                	push   $0x0
  pushl $245
80106a05:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106a0a:	e9 fb f0 ff ff       	jmp    80105b0a <alltraps>

80106a0f <vector246>:
.globl vector246
vector246:
  pushl $0
80106a0f:	6a 00                	push   $0x0
  pushl $246
80106a11:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106a16:	e9 ef f0 ff ff       	jmp    80105b0a <alltraps>

80106a1b <vector247>:
.globl vector247
vector247:
  pushl $0
80106a1b:	6a 00                	push   $0x0
  pushl $247
80106a1d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106a22:	e9 e3 f0 ff ff       	jmp    80105b0a <alltraps>

80106a27 <vector248>:
.globl vector248
vector248:
  pushl $0
80106a27:	6a 00                	push   $0x0
  pushl $248
80106a29:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106a2e:	e9 d7 f0 ff ff       	jmp    80105b0a <alltraps>

80106a33 <vector249>:
.globl vector249
vector249:
  pushl $0
80106a33:	6a 00                	push   $0x0
  pushl $249
80106a35:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106a3a:	e9 cb f0 ff ff       	jmp    80105b0a <alltraps>

80106a3f <vector250>:
.globl vector250
vector250:
  pushl $0
80106a3f:	6a 00                	push   $0x0
  pushl $250
80106a41:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106a46:	e9 bf f0 ff ff       	jmp    80105b0a <alltraps>

80106a4b <vector251>:
.globl vector251
vector251:
  pushl $0
80106a4b:	6a 00                	push   $0x0
  pushl $251
80106a4d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106a52:	e9 b3 f0 ff ff       	jmp    80105b0a <alltraps>

80106a57 <vector252>:
.globl vector252
vector252:
  pushl $0
80106a57:	6a 00                	push   $0x0
  pushl $252
80106a59:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106a5e:	e9 a7 f0 ff ff       	jmp    80105b0a <alltraps>

80106a63 <vector253>:
.globl vector253
vector253:
  pushl $0
80106a63:	6a 00                	push   $0x0
  pushl $253
80106a65:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106a6a:	e9 9b f0 ff ff       	jmp    80105b0a <alltraps>

80106a6f <vector254>:
.globl vector254
vector254:
  pushl $0
80106a6f:	6a 00                	push   $0x0
  pushl $254
80106a71:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106a76:	e9 8f f0 ff ff       	jmp    80105b0a <alltraps>

80106a7b <vector255>:
.globl vector255
vector255:
  pushl $0
80106a7b:	6a 00                	push   $0x0
  pushl $255
80106a7d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106a82:	e9 83 f0 ff ff       	jmp    80105b0a <alltraps>
80106a87:	66 90                	xchg   %ax,%ax
80106a89:	66 90                	xchg   %ax,%ax
80106a8b:	66 90                	xchg   %ax,%ax
80106a8d:	66 90                	xchg   %ax,%ax
80106a8f:	90                   	nop

80106a90 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106a90:	55                   	push   %ebp
80106a91:	89 e5                	mov    %esp,%ebp
80106a93:	57                   	push   %edi
80106a94:	56                   	push   %esi
80106a95:	89 c6                	mov    %eax,%esi
80106a97:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80106a98:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
80106a9e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106aa4:	83 ec 1c             	sub    $0x1c,%esp
80106aa7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106aaa:	39 d3                	cmp    %edx,%ebx
80106aac:	73 4f                	jae    80106afd <deallocuvm.part.0+0x6d>
80106aae:	89 d7                	mov    %edx,%edi
80106ab0:	eb 12                	jmp    80106ac4 <deallocuvm.part.0+0x34>
80106ab2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106ab8:	83 c0 01             	add    $0x1,%eax
80106abb:	c1 e0 16             	shl    $0x16,%eax
80106abe:	89 c3                	mov    %eax,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106ac0:	39 df                	cmp    %ebx,%edi
80106ac2:	76 39                	jbe    80106afd <deallocuvm.part.0+0x6d>
  pde = &pgdir[PDX(va)];
80106ac4:	89 d8                	mov    %ebx,%eax
80106ac6:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80106ac9:	8b 14 86             	mov    (%esi,%eax,4),%edx
80106acc:	f6 c2 01             	test   $0x1,%dl
80106acf:	74 e7                	je     80106ab8 <deallocuvm.part.0+0x28>
  return &pgtab[PTX(va)];
80106ad1:	89 d9                	mov    %ebx,%ecx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106ad3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80106ad9:	c1 e9 0a             	shr    $0xa,%ecx
80106adc:	81 e1 fc 0f 00 00    	and    $0xffc,%ecx
80106ae2:	8d 94 0a 00 00 00 80 	lea    -0x80000000(%edx,%ecx,1),%edx
    if(!pte)
80106ae9:	85 d2                	test   %edx,%edx
80106aeb:	74 cb                	je     80106ab8 <deallocuvm.part.0+0x28>
    else if((*pte & PTE_P) != 0){
80106aed:	8b 02                	mov    (%edx),%eax
80106aef:	a8 01                	test   $0x1,%al
80106af1:	75 1d                	jne    80106b10 <deallocuvm.part.0+0x80>
  for(; a  < oldsz; a += PGSIZE){
80106af3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106af9:	39 df                	cmp    %ebx,%edi
80106afb:	77 c7                	ja     80106ac4 <deallocuvm.part.0+0x34>
      myproc()->rss -= PGSIZE;
    }
    
  }
  return newsz;
}
80106afd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106b00:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b03:	5b                   	pop    %ebx
80106b04:	5e                   	pop    %esi
80106b05:	5f                   	pop    %edi
80106b06:	5d                   	pop    %ebp
80106b07:	c3                   	ret    
80106b08:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106b0f:	90                   	nop
      if(pa == 0)
80106b10:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106b15:	74 44                	je     80106b5b <deallocuvm.part.0+0xcb>
      kfree(v);
80106b17:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
80106b1a:	05 00 00 00 80       	add    $0x80000000,%eax
80106b1f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106b22:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      kfree(v);
80106b28:	50                   	push   %eax
80106b29:	e8 c2 ba ff ff       	call   801025f0 <kfree>
      *pte = 0;
80106b2e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106b31:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
      if(myproc()->rss > 0)
80106b37:	e8 04 d0 ff ff       	call   80103b40 <myproc>
80106b3c:	83 c4 10             	add    $0x10,%esp
80106b3f:	8b 40 04             	mov    0x4(%eax),%eax
80106b42:	85 c0                	test   %eax,%eax
80106b44:	0f 84 76 ff ff ff    	je     80106ac0 <deallocuvm.part.0+0x30>
      myproc()->rss -= PGSIZE;
80106b4a:	e8 f1 cf ff ff       	call   80103b40 <myproc>
80106b4f:	81 68 04 00 10 00 00 	subl   $0x1000,0x4(%eax)
80106b56:	e9 65 ff ff ff       	jmp    80106ac0 <deallocuvm.part.0+0x30>
        panic("kfree");
80106b5b:	83 ec 0c             	sub    $0xc,%esp
80106b5e:	68 86 7a 10 80       	push   $0x80107a86
80106b63:	e8 48 99 ff ff       	call   801004b0 <panic>
80106b68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106b6f:	90                   	nop

80106b70 <mappages>:
{
80106b70:	55                   	push   %ebp
80106b71:	89 e5                	mov    %esp,%ebp
80106b73:	57                   	push   %edi
80106b74:	56                   	push   %esi
80106b75:	53                   	push   %ebx
  a = (char*)PGROUNDDOWN((uint)va);
80106b76:	89 d3                	mov    %edx,%ebx
80106b78:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
80106b7e:	83 ec 1c             	sub    $0x1c,%esp
80106b81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106b84:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
80106b88:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106b8d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106b90:	8b 45 08             	mov    0x8(%ebp),%eax
80106b93:	29 d8                	sub    %ebx,%eax
80106b95:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106b98:	eb 3d                	jmp    80106bd7 <mappages+0x67>
80106b9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80106ba0:	89 da                	mov    %ebx,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106ba2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80106ba7:	c1 ea 0a             	shr    $0xa,%edx
80106baa:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80106bb0:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106bb7:	85 c0                	test   %eax,%eax
80106bb9:	74 75                	je     80106c30 <mappages+0xc0>
    if(*pte & PTE_P)
80106bbb:	f6 00 01             	testb  $0x1,(%eax)
80106bbe:	0f 85 86 00 00 00    	jne    80106c4a <mappages+0xda>
    *pte = pa | perm | PTE_P;
80106bc4:	0b 75 0c             	or     0xc(%ebp),%esi
80106bc7:	83 ce 01             	or     $0x1,%esi
80106bca:	89 30                	mov    %esi,(%eax)
    if(a == last)
80106bcc:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
80106bcf:	74 6f                	je     80106c40 <mappages+0xd0>
    a += PGSIZE;
80106bd1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  for(;;){
80106bd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  pde = &pgdir[PDX(va)];
80106bda:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106bdd:	8d 34 18             	lea    (%eax,%ebx,1),%esi
80106be0:	89 d8                	mov    %ebx,%eax
80106be2:	c1 e8 16             	shr    $0x16,%eax
80106be5:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
  if(*pde & PTE_P){
80106be8:	8b 07                	mov    (%edi),%eax
80106bea:	a8 01                	test   $0x1,%al
80106bec:	75 b2                	jne    80106ba0 <mappages+0x30>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106bee:	e8 dd bb ff ff       	call   801027d0 <kalloc>
80106bf3:	85 c0                	test   %eax,%eax
80106bf5:	74 39                	je     80106c30 <mappages+0xc0>
    memset(pgtab, 0, PGSIZE);
80106bf7:	83 ec 04             	sub    $0x4,%esp
80106bfa:	89 45 d8             	mov    %eax,-0x28(%ebp)
80106bfd:	68 00 10 00 00       	push   $0x1000
80106c02:	6a 00                	push   $0x0
80106c04:	50                   	push   %eax
80106c05:	e8 06 dd ff ff       	call   80104910 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106c0a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  return &pgtab[PTX(va)];
80106c0d:	83 c4 10             	add    $0x10,%esp
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106c10:	8d 82 00 00 00 80    	lea    -0x80000000(%edx),%eax
80106c16:	83 c8 07             	or     $0x7,%eax
80106c19:	89 07                	mov    %eax,(%edi)
  return &pgtab[PTX(va)];
80106c1b:	89 d8                	mov    %ebx,%eax
80106c1d:	c1 e8 0a             	shr    $0xa,%eax
80106c20:	25 fc 0f 00 00       	and    $0xffc,%eax
80106c25:	01 d0                	add    %edx,%eax
80106c27:	eb 92                	jmp    80106bbb <mappages+0x4b>
80106c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}
80106c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106c33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106c38:	5b                   	pop    %ebx
80106c39:	5e                   	pop    %esi
80106c3a:	5f                   	pop    %edi
80106c3b:	5d                   	pop    %ebp
80106c3c:	c3                   	ret    
80106c3d:	8d 76 00             	lea    0x0(%esi),%esi
80106c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106c43:	31 c0                	xor    %eax,%eax
}
80106c45:	5b                   	pop    %ebx
80106c46:	5e                   	pop    %esi
80106c47:	5f                   	pop    %edi
80106c48:	5d                   	pop    %ebp
80106c49:	c3                   	ret    
      panic("remap");
80106c4a:	83 ec 0c             	sub    $0xc,%esp
80106c4d:	68 58 81 10 80       	push   $0x80108158
80106c52:	e8 59 98 ff ff       	call   801004b0 <panic>
80106c57:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106c5e:	66 90                	xchg   %ax,%ax

80106c60 <seginit>:
{
80106c60:	55                   	push   %ebp
80106c61:	89 e5                	mov    %esp,%ebp
80106c63:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
80106c66:	e8 b5 ce ff ff       	call   80103b20 <cpuid>
  pd[0] = size-1;
80106c6b:	ba 2f 00 00 00       	mov    $0x2f,%edx
80106c70:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106c76:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106c7a:	c7 80 38 28 11 80 ff 	movl   $0xffff,-0x7feed7c8(%eax)
80106c81:	ff 00 00 
80106c84:	c7 80 3c 28 11 80 00 	movl   $0xcf9a00,-0x7feed7c4(%eax)
80106c8b:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106c8e:	c7 80 40 28 11 80 ff 	movl   $0xffff,-0x7feed7c0(%eax)
80106c95:	ff 00 00 
80106c98:	c7 80 44 28 11 80 00 	movl   $0xcf9200,-0x7feed7bc(%eax)
80106c9f:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106ca2:	c7 80 48 28 11 80 ff 	movl   $0xffff,-0x7feed7b8(%eax)
80106ca9:	ff 00 00 
80106cac:	c7 80 4c 28 11 80 00 	movl   $0xcffa00,-0x7feed7b4(%eax)
80106cb3:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106cb6:	c7 80 50 28 11 80 ff 	movl   $0xffff,-0x7feed7b0(%eax)
80106cbd:	ff 00 00 
80106cc0:	c7 80 54 28 11 80 00 	movl   $0xcff200,-0x7feed7ac(%eax)
80106cc7:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
80106cca:	05 30 28 11 80       	add    $0x80112830,%eax
  pd[1] = (uint)p;
80106ccf:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106cd3:	c1 e8 10             	shr    $0x10,%eax
80106cd6:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106cda:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106cdd:	0f 01 10             	lgdtl  (%eax)
}
80106ce0:	c9                   	leave  
80106ce1:	c3                   	ret    
80106ce2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106cf0 <walkpgdir>:
{
80106cf0:	55                   	push   %ebp
80106cf1:	89 e5                	mov    %esp,%ebp
80106cf3:	57                   	push   %edi
80106cf4:	56                   	push   %esi
80106cf5:	53                   	push   %ebx
80106cf6:	83 ec 0c             	sub    $0xc,%esp
80106cf9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pde = &pgdir[PDX(va)];
80106cfc:	8b 55 08             	mov    0x8(%ebp),%edx
80106cff:	89 fe                	mov    %edi,%esi
80106d01:	c1 ee 16             	shr    $0x16,%esi
80106d04:	8d 34 b2             	lea    (%edx,%esi,4),%esi
  if(*pde & PTE_P){
80106d07:	8b 1e                	mov    (%esi),%ebx
80106d09:	f6 c3 01             	test   $0x1,%bl
80106d0c:	74 22                	je     80106d30 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106d0e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80106d14:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
  return &pgtab[PTX(va)];
80106d1a:	89 f8                	mov    %edi,%eax
}
80106d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
80106d1f:	c1 e8 0a             	shr    $0xa,%eax
80106d22:	25 fc 0f 00 00       	and    $0xffc,%eax
80106d27:	01 d8                	add    %ebx,%eax
}
80106d29:	5b                   	pop    %ebx
80106d2a:	5e                   	pop    %esi
80106d2b:	5f                   	pop    %edi
80106d2c:	5d                   	pop    %ebp
80106d2d:	c3                   	ret    
80106d2e:	66 90                	xchg   %ax,%ax
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106d30:	8b 45 10             	mov    0x10(%ebp),%eax
80106d33:	85 c0                	test   %eax,%eax
80106d35:	74 31                	je     80106d68 <walkpgdir+0x78>
80106d37:	e8 94 ba ff ff       	call   801027d0 <kalloc>
80106d3c:	89 c3                	mov    %eax,%ebx
80106d3e:	85 c0                	test   %eax,%eax
80106d40:	74 26                	je     80106d68 <walkpgdir+0x78>
    memset(pgtab, 0, PGSIZE);
80106d42:	83 ec 04             	sub    $0x4,%esp
80106d45:	68 00 10 00 00       	push   $0x1000
80106d4a:	6a 00                	push   $0x0
80106d4c:	50                   	push   %eax
80106d4d:	e8 be db ff ff       	call   80104910 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106d52:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106d58:	83 c4 10             	add    $0x10,%esp
80106d5b:	83 c8 07             	or     $0x7,%eax
80106d5e:	89 06                	mov    %eax,(%esi)
80106d60:	eb b8                	jmp    80106d1a <walkpgdir+0x2a>
80106d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
}
80106d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
80106d6b:	31 c0                	xor    %eax,%eax
}
80106d6d:	5b                   	pop    %ebx
80106d6e:	5e                   	pop    %esi
80106d6f:	5f                   	pop    %edi
80106d70:	5d                   	pop    %ebp
80106d71:	c3                   	ret    
80106d72:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106d80 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106d80:	a1 e4 55 11 80       	mov    0x801155e4,%eax
80106d85:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106d8a:	0f 22 d8             	mov    %eax,%cr3
}
80106d8d:	c3                   	ret    
80106d8e:	66 90                	xchg   %ax,%ax

80106d90 <switchuvm>:
{
80106d90:	55                   	push   %ebp
80106d91:	89 e5                	mov    %esp,%ebp
80106d93:	57                   	push   %edi
80106d94:	56                   	push   %esi
80106d95:	53                   	push   %ebx
80106d96:	83 ec 1c             	sub    $0x1c,%esp
80106d99:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106d9c:	85 f6                	test   %esi,%esi
80106d9e:	0f 84 cb 00 00 00    	je     80106e6f <switchuvm+0xdf>
  if(p->kstack == 0)
80106da4:	8b 46 0c             	mov    0xc(%esi),%eax
80106da7:	85 c0                	test   %eax,%eax
80106da9:	0f 84 da 00 00 00    	je     80106e89 <switchuvm+0xf9>
  if(p->pgdir == 0)
80106daf:	8b 46 08             	mov    0x8(%esi),%eax
80106db2:	85 c0                	test   %eax,%eax
80106db4:	0f 84 c2 00 00 00    	je     80106e7c <switchuvm+0xec>
  pushcli();
80106dba:	e8 41 d9 ff ff       	call   80104700 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106dbf:	e8 fc cc ff ff       	call   80103ac0 <mycpu>
80106dc4:	89 c3                	mov    %eax,%ebx
80106dc6:	e8 f5 cc ff ff       	call   80103ac0 <mycpu>
80106dcb:	89 c7                	mov    %eax,%edi
80106dcd:	e8 ee cc ff ff       	call   80103ac0 <mycpu>
80106dd2:	83 c7 08             	add    $0x8,%edi
80106dd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106dd8:	e8 e3 cc ff ff       	call   80103ac0 <mycpu>
80106ddd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80106de0:	ba 67 00 00 00       	mov    $0x67,%edx
80106de5:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106dec:	83 c0 08             	add    $0x8,%eax
80106def:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106df6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106dfb:	83 c1 08             	add    $0x8,%ecx
80106dfe:	c1 e8 18             	shr    $0x18,%eax
80106e01:	c1 e9 10             	shr    $0x10,%ecx
80106e04:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
80106e0a:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106e10:	b9 99 40 00 00       	mov    $0x4099,%ecx
80106e15:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106e1c:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
80106e21:	e8 9a cc ff ff       	call   80103ac0 <mycpu>
80106e26:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106e2d:	e8 8e cc ff ff       	call   80103ac0 <mycpu>
80106e32:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106e36:	8b 5e 0c             	mov    0xc(%esi),%ebx
80106e39:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106e3f:	e8 7c cc ff ff       	call   80103ac0 <mycpu>
80106e44:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106e47:	e8 74 cc ff ff       	call   80103ac0 <mycpu>
80106e4c:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106e50:	b8 28 00 00 00       	mov    $0x28,%eax
80106e55:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106e58:	8b 46 08             	mov    0x8(%esi),%eax
80106e5b:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106e60:	0f 22 d8             	mov    %eax,%cr3
}
80106e63:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e66:	5b                   	pop    %ebx
80106e67:	5e                   	pop    %esi
80106e68:	5f                   	pop    %edi
80106e69:	5d                   	pop    %ebp
  popcli();
80106e6a:	e9 e1 d8 ff ff       	jmp    80104750 <popcli>
    panic("switchuvm: no process");
80106e6f:	83 ec 0c             	sub    $0xc,%esp
80106e72:	68 5e 81 10 80       	push   $0x8010815e
80106e77:	e8 34 96 ff ff       	call   801004b0 <panic>
    panic("switchuvm: no pgdir");
80106e7c:	83 ec 0c             	sub    $0xc,%esp
80106e7f:	68 89 81 10 80       	push   $0x80108189
80106e84:	e8 27 96 ff ff       	call   801004b0 <panic>
    panic("switchuvm: no kstack");
80106e89:	83 ec 0c             	sub    $0xc,%esp
80106e8c:	68 74 81 10 80       	push   $0x80108174
80106e91:	e8 1a 96 ff ff       	call   801004b0 <panic>
80106e96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106e9d:	8d 76 00             	lea    0x0(%esi),%esi

80106ea0 <inituvm>:
{
80106ea0:	55                   	push   %ebp
80106ea1:	89 e5                	mov    %esp,%ebp
80106ea3:	57                   	push   %edi
80106ea4:	56                   	push   %esi
80106ea5:	53                   	push   %ebx
80106ea6:	83 ec 1c             	sub    $0x1c,%esp
80106ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
80106eac:	8b 75 10             	mov    0x10(%ebp),%esi
80106eaf:	8b 7d 08             	mov    0x8(%ebp),%edi
80106eb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
80106eb5:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106ebb:	77 4b                	ja     80106f08 <inituvm+0x68>
  mem = kalloc();
80106ebd:	e8 0e b9 ff ff       	call   801027d0 <kalloc>
  memset(mem, 0, PGSIZE);
80106ec2:	83 ec 04             	sub    $0x4,%esp
80106ec5:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
80106eca:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106ecc:	6a 00                	push   $0x0
80106ece:	50                   	push   %eax
80106ecf:	e8 3c da ff ff       	call   80104910 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106ed4:	58                   	pop    %eax
80106ed5:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106edb:	5a                   	pop    %edx
80106edc:	6a 06                	push   $0x6
80106ede:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106ee3:	31 d2                	xor    %edx,%edx
80106ee5:	50                   	push   %eax
80106ee6:	89 f8                	mov    %edi,%eax
80106ee8:	e8 83 fc ff ff       	call   80106b70 <mappages>
  memmove(mem, init, sz);
80106eed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ef0:	89 75 10             	mov    %esi,0x10(%ebp)
80106ef3:	83 c4 10             	add    $0x10,%esp
80106ef6:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106ef9:	89 45 0c             	mov    %eax,0xc(%ebp)
}
80106efc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106eff:	5b                   	pop    %ebx
80106f00:	5e                   	pop    %esi
80106f01:	5f                   	pop    %edi
80106f02:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80106f03:	e9 a8 da ff ff       	jmp    801049b0 <memmove>
    panic("inituvm: more than a page");
80106f08:	83 ec 0c             	sub    $0xc,%esp
80106f0b:	68 9d 81 10 80       	push   $0x8010819d
80106f10:	e8 9b 95 ff ff       	call   801004b0 <panic>
80106f15:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106f20 <loaduvm>:
{
80106f20:	55                   	push   %ebp
80106f21:	89 e5                	mov    %esp,%ebp
80106f23:	57                   	push   %edi
80106f24:	56                   	push   %esi
80106f25:	53                   	push   %ebx
80106f26:	83 ec 1c             	sub    $0x1c,%esp
80106f29:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f2c:	8b 75 18             	mov    0x18(%ebp),%esi
  if((uint) addr % PGSIZE != 0)
80106f2f:	a9 ff 0f 00 00       	test   $0xfff,%eax
80106f34:	0f 85 bb 00 00 00    	jne    80106ff5 <loaduvm+0xd5>
  for(i = 0; i < sz; i += PGSIZE){
80106f3a:	01 f0                	add    %esi,%eax
80106f3c:	89 f3                	mov    %esi,%ebx
80106f3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106f41:	8b 45 14             	mov    0x14(%ebp),%eax
80106f44:	01 f0                	add    %esi,%eax
80106f46:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sz; i += PGSIZE){
80106f49:	85 f6                	test   %esi,%esi
80106f4b:	0f 84 87 00 00 00    	je     80106fd8 <loaduvm+0xb8>
80106f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  pde = &pgdir[PDX(va)];
80106f58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  if(*pde & PTE_P){
80106f5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106f5e:	29 d8                	sub    %ebx,%eax
  pde = &pgdir[PDX(va)];
80106f60:	89 c2                	mov    %eax,%edx
80106f62:	c1 ea 16             	shr    $0x16,%edx
  if(*pde & PTE_P){
80106f65:	8b 14 91             	mov    (%ecx,%edx,4),%edx
80106f68:	f6 c2 01             	test   $0x1,%dl
80106f6b:	75 13                	jne    80106f80 <loaduvm+0x60>
      panic("loaduvm: address should exist");
80106f6d:	83 ec 0c             	sub    $0xc,%esp
80106f70:	68 b7 81 10 80       	push   $0x801081b7
80106f75:	e8 36 95 ff ff       	call   801004b0 <panic>
80106f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80106f80:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106f83:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80106f89:	25 fc 0f 00 00       	and    $0xffc,%eax
80106f8e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106f95:	85 c0                	test   %eax,%eax
80106f97:	74 d4                	je     80106f6d <loaduvm+0x4d>
    pa = PTE_ADDR(*pte);
80106f99:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106f9b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    if(sz - i < PGSIZE)
80106f9e:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80106fa3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106fa8:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
80106fae:	0f 46 fb             	cmovbe %ebx,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106fb1:	29 d9                	sub    %ebx,%ecx
80106fb3:	05 00 00 00 80       	add    $0x80000000,%eax
80106fb8:	57                   	push   %edi
80106fb9:	51                   	push   %ecx
80106fba:	50                   	push   %eax
80106fbb:	ff 75 10             	push   0x10(%ebp)
80106fbe:	e8 fd ab ff ff       	call   80101bc0 <readi>
80106fc3:	83 c4 10             	add    $0x10,%esp
80106fc6:	39 f8                	cmp    %edi,%eax
80106fc8:	75 1e                	jne    80106fe8 <loaduvm+0xc8>
  for(i = 0; i < sz; i += PGSIZE){
80106fca:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
80106fd0:	89 f0                	mov    %esi,%eax
80106fd2:	29 d8                	sub    %ebx,%eax
80106fd4:	39 c6                	cmp    %eax,%esi
80106fd6:	77 80                	ja     80106f58 <loaduvm+0x38>
}
80106fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106fdb:	31 c0                	xor    %eax,%eax
}
80106fdd:	5b                   	pop    %ebx
80106fde:	5e                   	pop    %esi
80106fdf:	5f                   	pop    %edi
80106fe0:	5d                   	pop    %ebp
80106fe1:	c3                   	ret    
80106fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106feb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106ff0:	5b                   	pop    %ebx
80106ff1:	5e                   	pop    %esi
80106ff2:	5f                   	pop    %edi
80106ff3:	5d                   	pop    %ebp
80106ff4:	c3                   	ret    
    panic("loaduvm: addr must be page aligned");
80106ff5:	83 ec 0c             	sub    $0xc,%esp
80106ff8:	68 58 82 10 80       	push   $0x80108258
80106ffd:	e8 ae 94 ff ff       	call   801004b0 <panic>
80107002:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107010 <allocuvm>:
{
80107010:	55                   	push   %ebp
80107011:	89 e5                	mov    %esp,%ebp
80107013:	57                   	push   %edi
80107014:	56                   	push   %esi
80107015:	53                   	push   %ebx
80107016:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80107019:	8b 45 10             	mov    0x10(%ebp),%eax
{
8010701c:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
8010701f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107022:	85 c0                	test   %eax,%eax
80107024:	0f 88 c6 00 00 00    	js     801070f0 <allocuvm+0xe0>
  if(newsz < oldsz)
8010702a:	3b 45 0c             	cmp    0xc(%ebp),%eax
    return oldsz;
8010702d:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(newsz < oldsz)
80107030:	0f 82 aa 00 00 00    	jb     801070e0 <allocuvm+0xd0>
  a = PGROUNDUP(oldsz);
80107036:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
8010703c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80107042:	39 75 10             	cmp    %esi,0x10(%ebp)
80107045:	77 48                	ja     8010708f <allocuvm+0x7f>
80107047:	e9 97 00 00 00       	jmp    801070e3 <allocuvm+0xd3>
8010704c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    memset(mem, 0, PGSIZE);
80107050:	83 ec 04             	sub    $0x4,%esp
80107053:	68 00 10 00 00       	push   $0x1000
80107058:	6a 00                	push   $0x0
8010705a:	53                   	push   %ebx
8010705b:	e8 b0 d8 ff ff       	call   80104910 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107060:	58                   	pop    %eax
80107061:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80107067:	5a                   	pop    %edx
80107068:	6a 06                	push   $0x6
8010706a:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010706f:	89 f2                	mov    %esi,%edx
80107071:	50                   	push   %eax
80107072:	89 f8                	mov    %edi,%eax
80107074:	e8 f7 fa ff ff       	call   80106b70 <mappages>
80107079:	83 c4 10             	add    $0x10,%esp
8010707c:	85 c0                	test   %eax,%eax
8010707e:	0f 88 84 00 00 00    	js     80107108 <allocuvm+0xf8>
  for(; a < newsz; a += PGSIZE){
80107084:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010708a:	39 75 10             	cmp    %esi,0x10(%ebp)
8010708d:	76 54                	jbe    801070e3 <allocuvm+0xd3>
    mem = kalloc();
8010708f:	e8 3c b7 ff ff       	call   801027d0 <kalloc>
80107094:	89 c3                	mov    %eax,%ebx
    myproc()->rss += PGSIZE;
80107096:	e8 a5 ca ff ff       	call   80103b40 <myproc>
8010709b:	81 40 04 00 10 00 00 	addl   $0x1000,0x4(%eax)
    if(mem == 0){
801070a2:	85 db                	test   %ebx,%ebx
801070a4:	75 aa                	jne    80107050 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
801070a6:	83 ec 0c             	sub    $0xc,%esp
801070a9:	68 d5 81 10 80       	push   $0x801081d5
801070ae:	e8 1d 97 ff ff       	call   801007d0 <cprintf>
  if(newsz >= oldsz)
801070b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801070b6:	83 c4 10             	add    $0x10,%esp
801070b9:	39 45 10             	cmp    %eax,0x10(%ebp)
801070bc:	74 32                	je     801070f0 <allocuvm+0xe0>
801070be:	8b 55 10             	mov    0x10(%ebp),%edx
801070c1:	89 c1                	mov    %eax,%ecx
801070c3:	89 f8                	mov    %edi,%eax
801070c5:	e8 c6 f9 ff ff       	call   80106a90 <deallocuvm.part.0>
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
8010710b:	68 ed 81 10 80       	push   $0x801081ed
80107110:	e8 bb 96 ff ff       	call   801007d0 <cprintf>
  if(newsz >= oldsz)
80107115:	8b 45 0c             	mov    0xc(%ebp),%eax
80107118:	83 c4 10             	add    $0x10,%esp
8010711b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010711e:	74 0c                	je     8010712c <allocuvm+0x11c>
80107120:	8b 55 10             	mov    0x10(%ebp),%edx
80107123:	89 c1                	mov    %eax,%ecx
80107125:	89 f8                	mov    %edi,%eax
80107127:	e8 64 f9 ff ff       	call   80106a90 <deallocuvm.part.0>
      kfree(mem);
8010712c:	83 ec 0c             	sub    $0xc,%esp
8010712f:	53                   	push   %ebx
80107130:	e8 bb b4 ff ff       	call   801025f0 <kfree>
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
80107161:	e9 2a f9 ff ff       	jmp    80106a90 <deallocuvm.part.0>
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
8010719b:	e8 f0 f8 ff ff       	call   80106a90 <deallocuvm.part.0>
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
801071ce:	e8 1d b4 ff ff       	call   801025f0 <kfree>
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
801071e4:	e9 07 b4 ff ff       	jmp    801025f0 <kfree>
    panic("freevm: no pgdir");
801071e9:	83 ec 0c             	sub    $0xc,%esp
801071ec:	68 09 82 10 80       	push   $0x80108209
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
80107205:	e8 c6 b5 ff ff       	call   801027d0 <kalloc>
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
80107220:	e8 eb d6 ff ff       	call   80104910 <memset>
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
8010723b:	e8 30 f9 ff ff       	call   80106b70 <mappages>
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
8010728b:	a3 e4 55 11 80       	mov    %eax,0x801155e4
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
801072bc:	68 1a 82 10 80       	push   $0x8010821a
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
copyuvm(pde_t *pgdir, uint sz, struct proc* p)
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
80107303:	0f 84 c7 00 00 00    	je     801073d0 <copyuvm+0xe0>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80107309:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010730c:	85 c9                	test   %ecx,%ecx
8010730e:	0f 84 bc 00 00 00    	je     801073d0 <copyuvm+0xe0>
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
80107332:	68 24 82 10 80       	push   $0x80108224
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
8010735f:	0f 84 a7 00 00 00    	je     8010740c <copyuvm+0x11c>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80107365:	89 c7                	mov    %eax,%edi
    flags = PTE_FLAGS(*pte);
80107367:	25 ff 0f 00 00       	and    $0xfff,%eax
8010736c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pa = PTE_ADDR(*pte);
8010736f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
80107375:	e8 56 b4 ff ff       	call   801027d0 <kalloc>
8010737a:	89 c3                	mov    %eax,%ebx
8010737c:	85 c0                	test   %eax,%eax
8010737e:	74 6c                	je     801073ec <copyuvm+0xfc>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107380:	83 ec 04             	sub    $0x4,%esp
80107383:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80107389:	68 00 10 00 00       	push   $0x1000
8010738e:	57                   	push   %edi
8010738f:	50                   	push   %eax
80107390:	e8 1b d6 ff ff       	call   801049b0 <memmove>
    p->rss+=PGSIZE;
80107395:	8b 55 10             	mov    0x10(%ebp),%edx
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80107398:	b9 00 10 00 00       	mov    $0x1000,%ecx
    p->rss+=PGSIZE;
8010739d:	81 42 04 00 10 00 00 	addl   $0x1000,0x4(%edx)
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801073a4:	58                   	pop    %eax
801073a5:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801073ab:	5a                   	pop    %edx
801073ac:	ff 75 e4             	push   -0x1c(%ebp)
801073af:	89 f2                	mov    %esi,%edx
801073b1:	50                   	push   %eax
801073b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801073b5:	e8 b6 f7 ff ff       	call   80106b70 <mappages>
801073ba:	83 c4 10             	add    $0x10,%esp
801073bd:	85 c0                	test   %eax,%eax
801073bf:	78 1f                	js     801073e0 <copyuvm+0xf0>
  for(i = 0; i < sz; i += PGSIZE){
801073c1:	81 c6 00 10 00 00    	add    $0x1000,%esi
801073c7:	39 75 0c             	cmp    %esi,0xc(%ebp)
801073ca:	0f 87 50 ff ff ff    	ja     80107320 <copyuvm+0x30>
  return d;

bad:
  freevm(d);
  return 0;
}
801073d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801073d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801073d6:	5b                   	pop    %ebx
801073d7:	5e                   	pop    %esi
801073d8:	5f                   	pop    %edi
801073d9:	5d                   	pop    %ebp
801073da:	c3                   	ret    
801073db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801073df:	90                   	nop
      kfree(mem);
801073e0:	83 ec 0c             	sub    $0xc,%esp
801073e3:	53                   	push   %ebx
801073e4:	e8 07 b2 ff ff       	call   801025f0 <kfree>
      goto bad;
801073e9:	83 c4 10             	add    $0x10,%esp
  freevm(d);
801073ec:	83 ec 0c             	sub    $0xc,%esp
801073ef:	ff 75 e0             	push   -0x20(%ebp)
801073f2:	e8 89 fd ff ff       	call   80107180 <freevm>
  return 0;
801073f7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801073fe:	83 c4 10             	add    $0x10,%esp
}
80107401:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107404:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107407:	5b                   	pop    %ebx
80107408:	5e                   	pop    %esi
80107409:	5f                   	pop    %edi
8010740a:	5d                   	pop    %ebp
8010740b:	c3                   	ret    
      panic("copyuvm: page not present");
8010740c:	83 ec 0c             	sub    $0xc,%esp
8010740f:	68 3e 82 10 80       	push   $0x8010823e
80107414:	e8 97 90 ff ff       	call   801004b0 <panic>
80107419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

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
80107434:	0f 84 00 01 00 00    	je     8010753a <uva2ka.cold>
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
801074c0:	e8 eb d4 ff ff       	call   801049b0 <memmove>
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
801074ed:	0f 84 4e 00 00 00    	je     80107541 <copyout.cold>
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

8010753a <uva2ka.cold>:
  if((*pte & PTE_P) == 0)
8010753a:	a1 00 00 00 00       	mov    0x0,%eax
8010753f:	0f 0b                	ud2    

80107541 <copyout.cold>:
80107541:	a1 00 00 00 00       	mov    0x0,%eax
80107546:	0f 0b                	ud2    
80107548:	66 90                	xchg   %ax,%ax
8010754a:	66 90                	xchg   %ax,%ax
8010754c:	66 90                	xchg   %ax,%ax
8010754e:	66 90                	xchg   %ax,%ax

80107550 <init_slot>:
#include "buf.h"

struct swap_slot ss[NSLOTS];

void init_slot(){
  for(int i = 0; i<NSLOTS; i++){
80107550:	31 c0                	xor    %eax,%eax
80107552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    ss[i].is_free = 1;
80107558:	c7 04 c5 04 56 11 80 	movl   $0x1,-0x7feea9fc(,%eax,8)
8010755f:	01 00 00 00 
  for(int i = 0; i<NSLOTS; i++){
80107563:	83 c0 01             	add    $0x1,%eax
80107566:	3d 2c 01 00 00       	cmp    $0x12c,%eax
8010756b:	75 eb                	jne    80107558 <init_slot+0x8>
  }
}
8010756d:	c3                   	ret    
8010756e:	66 90                	xchg   %ax,%ax

80107570 <unset_access>:
        unset_access(p->pgdir,count);
    }
    return 0;
}

void unset_access(pde_t* p, int count){
80107570:	55                   	push   %ebp
80107571:	89 e5                	mov    %esp,%ebp
80107573:	57                   	push   %edi
80107574:	56                   	push   %esi
80107575:	53                   	push   %ebx
    int z = (count+9)/10;
80107576:	bb 67 66 66 66       	mov    $0x66666667,%ebx
void unset_access(pde_t* p, int count){
8010757b:	83 ec 0c             	sub    $0xc,%esp
    int z = (count+9)/10;
8010757e:	8b 45 0c             	mov    0xc(%ebp),%eax
void unset_access(pde_t* p, int count){
80107581:	8b 75 08             	mov    0x8(%ebp),%esi
    int z = (count+9)/10;
80107584:	8d 48 09             	lea    0x9(%eax),%ecx
80107587:	89 c8                	mov    %ecx,%eax
80107589:	c1 f9 1f             	sar    $0x1f,%ecx
8010758c:	f7 eb                	imul   %ebx
8010758e:	89 d3                	mov    %edx,%ebx
80107590:	c1 fb 02             	sar    $0x2,%ebx
    int i=0;
    while(z){
80107593:	29 cb                	sub    %ecx,%ebx
80107595:	74 41                	je     801075d8 <unset_access+0x68>
    int i=0;
80107597:	31 ff                	xor    %edi,%edi
80107599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        pte_t* pte = walkpgdir(p, (void*)i, 0);
801075a0:	83 ec 04             	sub    $0x4,%esp
801075a3:	6a 00                	push   $0x0
801075a5:	57                   	push   %edi
801075a6:	56                   	push   %esi
801075a7:	e8 44 f7 ff ff       	call   80106cf0 <walkpgdir>
        if(*pte & PTE_P){
            if(*pte & PTE_A){
801075ac:	83 c4 10             	add    $0x10,%esp
        if(*pte & PTE_P){
801075af:	8b 10                	mov    (%eax),%edx
            if(*pte & PTE_A){
801075b1:	89 d1                	mov    %edx,%ecx
801075b3:	83 e1 21             	and    $0x21,%ecx
801075b6:	83 f9 21             	cmp    $0x21,%ecx
801075b9:	74 0d                	je     801075c8 <unset_access+0x58>
                *pte &= ~PTE_A;
                z--;
            }
        }
        i+=PGSIZE;
801075bb:	81 c7 00 10 00 00    	add    $0x1000,%edi
    while(z){
801075c1:	eb dd                	jmp    801075a0 <unset_access+0x30>
801075c3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801075c7:	90                   	nop
                *pte &= ~PTE_A;
801075c8:	83 e2 df             	and    $0xffffffdf,%edx
        i+=PGSIZE;
801075cb:	81 c7 00 10 00 00    	add    $0x1000,%edi
                *pte &= ~PTE_A;
801075d1:	89 10                	mov    %edx,(%eax)
    while(z){
801075d3:	83 eb 01             	sub    $0x1,%ebx
801075d6:	75 c8                	jne    801075a0 <unset_access+0x30>
    }
}
801075d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801075db:	5b                   	pop    %ebx
801075dc:	5e                   	pop    %esi
801075dd:	5f                   	pop    %edi
801075de:	5d                   	pop    %ebp
801075df:	c3                   	ret    

801075e0 <victim_page>:
pte_t* victim_page(){
801075e0:	55                   	push   %ebp
801075e1:	89 e5                	mov    %esp,%ebp
801075e3:	57                   	push   %edi
801075e4:	56                   	push   %esi
801075e5:	53                   	push   %ebx
801075e6:	83 ec 0c             	sub    $0xc,%esp
        struct proc *p = victim_proc();
801075e9:	e8 02 cf ff ff       	call   801044f0 <victim_proc>
801075ee:	89 c7                	mov    %eax,%edi
        for(int i = 0; i < p->sz; i+=PGSIZE){
801075f0:	8b 00                	mov    (%eax),%eax
801075f2:	85 c0                	test   %eax,%eax
801075f4:	74 50                	je     80107646 <victim_page+0x66>
801075f6:	31 db                	xor    %ebx,%ebx
        int count = 0;
801075f8:	31 f6                	xor    %esi,%esi
801075fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
            pte_t* pte = walkpgdir(p->pgdir, (void*)i, 0);
80107600:	83 ec 04             	sub    $0x4,%esp
80107603:	6a 00                	push   $0x0
80107605:	53                   	push   %ebx
80107606:	ff 77 08             	push   0x8(%edi)
80107609:	e8 e2 f6 ff ff       	call   80106cf0 <walkpgdir>
            if(*pte & PTE_P){
8010760e:	83 c4 10             	add    $0x10,%esp
80107611:	8b 10                	mov    (%eax),%edx
80107613:	f6 c2 01             	test   $0x1,%dl
80107616:	74 08                	je     80107620 <victim_page+0x40>
                if(!(*pte & PTE_A)){
80107618:	83 e2 20             	and    $0x20,%edx
8010761b:	74 43                	je     80107660 <victim_page+0x80>
                    count++;
8010761d:	83 c6 01             	add    $0x1,%esi
        for(int i = 0; i < p->sz; i+=PGSIZE){
80107620:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107626:	3b 1f                	cmp    (%edi),%ebx
80107628:	72 d6                	jb     80107600 <victim_page+0x20>
        unset_access(p->pgdir,count);
8010762a:	83 ec 08             	sub    $0x8,%esp
8010762d:	56                   	push   %esi
8010762e:	ff 77 08             	push   0x8(%edi)
80107631:	e8 3a ff ff ff       	call   80107570 <unset_access>
    while(1){
80107636:	83 c4 10             	add    $0x10,%esp
        struct proc *p = victim_proc();
80107639:	e8 b2 ce ff ff       	call   801044f0 <victim_proc>
8010763e:	89 c7                	mov    %eax,%edi
        for(int i = 0; i < p->sz; i+=PGSIZE){
80107640:	8b 00                	mov    (%eax),%eax
80107642:	85 c0                	test   %eax,%eax
80107644:	75 b0                	jne    801075f6 <victim_page+0x16>
        unset_access(p->pgdir,count);
80107646:	83 ec 08             	sub    $0x8,%esp
        int count = 0;
80107649:	31 f6                	xor    %esi,%esi
        unset_access(p->pgdir,count);
8010764b:	56                   	push   %esi
8010764c:	ff 77 08             	push   0x8(%edi)
8010764f:	e8 1c ff ff ff       	call   80107570 <unset_access>
    while(1){
80107654:	83 c4 10             	add    $0x10,%esp
80107657:	eb e0                	jmp    80107639 <victim_page+0x59>
80107659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
                    if (p->rss > 0){
80107660:	8b 57 04             	mov    0x4(%edi),%edx
80107663:	85 d2                	test   %edx,%edx
80107665:	74 09                	je     80107670 <victim_page+0x90>
                        p->rss -= PGSIZE;
80107667:	81 ea 00 10 00 00    	sub    $0x1000,%edx
8010766d:	89 57 04             	mov    %edx,0x4(%edi)
}
80107670:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107673:	5b                   	pop    %ebx
80107674:	5e                   	pop    %esi
80107675:	5f                   	pop    %edi
80107676:	5d                   	pop    %ebp
80107677:	c3                   	ret    
80107678:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010767f:	90                   	nop

80107680 <allocate_page>:

void allocate_page(){
80107680:	55                   	push   %ebp
80107681:	89 e5                	mov    %esp,%ebp
80107683:	57                   	push   %edi
80107684:	56                   	push   %esi
80107685:	53                   	push   %ebx
    pte_t* pte = victim_page();
    uint slot = NSLOTS;
    for(slot=0; slot<NSLOTS; slot++){
80107686:	31 db                	xor    %ebx,%ebx
void allocate_page(){
80107688:	83 ec 0c             	sub    $0xc,%esp
    pte_t* pte = victim_page();
8010768b:	e8 50 ff ff ff       	call   801075e0 <victim_page>
80107690:	89 c7                	mov    %eax,%edi
    for(slot=0; slot<NSLOTS; slot++){
80107692:	eb 0f                	jmp    801076a3 <allocate_page+0x23>
80107694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107698:	83 c3 01             	add    $0x1,%ebx
8010769b:	81 fb 2c 01 00 00    	cmp    $0x12c,%ebx
801076a1:	74 5e                	je     80107701 <allocate_page+0x81>
        if(ss[slot].is_free) break;
801076a3:	8b 04 dd 04 56 11 80 	mov    -0x7feea9fc(,%ebx,8),%eax
801076aa:	85 c0                	test   %eax,%eax
801076ac:	74 ea                	je     80107698 <allocate_page+0x18>
    }
    if(slot == NSLOTS){
        panic("Slots filled");
    }
    char* page = (char*)P2V(PTE_ADDR(*pte));   
801076ae:	8b 37                	mov    (%edi),%esi
    write_page(page,2+8*slot);
801076b0:	83 ec 08             	sub    $0x8,%esp
801076b3:	8d 04 dd 02 00 00 00 	lea    0x2(,%ebx,8),%eax
801076ba:	50                   	push   %eax
    char* page = (char*)P2V(PTE_ADDR(*pte));   
801076bb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
801076c1:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    write_page(page,2+8*slot);
801076c7:	56                   	push   %esi
801076c8:	e8 d3 8b ff ff       	call   801002a0 <write_page>
    ss[slot].is_free = 0;
801076cd:	c7 04 dd 04 56 11 80 	movl   $0x0,-0x7feea9fc(,%ebx,8)
801076d4:	00 00 00 00 
    ss[slot].page_perm = PTE_FLAGS(*pte);
801076d8:	8b 07                	mov    (%edi),%eax
801076da:	25 ff 0f 00 00       	and    $0xfff,%eax
801076df:	89 04 dd 00 56 11 80 	mov    %eax,-0x7feeaa00(,%ebx,8)
    *pte= slot << 12 | PTE_S;
801076e6:	c1 e3 0c             	shl    $0xc,%ebx
801076e9:	80 cf 02             	or     $0x2,%bh
801076ec:	89 1f                	mov    %ebx,(%edi)
    kfree(page);
801076ee:	89 34 24             	mov    %esi,(%esp)
801076f1:	e8 fa ae ff ff       	call   801025f0 <kfree>
    return;
801076f6:	83 c4 10             	add    $0x10,%esp
}
801076f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801076fc:	5b                   	pop    %ebx
801076fd:	5e                   	pop    %esi
801076fe:	5f                   	pop    %edi
801076ff:	5d                   	pop    %ebp
80107700:	c3                   	ret    
        panic("Slots filled");
80107701:	83 ec 0c             	sub    $0xc,%esp
80107704:	68 7b 82 10 80       	push   $0x8010827b
80107709:	e8 a2 8d ff ff       	call   801004b0 <panic>
8010770e:	66 90                	xchg   %ax,%ax

80107710 <clean_swap>:

void clean_swap(pde_t* pde){
80107710:	55                   	push   %ebp
80107711:	89 e5                	mov    %esp,%ebp
80107713:	56                   	push   %esi
80107714:	53                   	push   %ebx
80107715:	8b 5d 08             	mov    0x8(%ebp),%ebx
80107718:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
8010771e:	eb 07                	jmp    80107727 <clean_swap+0x17>
    for(int i = 0; i < NPDENTRIES; i++){
80107720:	83 c3 04             	add    $0x4,%ebx
80107723:	39 f3                	cmp    %esi,%ebx
80107725:	74 3c                	je     80107763 <clean_swap+0x53>
        if(pde[i] & PTE_P){
80107727:	8b 0b                	mov    (%ebx),%ecx
80107729:	f6 c1 01             	test   $0x1,%cl
8010772c:	74 f2                	je     80107720 <clean_swap+0x10>
            pte_t* pte= (pte_t*)P2V(PTE_ADDR(pde[i]));
8010772e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
80107734:	8d 81 00 00 00 80    	lea    -0x80000000(%ecx),%eax
            for(int j=0; j< NPTENTRIES; j++){
8010773a:	81 e9 00 f0 ff 7f    	sub    $0x7ffff000,%ecx
                if(pte[j] & PTE_S){
80107740:	8b 10                	mov    (%eax),%edx
80107742:	f6 c6 02             	test   $0x2,%dh
80107745:	74 0e                	je     80107755 <clean_swap+0x45>
                    uint slot= PTE_ADDR(pte[j]) >> 12;
80107747:	c1 ea 0c             	shr    $0xc,%edx
                    ss[slot].is_free=1;
8010774a:	c7 04 d5 04 56 11 80 	movl   $0x1,-0x7feea9fc(,%edx,8)
80107751:	01 00 00 00 
            for(int j=0; j< NPTENTRIES; j++){
80107755:	83 c0 04             	add    $0x4,%eax
80107758:	39 c1                	cmp    %eax,%ecx
8010775a:	75 e4                	jne    80107740 <clean_swap+0x30>
    for(int i = 0; i < NPDENTRIES; i++){
8010775c:	83 c3 04             	add    $0x4,%ebx
8010775f:	39 f3                	cmp    %esi,%ebx
80107761:	75 c4                	jne    80107727 <clean_swap+0x17>
                }
            }
        }
    }
}
80107763:	5b                   	pop    %ebx
80107764:	5e                   	pop    %esi
80107765:	5d                   	pop    %ebp
80107766:	c3                   	ret    
80107767:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010776e:	66 90                	xchg   %ax,%ax

80107770 <page_fault>:

void page_fault(){
80107770:	55                   	push   %ebp
80107771:	89 e5                	mov    %esp,%ebp
80107773:	57                   	push   %edi
80107774:	56                   	push   %esi
80107775:	53                   	push   %ebx
80107776:	83 ec 1c             	sub    $0x1c,%esp
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107779:	0f 20 d6             	mov    %cr2,%esi
    uint va = rcr2();
    struct proc *p = myproc();
8010777c:	e8 bf c3 ff ff       	call   80103b40 <myproc>
    pte_t *pte = walkpgdir(p->pgdir, (void*)va, 0);
80107781:	83 ec 04             	sub    $0x4,%esp
80107784:	6a 00                	push   $0x0
    struct proc *p = myproc();
80107786:	89 c3                	mov    %eax,%ebx
    pte_t *pte = walkpgdir(p->pgdir, (void*)va, 0);
80107788:	56                   	push   %esi
80107789:	ff 70 08             	push   0x8(%eax)
8010778c:	e8 5f f5 ff ff       	call   80106cf0 <walkpgdir>
    if((*pte & PTE_S)){
80107791:	83 c4 10             	add    $0x10,%esp
80107794:	8b 38                	mov    (%eax),%edi
80107796:	f7 c7 00 02 00 00    	test   $0x200,%edi
8010779c:	75 12                	jne    801077b0 <page_fault+0x40>
        ss[slot].is_free = 1;
        *pte = PTE_ADDR(V2P(page)) | PTE_FLAGS(permissions);
        *pte = *pte | PTE_A;
        p->rss += PGSIZE;
    }
8010779e:	8d 65 f4             	lea    -0xc(%ebp),%esp
801077a1:	5b                   	pop    %ebx
801077a2:	5e                   	pop    %esi
801077a3:	5f                   	pop    %edi
801077a4:	5d                   	pop    %ebp
801077a5:	c3                   	ret    
801077a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801077ad:	8d 76 00             	lea    0x0(%esi),%esi
        uint slot = *pte >> 12;
801077b0:	c1 ef 0c             	shr    $0xc,%edi
801077b3:	89 c6                	mov    %eax,%esi
        char* page = kalloc();
801077b5:	e8 16 b0 ff ff       	call   801027d0 <kalloc>
        read_page(page, 8*slot+2);
801077ba:	83 ec 08             	sub    $0x8,%esp
801077bd:	8d 14 fd 02 00 00 00 	lea    0x2(,%edi,8),%edx
801077c4:	52                   	push   %edx
801077c5:	50                   	push   %eax
801077c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801077c9:	e8 62 8b ff ff       	call   80100330 <read_page>
        *pte = PTE_ADDR(V2P(page)) | PTE_FLAGS(permissions);
801077ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        uint permissions = ss[slot].page_perm;
801077d1:	8b 14 fd 00 56 11 80 	mov    -0x7feeaa00(,%edi,8),%edx
        p->rss += PGSIZE;
801077d8:	83 c4 10             	add    $0x10,%esp
        ss[slot].is_free = 1;
801077db:	c7 04 fd 04 56 11 80 	movl   $0x1,-0x7feea9fc(,%edi,8)
801077e2:	01 00 00 00 
        *pte = PTE_ADDR(V2P(page)) | PTE_FLAGS(permissions);
801077e6:	05 00 00 00 80       	add    $0x80000000,%eax
801077eb:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
801077f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077f6:	09 d0                	or     %edx,%eax
        *pte = *pte | PTE_A;
801077f8:	83 c8 20             	or     $0x20,%eax
801077fb:	89 06                	mov    %eax,(%esi)
        p->rss += PGSIZE;
801077fd:	81 43 04 00 10 00 00 	addl   $0x1000,0x4(%ebx)
80107804:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107807:	5b                   	pop    %ebx
80107808:	5e                   	pop    %esi
80107809:	5f                   	pop    %edi
8010780a:	5d                   	pop    %ebp
8010780b:	c3                   	ret    
