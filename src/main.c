#include <stdio.h>
#include <stdint.h>
#include <assert.h>

/*
  ## Implemented & tested
  - JP: jump opcode

  ## Implemented & not tested
  - RET: return opcode
  - CALL: call opcode
  - SEC: Skip if equal opcode
  - SNEC: Skip if not equal opcode
*/

extern int _cpu_cycle(int16_t opcode);
extern int16_t IpMem;

void test_jump() {
  _cpu_cycle(0x1555);

  printf("IpMem %x \n", IpMem);
  assert(IpMem == 0x0555);

  _cpu_cycle(0x1300);

  printf("IpMem %x \n", IpMem);
  assert(IpMem == 0x0300);
}

int main() {
  printf("Init emulation tests\n");

  test_jump();

  printf("End emulation tests\n");
  return 0;
}