using Iced.Intel;
using PeNet.Header.Pe;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using static Iced.Intel.AssemblerRegisters;
using static spp.PE;

namespace spp
{
    // https://docs.microsoft.com/en-us/windows/win32/api/enclaveapi/
    // https://stackoverflow.com/questions/69862883/how-can-i-run-loadenclavedata-function-in-memory
    class Program
    {
        // usage: spp.exe <input> <output> <options.json>
        // TODO: upgrades should include a stateful array of data that must exist throughout the entire setup of the program so that emulation programs are rendered useless
        static void Main(string[] args)
        {
            if(args.Length != 3)
            {
                Error("Invalid args: <input> <output> <options.json>");
            }
            if(!File.Exists(args[0]))
            {
                Error("Invalid input: File doesnt exist");
            }
            if(!File.Exists(args[2]))
            {
                Error("Invalid options: File doesnt exist");
            }

            string input = args[0];
            string output = args[1];
            string options = args[2];

            byte[] originalPEBuff = File.ReadAllBytes(input);

            bool result = PeNet.PeFile.TryParse(originalPEBuff, out var peFile);

            // first, run it through the obfuscation processor
            // processor needs to have pattern matchers that translate certain code patterns nonlinearly into more difficult to understand patterns
            // templates:
                // Function Prologue/Epilogue Hider:
                    // Take all equivalent function prologues (pushes and sub), extract to a const location, push return address instead, and jump to template
                    // push, push, push => lea rax, [rip+n]; jmp tmplt; NOP NOP NOP; tmplt: push push push jmp rax;
                // Padding Hider:
                    // Take all padding locations and use them for either relocation purposes or destroy them with semi-random instructions
                // Stack Check Hider:
                    // convert all stack checks to jumps that do extra stuff and reimplement the stack guard checks through obfuscated means
                // Call hider:
                    // call (loc) -> jmp newloc; newloc: sub xsp, size, lea rax, [rip+returnAddy]; push rax; jmp callLoc;
                // Code in Code protection
                // self relocating code (anti-debug)
                // https://back.engineering/13/04/2022/ (CALL 0x5 obfuscating)
                // https://github.com/mike1k/perses
                // https://www.usenix.org/system/files/sec21fall-liu-binbin.pdf
            // https://www.felixcloutier.com/x86/iret:iretd
            // https://www.youtube.com/watch?v=0SvX6F80qg8
            // https://github.com/RUB-SysSec/loki
            // https://anti-reversing.com/Downloads/Anti-Reversing/The_Ultimate_Anti-Reversing_Reference.pdf
            // https://www.blackhat.com/presentations/bh-usa-07/Yason/Whitepaper/bh-usa-07-yason-WP.pdf
            // https://www.unknowncheats.me/forum/call-of-duty-modern-warfare/390209-deobfuscate-functions.html#post2770403
            // https://medium.com/swlh/assembly-wrapping-a-new-technique-for-anti-disassembly-c144eb90e036
            // Return address hiding via custom stack return manipulations (obfuscated return address management should make most debuggers shit the bed)

            // Note we should aim for the following:
            // 1. A blanket no questions asked function mutator that doesnt increase function complexity but rather simply increases analysis complexity
            // 2. A opt-in macro system to emit cv style start/end markers to protect highly valuable functions
            // 3. A opt-in macro system to emit protected strings
            // 4. A opt-in code integrity system like arxan
            // 5. Opt in struct field randomization
            // 6. Opt in pointer randomization

            // Note that now complex templates are possible
            // with prologue and call masking, parameter encryption is possible

            if(!result)
            {
                Error("Invalid PE file");
            }

            PE_META_DATA PEINFO = GetPeMetaData(originalPEBuff.Unmanaged());

            List<byte> shellcode = new List<byte>();

            byte[] mapped = new byte[peFile.ImageNtHeaders.OptionalHeader.SizeOfImage];
            ImageSectionHeader textSection = null;
            foreach(var section in peFile.ImageSectionHeaders)
            {
                switch(section.Name)
                {
                    // need to blacklist so custom sections get mapped
                    case ".reloc":
                    case ".pdata":
                    case ".debug":
                    case ".debug$S":
                    case ".debug$F":
                    case ".debug$T":
                    case ".debug$P":
                    case ".edata":
                        break;

                    default:
                        if(section.Name == ".text")
                        {
                            textSection = section;
                        }
                        Console.WriteLine($"Mapped {section.Name}");
                        peFile.RawFile.AsSpan(section.PointerToRawData, section.SizeOfRawData).ToArray().CopyTo(mapped, section.VirtualAddress);
                        break;
                }
            }

            if(textSection is null)
            {
                Error("Cannot protect a PE without a .text section!");
            }

            // TODO: need to delete rdata information as its used (ie: EAT, IAT, etc etc)
            // TODO: need to grab address of entry point from the header
            // TODO: need to specify in options which export to call if any and how many params it takes

            var prologue = new Assembler(peFile.Is64Bit ? 64: 32);

            #region PROLOGUE
            // I[X] store base address of region in xdx (we need this for relocation purposes)
            //      48 8d 15 f9 ff ff ff for x64 (stores base in rdx)
            //      e8 00 00 00 00 5a 83 ea 06 for x86 (stores base in edx)
            if (peFile.Is64Bit)
            {
                shellcode.AddRange(new byte[] { 0x48, 0x8d, 0x15, 0xf9, 0xff, 0xff, 0xff });
            }
            else
            {
                shellcode.AddRange(new byte[] { 0xe8, 0x00, 0x00, 0x00, 0x00, 0x5a, 0x83, 0xea, 0x06 });
            }

            // I[X] save all registers so we can use whatever we want because calling conventions unecessary
            if (peFile.Is64Bit)
            {
                prologue.push(rbx);
                prologue.push(rax);
                prologue.push(rsi);
                prologue.push(rdi);
                prologue.push(rbp);
                prologue.push(r12);
                prologue.push(r13);
                prologue.push(r14);
                prologue.push(r15);
            }
            else
            {
                prologue.push(ebx);
                prologue.push(ebp);
                prologue.push(edi);
                prologue.push(esi);
            }

            // I[X] mov xbp, xsp
            if (peFile.Is64Bit)
            {
                prologue.mov(rbp, rsp);
            }
            else
            {
                prologue.mov(ebp, esp);
            }


            // constants in the stack:
            // xbp+0x000: base of region
            // xbp+0x008: LdrLoadDll
            // xbp+0x010: LdrGetProcedureAddress
            // xbp+0x018: saved RCX
            // xbp+0x020: size of shellcode
            // xbp+0x028: ALIGN

            // push xdx (base, use xbp to keep track of this, so at this point base -> xbp)
            // also need to reserve base space on stack
            if (peFile.Is64Bit)
            {
                prologue.push(rdx); // xbp+0x000: base of region

                prologue.push(rdx); // xbp+0x008: LdrLoadDll

                prologue.push(rdx); // xbp+0x010: LdrGetProcedureAddress

                prologue.push(rcx); // xbp+0x018: saved RCX

                prologue.push(rcx); // xbp+0x020: size of shellcode

                prologue.push(rcx);
            }
            else
            {
                prologue.push(edx); // xbp+0x000: base of region
                prologue.push(edx);

                prologue.push(edx); // xbp+0x008: LdrLoadDll
                prologue.push(edx);

                prologue.push(edx); // xbp+0x010: LdrGetProcedureAddress
                prologue.push(edx);

                prologue.push(ecx); // xbp+0x018: saved ECX
                prologue.push(ecx);

                prologue.push(ecx); // xbp+0x020: size of shellcode
                prologue.push(ecx);

                prologue.push(ecx);
                prologue.push(ecx);
            }

            #endregion PROLOGUE

            #region SECTION A
            var sectionA = new Assembler(peFile.Is64Bit ? 64 : 32);
            List<byte> sectionABytecode = new List<byte>();
            var sizeOfSection = shellcode.Count;
            // [ ] decode A section and destroy I section

            // theory:
            // need rolling decryption that relies on stateful changes of previous registers mixed into the code
            // additionally, the code section we are operating in should destroy old data in a way that creates a state that changes the decryption result of the next section
            // gadgets for operation should be pulled from a randomized operation equivalency table
            // ie: a * 3 = (a << 2) + a = (a << 4) - a = (a << 2) + (a << 2) - a = ((a * 2) << 1) - a
            // Equivalency.Multiply(asm, a, b, depth);
            // note that we really would prefer stateful equivalency -- parameters need to be setup long before they are necessary and things like that
            // we also really like weird instructions that cant really be turned back into c.
            // for decoding and encoding we should just unroll loops

            // for destruction/construction, lets make the algorithm the same
            // lets use generated constants to define the encryption routine and omit them from the output routine
            // note that not all data should be preserved from the original region. only parts should decide what the next state is. we dont want the algo to be reversible.
            // the idea is that neither the initial state nor the final state should have any usable data. the decryption and encryption routines should make you be forced to execute them to operate.
            // it would also be nice to try to destroy static and dynamic analysis techniques... maybe hide anti-debug tech in the initialization procedures?

            // destroy I section
            if(peFile.Is64Bit)
            {
                // TODO
            }
            else
            {
                // NOTE: dont modify first 4 bytes
                // TODO
            }

            // A[X] grab peb
            //      mov rdx, GS:[0x60] for x64
            //      mov edx, FS:[0x30] for x64
            if (peFile.Is64Bit)
            {
                sectionABytecode.AddRange(new byte[] { 0x65, 0x48, 0x8B, 0x14, 0x25, 0x60, 0x00, 0x00, 0x00 });
            }
            else
            {
                sectionABytecode.AddRange(new byte[] { 0x64, 0x8B, 0x15, 0x30, 0x00, 0x00, 0x00 });
            }

            // A[X-] iterate peb for ntdll (https://www.youtube.com/watch?v=3wZCVEJOGos)
            // A[X-] iterate ntdll exports for LdrLoadDll and LdrGetProcedureAddress (https://www.ired.team/offensive-security/code-injection-process-injection/finding-kernel32-base-and-function-addresses-in-shellcode)
            //     save them at xbp+0x8: LdrLoadDll and xbp+0x10: LdrGetProcedureAddress
            if (peFile.Is64Bit)
            {
                var beginloop = sectionA.CreateLabel();
                var breakloop = sectionA.CreateLabel();
                var continueloop = sectionA.CreateLabel();
                var continueLoading = sectionA.CreateLabel();

                var beginSearch = sectionA.CreateLabel();
                var endSearch = sectionA.CreateLabel();
                var continueSearch = sectionA.CreateLabel();

                var begin2Search = sectionA.CreateLabel();
                var end2Search = sectionA.CreateLabel();
                var continue2Search = sectionA.CreateLabel();

                sectionA.mov(rax, __qword_ptr[rdx + 0x10]); // image base address
                sectionA.mov(rdi, rax); // image base address
                sectionA.shr(rax, 40); // 0x7F
                sectionA.xor(rax, 0x67); // 0x18
                sectionA.mov(rdx, __qword_ptr[rdx + rax]); // peb->ldr
                sectionA.sub(rax, 0x8);
                sectionA.mov(rdx, __qword_ptr[rdx + rax]); // peb->ldr->InLoadOrderModuleList

                sectionA.mov(rsi, rdx); // save &first
                sectionA.mov(rbx, 0); // this is our h_ntdll

                sectionA.Label(ref beginloop);
                sectionA.mov(rax, __[rdx]); // entry->flink
                sectionA.cmp(rax, rsi); // compare entry->flink to &first
                sectionA.je(breakloop); // if they are equal, list is over and we need to jump to exit label
                // dont modify: rsi, rdi, rbx

                // rdx is the entry pointer
                // 0x058 BaseDllName
                sectionA.mov(rax, rdx);
                sectionA.mov(rcx, rdi); // image base address
                sectionA.shr(rcx, 41); // 0x3f
                sectionA.xor(rcx, 0x67); // 0x58 how lucky is this ?!
                sectionA.add(rax, rcx); // &entry->BaseDllName
                sectionA.mov(rax, __[rax+0x8]); // the address of the dll name

                sectionA.mov(ecx, __dword_ptr[rax]); // should be 0x0074006E in wchar format (nt)
                sectionA.sub(ecx, 0x1234);
                sectionA.cmp(ecx, 0x73EE3A);
                sectionA.jne(continueloop);

                sectionA.mov(ecx, __dword_ptr[rax+4]); // should be 0x006C0064 in wchar format (dl)
                sectionA.sub(ecx, 0x4321);
                sectionA.cmp(ecx, 0x6BBD43);
                sectionA.jne(continueloop);

                sectionA.mov(rbx, rdx); // save module (we found it)
                sectionA.jmp(breakloop); // finished

                sectionA.Label(ref continueloop);
                sectionA.mov(rdx, __[rdx]); // entry = entry->flink
                sectionA.jmp(beginloop);

                sectionA.Label(ref breakloop);
                
                // rbx is either ntdll handle or 0
                sectionA.cmp(rbx, 0);
                sectionA.jne(continueLoading);
                sectionA.jmp(breakloop); // hang the thread

                sectionA.Label(ref continueLoading);
                // we have ntdll, now we need to find LdrLoadDll and LdrGetProcedureAddress
                
                // PROTECTED: RDX (base ntdll), ECX (num exported funcs), R10 (exported func addresses), R11 (name pointer table), r14 (ordinal table)
                sectionA.mov(rdx, rbx); // save base of ntdll in rdx and do not modify until no longer needed
                sectionA.mov(rax, 0);
                sectionA.mov(rbx, 0);
                sectionA.mov(rsi, rdi); // image base address
                sectionA.shr(rsi, 41); // 0x3f
                sectionA.sub(rsi, 3); // 0x3C
                sectionA.mov(eax, __dword_ptr[rdx + rsi]); // grab rva of pe signature
                sectionA.add(rax, rdx); // add to image base
                sectionA.xor(rsi, 0x44); // 0x78
                sectionA.mov(ebx, __dword_ptr[rax + rsi]); // grab rva of exports
                sectionA.add(rbx, rdx); // add to image base to get exports offset
                sectionA.shr(rsi, 2); // 0x1E
                sectionA.sub(rsi, 0xA); // 0x14
                sectionA.mov(ecx, __dword_ptr[rbx + rsi]); // number of exported functions
                sectionA.xor(rsi, 0x1a); // 0xE
                sectionA.shl(rsi, 1); // 0x1C
                sectionA.mov(r10d, __dword_ptr[rbx + rsi]); // exported functions table rva
                sectionA.add(r10, rdx); // add to image base to get exported functions addy
                sectionA.sub(rsi, 0xC); // 0x10
                sectionA.shl(rsi, 1); // 0x20
                sectionA.mov(r11d, __dword_ptr[rbx + rsi]); // name pointer table rva
                sectionA.add(r11, rdx); // add to image base to get name pointer table addy
                sectionA.mov(r14d, __dword_ptr[rbx + rsi + 4]); // ordinal table rva
                sectionA.add(r14, rdx); // add to image base to get ordinal table addy

                sectionA.xor(eax, eax); // clear rax

                // Dont use rdx, rcx, r10, r11
                sectionA.Label(ref beginSearch);
                sectionA.cmp(eax, ecx); // compare count (eax) to num functions (ecx)
                sectionA.jae(endSearch); // if we are above or equal to count, bounce

                sectionA.mov(esi, __dword_ptr[r11 + rax * 4]); // grab source string rva
                sectionA.add(rsi, rdx); // add to image base to get source string offset

                sectionA.mov(r12d, __dword_ptr[rsi + 1]); // should be drLo 0x6F4C7264
                sectionA.inc(r12d);
                sectionA.xor(r12d, 0x7265);
                sectionA.dec(r12d);
                sectionA.cmp(r12d, 0x6F4BFFFF);
                sectionA.jne(continueSearch);

                sectionA.mov(r12d, __dword_ptr[rsi + 6]); // should be dDll 0x6C6C4464
                sectionA.sub(r12d, 0x28280020); // DDDD

                sectionA.cmp(r12b, 0x43); // check if input[3] <= C
                sectionA.jbe(continueSearch);

                sectionA.movzx(r13, r12b);

                sectionA.shr(r12, 8);
                sectionA.cmp(r12b, r13b);
                sectionA.jne(continueSearch); // check if input[2] == input[3]

                sectionA.shr(r12, 8);
                sectionA.cmp(r12b, r13b);
                sectionA.jne(continueSearch); // check if input[1] == input[3]

                sectionA.shr(r12, 8);
                sectionA.cmp(r12b, r13b);
                sectionA.jne(continueSearch); // check if input[0] == input[3]

                sectionA.cmp(r12b, 0x45); // check if input[0] >= E
                sectionA.jae(continueSearch);

                // all characters are 'D', found ldr load
                sectionA.jmp(endSearch);

                sectionA.Label(ref continueSearch);
                sectionA.inc(eax);
                sectionA.jmp(beginSearch);

                sectionA.Label(ref endSearch);

                // eax is either count or index of the function
                sectionA.cmp(eax, ecx); // compare count (eax) to num functions (ecx)
                sectionA.jae(endSearch); // if we are above or equal to count, hang the process

                sectionA.mov(r12d, __dword_ptr[r10 + rax * 4]); // grab rva for LdrLoadDll
                sectionA.add(r12, rdx); // convert to real address
                sectionA.mov(__[rbp + 0x008], rdx); // store in stack

                // need to find LdrGetProcedureAddress
                sectionA.xor(eax, eax); // clear rax

                sectionA.Label(ref begin2Search);
                sectionA.cmp(eax, ecx); // compare count (eax) to num functions (ecx)
                sectionA.jae(end2Search); // if we are above or equal to count, bounce

                sectionA.mov(esi, __dword_ptr[r11 + rax * 4]); // grab source string rva
                sectionA.add(rsi, rdx); // add to image base to get source string offset

                sectionA.mov(r12d, __dword_ptr[rsi + 3]); // should be GetP 0x50746547
                sectionA.sub(r12d, 0x112233);
                sectionA.cmp(r12d, 0x50634314);
                sectionA.jne(continue2Search);

                sectionA.mov(r12d, __dword_ptr[rsi + 0x13]); // should be ess\x00 0x00737365
                sectionA.add(r12d, 0x7300000E); // ssss

                sectionA.cmp(r12b, 0x72); // check if input[3] <= r
                sectionA.jbe(continue2Search);

                sectionA.movzx(r13, r12b);

                sectionA.shr(r12, 8);
                sectionA.cmp(r12b, r13b);
                sectionA.jne(continue2Search); // check if input[2] == input[3]

                sectionA.shr(r12, 8);
                sectionA.cmp(r12b, r13b);
                sectionA.jne(continue2Search); // check if input[1] == input[3]

                sectionA.shr(r12, 8);
                sectionA.cmp(r12b, r13b);
                sectionA.jne(continue2Search); // check if input[0] == input[3]

                sectionA.cmp(r12b, 0x74); // check if input[0] >= t
                sectionA.jae(continue2Search);

                // all characters are 's', found ldrgetprocedureaddress
                sectionA.jmp(end2Search);

                sectionA.Label(ref continue2Search);
                sectionA.inc(eax);
                sectionA.jmp(begin2Search);

                sectionA.Label(ref end2Search);

                // eax is either count or index of the function
                sectionA.cmp(eax, ecx); // compare count (eax) to num functions (ecx)
                sectionA.jae(end2Search); // if we are above or equal to count, hang the process

                sectionA.mov(r12d, __dword_ptr[r10 + rax * 4]); // grab rva for ldrgetprocedureaddress
                sectionA.add(r12, rdx); // convert to real address
                sectionA.mov(__[rbp + 0x010], rdx); // store in stack

                // found both, continue to next section
            }
            else
            {
                sectionA.mov(eax, __[ebp + 0x0]); // start of assembly*
                sectionA.mov(eax, __[eax]); // start of assembly (0x000000E8)
                sectionA.mov(esi, eax);
                sectionA.shr(eax, 4); // 0xE
                sectionA.sub(eax, 2); // 0xC
                sectionA.mov(edx, __[edx + eax]); // peb->ldr
                sectionA.xor(esi, 0xe4); // 0xC
                sectionA.mov(edx, __[edx + esi]); // peb->ldr->InLoadOrderModuleList

                // TODO
            }

            #endregion

            // TODO: randomize relocation order
            #region SECTION B
            // [ ] destroy A section and decode B section
            // B[ ] generate assembly that fixes all fixups hardcoded (no loops)

            var sectionB = new Assembler(peFile.Is64Bit ? 64 : 32);
            List<byte> sectionBBytecode = new List<byte>();

            Dictionary<uint, long> Relocations = new Dictionary<uint, long>(); // list of patch spots and the deltas they have from the original image base
            byte[] empty4 = new byte[4];
            byte[] empty8 = new byte[8];
            foreach (var rDir in peFile.ImageRelocationDirectory)
            {
                foreach(var reloc in rDir.TypeOffsets)
                {
                    switch(reloc.Type)
                    {
                        case 0:
                            continue;
                        case 0x3: // x86
                            {
                                long original = BitConverter.ToInt32(mapped, (int)(rDir.VirtualAddress + reloc.Offset));
                                empty4.CopyTo(mapped, (int)(rDir.VirtualAddress + reloc.Offset)); // wipe old data
                                original -= (long)peFile.ImageNtHeaders.OptionalHeader.ImageBase;
                                Relocations[rDir.VirtualAddress + reloc.Offset] = original;
                            }
                            break;
                        default:
                            {
                                long original = BitConverter.ToInt64(mapped, (int)(rDir.VirtualAddress + reloc.Offset));
                                empty8.CopyTo(mapped, (int)(rDir.VirtualAddress + reloc.Offset)); // wipe old data
                                original -= (long)peFile.ImageNtHeaders.OptionalHeader.ImageBase;
                                Relocations[rDir.VirtualAddress + reloc.Offset] = original;
                            }
                            break;
                    }
                }
            }

            // destroy this data
            IMAGE_DATA_DIRECTORY idd = PEINFO.Is32Bit ? PEINFO.OptHeader32.BaseRelocationTable : PEINFO.OptHeader64.BaseRelocationTable;
            IntPtr pRelocTable = (IntPtr)(idd.VirtualAddress);
            Int32 nextRelocTableBlock = -1;
            while (nextRelocTableBlock != 0)
            {
                // destroy current block after reading it
                IMAGE_BASE_RELOCATION ibr = new IMAGE_BASE_RELOCATION();
                ibr = mapped.Skip(pRelocTable.ToInt32()).Take(Marshal.SizeOf(typeof(IMAGE_BASE_RELOCATION))).ToArray().ToStruct<IMAGE_BASE_RELOCATION>();
                new byte[ibr.SizeOfBlock].CopyTo(mapped, pRelocTable.ToInt32());

                // Check for next block
                pRelocTable = (IntPtr)((UInt64)pRelocTable + ibr.SizeOfBlock);
                nextRelocTableBlock = BitConverter.ToInt32(mapped, pRelocTable.ToInt32());
            }

            // we want to do an unrolled loop, where, using 5-10 state trackers, we encrypt stateful transitions between the image relocation deltas
            // 64 bit uses 5 stack values and 1 register: rdi (base pointer for the indexes)
            // 32 bit uses 5 stack values and 1 register: edi (base pointer for the indexes)
            Random r = new Random();
            long[] states = new long[5];

            if (peFile.Is64Bit)
            {
                sectionB.sub(rsp, 0x8 * 0x5);
                sectionB.mov(rdi, rsp);
            }
            else
            {
                sectionB.sub(esp, 0x4 * 0x5);
                sectionB.mov(edi, esp);
            }

            for (int i = 0; i < states.Length; i++)
            {
                var start = r.Next((int)textSection.VirtualAddress, (int)textSection.VirtualAddress + (int)textSection.VirtualSize - 8);
                retry:
                foreach(var reloc in Relocations)
                {
                    if(start >= reloc.Key && start <= reloc.Key + (peFile.Is64Bit ? 8 : 4))
                    {
                        start += 8;
                        goto retry;
                    }
                }
                if(peFile.Is64Bit)
                {
                    states[i] = BitConverter.ToInt64(mapped, start);
                    sectionB.mov(rsi, __[rbp + 0x20]);
                    sectionB.add(rsi, __[rbp + 0x00]);
                    sectionB.add(rsi, start);
                    sectionB.mov(rsi, __[rsi]);
                    sectionB.mov(__[rdi + (i * 8)], rsi);
                }
                else
                {
                    states[i] = BitConverter.ToInt32(mapped, start);
                    sectionB.mov(esi, __[ebp + 0x20]);
                    sectionB.add(esi, __[ebp + 0x00]);
                    sectionB.add(esi, start);
                    sectionB.mov(esi, __[esi]);
                    sectionB.mov(__[edi + (i * 4)], esi);
                }
            }

            foreach(var reloc in Relocations)
            {
                int finalIndex = r.Next(states.Length);

                // lets perform 2 sets of operations per relocation

                // the first operation set can just randomly shift the states of input registers to the final equation

                // number of registers to modify
                int numRegisters = r.Next(1, states.Length);
                int startIndex = r.Next(states.Length);

                for(int i = 0; i < numRegisters; i++)
                {
                    var indx = (startIndex + i) % states.Length;
                    var indx2 = (indx + r.Next(1, states.Length)) % states.Length;

                    var op = (StatefulOperators)r.Next((int)StatefulOperators.SFO_SINGLE_FIRST, (int)StatefulOperators.SFO_DOUBLE_COUNT);

                    switch (op)
                    {
                        case StatefulOperators.SFO_SINGLE_ROR:
                            if(peFile.Is64Bit)
                            {
                                int rorAmount = r.Next(1, 61);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                sectionB.ror(rax, (byte)rorAmount);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                states[indx] = (long)RotateRight((ulong)states[indx], rorAmount);
                            }
                            else
                            {
                                int rorAmount = r.Next(1, 31);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                sectionB.ror(eax, (byte)rorAmount);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                states[indx] = (long)RotateRight32((uint)states[indx], rorAmount);
                            }
                            break;
                        case StatefulOperators.SFO_SINGLE_ROL:
                            if (peFile.Is64Bit)
                            {
                                int rorAmount = r.Next(1, 61);
                                sectionB.mov(rax, __[rdi + (indx * 8)]);
                                sectionB.rol(rax, (byte)rorAmount);
                                sectionB.mov(__[rdi + (indx * 8)], rax);
                                states[indx] = (long)RotateLeft((ulong)states[indx], rorAmount);
                            }
                            else
                            {
                                int rorAmount = r.Next(1, 31);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                sectionB.rol(eax, (byte)rorAmount);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                states[indx] = (long)RotateLeft32((uint)states[indx], rorAmount);
                            }
                            break;
                        case StatefulOperators.SFO_SINGLE_SHL:
                            if (peFile.Is64Bit)
                            {
                                int shAmount = r.Next(1, 31);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                sectionB.shl(rax, (byte)shAmount);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                states[indx] = states[indx] << shAmount;
                            }
                            else
                            {
                                int shAmount = r.Next(1, 15);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                sectionB.shl(eax, (byte)shAmount);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                states[indx] = (int)states[indx] << shAmount;
                            }
                            break;
                        case StatefulOperators.SFO_SINGLE_SHR:
                            if (peFile.Is64Bit)
                            {
                                int shAmount = r.Next(1, 31);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                sectionB.shr(rax, (byte)shAmount);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                states[indx] = states[indx] >> shAmount;
                            }
                            else
                            {
                                int shAmount = r.Next(1, 15);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                sectionB.shr(eax, (byte)shAmount);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                states[indx] = (int)states[indx] >> shAmount;
                            }
                            break;
                        case StatefulOperators.SFO_SINGLE_BSWAP:
                            if (peFile.Is64Bit)
                            {
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                sectionB.bswap(rax);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                states[indx] = BitConverter.ToInt64(BitConverter.GetBytes(states[indx]).Reverse().ToArray(), 0);
                            }
                            else
                            {
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                sectionB.bswap(eax);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                states[indx] = BitConverter.ToInt32(BitConverter.GetBytes((int)states[indx]).Reverse().ToArray(), 0);
                            }
                            break;
                        case StatefulOperators.SFO_SINGLE_BITNEGATE:
                            if (peFile.Is64Bit)
                            {
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                sectionB.neg(rax);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                states[indx] = ~states[indx];
                            }
                            else
                            {
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                sectionB.neg(eax);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                states[indx] = ~(int)states[indx];
                            }
                            break;
                        case StatefulOperators.SFO_DOUBLE_ADD:
                            if (peFile.Is64Bit)
                            {
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                sectionB.add(rax, __[rdi + (indx2 * 8)]);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                states[indx] = (long)((ulong)states[indx] + (ulong)states[indx2]);
                            }
                            else
                            {
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                sectionB.add(eax, __[edi + (indx2 * 4)]);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                states[indx] = (long)((uint)states[indx] + (uint)states[indx2]);
                            }
                            break;
                        case StatefulOperators.SFO_DOUBLE_SUB:
                            if (peFile.Is64Bit)
                            {
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                sectionB.sub(rax, __[rdi + (indx2 * 8)]);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                states[indx] = (long)((ulong)states[indx] - (ulong)states[indx2]);
                            }
                            else
                            {
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                sectionB.sub(eax, __[edi + (indx2 * 4)]);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                states[indx] = (long)((uint)states[indx] - (uint)states[indx2]);
                            }
                            break;
                        case StatefulOperators.SFO_DOUBLE_MULT:
                            if (peFile.Is64Bit)
                            {
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                sectionB.mov(rbx, __[rdi + (indx2 * 8)]);
                                sectionB.mul(rbx);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                states[indx] = (long)((ulong)states[indx] * (ulong)states[indx2]);
                            }
                            else
                            {
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                sectionB.mov(ebx, __[edi + (indx2 * 4)]);
                                sectionB.mul(ebx);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                states[indx] = (long)((uint)states[indx] * (uint)states[indx2]);
                            }
                            break;
                        case StatefulOperators.SFO_DOUBLE_XOR:
                            if (peFile.Is64Bit)
                            {
                                sectionB.mov(rax, __[rdi + (indx * 8)]);
                                sectionB.xor(rax, __[rdi + (indx2 * 8)]);
                                sectionB.mov(__[rdi + (indx * 8)], rax);
                                states[indx] = (long)((ulong)states[indx] ^ (ulong)states[indx2]);
                            }
                            else
                            {
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                sectionB.xor(eax, __[edi + (indx2 * 4)]);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                states[indx] = (long)((uint)states[indx] ^ (uint)states[indx2]);
                            }
                            break;
                        case StatefulOperators.SFO_DOUBLE_OR:
                            if (peFile.Is64Bit)
                            {
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                sectionB.or(rax, __[rdi + (indx2 * 8)]);
                                sectionB.xchg(__[rdi + (indx * 8)], rax);
                                states[indx] = (long)((ulong)states[indx] | (ulong)states[indx2]);
                            }
                            else
                            {
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                sectionB.or(eax, __[edi + (indx2 * 4)]);
                                sectionB.xchg(__[edi + (indx * 4)], eax);
                                states[indx] = (long)((uint)states[indx] | (uint)states[indx2]);
                            }
                            break;
                    }
                }

                // the second operation set needs to manipulate these registers and place the final delta value into the final state register

                if (peFile.Is64Bit)
                {
                    sectionB.mov(rax, __[rdi + (finalIndex * 8)]);
                    sectionB.mov(rbx, reloc.Value ^ states[finalIndex]);
                    sectionB.xor(rax, rbx);
                    sectionB.add(rax, __[rbp + 0x20]);
                    sectionB.add(rax, __[rbp + 0x00]); // moduleBase + delta
                    sectionB.mov(rbx, reloc.Key);
                    sectionB.add(rbx, __[rbp + 0x20]);
                    sectionB.add(rbx, __[rbp + 0x00]); // moduleBase + relocation virtual
                    sectionB.mov(__[rbx], rax);
                }
                else
                {
                    sectionB.mov(eax, __[edi + (finalIndex * 4)]);
                    sectionB.mov(ebx, (uint)reloc.Value ^ (uint)states[finalIndex]);
                    sectionB.xor(eax, ebx);
                    sectionB.add(eax, __[ebp + 0x20]);
                    sectionB.add(eax, __[ebp + 0x00]); // moduleBase + delta
                    sectionB.mov(ebx, reloc.Key);
                    sectionB.add(ebx, __[ebp + 0x20]);
                    sectionB.add(ebx, __[ebp + 0x00]); // moduleBase + relocation virtual
                    sectionB.mov(__[ebx], eax);
                }
            }

            if (peFile.Is64Bit)
            {
                sectionB.add(rsp, 0x8 * 0x5);
            }
            else
            {
                sectionB.add(esp, 0x4 * 0x5);
            }

            #endregion

            #region SECTION C
            var sectionC = new Assembler(peFile.Is64Bit ? 64 : 32);
            List<byte> sectionCBytecode = new List<byte>();

            // [ ] destroy B section and decode C section
            // C[ ] generate assembly that fixes all import thunks

            // can also deploy a stub for finding the dll we want using TEB and a random generated pattern matching method
            // now typically you just replace the function stub value at the thunk, but this is super easy to detect. Can we mask this somehow?
            //  Idea: change address to local stub in binary that decrypts the original pointer on use

            // need to get unicode formatted strings onto the stack or the assembled segment for loadlibrary

            // save sp in di
            // save space in the stack for a unicode buffer struct
            // 64 bit: 2 + 2 + 4 + 8 => 0x10
            // 32 bit: 2 + 2 + 4 => 0x8 (but we use 0x10 so we keep stuff nicely aligned)
            // immediately after, save 0x210 bytes for the dll pathname (max_path)
            // this means that buffer points to sp after the space is allocated
            if (peFile.Is64Bit)
            {
                sectionC.sub(rsp, 0x10); // string struct
                sectionC.mov(rdi, rsp); // save string location
                sectionC.sub(rsp, 0x210); // buffer space

                // setup the unicode string
                sectionC.mov(rax, rdi);
                sectionC.mov(rbx, 0);
                sectionC.mov(__word_ptr[rax], bx); // length of string
                sectionC.mov(__word_ptr[rax + 2], (short)0x210); // maxlength of string
                sectionC.mov(__dword_ptr[rax + 8], rsp); // buffer location
            }
            else
            {
                sectionC.sub(rsp, 0x10); // string struct
                sectionC.mov(edi, esp);
                sectionC.sub(rsp, 0x210); // buffer space

                // setup the unicode string
                sectionC.mov(eax, edi);
                sectionC.mov(ebx, 0);
                sectionC.mov(__word_ptr[eax], bx); // length of string
                sectionC.mov(__word_ptr[eax + 2], (short)0x210); // maxlength of string
                sectionC.mov(__dword_ptr[eax + 4], esp); // buffer location
            }

            // now that we have a unicode string in di, we can begin working on the linking
            // using an unrolled loop over the imports, we will locate a library and store its pointer in rsi. 
            // then, we will write each of its thunks as shellcode pointers to rip, then we unconditionally jump over the shellcode to decode the pointer
            // the pointer will get stored encrypted in the rwx region
            // then we call 0x05; xchg [rsp], rax; mov rax, ptr_enc; xor rax, dec; xchg [rsp], rax; ret;

            idd = PEINFO.Is32Bit ? PEINFO.OptHeader32.ImportTable : PEINFO.OptHeader64.ImportTable;

            if (idd.VirtualAddress == 0)
            {
                goto endregionc;
            }

            IntPtr pImportTable = (IntPtr)(idd.VirtualAddress);

            int counter = 0;
            IMAGE_IMPORT_DESCRIPTOR iid = mapped.Skip(pImportTable.ToInt32() + (int)(Marshal.SizeOf(typeof(IMAGE_IMPORT_DESCRIPTOR)) * counter)).Take(Marshal.SizeOf(typeof(IMAGE_IMPORT_DESCRIPTOR))).ToArray().ToStruct<IMAGE_IMPORT_DESCRIPTOR>();
             
            byte[] randXor = new byte[4];
            r.NextBytes(randXor); // TODO: fix this. binary ninja just undoes the encryption lol
            int xor = BitConverter.ToInt32(randXor);

            List<KeyValuePair<int, int>> offStrPatch = new List<KeyValuePair<int, int>>();
            while (iid.Name != 0)
            {
                new byte[Marshal.SizeOf(typeof(IMAGE_IMPORT_DESCRIPTOR))].CopyTo(mapped, pImportTable.ToInt32() + (int)(Marshal.SizeOf(typeof(IMAGE_IMPORT_DESCRIPTOR)) * counter)); // erase import data

                // Get DLL
                string DllName = string.Empty;
                try
                {
                    DllName = mapped.String((int)iid.Name);
                }
                catch 
                {
                    Error("Failed to map an import descriptor...");
                }

                offStrPatch.Add(new KeyValuePair<int, int>((int)iid.Name, DllName.Length));

                // Loop imports
                if (DllName == string.Empty)
                {
                    goto linkImportsContinue;
                }

                if(DllName.Length > 260)
                {
                    Error($"{DllName} import path too long (>260)");
                }

                // Find DLL
        
                if (peFile.Is64Bit)
                {
                    sectionC.mov(rcx, __qword_ptr[rdi + 8]); // buffer in rcx
                    sectionC.mov(rbx, xor);
                }
                else
                {
                    sectionC.mov(ecx, __dword_ptr[edi + 4]); // buffer in ecx
                    sectionC.mov(ebx, xor);
                }

                // copy this string into the stack buffer space and update the strlen
                for(int i = 0; i < DllName.Length; i++)
                {
                    byte[] buff = new byte[4];
                    buff[0] = (byte)DllName[i];

                    if (i + 1 < DllName.Length)
                    {
                        buff[2] = (byte)DllName[i + 1];
                        i++;
                    }

                    int dw = BitConverter.ToInt32(buff, 0);
                    var emit = xor ^ dw;

                    if (peFile.Is64Bit)
                    {
                        sectionC.mov(rax, emit);
                        sectionC.xor(rax, rbx);
                        sectionC.xor(rbx, rax);
                        sectionC.mov(__qword_ptr[rcx], eax);
                        sectionC.add(rcx, 4);
                    }
                    else
                    {
                        sectionC.mov(eax, emit);
                        sectionC.xor(eax, ebx);
                        sectionC.xor(ebx, eax);
                        sectionC.mov(__qword_ptr[ecx], eax);
                        sectionC.add(rcx, 4);
                    }

                    xor ^= dw;
                }

                // write the correct length params
                if (peFile.Is64Bit)
                {
                    sectionC.mov(rax, 0);
                    sectionC.mov(__word_ptr[rcx], ax);
                    sectionC.add(rcx, 2);
                    sectionC.mov(__dword_ptr[rdi], (((int)(short)DllName.Length) << 32) | (0x210)); // size params for the struct {length, maxlen}
                }
                else
                {
                    sectionC.mov(eax, 0);
                    sectionC.mov(__word_ptr[ecx], ax);
                    sectionC.add(ecx, 2);
                    sectionC.mov(__dword_ptr[edi], (((int)(short)DllName.Length) << 32) | (0x210)); // size params for the struct {length, maxlen}
                }

                // call ldrloaddll
                if (peFile.Is64Bit)
                {
                    sectionC.sub(rsp, 8);
                    sectionC.mov(rcx, 0);
                    sectionC.mov(rdx, 0);
                    sectionC.mov(r8, rdi);
                    sectionC.mov(r9, rsp);
                    sectionC.sub(rsp, 0x28);

                    var alabel = sectionC.CreateLabel();
                    sectionC.call(alabel);
                    sectionC.Label(ref alabel);

                    sectionC.xchg(__[rsp], rax);
                    sectionC.add(rax, 0x1E);
                    sectionC.xchg(__[rsp], rax);
                    var blabel = sectionC.CreateLabel();
                    sectionC.call(blabel);
                    sectionC.Label(ref blabel);

                    sectionC.xchg(__[rsp], rax);
                    sectionC.mov(rax, __[rbp+0x8]);
                    sectionC.xchg(__[rsp], rax);
                    sectionC.ret();

                    sectionC.add(rsp, 0x28);

                    var lbl = sectionC.CreateLabel();
                    sectionC.Label(ref lbl);
                    sectionC.cmp(rax, 0);
                    sectionC.jne(lbl);

                    sectionC.mov(rax, __[rsp]); // [rsp] is hModule
                    sectionC.add(rsp, 8);

                    // we now have module in rax
                }
                else
                {
                    // TODO
                }

                // module in xax

                // alloc stack space for:
                // rsp+0x00 -> module
                // rsp+0x08 -> numExportedFuncs
                // rsp+0x10 -> exportedFuncAddress
                // rsp+0x18 -> namePointerTable
                // rsp+0x20 -> ordinalTable

                // need to grab critical info about the module and store in the stack for reuse
                if (peFile.Is64Bit)
                {
                    sectionC.sub(rsp, 6 * 0x8);
                    sectionC.xchg(__[rsp], rax); // store module at +0

                    // move 0x3c into rax
                    {
                        var lb = sectionC.CreateLabel();
                        sectionC.call(lb);
                        sectionC.Label(ref lb);
                        sectionC.add(rsp, 8);
                        sectionC.mov(rax, rsp);
                        sectionC.sub(rax, 8);
                        sectionC.xchg(__[rax], rax); // rax now has the address of label 'lb'

                        sectionC.mov(rbx, rax); // move the return pointer into rbx
                        sectionC.bswap(rbx); // flip the bytes in the register, moving 0000 to the last 4 bytes since its a pointer in usermode
                        sectionC.rol(rax, 16); // rotate the pointer left 2 bytes (same as above operation)
                        sectionC.neg(rax); // negate rax so that last two bytes are 0xFF
                        sectionC.xor(rax, rbx); // 0xFFFF ^ 0x0000 => 0xFFFF
                        sectionC.sub(rax, 2); // 0xFFFD
                        sectionC.movzx(rbx, al); // 0xFD
                        sectionC.shr(rax, 8); // 0xFF
                        sectionC.movzx(rcx, al); // 0xFF
                        sectionC.sub(rcx, rbx); // 0x2

                        // cl is now 2, we can shift 15 right two bits and its GG

                        sectionC.mov(rbx, 15); // 0b1111
                        sectionC.rol(rbx, cl); // 0b111100
                        sectionC.mov(rax, rbx); // 0x3C
                    }

                    sectionC.add(rax, __[rsp]); // add module+0x3C
                    sectionC.mov(ebx, __dword_ptr[rax]); // grab rva for new pe header
                    sectionC.add(rbx, __[rsp]); // grab physical address for new pe header

                    // mov 0x78 into rax by rotating left 1 bit
                    {
                        sectionC.rol(rax, 1); // 0b1111000 (0x78)
                    }

                    sectionC.add(rbx, rax); // module+peHeader+0x78 => LPRVAExportsTable
                    sectionC.mov(eax, __dword_ptr[rbx]); // RVAExportsTable
                    sectionC.add(rcx, __[rsp]); // module+RVAExportsTable

                    // change rax to 0b10100 from 0b1111000
                    {
                        sectionC.shr(rax, 1);
                        sectionC.xor(rax, 0x28);
                    }

                    sectionC.mov(rdx, rax); // 0x14
                    sectionC.add(rdx, rcx); // lpNumExportedFunctions
                    sectionC.mov(edx, __dword_ptr[rdx]); // numexportedfunctions (dw)
                    sectionC.mov(__dword_ptr[rsp + 0x8], edx); // save in stack

                    // change rax to 0x1C from 0x14
                    {
                        sectionC.add(rax, 0x8);
                    }

                    sectionC.mov(rdx, rax); // 0x1C
                    sectionC.add(rdx, rcx); // lpRVAExportedFunctions
                    sectionC.mov(edx, __dword_ptr[rdx]); // RVAExportedFunctions (dw)
                    sectionC.add(rdx, rcx); // lpExportedFunctions
                    sectionC.mov(__dword_ptr[rsp + 0x10], rdx); // save in stack

                    // change rax to 0x20 from 0x1C (0b11100 to 0b100000)
                    {
                        sectionC.shr(rax, 0x4);
                        sectionC.rol(rax, 0x5);
                    }

                    sectionC.mov(rdx, rax); // 0x20
                    sectionC.add(rdx, rcx); // lpRVANamePointerTable
                    sectionC.mov(edx, __dword_ptr[rdx]); // RVANamePointerTable (dw)
                    sectionC.add(rdx, rcx); // lpNamePointerTable
                    sectionC.mov(__dword_ptr[rsp + 0x18], rdx); // save in stack

                    // change rax to 0x24 from 0x20 (0b100000 to 0b100100)
                    {
                        sectionC.mov(rbx, rax);
                        sectionC.ror(rbx, 3);
                        sectionC.xor(rax, rbx);
                    }

                    sectionC.mov(rdx, rax); // 0x24
                    sectionC.add(rdx, rcx); // lpRVAOrdinalsTable
                    sectionC.mov(edx, __dword_ptr[rdx]); // RVAOrdinalsTable (dw)
                    sectionC.add(rdx, rcx); // lpOrdinalsTable
                    sectionC.mov(__dword_ptr[rsp + 0x20], rdx); // save in stack
                }
                else
                {
                    sectionC.sub(esp, 6 * 0x8);
                    sectionC.xchg(__[esp], eax); // store module at +0

                    // TODO 
                }

                
                // NOTE: rsi/esi still in use here so dont use for gp

                if(peFile.Is64Bit)
                {
                    IMAGE_THUNK_DATA64 oft_itd = new IMAGE_THUNK_DATA64();
                    for (int i = 0; true; i++)
                    {
                        oft_itd = mapped.Skip((int)(iid.OriginalFirstThunk + (uint)(i * sizeof(ulong)))).Take(8).ToArray().ToStruct<IMAGE_THUNK_DATA64>();
                        IntPtr ft_itd = (IntPtr)((UInt64)iid.FirstThunk + (UInt64)(i * (sizeof(UInt64))));
                        if (oft_itd.AddressOfData == 0)
                        {
                            break;
                        }

                        new byte[8].CopyTo(mapped, (int)(iid.OriginalFirstThunk + (uint)(i * sizeof(ulong)))); // delete oft_itd

                        if (oft_itd.AddressOfData < 0x8000000000000000) // !IMAGE_ORDINAL_FLAG64
                        {
                            uint pImpByName = (uint)((uint)oft_itd.AddressOfData + sizeof(UInt16));
                            string fnName = mapped.String((int)pImpByName);
                            offStrPatch.Add(new KeyValuePair<int, int>((int)pImpByName, fnName.Length));

                            uint fnHash = FNV1A_S(fnName); // hashed function name is what our searcher will use to locate the name of the export

                            // we then iterate the library exports and hash each function name to compare against ours.
                            
                            // prepare counter register to be 0. this will end up being ordinal index
                            sectionC.mov(rcx, 0);

                            // grab the base of the names table and store in rdx
                            sectionC.mov(rdx, __[rsp + 0x18]);

                            // grab number of exported functions and store in r10d
                            sectionC.mov(r10d, __dword_ptr[rsp + 0x8]);

                            // search for the name index
                            {
                                var searchhead = sectionC.CreateLabel();
                                var searchbreak = sectionC.CreateLabel();
                                sectionC.Label(ref searchhead);
                                sectionC.cmp(ecx, r10d); // index >= count ?
                                sectionC.jae(searchbreak);

                                // first, grab name physical address
                                sectionC.mov(rsi, __dword_ptr[rdx + rcx * 4]); // grab rva of string name
                                sectionC.add(rsi, __[rsp + 0]); // add image base

                                // then fnv1a_s hash the string
                                {
                                    sectionC.push(rcx);
                                    sectionC.push(r10);
                                    sectionC.push(rdx);

                                    sectionC.mov(rax, 0xF93EE401);
                                    sectionC.mov(r11, 0x100011B);
                                    var hashhead = sectionC.CreateLabel();
                                    var hashbreak = sectionC.CreateLabel();

                                    sectionC.Label(ref hashhead);
                                    sectionC.movzx(r10, __byte_ptr[rsi]);
                                    sectionC.cmp(r10, 0);
                                    sectionC.je(hashbreak); // *str == 0?

                                    sectionC.xor(rax, r10); // hash ^= *str
                                    sectionC.mul(r11); // hash *= prime
                                    sectionC.inc(rsi); // str++

                                    sectionC.jmp(hashhead);

                                    sectionC.Label(ref hashbreak);

                                    sectionC.mul(r11); // return hash * prime

                                    sectionC.pop(rdx);
                                    sectionC.pop(r10);
                                    sectionC.pop(rcx);
                                }

                                // compare hash against what we want. if valid, break. otherwise, continue.
                                sectionC.mov(r11, fnHash);
                                sectionC.cmp(r11, rax);
                                sectionC.je(searchbreak);
                                sectionC.inc(rcx);
                                sectionC.jmp(searchhead);

                                sectionC.Label(ref searchbreak);
                                sectionC.cmp(ecx, r10d); // index >= count ?
                                sectionC.jae(searchbreak);
                            }
                        }
                        else
                        {
                            ulong fOrdinal = oft_itd.AddressOfData & 0xFFFF;
                            sectionC.mov(rcx, fOrdinal);
                        }

                        // ok so we found the index of the name we wanted and the index is in ecx.

                        sectionC.mov(rdx, __[rsp + 0x20]); // grab the base of the ordinal table and store in rdx
                        sectionC.mov(rsi, 0); // zero rsi
                        sectionC.mov(si, __word_ptr[rdx + rcx * 2]); // grab ordinal and store in rsi
                        sectionC.mov(rdx, __[rsp + 0x10]); // grab the base of the exports table and store in rdx
                        sectionC.mov(eax, __dword_ptr[rdx + rsi * 4]); // rva of exported function
                        sectionC.add(rax, __[rsp + 0]); // physical address of exported function

                        // physical address in rax

                        // Write pointer

                        sectionB.mov(rbx, __[rbp + 0x20]);
                        sectionB.add(rbx, __[rbp + 0x00]);
                        sectionC.add(rbx, ft_itd.ToInt32()); // calc write offset

                        // sectionC.mov(__qword_ptr[rbx], eax);
                        // now we could do this, but if we do we risk import table reconstruction being trivial

                        // the theory instead is to place an absolute address to shellcode inlined here that will save an encrypted pointer in physical space (requires RWX)
                        // this encrypted pointer should then be xor decrypted (we only have to do a 6 byte key since its a 64 bit usermode pointer) and jumped to via a call5 retn jump
                        var skipTo = sectionC.CreateLabel();

                        int randXorEnc = r.Next() & 0xFFFFFF;

                        // encrypt pointer
                        sectionC.xor(rax, randXorEnc);

                        // grab rip
                        {
                            var lbl = sectionC.CreateLabel();
                            sectionC.call(lbl);
                            sectionC.Label(ref lbl);
                        }

                        sectionC.xchg(__[rsp], rcx); // put call-rip into rcx
                        sectionC.add(rsp, 8); // fix stack
                        sectionC.add(rcx, 0x32); // offset instruction address so that it points to the mov instruction
                        sectionC.mov(__[rcx], rax); // store encrypted pointer

                        // grab rip
                        {
                            var lbl = sectionC.CreateLabel();
                            sectionC.call(lbl);
                            sectionC.Label(ref lbl);
                        }

                        sectionC.xchg(__[rsp], rcx); // put call-rip into rcx
                        sectionC.add(rsp, 8); // fix stack
                        sectionC.add(rcx, 0x30); // add size of preamble
                        sectionC.mov(__[rbx], rcx); // write location of shellcode
                        sectionC.jmp(skipTo); // skip shellcode

                        sectionC.ud2(); // mess with disassemblers
                        { 
                            // push to stack
                            var lbl = sectionC.CreateLabel();
                            sectionC.call(lbl);
                            sectionC.Label(ref lbl);
                        }
                        sectionC.xchg(__[rsp], rax); // save rax, grab return address
                        sectionC.mov(rax, 0xFFFFFFFFFFFFFFFF); // this gets replaced with the actual linked memory address encrypted with xor
                        sectionC.xor(rax, randXorEnc); // decrypt the address
                        sectionC.xchg(__[rsp], rax); // replace return address and restore rax
                        sectionC.ret(); // jump to the linked function
                        sectionC.Label(ref skipTo); // end of shellcode
                    }
                }
                else
                {
                    // TODO
                }

                // restore stack
                if(peFile.Is64Bit)
                {
                    sectionC.add(rsp, 6 * 0x8);
                }
                else
                {
                    sectionC.add(esp, 6 * 0x8);
                }

                //// Loop thunks
                //if (PEINFO.Is32Bit)
                //{
                //    IMAGE_THUNK_DATA32 oft_itd = new IMAGE_THUNK_DATA32();
                //    for (int i = 0; true; i++)
                //    {
                //        oft_itd = moduleRemote.Skip((int)(iid.OriginalFirstThunk + (UInt32)(i * (sizeof(UInt32))))).Take(4).ToArray().ToStruct<IMAGE_THUNK_DATA32>();
                //        IntPtr ft_itd = (IntPtr)((UInt64)iid.FirstThunk + (UInt64)(i * (sizeof(UInt32))));
                //        if (oft_itd.AddressOfData == 0)
                //        {
                //            break;
                //        }

                //        if (oft_itd.AddressOfData < 0x80000000) // !IMAGE_ORDINAL_FLAG32
                //        {
                //            uint pImpByName = (uint)((uint)oft_itd.AddressOfData + sizeof(UInt16));

                //            var pFunc = GetProcAddress(sModule.ModuleName, moduleRemote.String((int)pImpByName));

                //            // Write ProcAddress
                //            BitConverter.GetBytes((int)pFunc).CopyTo(moduleRemote, ft_itd.ToInt32());
                //        }
                //        else
                //        {
                //            ulong fOrdinal = oft_itd.AddressOfData & 0xFFFF;
                //            var pFunc = GetModuleExportAddress(sModule.ModuleName, (short)fOrdinal);

                //            // Write ProcAddress
                //            BitConverter.GetBytes((int)pFunc).CopyTo(moduleRemote, ft_itd.ToInt32());
                //        }
                //    }
                //}

                linkImportsContinue:
                counter++;
                iid = mapped.Skip(pImportTable.ToInt32() + (int)(Marshal.SizeOf(typeof(IMAGE_IMPORT_DESCRIPTOR)) * counter)).Take(Marshal.SizeOf(typeof(IMAGE_IMPORT_DESCRIPTOR))).ToArray().ToStruct<IMAGE_IMPORT_DESCRIPTOR>();
            }

            // wipe the data of the import descriptors and the names
            foreach(var dllname in offStrPatch)
            {
                new byte[dllname.Value].CopyTo(mapped, dllname.Key);
            }

            // TODO: wipe exports table
            endregionc:

            if (peFile.Is64Bit)
            {
                sectionC.add(rsp, 0x220); // restore stack
            }
            else
            {
                sectionC.add(esp, 0x220); // restore stack

            }
            #endregion


            // TODO
            // C[ ] generate assembly that links SEH (NOTE: obfuscation will break it but we assume obfuscation and shellcodifier are two different components of the program)
            // C[ ] generate assembly that initializes TLS
            // C[ ] TODO: initialize CFG
            // [ ] destroy C section
            // [ ] call entrypoint
            // [ ] call optional start routine (1 arg - RCX)
            // [ ] clear saved stack area (mov xsp, xbp; pop in order...)
            // [ ] restore all registers and return 

            // final serialization procedure
            #region SERIALIZER

            var stream = new MemoryStream();
            prologue.Assemble(new StreamCodeWriter(stream), 0);
            shellcode.AddRange(stream.ToArray());
            stream.Dispose();

            stream = new MemoryStream();
            sectionA.Assemble(new StreamCodeWriter(stream), 0);
            sectionABytecode.AddRange(stream.ToArray());
            stream.Dispose();

            stream = new MemoryStream();
            sectionB.Assemble(new StreamCodeWriter(stream), 0);
            sectionBBytecode.AddRange(stream.ToArray());
            stream.Dispose();

            stream = new MemoryStream();
            sectionC.Assemble(new StreamCodeWriter(stream), 0);
            sectionCBytecode.AddRange(stream.ToArray());
            stream.Dispose();

            // TODO: update this every time sections are added
            // note that this is also where we would pack data using intermediate code
            int finalSize = shellcode.Count + 128 + sectionABytecode.Count + sectionBBytecode.Count + sectionCBytecode.Count;
            finalSize += finalSize % 64;

            var sectionSizeSetter = new Assembler(peFile.Is64Bit ? 64 : 32);
            sectionSizeSetter.mov(__dword_ptr[rbp + 0x20], finalSize);

            stream = new MemoryStream();
            sectionSizeSetter.Assemble(new StreamCodeWriter(stream), 0);
            shellcode.AddRange(stream.ToArray());
            stream.Dispose();

            shellcode.AddRange(sectionABytecode);
            shellcode.AddRange(sectionBBytecode);
            shellcode.AddRange(sectionCBytecode);
            shellcode.AddRange(new byte[finalSize - shellcode.Count]);

            #endregion

            List<byte> finalData = new List<byte>();
            finalData.AddRange(shellcode);
            finalData.AddRange(mapped);

            File.WriteAllBytes(output, finalData.ToArray());
        }

