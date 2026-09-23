## Q1. What is Moore's Law?

- Moore's Law is an observation and prediction made by Gordon Moore in 1965 that the number of transistors on a microchip doubles approximately every two years.
- Because of that, computing power and efficiency grew exponentially over the past decades and ICs became smaller, more powerful, more reliable and easier to manufacture.
- Smaller feature size means more transistors per chip, so more processing power in the same space.
- But this growth has its own limit: higher clock speed means more power consumption and heat, and single-processor performance improvement ended around 2003. That's why the industry moved to multi-core processors

## Q2. Explain SISD, SIMD, MISD and MIMD.

These are the 4 categories of Flynn's taxonomy, a classification of computer architectures made by Michael J. Flynn in 1966. It is used to divide machines by how many instruction streams and data streams they can handle at the same time.

- SISD (single instruction, single data) - one instruction stream working on one data stream.  Basically a regular uniprocessor like a single-core machine, the traditional sequential computer.

- SIMD (single instruction, multiple data) - one instruction stream that works on multiple data streams at once, so the same operation is applied to many data items in parallel.

- MISD (multiple instruction, single data) - multiple instruction streams working on a single data stream. It's very rare and mostly theoretical. The closest example is stream processors,

- MIMD (multiple instruction, multiple data) - multiple instruction streams and multiple data streams, each processor core runs its own program on its own data independently. Examples are modern multiprocessors and multicore processors

## Q3. How many types of instruction sets are there, and explain them.

- **Instruction set architecture (ISA)** defines what operations a processor can perform (arithmetic, logical, control etc.) and how memory is organized and accessed.
- It's basically the link between hardware and software, so software written for some ISA can run on any hardware that supports this ISA.
	- For example: High-level code in Python gets compiled into machine instructions of the ISA, and assembly language is just the human-readable form of these instructions, for example ADD $0, $a1, $a2 adds two registers and stores the result.

- There are 2 main types of instruction sets:
	1. **RISC (reduced instruction set computing)** - uses a small, highly optimized set of instructions. This makes the processor design simpler and gives faster processing speed and better efficiency, which is critical for modern computing. RISC appeared thanks to the progress of high-level language compilers and UNIX.
	2. **CISC (complex instruction set computing)** - the opposite approach, where the processor has a bigger set of more complex instructions instead of a small and simple one.

----

- AI was used:
	- to transcribe the lectures (you can use @kbtu_unibot to download the transcriptions),
	- to understand the material by asking Claude,
	- to analyze the draft for grammar mistakes
