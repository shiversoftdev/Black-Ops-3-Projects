using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace gsc2c
{
    internal class PrimeExport
    {
        /* Function Generated Export anatomy:
         
            VM_OP_SafeCreate or VM_OP_CheckClearParams
            VM_OP_ExecuteFN (64 bit unique function ID)
                -- begins native execution of the c code from the gsc
            
            ASM c_fn_gen(<p_opcode_params>) (NOTE: this should globify the asm, we should try not to have any distinguishable functions)
                - lets take any repeated code and automatically push into jump combos
            
            for waits/endons/etc:
                
                reserve a singular wait/waittill/etc opcode in data to use for instruction pointer, followed by VM_OP_ReturnToNative
            
            for OP_End/OP_Return:
                
                reserve these opcodes and move instruction pointer to them when necessary

            for OP_FuncCall:
                
                imports table will construct an array of all these function calls and emit them in the binary under a stub function
            
            for jumps:
                 call the opcode and inspect where the jump goes, then reorient the native pointer to its correct location based on the jump conditions (binary whether it jumps or doesnt jump!)
         */
        public uint HashName;

    }
}
