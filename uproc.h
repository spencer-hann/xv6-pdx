#ifndef UPROC_H
#define UPROC_H
#ifdef CS333_P2

#include "types.h"
#define STRMAX 32

struct uproc {
  uint pid;
  uint uid;
  uint gid;
  uint ppid;
  uint elapsed_ticks;
  uint CPU_total_ticks;
  char state[STRMAX];
  uint size;
  char name[STRMAX];
};

#endif //CS333_P2
#endif //UPROC_H
