#include <am.h>
#include <benchmark.h>
#include <trap.h>
#include <limits.h>

volatile unsigned int* cnt0_uart  =(void*) 0x40020000;
volatile unsigned int* cnt1_uart  =(void*) 0x40020008;
volatile unsigned int* cnt2_uart  =(void*) 0x40021000;
volatile unsigned int* cnt3_uart  =(void*) 0x40021008;
volatile unsigned int* cnt4_uart  =(void*) 0x40022000;
volatile unsigned int* cnt5_uart  =(void*) 0x40022008;
volatile unsigned int* cnt6_uart  =(void*) 0x40023000;
volatile unsigned int* cnt7_uart  =(void*) 0x40023008;
volatile unsigned int* cnt8_uart  =(void*) 0x40024000;
volatile unsigned int* cnt9_uart  =(void*) 0x40024008;
volatile unsigned int* cnt10_uart =(void*) 0x40025000;
volatile unsigned int* cnt11_uart =(void*) 0x40025008;
volatile unsigned int* cnt12_uart =(void*) 0x40026000;
volatile unsigned int* cnt13_uart =(void*) 0x40026008;
volatile unsigned int* cnt14_uart =(void*) 0x40027000;
volatile unsigned int* cnt15_uart =(void*) 0x40027008;

typedef struct Result {
  int pass;
  unsigned long msec; 
  unsigned long if_cnt;
  unsigned long iw_cnt;
  unsigned long id_cnt;
  unsigned long st_cnt;
  unsigned long ld_cnt;
  unsigned long rdw_cnt;
  unsigned long wb_cnt;
} Result;

unsigned long _uptime() {
  volatile unsigned int cnt0 = (*cnt0_uart)*0x100000000 + *(cnt1_uart);  
  return cnt0;
}

unsigned long _read_if_cycle() {
  volatile unsigned int cnt2 = (*cnt2_uart)*0x100000000 + *(cnt3_uart);
  return cnt2;
}

unsigned long _read_iw_cycle() {
  volatile unsigned int cnt4 = (*cnt4_uart)*0x100000000 + *(cnt5_uart);
  return cnt4;
}

unsigned long _read_id_cycle() {
  volatile unsigned int cnt6 = (*cnt6_uart)*0x100000000 + *(cnt7_uart);
  return cnt6;
}

unsigned long _read_st_cycle() {
  volatile unsigned int cnt8 = (*cnt8_uart)*0x100000000 + *(cnt9_uart);
  return cnt8;
}

unsigned long _read_ld_cycle() {
  volatile unsigned int cnt10 = (*cnt10_uart)*0x100000000 + *(cnt11_uart);
  return cnt10;
}

unsigned long _read_rdw_cycle() {
  volatile unsigned int cnt12 = (*cnt12_uart)*0x100000000 + *(cnt13_uart);
  return cnt12;
}

unsigned long _read_wb_cycle() {
  volatile unsigned int cnt14 = (*cnt14_uart)*0x100000000 + *(cnt15_uart);
  return cnt14;
}

static void bench_prepare(Result *res) {
  // TODO [COD]
  //   Add preprocess code, record performance counters' initial states.
  //   You can communicate between bench_prepare() and bench_done() through
  //   static variables or add additional fields in `struct Result`

  res->msec = _uptime();
  res->if_cnt = _read_if_cycle();
  res->iw_cnt = _read_iw_cycle();
  res->id_cnt = _read_id_cycle();
  res->st_cnt = _read_st_cycle();
  res->ld_cnt = _read_ld_cycle();
  res->rdw_cnt = _read_rdw_cycle();
  res->wb_cnt = _read_wb_cycle();               
}

static void bench_done(Result *res) {
  // TODO [COD]
  //  Add postprocess code, record performance counters' current states.
  res->msec = _uptime() - res->msec;
  res->if_cnt = _read_if_cycle() - res->if_cnt;
  res->iw_cnt = _read_iw_cycle() - res->iw_cnt;
  res->id_cnt = _read_id_cycle() - res->id_cnt;
  res->st_cnt = _read_st_cycle() - res->st_cnt;
  res->ld_cnt = _read_ld_cycle() - res->ld_cnt;
  res->rdw_cnt = _read_rdw_cycle() - res->rdw_cnt;
  res->wb_cnt = _read_wb_cycle() - res->wb_cnt;      
}


