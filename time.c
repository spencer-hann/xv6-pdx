#ifdef CS333_P2
#include "types.h"
#include "user.h"

void
display_result(char* name, int millisec) {
  if (name)
    printf(1,"%s ", name);

  printf(1,"ran in %d", millisec / 1000);

  millisec %= 1000;
  if (millisec)
    printf(1,".");

  if (millisec < 100 && millisec > 0)
    printf(1,"0");
  else
    printf(1,"%d", millisec/100);

  millisec %= 100;
  if (millisec < 10 && millisec > 0)
    printf(1,"0");
  else
    printf(1,"%d", millisec/10);

  if (millisec%=10)
    printf(1,"%d", millisec);

  printf(1," seconds\n");
}

int
main(int argc, char* argv[])
{
  int start, forkflag;

  if (argc == 1)
    printf(2,"No program name provided... ");

  start = uptime();
  forkflag = fork();
  if (forkflag < 0) {
    printf(2,"fork() error");
    exit();
  }

  if (forkflag > 0) {
    wait();
    display_result(argv[1], uptime() - start);
    exit();
  }

  exec(argv[1], argv+1);
  // should not return
  printf(2,"%s failed\n", argv[1]);

  exit();
}

#endif
