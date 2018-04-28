
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

#define UPROCS_MAX 16 // 1 16 64 72

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	56                   	push   %esi
   e:	53                   	push   %ebx
   f:	51                   	push   %ecx
  10:	83 ec 2c             	sub    $0x2c,%esp
  int millisec, num_uprocs,  max = UPROCS_MAX;
  13:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  struct uproc* table = malloc(sizeof(struct uproc) * max);
  1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1d:	6b c0 5c             	imul   $0x5c,%eax,%eax
  20:	83 ec 0c             	sub    $0xc,%esp
  23:	50                   	push   %eax
  24:	e8 d5 09 00 00       	call   9fe <malloc>
  29:	83 c4 10             	add    $0x10,%esp
  2c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  struct uproc *begin, *end;
  
  num_uprocs = getprocs(max, table);
  2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  32:	83 ec 08             	sub    $0x8,%esp
  35:	ff 75 dc             	pushl  -0x24(%ebp)
  38:	50                   	push   %eax
  39:	e8 0e 06 00 00       	call   64c <getprocs>
  3e:	83 c4 10             	add    $0x10,%esp
  41:	89 45 d8             	mov    %eax,-0x28(%ebp)

  if (num_uprocs < 0) {
  44:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  48:	79 25                	jns    6f <main+0x6f>
    printf(2,"Error retrieving info for processes.\n");
  4a:	83 ec 08             	sub    $0x8,%esp
  4d:	68 e4 0a 00 00       	push   $0xae4
  52:	6a 02                	push   $0x2
  54:	e8 d2 06 00 00       	call   72b <printf>
  59:	83 c4 10             	add    $0x10,%esp
    free(table);
  5c:	83 ec 0c             	sub    $0xc,%esp
  5f:	ff 75 dc             	pushl  -0x24(%ebp)
  62:	e8 55 08 00 00       	call   8bc <free>
  67:	83 c4 10             	add    $0x10,%esp
    exit();
  6a:	e8 05 05 00 00       	call   574 <exit>
  }
  
  printf(1,"PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\n");
  6f:	83 ec 08             	sub    $0x8,%esp
  72:	68 0c 0b 00 00       	push   $0xb0c
  77:	6a 01                	push   $0x1
  79:	e8 ad 06 00 00       	call   72b <printf>
  7e:	83 c4 10             	add    $0x10,%esp

  begin = table;
  81:	8b 45 dc             	mov    -0x24(%ebp),%eax
  84:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  end = table + num_uprocs;
  87:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8a:	6b d0 5c             	imul   $0x5c,%eax,%edx
  8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  90:	01 d0                	add    %edx,%eax
  92:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  while (begin < end) {
  95:	e9 91 01 00 00       	jmp    22b <main+0x22b>
    printf(1,"%d\t%s\t%d\t%d\t%d\t", begin->pid,
  9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  9d:	8b 58 0c             	mov    0xc(%eax),%ebx
  a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  a3:	8b 48 08             	mov    0x8(%eax),%ecx
  a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  a9:	8b 50 04             	mov    0x4(%eax),%edx
         begin->name,begin->uid,begin->gid,begin->ppid);
  ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  af:	8d 70 3c             	lea    0x3c(%eax),%esi
  printf(1,"PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\n");

  begin = table;
  end = table + num_uprocs;
  while (begin < end) {
    printf(1,"%d\t%s\t%d\t%d\t%d\t", begin->pid,
  b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  b5:	8b 00                	mov    (%eax),%eax
  b7:	83 ec 04             	sub    $0x4,%esp
  ba:	53                   	push   %ebx
  bb:	51                   	push   %ecx
  bc:	52                   	push   %edx
  bd:	56                   	push   %esi
  be:	50                   	push   %eax
  bf:	68 3a 0b 00 00       	push   $0xb3a
  c4:	6a 01                	push   $0x1
  c6:	e8 60 06 00 00       	call   72b <printf>
  cb:	83 c4 20             	add    $0x20,%esp
         begin->name,begin->uid,begin->gid,begin->ppid);
//    print_millisec(begin->elapsed_ticks);
    millisec = begin->elapsed_ticks;
  ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  d1:	8b 40 10             	mov    0x10(%eax),%eax
  d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
    printf(1,"%d.", millisec /1000);
  d7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  da:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  df:	89 c8                	mov    %ecx,%eax
  e1:	f7 ea                	imul   %edx
  e3:	c1 fa 06             	sar    $0x6,%edx
  e6:	89 c8                	mov    %ecx,%eax
  e8:	c1 f8 1f             	sar    $0x1f,%eax
  eb:	29 c2                	sub    %eax,%edx
  ed:	89 d0                	mov    %edx,%eax
  ef:	83 ec 04             	sub    $0x4,%esp
  f2:	50                   	push   %eax
  f3:	68 4a 0b 00 00       	push   $0xb4a
  f8:	6a 01                	push   $0x1
  fa:	e8 2c 06 00 00       	call   72b <printf>
  ff:	83 c4 10             	add    $0x10,%esp

    millisec %= 1000;
 102:	8b 4d d0             	mov    -0x30(%ebp),%ecx
 105:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 10a:	89 c8                	mov    %ecx,%eax
 10c:	f7 ea                	imul   %edx
 10e:	c1 fa 06             	sar    $0x6,%edx
 111:	89 c8                	mov    %ecx,%eax
 113:	c1 f8 1f             	sar    $0x1f,%eax
 116:	29 c2                	sub    %eax,%edx
 118:	89 d0                	mov    %edx,%eax
 11a:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 120:	29 c1                	sub    %eax,%ecx
 122:	89 c8                	mov    %ecx,%eax
 124:	89 45 d0             	mov    %eax,-0x30(%ebp)
    if (millisec < 100)
 127:	83 7d d0 63          	cmpl   $0x63,-0x30(%ebp)
 12b:	7f 12                	jg     13f <main+0x13f>
      printf(1,"0");
 12d:	83 ec 08             	sub    $0x8,%esp
 130:	68 4e 0b 00 00       	push   $0xb4e
 135:	6a 01                	push   $0x1
 137:	e8 ef 05 00 00       	call   72b <printf>
 13c:	83 c4 10             	add    $0x10,%esp
    if (millisec < 10)
 13f:	83 7d d0 09          	cmpl   $0x9,-0x30(%ebp)
 143:	7f 12                	jg     157 <main+0x157>
      printf(1,"0");
 145:	83 ec 08             	sub    $0x8,%esp
 148:	68 4e 0b 00 00       	push   $0xb4e
 14d:	6a 01                	push   $0x1
 14f:	e8 d7 05 00 00       	call   72b <printf>
 154:	83 c4 10             	add    $0x10,%esp

    printf(1,"%d\t", millisec);
 157:	83 ec 04             	sub    $0x4,%esp
 15a:	ff 75 d0             	pushl  -0x30(%ebp)
 15d:	68 50 0b 00 00       	push   $0xb50
 162:	6a 01                	push   $0x1
 164:	e8 c2 05 00 00       	call   72b <printf>
 169:	83 c4 10             	add    $0x10,%esp
//    print_millisec(begin->CPU_total_ticks);
    millisec = begin->CPU_total_ticks;
 16c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 16f:	8b 40 14             	mov    0x14(%eax),%eax
 172:	89 45 d0             	mov    %eax,-0x30(%ebp)
    printf(1,"%d.", millisec /1000);
 175:	8b 4d d0             	mov    -0x30(%ebp),%ecx
 178:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 17d:	89 c8                	mov    %ecx,%eax
 17f:	f7 ea                	imul   %edx
 181:	c1 fa 06             	sar    $0x6,%edx
 184:	89 c8                	mov    %ecx,%eax
 186:	c1 f8 1f             	sar    $0x1f,%eax
 189:	29 c2                	sub    %eax,%edx
 18b:	89 d0                	mov    %edx,%eax
 18d:	83 ec 04             	sub    $0x4,%esp
 190:	50                   	push   %eax
 191:	68 4a 0b 00 00       	push   $0xb4a
 196:	6a 01                	push   $0x1
 198:	e8 8e 05 00 00       	call   72b <printf>
 19d:	83 c4 10             	add    $0x10,%esp

    millisec %= 1000;
 1a0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
 1a3:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 1a8:	89 c8                	mov    %ecx,%eax
 1aa:	f7 ea                	imul   %edx
 1ac:	c1 fa 06             	sar    $0x6,%edx
 1af:	89 c8                	mov    %ecx,%eax
 1b1:	c1 f8 1f             	sar    $0x1f,%eax
 1b4:	29 c2                	sub    %eax,%edx
 1b6:	89 d0                	mov    %edx,%eax
 1b8:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 1be:	29 c1                	sub    %eax,%ecx
 1c0:	89 c8                	mov    %ecx,%eax
 1c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    if (millisec < 100)
 1c5:	83 7d d0 63          	cmpl   $0x63,-0x30(%ebp)
 1c9:	7f 12                	jg     1dd <main+0x1dd>
      printf(1,"0");
 1cb:	83 ec 08             	sub    $0x8,%esp
 1ce:	68 4e 0b 00 00       	push   $0xb4e
 1d3:	6a 01                	push   $0x1
 1d5:	e8 51 05 00 00       	call   72b <printf>
 1da:	83 c4 10             	add    $0x10,%esp
    if (millisec < 10)
 1dd:	83 7d d0 09          	cmpl   $0x9,-0x30(%ebp)
 1e1:	7f 12                	jg     1f5 <main+0x1f5>
      printf(1,"0");
 1e3:	83 ec 08             	sub    $0x8,%esp
 1e6:	68 4e 0b 00 00       	push   $0xb4e
 1eb:	6a 01                	push   $0x1
 1ed:	e8 39 05 00 00       	call   72b <printf>
 1f2:	83 c4 10             	add    $0x10,%esp

    printf(1,"%d\t", millisec);
 1f5:	83 ec 04             	sub    $0x4,%esp
 1f8:	ff 75 d0             	pushl  -0x30(%ebp)
 1fb:	68 50 0b 00 00       	push   $0xb50
 200:	6a 01                	push   $0x1
 202:	e8 24 05 00 00       	call   72b <printf>
 207:	83 c4 10             	add    $0x10,%esp
    printf(1,"%s\t%d\n",begin->state,begin->size);
 20a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 20d:	8b 40 38             	mov    0x38(%eax),%eax
 210:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 213:	83 c2 18             	add    $0x18,%edx
 216:	50                   	push   %eax
 217:	52                   	push   %edx
 218:	68 54 0b 00 00       	push   $0xb54
 21d:	6a 01                	push   $0x1
 21f:	e8 07 05 00 00       	call   72b <printf>
 224:	83 c4 10             	add    $0x10,%esp

    ++begin;
 227:	83 45 e4 5c          	addl   $0x5c,-0x1c(%ebp)
  
  printf(1,"PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\n");

  begin = table;
  end = table + num_uprocs;
  while (begin < end) {
 22b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 22e:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
 231:	0f 82 63 fe ff ff    	jb     9a <main+0x9a>
    printf(1,"%s\t%d\n",begin->state,begin->size);

    ++begin;
  }

  free(table);
 237:	83 ec 0c             	sub    $0xc,%esp
 23a:	ff 75 dc             	pushl  -0x24(%ebp)
 23d:	e8 7a 06 00 00       	call   8bc <free>
 242:	83 c4 10             	add    $0x10,%esp
  exit();
 245:	e8 2a 03 00 00       	call   574 <exit>

0000024a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 24a:	55                   	push   %ebp
 24b:	89 e5                	mov    %esp,%ebp
 24d:	57                   	push   %edi
 24e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 24f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 252:	8b 55 10             	mov    0x10(%ebp),%edx
 255:	8b 45 0c             	mov    0xc(%ebp),%eax
 258:	89 cb                	mov    %ecx,%ebx
 25a:	89 df                	mov    %ebx,%edi
 25c:	89 d1                	mov    %edx,%ecx
 25e:	fc                   	cld    
 25f:	f3 aa                	rep stos %al,%es:(%edi)
 261:	89 ca                	mov    %ecx,%edx
 263:	89 fb                	mov    %edi,%ebx
 265:	89 5d 08             	mov    %ebx,0x8(%ebp)
 268:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 26b:	90                   	nop
 26c:	5b                   	pop    %ebx
 26d:	5f                   	pop    %edi
 26e:	5d                   	pop    %ebp
 26f:	c3                   	ret    

00000270 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 270:	55                   	push   %ebp
 271:	89 e5                	mov    %esp,%ebp
 273:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 276:	8b 45 08             	mov    0x8(%ebp),%eax
 279:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 27c:	90                   	nop
 27d:	8b 45 08             	mov    0x8(%ebp),%eax
 280:	8d 50 01             	lea    0x1(%eax),%edx
 283:	89 55 08             	mov    %edx,0x8(%ebp)
 286:	8b 55 0c             	mov    0xc(%ebp),%edx
 289:	8d 4a 01             	lea    0x1(%edx),%ecx
 28c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 28f:	0f b6 12             	movzbl (%edx),%edx
 292:	88 10                	mov    %dl,(%eax)
 294:	0f b6 00             	movzbl (%eax),%eax
 297:	84 c0                	test   %al,%al
 299:	75 e2                	jne    27d <strcpy+0xd>
    ;
  return os;
 29b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 29e:	c9                   	leave  
 29f:	c3                   	ret    

000002a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2a3:	eb 08                	jmp    2ad <strcmp+0xd>
    p++, q++;
 2a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2a9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2ad:	8b 45 08             	mov    0x8(%ebp),%eax
 2b0:	0f b6 00             	movzbl (%eax),%eax
 2b3:	84 c0                	test   %al,%al
 2b5:	74 10                	je     2c7 <strcmp+0x27>
 2b7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ba:	0f b6 10             	movzbl (%eax),%edx
 2bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c0:	0f b6 00             	movzbl (%eax),%eax
 2c3:	38 c2                	cmp    %al,%dl
 2c5:	74 de                	je     2a5 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2c7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ca:	0f b6 00             	movzbl (%eax),%eax
 2cd:	0f b6 d0             	movzbl %al,%edx
 2d0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d3:	0f b6 00             	movzbl (%eax),%eax
 2d6:	0f b6 c0             	movzbl %al,%eax
 2d9:	29 c2                	sub    %eax,%edx
 2db:	89 d0                	mov    %edx,%eax
}
 2dd:	5d                   	pop    %ebp
 2de:	c3                   	ret    

000002df <strlen>:

uint
strlen(char *s)
{
 2df:	55                   	push   %ebp
 2e0:	89 e5                	mov    %esp,%ebp
 2e2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2ec:	eb 04                	jmp    2f2 <strlen+0x13>
 2ee:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	01 d0                	add    %edx,%eax
 2fa:	0f b6 00             	movzbl (%eax),%eax
 2fd:	84 c0                	test   %al,%al
 2ff:	75 ed                	jne    2ee <strlen+0xf>
    ;
  return n;
 301:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 304:	c9                   	leave  
 305:	c3                   	ret    

00000306 <memset>:

void*
memset(void *dst, int c, uint n)
{
 306:	55                   	push   %ebp
 307:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 309:	8b 45 10             	mov    0x10(%ebp),%eax
 30c:	50                   	push   %eax
 30d:	ff 75 0c             	pushl  0xc(%ebp)
 310:	ff 75 08             	pushl  0x8(%ebp)
 313:	e8 32 ff ff ff       	call   24a <stosb>
 318:	83 c4 0c             	add    $0xc,%esp
  return dst;
 31b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 31e:	c9                   	leave  
 31f:	c3                   	ret    

00000320 <strchr>:

char*
strchr(const char *s, char c)
{
 320:	55                   	push   %ebp
 321:	89 e5                	mov    %esp,%ebp
 323:	83 ec 04             	sub    $0x4,%esp
 326:	8b 45 0c             	mov    0xc(%ebp),%eax
 329:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 32c:	eb 14                	jmp    342 <strchr+0x22>
    if(*s == c)
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
 331:	0f b6 00             	movzbl (%eax),%eax
 334:	3a 45 fc             	cmp    -0x4(%ebp),%al
 337:	75 05                	jne    33e <strchr+0x1e>
      return (char*)s;
 339:	8b 45 08             	mov    0x8(%ebp),%eax
 33c:	eb 13                	jmp    351 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 33e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 342:	8b 45 08             	mov    0x8(%ebp),%eax
 345:	0f b6 00             	movzbl (%eax),%eax
 348:	84 c0                	test   %al,%al
 34a:	75 e2                	jne    32e <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 34c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 351:	c9                   	leave  
 352:	c3                   	ret    

00000353 <gets>:

char*
gets(char *buf, int max)
{
 353:	55                   	push   %ebp
 354:	89 e5                	mov    %esp,%ebp
 356:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 359:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 360:	eb 42                	jmp    3a4 <gets+0x51>
    cc = read(0, &c, 1);
 362:	83 ec 04             	sub    $0x4,%esp
 365:	6a 01                	push   $0x1
 367:	8d 45 ef             	lea    -0x11(%ebp),%eax
 36a:	50                   	push   %eax
 36b:	6a 00                	push   $0x0
 36d:	e8 1a 02 00 00       	call   58c <read>
 372:	83 c4 10             	add    $0x10,%esp
 375:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 378:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 37c:	7e 33                	jle    3b1 <gets+0x5e>
      break;
    buf[i++] = c;
 37e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 381:	8d 50 01             	lea    0x1(%eax),%edx
 384:	89 55 f4             	mov    %edx,-0xc(%ebp)
 387:	89 c2                	mov    %eax,%edx
 389:	8b 45 08             	mov    0x8(%ebp),%eax
 38c:	01 c2                	add    %eax,%edx
 38e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 392:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 394:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 398:	3c 0a                	cmp    $0xa,%al
 39a:	74 16                	je     3b2 <gets+0x5f>
 39c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3a0:	3c 0d                	cmp    $0xd,%al
 3a2:	74 0e                	je     3b2 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a7:	83 c0 01             	add    $0x1,%eax
 3aa:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3ad:	7c b3                	jl     362 <gets+0xf>
 3af:	eb 01                	jmp    3b2 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 3b1:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3b5:	8b 45 08             	mov    0x8(%ebp),%eax
 3b8:	01 d0                	add    %edx,%eax
 3ba:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3bd:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3c0:	c9                   	leave  
 3c1:	c3                   	ret    

000003c2 <stat>:

int
stat(char *n, struct stat *st)
{
 3c2:	55                   	push   %ebp
 3c3:	89 e5                	mov    %esp,%ebp
 3c5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3c8:	83 ec 08             	sub    $0x8,%esp
 3cb:	6a 00                	push   $0x0
 3cd:	ff 75 08             	pushl  0x8(%ebp)
 3d0:	e8 df 01 00 00       	call   5b4 <open>
 3d5:	83 c4 10             	add    $0x10,%esp
 3d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3df:	79 07                	jns    3e8 <stat+0x26>
    return -1;
 3e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3e6:	eb 25                	jmp    40d <stat+0x4b>
  r = fstat(fd, st);
 3e8:	83 ec 08             	sub    $0x8,%esp
 3eb:	ff 75 0c             	pushl  0xc(%ebp)
 3ee:	ff 75 f4             	pushl  -0xc(%ebp)
 3f1:	e8 d6 01 00 00       	call   5cc <fstat>
 3f6:	83 c4 10             	add    $0x10,%esp
 3f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3fc:	83 ec 0c             	sub    $0xc,%esp
 3ff:	ff 75 f4             	pushl  -0xc(%ebp)
 402:	e8 95 01 00 00       	call   59c <close>
 407:	83 c4 10             	add    $0x10,%esp
  return r;
 40a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 40d:	c9                   	leave  
 40e:	c3                   	ret    

0000040f <atoi>:

int
atoi(const char *s)
{
 40f:	55                   	push   %ebp
 410:	89 e5                	mov    %esp,%ebp
 412:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 415:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 41c:	eb 04                	jmp    422 <atoi+0x13>
 41e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 422:	8b 45 08             	mov    0x8(%ebp),%eax
 425:	0f b6 00             	movzbl (%eax),%eax
 428:	3c 20                	cmp    $0x20,%al
 42a:	74 f2                	je     41e <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 42c:	8b 45 08             	mov    0x8(%ebp),%eax
 42f:	0f b6 00             	movzbl (%eax),%eax
 432:	3c 2d                	cmp    $0x2d,%al
 434:	75 07                	jne    43d <atoi+0x2e>
 436:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 43b:	eb 05                	jmp    442 <atoi+0x33>
 43d:	b8 01 00 00 00       	mov    $0x1,%eax
 442:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 445:	8b 45 08             	mov    0x8(%ebp),%eax
 448:	0f b6 00             	movzbl (%eax),%eax
 44b:	3c 2b                	cmp    $0x2b,%al
 44d:	74 0a                	je     459 <atoi+0x4a>
 44f:	8b 45 08             	mov    0x8(%ebp),%eax
 452:	0f b6 00             	movzbl (%eax),%eax
 455:	3c 2d                	cmp    $0x2d,%al
 457:	75 2b                	jne    484 <atoi+0x75>
    s++;
 459:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 45d:	eb 25                	jmp    484 <atoi+0x75>
    n = n*10 + *s++ - '0';
 45f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 462:	89 d0                	mov    %edx,%eax
 464:	c1 e0 02             	shl    $0x2,%eax
 467:	01 d0                	add    %edx,%eax
 469:	01 c0                	add    %eax,%eax
 46b:	89 c1                	mov    %eax,%ecx
 46d:	8b 45 08             	mov    0x8(%ebp),%eax
 470:	8d 50 01             	lea    0x1(%eax),%edx
 473:	89 55 08             	mov    %edx,0x8(%ebp)
 476:	0f b6 00             	movzbl (%eax),%eax
 479:	0f be c0             	movsbl %al,%eax
 47c:	01 c8                	add    %ecx,%eax
 47e:	83 e8 30             	sub    $0x30,%eax
 481:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 484:	8b 45 08             	mov    0x8(%ebp),%eax
 487:	0f b6 00             	movzbl (%eax),%eax
 48a:	3c 2f                	cmp    $0x2f,%al
 48c:	7e 0a                	jle    498 <atoi+0x89>
 48e:	8b 45 08             	mov    0x8(%ebp),%eax
 491:	0f b6 00             	movzbl (%eax),%eax
 494:	3c 39                	cmp    $0x39,%al
 496:	7e c7                	jle    45f <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 498:	8b 45 f8             	mov    -0x8(%ebp),%eax
 49b:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 49f:	c9                   	leave  
 4a0:	c3                   	ret    

000004a1 <atoo>:

int
atoo(const char *s)
{
 4a1:	55                   	push   %ebp
 4a2:	89 e5                	mov    %esp,%ebp
 4a4:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 4a7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 4ae:	eb 04                	jmp    4b4 <atoo+0x13>
 4b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4b4:	8b 45 08             	mov    0x8(%ebp),%eax
 4b7:	0f b6 00             	movzbl (%eax),%eax
 4ba:	3c 20                	cmp    $0x20,%al
 4bc:	74 f2                	je     4b0 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 4be:	8b 45 08             	mov    0x8(%ebp),%eax
 4c1:	0f b6 00             	movzbl (%eax),%eax
 4c4:	3c 2d                	cmp    $0x2d,%al
 4c6:	75 07                	jne    4cf <atoo+0x2e>
 4c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4cd:	eb 05                	jmp    4d4 <atoo+0x33>
 4cf:	b8 01 00 00 00       	mov    $0x1,%eax
 4d4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 4d7:	8b 45 08             	mov    0x8(%ebp),%eax
 4da:	0f b6 00             	movzbl (%eax),%eax
 4dd:	3c 2b                	cmp    $0x2b,%al
 4df:	74 0a                	je     4eb <atoo+0x4a>
 4e1:	8b 45 08             	mov    0x8(%ebp),%eax
 4e4:	0f b6 00             	movzbl (%eax),%eax
 4e7:	3c 2d                	cmp    $0x2d,%al
 4e9:	75 27                	jne    512 <atoo+0x71>
    s++;
 4eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 4ef:	eb 21                	jmp    512 <atoo+0x71>
    n = n*8 + *s++ - '0';
 4f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4f4:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 4fb:	8b 45 08             	mov    0x8(%ebp),%eax
 4fe:	8d 50 01             	lea    0x1(%eax),%edx
 501:	89 55 08             	mov    %edx,0x8(%ebp)
 504:	0f b6 00             	movzbl (%eax),%eax
 507:	0f be c0             	movsbl %al,%eax
 50a:	01 c8                	add    %ecx,%eax
 50c:	83 e8 30             	sub    $0x30,%eax
 50f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 512:	8b 45 08             	mov    0x8(%ebp),%eax
 515:	0f b6 00             	movzbl (%eax),%eax
 518:	3c 2f                	cmp    $0x2f,%al
 51a:	7e 0a                	jle    526 <atoo+0x85>
 51c:	8b 45 08             	mov    0x8(%ebp),%eax
 51f:	0f b6 00             	movzbl (%eax),%eax
 522:	3c 37                	cmp    $0x37,%al
 524:	7e cb                	jle    4f1 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 526:	8b 45 f8             	mov    -0x8(%ebp),%eax
 529:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 52d:	c9                   	leave  
 52e:	c3                   	ret    

0000052f <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 52f:	55                   	push   %ebp
 530:	89 e5                	mov    %esp,%ebp
 532:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 535:	8b 45 08             	mov    0x8(%ebp),%eax
 538:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 53b:	8b 45 0c             	mov    0xc(%ebp),%eax
 53e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 541:	eb 17                	jmp    55a <memmove+0x2b>
    *dst++ = *src++;
 543:	8b 45 fc             	mov    -0x4(%ebp),%eax
 546:	8d 50 01             	lea    0x1(%eax),%edx
 549:	89 55 fc             	mov    %edx,-0x4(%ebp)
 54c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 54f:	8d 4a 01             	lea    0x1(%edx),%ecx
 552:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 555:	0f b6 12             	movzbl (%edx),%edx
 558:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 55a:	8b 45 10             	mov    0x10(%ebp),%eax
 55d:	8d 50 ff             	lea    -0x1(%eax),%edx
 560:	89 55 10             	mov    %edx,0x10(%ebp)
 563:	85 c0                	test   %eax,%eax
 565:	7f dc                	jg     543 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 567:	8b 45 08             	mov    0x8(%ebp),%eax
}
 56a:	c9                   	leave  
 56b:	c3                   	ret    

0000056c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 56c:	b8 01 00 00 00       	mov    $0x1,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret    

00000574 <exit>:
SYSCALL(exit)
 574:	b8 02 00 00 00       	mov    $0x2,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret    

0000057c <wait>:
SYSCALL(wait)
 57c:	b8 03 00 00 00       	mov    $0x3,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret    

00000584 <pipe>:
SYSCALL(pipe)
 584:	b8 04 00 00 00       	mov    $0x4,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret    

0000058c <read>:
SYSCALL(read)
 58c:	b8 05 00 00 00       	mov    $0x5,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret    

00000594 <write>:
SYSCALL(write)
 594:	b8 10 00 00 00       	mov    $0x10,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret    

0000059c <close>:
SYSCALL(close)
 59c:	b8 15 00 00 00       	mov    $0x15,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret    

000005a4 <kill>:
SYSCALL(kill)
 5a4:	b8 06 00 00 00       	mov    $0x6,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret    

000005ac <exec>:
SYSCALL(exec)
 5ac:	b8 07 00 00 00       	mov    $0x7,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret    

000005b4 <open>:
SYSCALL(open)
 5b4:	b8 0f 00 00 00       	mov    $0xf,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret    

000005bc <mknod>:
SYSCALL(mknod)
 5bc:	b8 11 00 00 00       	mov    $0x11,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <unlink>:
SYSCALL(unlink)
 5c4:	b8 12 00 00 00       	mov    $0x12,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <fstat>:
SYSCALL(fstat)
 5cc:	b8 08 00 00 00       	mov    $0x8,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <link>:
SYSCALL(link)
 5d4:	b8 13 00 00 00       	mov    $0x13,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <mkdir>:
SYSCALL(mkdir)
 5dc:	b8 14 00 00 00       	mov    $0x14,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <chdir>:
SYSCALL(chdir)
 5e4:	b8 09 00 00 00       	mov    $0x9,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <dup>:
SYSCALL(dup)
 5ec:	b8 0a 00 00 00       	mov    $0xa,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <getpid>:
SYSCALL(getpid)
 5f4:	b8 0b 00 00 00       	mov    $0xb,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <sbrk>:
SYSCALL(sbrk)
 5fc:	b8 0c 00 00 00       	mov    $0xc,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <sleep>:
SYSCALL(sleep)
 604:	b8 0d 00 00 00       	mov    $0xd,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <uptime>:
SYSCALL(uptime)
 60c:	b8 0e 00 00 00       	mov    $0xe,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <halt>:
SYSCALL(halt)
 614:	b8 16 00 00 00       	mov    $0x16,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <date>:
SYSCALL(date)
 61c:	b8 17 00 00 00       	mov    $0x17,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <getuid>:
SYSCALL(getuid)
 624:	b8 18 00 00 00       	mov    $0x18,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <getgid>:
SYSCALL(getgid)
 62c:	b8 19 00 00 00       	mov    $0x19,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <getppid>:
SYSCALL(getppid)
 634:	b8 1a 00 00 00       	mov    $0x1a,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <setuid>:
SYSCALL(setuid)
 63c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <setgid>:
SYSCALL(setgid)
 644:	b8 1c 00 00 00       	mov    $0x1c,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <getprocs>:
SYSCALL(getprocs)
 64c:	b8 1d 00 00 00       	mov    $0x1d,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 654:	55                   	push   %ebp
 655:	89 e5                	mov    %esp,%ebp
 657:	83 ec 18             	sub    $0x18,%esp
 65a:	8b 45 0c             	mov    0xc(%ebp),%eax
 65d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 660:	83 ec 04             	sub    $0x4,%esp
 663:	6a 01                	push   $0x1
 665:	8d 45 f4             	lea    -0xc(%ebp),%eax
 668:	50                   	push   %eax
 669:	ff 75 08             	pushl  0x8(%ebp)
 66c:	e8 23 ff ff ff       	call   594 <write>
 671:	83 c4 10             	add    $0x10,%esp
}
 674:	90                   	nop
 675:	c9                   	leave  
 676:	c3                   	ret    

00000677 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 677:	55                   	push   %ebp
 678:	89 e5                	mov    %esp,%ebp
 67a:	53                   	push   %ebx
 67b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 67e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 685:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 689:	74 17                	je     6a2 <printint+0x2b>
 68b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 68f:	79 11                	jns    6a2 <printint+0x2b>
    neg = 1;
 691:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 698:	8b 45 0c             	mov    0xc(%ebp),%eax
 69b:	f7 d8                	neg    %eax
 69d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6a0:	eb 06                	jmp    6a8 <printint+0x31>
  } else {
    x = xx;
 6a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 6a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6af:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6b2:	8d 41 01             	lea    0x1(%ecx),%eax
 6b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6be:	ba 00 00 00 00       	mov    $0x0,%edx
 6c3:	f7 f3                	div    %ebx
 6c5:	89 d0                	mov    %edx,%eax
 6c7:	0f b6 80 d4 0d 00 00 	movzbl 0xdd4(%eax),%eax
 6ce:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6d8:	ba 00 00 00 00       	mov    $0x0,%edx
 6dd:	f7 f3                	div    %ebx
 6df:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6e2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6e6:	75 c7                	jne    6af <printint+0x38>
  if(neg)
 6e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6ec:	74 2d                	je     71b <printint+0xa4>
    buf[i++] = '-';
 6ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f1:	8d 50 01             	lea    0x1(%eax),%edx
 6f4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6f7:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6fc:	eb 1d                	jmp    71b <printint+0xa4>
    putc(fd, buf[i]);
 6fe:	8d 55 dc             	lea    -0x24(%ebp),%edx
 701:	8b 45 f4             	mov    -0xc(%ebp),%eax
 704:	01 d0                	add    %edx,%eax
 706:	0f b6 00             	movzbl (%eax),%eax
 709:	0f be c0             	movsbl %al,%eax
 70c:	83 ec 08             	sub    $0x8,%esp
 70f:	50                   	push   %eax
 710:	ff 75 08             	pushl  0x8(%ebp)
 713:	e8 3c ff ff ff       	call   654 <putc>
 718:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 71b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 71f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 723:	79 d9                	jns    6fe <printint+0x87>
    putc(fd, buf[i]);
}
 725:	90                   	nop
 726:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 729:	c9                   	leave  
 72a:	c3                   	ret    

0000072b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 72b:	55                   	push   %ebp
 72c:	89 e5                	mov    %esp,%ebp
 72e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 731:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 738:	8d 45 0c             	lea    0xc(%ebp),%eax
 73b:	83 c0 04             	add    $0x4,%eax
 73e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 741:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 748:	e9 59 01 00 00       	jmp    8a6 <printf+0x17b>
    c = fmt[i] & 0xff;
 74d:	8b 55 0c             	mov    0xc(%ebp),%edx
 750:	8b 45 f0             	mov    -0x10(%ebp),%eax
 753:	01 d0                	add    %edx,%eax
 755:	0f b6 00             	movzbl (%eax),%eax
 758:	0f be c0             	movsbl %al,%eax
 75b:	25 ff 00 00 00       	and    $0xff,%eax
 760:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 763:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 767:	75 2c                	jne    795 <printf+0x6a>
      if(c == '%'){
 769:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 76d:	75 0c                	jne    77b <printf+0x50>
        state = '%';
 76f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 776:	e9 27 01 00 00       	jmp    8a2 <printf+0x177>
      } else {
        putc(fd, c);
 77b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 77e:	0f be c0             	movsbl %al,%eax
 781:	83 ec 08             	sub    $0x8,%esp
 784:	50                   	push   %eax
 785:	ff 75 08             	pushl  0x8(%ebp)
 788:	e8 c7 fe ff ff       	call   654 <putc>
 78d:	83 c4 10             	add    $0x10,%esp
 790:	e9 0d 01 00 00       	jmp    8a2 <printf+0x177>
      }
    } else if(state == '%'){
 795:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 799:	0f 85 03 01 00 00    	jne    8a2 <printf+0x177>
      if(c == 'd'){
 79f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7a3:	75 1e                	jne    7c3 <printf+0x98>
        printint(fd, *ap, 10, 1);
 7a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a8:	8b 00                	mov    (%eax),%eax
 7aa:	6a 01                	push   $0x1
 7ac:	6a 0a                	push   $0xa
 7ae:	50                   	push   %eax
 7af:	ff 75 08             	pushl  0x8(%ebp)
 7b2:	e8 c0 fe ff ff       	call   677 <printint>
 7b7:	83 c4 10             	add    $0x10,%esp
        ap++;
 7ba:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7be:	e9 d8 00 00 00       	jmp    89b <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7c3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7c7:	74 06                	je     7cf <printf+0xa4>
 7c9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7cd:	75 1e                	jne    7ed <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d2:	8b 00                	mov    (%eax),%eax
 7d4:	6a 00                	push   $0x0
 7d6:	6a 10                	push   $0x10
 7d8:	50                   	push   %eax
 7d9:	ff 75 08             	pushl  0x8(%ebp)
 7dc:	e8 96 fe ff ff       	call   677 <printint>
 7e1:	83 c4 10             	add    $0x10,%esp
        ap++;
 7e4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e8:	e9 ae 00 00 00       	jmp    89b <printf+0x170>
      } else if(c == 's'){
 7ed:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7f1:	75 43                	jne    836 <printf+0x10b>
        s = (char*)*ap;
 7f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f6:	8b 00                	mov    (%eax),%eax
 7f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7fb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 803:	75 25                	jne    82a <printf+0xff>
          s = "(null)";
 805:	c7 45 f4 5b 0b 00 00 	movl   $0xb5b,-0xc(%ebp)
        while(*s != 0){
 80c:	eb 1c                	jmp    82a <printf+0xff>
          putc(fd, *s);
 80e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 811:	0f b6 00             	movzbl (%eax),%eax
 814:	0f be c0             	movsbl %al,%eax
 817:	83 ec 08             	sub    $0x8,%esp
 81a:	50                   	push   %eax
 81b:	ff 75 08             	pushl  0x8(%ebp)
 81e:	e8 31 fe ff ff       	call   654 <putc>
 823:	83 c4 10             	add    $0x10,%esp
          s++;
 826:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 82a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82d:	0f b6 00             	movzbl (%eax),%eax
 830:	84 c0                	test   %al,%al
 832:	75 da                	jne    80e <printf+0xe3>
 834:	eb 65                	jmp    89b <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 836:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 83a:	75 1d                	jne    859 <printf+0x12e>
        putc(fd, *ap);
 83c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 83f:	8b 00                	mov    (%eax),%eax
 841:	0f be c0             	movsbl %al,%eax
 844:	83 ec 08             	sub    $0x8,%esp
 847:	50                   	push   %eax
 848:	ff 75 08             	pushl  0x8(%ebp)
 84b:	e8 04 fe ff ff       	call   654 <putc>
 850:	83 c4 10             	add    $0x10,%esp
        ap++;
 853:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 857:	eb 42                	jmp    89b <printf+0x170>
      } else if(c == '%'){
 859:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 85d:	75 17                	jne    876 <printf+0x14b>
        putc(fd, c);
 85f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 862:	0f be c0             	movsbl %al,%eax
 865:	83 ec 08             	sub    $0x8,%esp
 868:	50                   	push   %eax
 869:	ff 75 08             	pushl  0x8(%ebp)
 86c:	e8 e3 fd ff ff       	call   654 <putc>
 871:	83 c4 10             	add    $0x10,%esp
 874:	eb 25                	jmp    89b <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 876:	83 ec 08             	sub    $0x8,%esp
 879:	6a 25                	push   $0x25
 87b:	ff 75 08             	pushl  0x8(%ebp)
 87e:	e8 d1 fd ff ff       	call   654 <putc>
 883:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 886:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 889:	0f be c0             	movsbl %al,%eax
 88c:	83 ec 08             	sub    $0x8,%esp
 88f:	50                   	push   %eax
 890:	ff 75 08             	pushl  0x8(%ebp)
 893:	e8 bc fd ff ff       	call   654 <putc>
 898:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 89b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8a2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8a6:	8b 55 0c             	mov    0xc(%ebp),%edx
 8a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ac:	01 d0                	add    %edx,%eax
 8ae:	0f b6 00             	movzbl (%eax),%eax
 8b1:	84 c0                	test   %al,%al
 8b3:	0f 85 94 fe ff ff    	jne    74d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8b9:	90                   	nop
 8ba:	c9                   	leave  
 8bb:	c3                   	ret    

000008bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8bc:	55                   	push   %ebp
 8bd:	89 e5                	mov    %esp,%ebp
 8bf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8c2:	8b 45 08             	mov    0x8(%ebp),%eax
 8c5:	83 e8 08             	sub    $0x8,%eax
 8c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8cb:	a1 f0 0d 00 00       	mov    0xdf0,%eax
 8d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8d3:	eb 24                	jmp    8f9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d8:	8b 00                	mov    (%eax),%eax
 8da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8dd:	77 12                	ja     8f1 <free+0x35>
 8df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e5:	77 24                	ja     90b <free+0x4f>
 8e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ea:	8b 00                	mov    (%eax),%eax
 8ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8ef:	77 1a                	ja     90b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f4:	8b 00                	mov    (%eax),%eax
 8f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8ff:	76 d4                	jbe    8d5 <free+0x19>
 901:	8b 45 fc             	mov    -0x4(%ebp),%eax
 904:	8b 00                	mov    (%eax),%eax
 906:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 909:	76 ca                	jbe    8d5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 90b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90e:	8b 40 04             	mov    0x4(%eax),%eax
 911:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 918:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91b:	01 c2                	add    %eax,%edx
 91d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 920:	8b 00                	mov    (%eax),%eax
 922:	39 c2                	cmp    %eax,%edx
 924:	75 24                	jne    94a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 926:	8b 45 f8             	mov    -0x8(%ebp),%eax
 929:	8b 50 04             	mov    0x4(%eax),%edx
 92c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92f:	8b 00                	mov    (%eax),%eax
 931:	8b 40 04             	mov    0x4(%eax),%eax
 934:	01 c2                	add    %eax,%edx
 936:	8b 45 f8             	mov    -0x8(%ebp),%eax
 939:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 93c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93f:	8b 00                	mov    (%eax),%eax
 941:	8b 10                	mov    (%eax),%edx
 943:	8b 45 f8             	mov    -0x8(%ebp),%eax
 946:	89 10                	mov    %edx,(%eax)
 948:	eb 0a                	jmp    954 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 94a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94d:	8b 10                	mov    (%eax),%edx
 94f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 952:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 954:	8b 45 fc             	mov    -0x4(%ebp),%eax
 957:	8b 40 04             	mov    0x4(%eax),%eax
 95a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 961:	8b 45 fc             	mov    -0x4(%ebp),%eax
 964:	01 d0                	add    %edx,%eax
 966:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 969:	75 20                	jne    98b <free+0xcf>
    p->s.size += bp->s.size;
 96b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96e:	8b 50 04             	mov    0x4(%eax),%edx
 971:	8b 45 f8             	mov    -0x8(%ebp),%eax
 974:	8b 40 04             	mov    0x4(%eax),%eax
 977:	01 c2                	add    %eax,%edx
 979:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 97f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 982:	8b 10                	mov    (%eax),%edx
 984:	8b 45 fc             	mov    -0x4(%ebp),%eax
 987:	89 10                	mov    %edx,(%eax)
 989:	eb 08                	jmp    993 <free+0xd7>
  } else
    p->s.ptr = bp;
 98b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 991:	89 10                	mov    %edx,(%eax)
  freep = p;
 993:	8b 45 fc             	mov    -0x4(%ebp),%eax
 996:	a3 f0 0d 00 00       	mov    %eax,0xdf0
}
 99b:	90                   	nop
 99c:	c9                   	leave  
 99d:	c3                   	ret    

0000099e <morecore>:

static Header*
morecore(uint nu)
{
 99e:	55                   	push   %ebp
 99f:	89 e5                	mov    %esp,%ebp
 9a1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9a4:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9ab:	77 07                	ja     9b4 <morecore+0x16>
    nu = 4096;
 9ad:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9b4:	8b 45 08             	mov    0x8(%ebp),%eax
 9b7:	c1 e0 03             	shl    $0x3,%eax
 9ba:	83 ec 0c             	sub    $0xc,%esp
 9bd:	50                   	push   %eax
 9be:	e8 39 fc ff ff       	call   5fc <sbrk>
 9c3:	83 c4 10             	add    $0x10,%esp
 9c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9c9:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9cd:	75 07                	jne    9d6 <morecore+0x38>
    return 0;
 9cf:	b8 00 00 00 00       	mov    $0x0,%eax
 9d4:	eb 26                	jmp    9fc <morecore+0x5e>
  hp = (Header*)p;
 9d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9df:	8b 55 08             	mov    0x8(%ebp),%edx
 9e2:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e8:	83 c0 08             	add    $0x8,%eax
 9eb:	83 ec 0c             	sub    $0xc,%esp
 9ee:	50                   	push   %eax
 9ef:	e8 c8 fe ff ff       	call   8bc <free>
 9f4:	83 c4 10             	add    $0x10,%esp
  return freep;
 9f7:	a1 f0 0d 00 00       	mov    0xdf0,%eax
}
 9fc:	c9                   	leave  
 9fd:	c3                   	ret    

000009fe <malloc>:

void*
malloc(uint nbytes)
{
 9fe:	55                   	push   %ebp
 9ff:	89 e5                	mov    %esp,%ebp
 a01:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a04:	8b 45 08             	mov    0x8(%ebp),%eax
 a07:	83 c0 07             	add    $0x7,%eax
 a0a:	c1 e8 03             	shr    $0x3,%eax
 a0d:	83 c0 01             	add    $0x1,%eax
 a10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a13:	a1 f0 0d 00 00       	mov    0xdf0,%eax
 a18:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a1f:	75 23                	jne    a44 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a21:	c7 45 f0 e8 0d 00 00 	movl   $0xde8,-0x10(%ebp)
 a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2b:	a3 f0 0d 00 00       	mov    %eax,0xdf0
 a30:	a1 f0 0d 00 00       	mov    0xdf0,%eax
 a35:	a3 e8 0d 00 00       	mov    %eax,0xde8
    base.s.size = 0;
 a3a:	c7 05 ec 0d 00 00 00 	movl   $0x0,0xdec
 a41:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a47:	8b 00                	mov    (%eax),%eax
 a49:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4f:	8b 40 04             	mov    0x4(%eax),%eax
 a52:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a55:	72 4d                	jb     aa4 <malloc+0xa6>
      if(p->s.size == nunits)
 a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5a:	8b 40 04             	mov    0x4(%eax),%eax
 a5d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a60:	75 0c                	jne    a6e <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a65:	8b 10                	mov    (%eax),%edx
 a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6a:	89 10                	mov    %edx,(%eax)
 a6c:	eb 26                	jmp    a94 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a71:	8b 40 04             	mov    0x4(%eax),%eax
 a74:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a77:	89 c2                	mov    %eax,%edx
 a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a82:	8b 40 04             	mov    0x4(%eax),%eax
 a85:	c1 e0 03             	shl    $0x3,%eax
 a88:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a91:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a97:	a3 f0 0d 00 00       	mov    %eax,0xdf0
      return (void*)(p + 1);
 a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9f:	83 c0 08             	add    $0x8,%eax
 aa2:	eb 3b                	jmp    adf <malloc+0xe1>
    }
    if(p == freep)
 aa4:	a1 f0 0d 00 00       	mov    0xdf0,%eax
 aa9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 aac:	75 1e                	jne    acc <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 aae:	83 ec 0c             	sub    $0xc,%esp
 ab1:	ff 75 ec             	pushl  -0x14(%ebp)
 ab4:	e8 e5 fe ff ff       	call   99e <morecore>
 ab9:	83 c4 10             	add    $0x10,%esp
 abc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 abf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ac3:	75 07                	jne    acc <malloc+0xce>
        return 0;
 ac5:	b8 00 00 00 00       	mov    $0x0,%eax
 aca:	eb 13                	jmp    adf <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acf:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad5:	8b 00                	mov    (%eax),%eax
 ad7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ada:	e9 6d ff ff ff       	jmp    a4c <malloc+0x4e>
}
 adf:	c9                   	leave  
 ae0:	c3                   	ret    