Benchmark *current;
Setting *setting;

static char *start;

#define ARR_SIZE(a) (sizeof((a)) / sizeof((a)[0]))

// The benchmark list

#define ENTRY(_name, _sname, _s1, _s2, _desc) \
  { .prepare = bench_##_name##_prepare, \
    .run = bench_##_name##_run, \
    .validate = bench_##_name##_validate, \
    .name = _sname, \
    .desc = _desc, \
    .settings = {_s1, _s2}, },

Benchmark benchmarks[] = {
  BENCHMARK_LIST(ENTRY)
};

extern char _heap_start[];
extern char _heap_end[];
_Area _heap = {
  .start = _heap_start,
  .end = _heap_end,
};

static const char *bench_check(Benchmark *bench) {
  unsigned long freesp = (unsigned long)_heap.end - (unsigned long)_heap.start;
  if (freesp < setting->mlim) {
    return "(insufficient memory)";
  }
  return NULL;
}

void run_once(Benchmark *b, Result *res) {
  bench_reset();       // reset malloc state
  current->prepare();  // call bechmark's prepare function
  bench_prepare(res);  // clean everything, start timer
  current->run();      // run it
  bench_done(res);     // collect results
  res->pass = current->validate();
}

int main() {
  int pass = 1;

  _Static_assert(ARR_SIZE(benchmarks) > 0, "non benchmark");

  for (int i = 0; i < ARR_SIZE(benchmarks); i ++) {
    Benchmark *bench = &benchmarks[i];
    current = bench;
    setting = &bench->settings[SETTING];
    const char *msg = bench_check(bench);
    printk("[%s] %s: ", bench->name, bench->desc);
    if (msg != NULL) {
      printk("Ignored %s\n", msg);
    } else {
      unsigned long msec = ULONG_MAX;
      int succ = 1;
      for (int i = 0; i < REPEAT; i ++) {
        Result res;
        run_once(bench, &res);
        printk(res.pass ? "*\n" : "X\n");
        succ &= res.pass;
        if (res.msec < msec) msec = res.msec;

        printk(" Cycle Count = %u\n",res.msec);
        printk(" IF    Count = %u\n",res.if_cnt);
        printk(" IW    Count = %u\n",res.iw_cnt);  
        printk(" ID    Count = %u\n",res.id_cnt);
        printk(" ST    Count = %u\n",res.st_cnt);
        printk(" LD    Count = %u\n",res.ld_cnt);
        printk(" RDW   Count = %u\n",res.rdw_cnt);
        printk(" WB    Count = %u\n",res.wb_cnt);         
      }

      if (succ) printk(" Passed.\n");
      else printk(" Failed.\n");

      pass &= succ;

    }
  }

  printk("benchmark finished\n");

  if(pass)
	  hit_good_trap();
  else
	  nemu_assert(0);

  return 0;
}

// Library


void* bench_alloc(size_t size) {
  if ((uintptr_t)start % 16 != 0) {
    start = start + 16 - ((uintptr_t)start % 16);
  }
  char *old = start;
  start += size;
  assert((uintptr_t)_heap.start <= (uintptr_t)start && (uintptr_t)start < (uintptr_t)_heap.end);
  for (char *p = old; p != start; p ++) *p = '\0';
  assert((uintptr_t)start - (uintptr_t)_heap.start <= setting->mlim);
  return old;
}

void bench_free(void *ptr) {
}

void bench_reset() {
  start = (char*)_heap.start;
}

static int32_t seed = 1;

void bench_srand(int32_t _seed) {
  seed = _seed & 0x7fff;
}

int32_t bench_rand() {
  seed = (mmul_u(seed , (int32_t)214013L) + (int32_t)2531011L);
  return (seed >> 16) & 0x7fff;
}

// FNV hash
uint32_t checksum(void *start, void *end) {
  const int32_t x = 16777619;
  int32_t hash = 2166136261u;
  for (uint8_t *p = (uint8_t*)start; p + 4 < (uint8_t*)end; p += 4) {
    int32_t h1 = hash;
    for (int i = 0; i < 4; i ++) {
      h1 = mmul_u((h1 ^ p[i]) , x);
    }
    hash = h1;
  }
  hash += hash << 13;
  hash ^= hash >> 7;
  hash += hash << 3;
  hash ^= hash >> 17;
  hash += hash << 5;
  return hash;
}