        static void Error(string msg)
        {
            Console.WriteLine(msg);
            Environment.Exit(1);
        }

        private static ulong RotateRight(ulong x, int n)
        {
            return (((x) >> (n)) | ((x) << (64 - (n))));
        }

        private static ulong RotateLeft(ulong x, int n)
        {
            return (((x) << (n)) | ((x) >> (64 - (n))));
        }

        private static uint RotateRight32(uint x, int n)
        {
            return (((x) >> (n)) | ((x) << (32 - (n))));
        }

        private static uint RotateLeft32(uint x, int n)
        {
            return (((x) << (n)) | ((x) >> (32 - (n))));
        }


        // use fnv32 for function names.
        // offset basis: 0xf93ee401
        // fnv prime: 0x100011B
        private static uint FNV1A_S(string s)
        {
            uint hash = 0xf93ee401;

            for(int i = 0; i < s.Length; i++)
            {
                hash ^= (byte)s[i];
                hash *= 0x100011B;
            }

            return hash * 0x100011B;
        }

        private enum StatefulOperators
        {
            SFO_SINGLE_ROR,
            SFO_SINGLE_FIRST = SFO_SINGLE_ROR,
            SFO_SINGLE_ROL,
            SFO_SINGLE_SHL,
            SFO_SINGLE_SHR,
            SFO_SINGLE_BSWAP,
            SFO_SINGLE_BITNEGATE,
            SFO_DOUBLE_ADD,
            SFO_DOUBLE_FIRST = SFO_DOUBLE_ADD,
            SFO_SINGLE_COUNT = SFO_DOUBLE_FIRST,
            SFO_DOUBLE_SUB,
            SFO_DOUBLE_MULT,
            SFO_DOUBLE_XOR,
            SFO_DOUBLE_OR,
            SFO_DOUBLE_COUNT
        }
    }
}
