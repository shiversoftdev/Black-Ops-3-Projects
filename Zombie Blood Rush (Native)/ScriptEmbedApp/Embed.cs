﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Diagnostics;
using System.IO.Compression;

namespace ScriptEmbedApp
{
    class Embed
    {
        private const ulong TX_MASK = 0x7F53EB31FCCBA841;
        private const int XOR_KEY = 0x6E;
        private const ushort VM_CODEMASK = 0x14E7;
        private const int BUFFER_SIZE = 2000000;
        private const int TABLE_SIZE = 0x1000;
        private const int TX_SIZE = 0x1000;
        private const string TargetScript = "scripts/shared/duplicaterender_mgr.gsc";
        private const string SECTION = ".8yMPxCG";
        private const bool USE_MASKING = false;

        private static ulong t8s64(string input)
        {
            return t8s64(Encoding.ASCII.GetBytes(input.ToLower()));
        }

        private static ulong t8s64(byte[] bytes, ulong fnv64Offset = 14695981039346656037, ulong fnv64Prime = 0x100000001b3)
        {
            ulong hash = fnv64Offset;

            for (var i = 0; i < bytes.Length; i++)
            {
                hash = hash ^ bytes[i];
                hash *= fnv64Prime;
            }

            return 0x7FFFFFFFFFFFFFFF & hash;
        }

        private static short[] Slots = new short[] { 0x17, 0x1A, 0x1D, 0x1F, 0x21, 0x29, 0x2F, 0x32, 0x34, 0x37, 0x38, 0x3B, 0x3D, 0x40, 0x48, 0x51, 0x52, 0x55, 0x56, 0x58, 0x5C, 0x5E, 0x65, 0x6D, 0x6E, 0x6F, 0x71, 0x73, 0x74, 0x7B, 0x7C, 0x7F, 0x80, 0x81, 0x85, 0x87, 0x88, 0x8D, 0x8E, 0x91, 0x92, 0x93, 0x94, 0x97, 0x99, 0x9A, 0xA4, 0xA5, 0xAC, 0xB5, 0xB8, 0xB9, 0xBA, 0xBD, 0xC3, 0xC5, 0xCB, 0xCD, 0xCF, 0xD1, 0xD3, 0xD6, 0xDE, 0xE1, 0xE2, 0xE6, 0xE7, 0xE8, 0xEE, 0xF3, 0xF8, 0xF9, 0xFA, 0xFD, 0x101, 0x10A, 0x10F, 0x113, 0x114, 0x119, 0x11E, 0x11F, 0x120, 0x121, 0x127, 0x129, 0x12A, 0x12D, 0x130, 0x134, 0x135, 0x138, 0x139, 0x13C, 0x142, 0x148, 0x14D, 0x151, 0x154, 0x159, 0x15C, 0x15D, 0x160, 0x165, 0x168, 0x169, 0x16F, 0x171, 0x175, 0x177, 0x17B, 0x17C, 0x17D, 0x17E, 0x181, 0x183, 0x184, 0x186, 0x187, 0x189, 0x18B, 0x18C, 0x18D, 0x19C, 0x19E, 0x1A0, 0x1A1, 0x1AD, 0x1B1, 0x1B3, 0x1B4, 0x1B8, 0x1B9, 0x1BC, 0x1BD, 0x1BE, 0x1C1, 0x1C2, 0x1C3, 0x1C6, 0x1CA, 0x1CD, 0x1CE, 0x1CF, 0x1D0, 0x1D7, 0x1DC, 0x1DE, 0x1E1, 0x1E7, 0x1EB, 0x1EE, 0x1F1, 0x1F2, 0x1F3, 0x1F4, 0x1F5, 0x1F7, 0x1F9, 0x1FB, 0x1FC, 0x1FE, 0x200, 0x201, 0x202, 0x217, 0x218, 0x220, 0x221, 0x224, 0x227, 0x239, 0x23A, 0x23C, 0x23F, 0x240, 0x24B, 0x250, 0x251, 0x252, 0x254, 0x257, 0x258, 0x259, 0x25B, 0x25C, 0x25D, 0x262, 0x263, 0x269, 0x26A, 0x26D, 0x26F, 0x270, 0x275, 0x279, 0x27B, 0x27E, 0x283, 0x286, 0x28A, 0x28C, 0x28E, 0x28F, 0x290, 0x293, 0x297, 0x2A2, 0x2A5, 0x2A6, 0x2A7, 0x2AF, 0x2B4, 0x2B8, 0x2B9, 0x2BC, 0x2C8, 0x2C9, 0x2CB, 0x2D0, 0x2D2, 0x2D3, 0x2D5, 0x2D8, 0x2D9, 0x2DD, 0x2E1, 0x2E3, 0x2EA, 0x2EB, 0x2EC, 0x2ED, 0x2F8, 0x2F9, 0x2FB, 0x2FE, 0x2FF, 0x302, 0x305, 0x306, 0x30C, 0x310, 0x312, 0x319, 0x31D, 0x31E, 0x328, 0x331, 0x334, 0x337, 0x338, 0x33A, 0x33D, 0x33E, 0x348, 0x34A, 0x34C, 0x355, 0x358, 0x35A, 0x35C, 0x35D, 0x360, 0x361, 0x364, 0x365, 0x36A, 0x36E, 0x373, 0x374, 0x376, 0x379, 0x37B, 0x37C, 0x37D, 0x37E, 0x37F, 0x380, 0x381, 0x384, 0x38C, 0x393, 0x395, 0x398, 0x39D, 0x39F, 0x3A0, 0x3A4, 0x3B1, 0x3B3, 0x3B4, 0x3B6, 0x3BE, 0x3C0, 0x3C2, 0x3C4, 0x3C9, 0x3CA, 0x3CB, 0x3CE, 0x3D9, 0x3DD, 0x3E1, 0x3E5, 0x3E8, 0x3E9, 0x3EA, 0x3EC, 0x3F0, 0x3F1, 0x3F7, 0x3F8, 0x3F9, 0x400, 0x408, 0x40D, 0x411, 0x412, 0x413, 0x414, 0x415, 0x418, 0x41B, 0x41C, 0x41F, 0x422, 0x42B, 0x431, 0x432, 0x435, 0x43B, 0x43D, 0x43E, 0x43F, 0x440, 0x443, 0x447, 0x44A, 0x44E, 0x451, 0x454, 0x456, 0x458, 0x460, 0x46A, 0x46C, 0x46D, 0x46E, 0x470, 0x471, 0x473, 0x475, 0x47B, 0x47C, 0x482, 0x484, 0x489, 0x493, 0x495, 0x497, 0x49A, 0x49C, 0x4A0, 0x4A2, 0x4A3, 0x4A4, 0x4A7, 0x4A9, 0x4AB, 0x4AC, 0x4AD, 0x4AE, 0x4AF, 0x4B5, 0x4B7, 0x4BA, 0x4BE, 0x4C2, 0x4C4, 0x4CA, 0x4CB, 0x4CF, 0x4D4, 0x4D9, 0x4E0, 0x4E1, 0x4E6, 0x4E7, 0x4E9, 0x4EC, 0x4EE, 0x4F1, 0x4F5, 0x4F8, 0x4F9, 0x4FB, 0x4FF, 0x501, 0x509, 0x50D, 0x511, 0x51A, 0x51E, 0x51F, 0x521, 0x522, 0x528, 0x52B, 0x52E, 0x532, 0x536, 0x53E, 0x53F, 0x543, 0x544, 0x546, 0x547, 0x549, 0x54C, 0x551, 0x558, 0x559, 0x55F, 0x563, 0x564, 0x569, 0x56B, 0x56C, 0x570, 0x57A, 0x57C, 0x57E, 0x582, 0x586, 0x588, 0x58C, 0x58F, 0x591, 0x593, 0x598, 0x599, 0x59A, 0x59B, 0x59C, 0x5A1, 0x5A4, 0x5A5, 0x5A9, 0x5AD, 0x5B1, 0x5B7, 0x5BC, 0x5BE, 0x5C3, 0x5C4, 0x5C9, 0x5CB, 0x5D1, 0x5D4, 0x5D7, 0x5DD, 0x5EA, 0x5EB, 0x5ED, 0x5EF, 0x5F0, 0x5F1, 0x5F2, 0x5F9, 0x604, 0x607, 0x609, 0x60B, 0x60E, 0x611, 0x612, 0x618, 0x61A, 0x61B, 0x61F, 0x622, 0x624, 0x625, 0x627, 0x62A, 0x62F, 0x632, 0x635, 0x636, 0x638, 0x63E, 0x641, 0x644, 0x646, 0x649, 0x64C, 0x64E, 0x651, 0x654, 0x65B, 0x663, 0x665, 0x666, 0x667, 0x66A, 0x66F, 0x673, 0x676, 0x677, 0x67B, 0x67D, 0x681, 0x687, 0x68A, 0x690, 0x693, 0x694, 0x697, 0x69D, 0x6A0, 0x6A1, 0x6A2, 0x6A4, 0x6A6, 0x6A8, 0x6AB, 0x6AE, 0x6B1, 0x6B2, 0x6B6, 0x6B8, 0x6B9, 0x6BE, 0x6C7, 0x6C8, 0x6CA, 0x6CF, 0x6D1, 0x6D3, 0x6D5, 0x6D6, 0x6D9, 0x6E0, 0x6E3, 0x6E6, 0x6E7, 0x6E9, 0x6ED, 0x6F0, 0x6F4, 0x6F7, 0x6F8, 0x6FC, 0x6FD, 0x700, 0x707, 0x70B, 0x713, 0x714, 0x71B, 0x723, 0x724, 0x72A, 0x72C, 0x72E, 0x730, 0x737, 0x73A, 0x73C, 0x73E, 0x73F, 0x741, 0x745, 0x747, 0x748, 0x74A, 0x74C, 0x750, 0x751, 0x752, 0x759, 0x75A, 0x75E, 0x760, 0x761, 0x765, 0x766, 0x76B, 0x770, 0x772, 0x773, 0x77E, 0x780, 0x782, 0x786, 0x78A, 0x78B, 0x78C, 0x793, 0x7A2, 0x7A4, 0x7AC, 0x7B5, 0x7B6, 0x7B7, 0x7B8, 0x7B9, 0x7BB, 0x7BC, 0x7BF, 0x7C6, 0x7C7, 0x7CA, 0x7CB, 0x7D9, 0x7DA, 0x7DE, 0x7E0, 0x7E1, 0x7E4, 0x7E7, 0x7EC, 0x7EF, 0x7F5, 0x7FB, 0x7FF, 0x801, 0x804, 0x80A, 0x80E, 0x80F, 0x812, 0x816, 0x818, 0x81C, 0x820, 0x821, 0x823, 0x824, 0x826, 0x82A, 0x830, 0x832, 0x834, 0x838, 0x83B, 0x83C, 0x83D, 0x841, 0x843, 0x846, 0x847, 0x852, 0x855, 0x85C, 0x85D, 0x85E, 0x85F, 0x862, 0x863, 0x866, 0x867, 0x869, 0x86A, 0x86B, 0x86C, 0x86F, 0x875, 0x877, 0x878, 0x87E, 0x880, 0x881, 0x883, 0x884, 0x886, 0x888, 0x892, 0x89A, 0x89B, 0x89D, 0x89E, 0x8A2, 0x8A5, 0x8AE, 0x8AF, 0x8B1, 0x8B2, 0x8B5, 0x8B9, 0x8BB, 0x8C1, 0x8C4, 0x8C6, 0x8CA, 0x8CE, 0x8D0, 0x8D2, 0x8D4, 0x8D5, 0x8D8, 0x8D9, 0x8DA, 0x8DD, 0x8E0, 0x8ED, 0x8F1, 0x8F3, 0x8F8, 0x8FB, 0x8FD, 0x8FF, 0x900, 0x901, 0x904, 0x906, 0x907, 0x908, 0x90A, 0x90C, 0x90D, 0x914, 0x915, 0x918, 0x91B, 0x91F, 0x925, 0x92B, 0x932, 0x936, 0x937, 0x939, 0x93A, 0x93D, 0x942, 0x944, 0x947, 0x94C, 0x952, 0x956, 0x95C, 0x95D, 0x960, 0x962, 0x965, 0x974, 0x976, 0x977, 0x97A, 0x97C, 0x97E, 0x981, 0x989, 0x991, 0x996, 0x999, 0x99C, 0x99D, 0x9A1, 0x9A2, 0x9A6, 0x9AB, 0x9AC, 0x9B6, 0x9BE, 0x9BF, 0x9C9, 0x9CA, 0x9CF, 0x9D0, 0x9D1, 0x9D2, 0x9D6, 0x9DA, 0x9DE, 0x9E0, 0x9E1, 0x9E3, 0x9E4, 0x9E5, 0x9E6, 0x9E7, 0x9F9, 0x9FB, 0x9FD, 0x9FE, 0x9FF, 0xA02, 0xA04, 0xA05, 0xA06, 0xA0F, 0xA14, 0xA17, 0xA19, 0xA1A, 0xA22, 0xA23, 0xA27, 0xA28, 0xA2A, 0xA32, 0xA33, 0xA37, 0xA3C, 0xA3D, 0xA48, 0xA4B, 0xA4D, 0xA4F, 0xA50, 0xA54, 0xA5B, 0xA5F, 0xA61, 0xA62, 0xA68, 0xA69, 0xA6A, 0xA6C, 0xA6E, 0xA72, 0xA78, 0xA7B, 0xA80, 0xA81, 0xA84, 0xA85, 0xA87, 0xA91, 0xAA7, 0xAA8, 0xAAC, 0xAB6, 0xABD, 0xABE, 0xAC0, 0xAC5, 0xAC8, 0xAC9, 0xACA, 0xACC, 0xACE, 0xACF, 0xAD1, 0xAD4, 0xAD6, 0xAD9, 0xADA, 0xADF, 0xAE0, 0xAE3, 0xAE4, 0xAE6, 0xAE9, 0xAED, 0xAEE, 0xAF5, 0xAFA, 0xAFB, 0xB01, 0xB02, 0xB11, 0xB12, 0xB14, 0xB15, 0xB1E, 0xB1F, 0xB20, 0xB26, 0xB2C, 0xB2D, 0xB32, 0xB37, 0xB3E, 0xB40, 0xB41, 0xB44, 0xB46, 0xB48, 0xB49, 0xB4F, 0xB50, 0xB5B, 0xB63, 0xB65, 0xB6B, 0xB6D, 0xB6F, 0xB72, 0xB73, 0xB77, 0xB7A, 0xB7F, 0xB85, 0xB88, 0xB8A, 0xB8C, 0xB91, 0xB92, 0xB93, 0xB9B, 0xB9F, 0xBA3, 0xBA6, 0xBAD, 0xBB0, 0xBB3, 0xBB9, 0xBBA, 0xBBC, 0xBBE, 0xBC3, 0xBC7, 0xBD7, 0xBD8, 0xBDA, 0xBDB, 0xBE1, 0xBE2, 0xBE3, 0xBE6, 0xBE8, 0xBE9, 0xBEF, 0xBF6, 0xBFC, 0xBFE, 0xC00, 0xC02, 0xC0A, 0xC0D, 0xC11, 0xC13, 0xC15, 0xC19, 0xC1E, 0xC1F, 0xC21, 0xC23, 0xC29, 0xC2E, 0xC31, 0xC36, 0xC3A, 0xC3B, 0xC41, 0xC42, 0xC48, 0xC4C, 0xC53, 0xC54, 0xC59, 0xC63, 0xC66, 0xC68, 0xC69, 0xC6B, 0xC71, 0xC76, 0xC79, 0xC7C, 0xC7E, 0xC80, 0xC82, 0xC84, 0xC88, 0xC8D, 0xC90, 0xC94, 0xC96, 0xC97, 0xC99, 0xC9E, 0xC9F, 0xCA0, 0xCA1, 0xCA6, 0xCAB, 0xCAF, 0xCB1, 0xCB5, 0xCB6, 0xCB9, 0xCBB, 0xCBE, 0xCC1, 0xCC4, 0xCC6, 0xCC7, 0xCC8, 0xCCB, 0xCCE, 0xCD1, 0xCD2, 0xCD3, 0xCDA, 0xCDC, 0xCDF, 0xCE0, 0xCE4, 0xCE5, 0xCE9, 0xCEC, 0xCED, 0xCF0, 0xCF6, 0xCFA, 0xD01, 0xD02, 0xD03, 0xD08, 0xD09, 0xD0B, 0xD0C, 0xD10, 0xD11, 0xD13, 0xD14, 0xD15, 0xD16, 0xD1C, 0xD1E, 0xD1F, 0xD20, 0xD22, 0xD23, 0xD25, 0xD26, 0xD2C, 0xD2D, 0xD30, 0xD33, 0xD34, 0xD35, 0xD3C, 0xD3D, 0xD41, 0xD42, 0xD44, 0xD4A, 0xD4D, 0xD52, 0xD53, 0xD54, 0xD58, 0xD59, 0xD5C, 0xD5F, 0xD61, 0xD65, 0xD67, 0xD6A, 0xD6C, 0xD6E, 0xD70, 0xD71, 0xD74, 0xD79, 0xD7A, 0xD7C, 0xD7E, 0xD81, 0xD85, 0xD88, 0xD8A, 0xD8C, 0xD8E, 0xD8F, 0xD90, 0xD93, 0xD95, 0xD96, 0xD97, 0xD99, 0xD9A, 0xD9B, 0xD9C, 0xD9F, 0xDA5, 0xDA7, 0xDA9, 0xDAA, 0xDB1, 0xDB2, 0xDB3, 0xDB4, 0xDBB, 0xDBC, 0xDC2, 0xDC4, 0xDC7, 0xDC8, 0xDDA, 0xDDE, 0xDDF, 0xDE3, 0xDE6, 0xDE8, 0xDED, 0xDF0, 0xDF1, 0xDF2, 0xDF4, 0xDF5, 0xDF6, 0xDF7, 0xDF9, 0xDFB, 0xE02, 0xE03, 0xE09, 0xE0B, 0xE0D, 0xE0E, 0xE0F, 0xE12, 0xE1C, 0xE1E, 0xE22, 0xE26, 0xE2C, 0xE33, 0xE44, 0xE47, 0xE48, 0xE49, 0xE4E, 0xE50, 0xE5B, 0xE60, 0xE65, 0xE66, 0xE67, 0xE6B, 0xE6C, 0xE6D, 0xE6E, 0xE70, 0xE72, 0xE73, 0xE74, 0xE77, 0xE7A, 0xE7F, 0xE81, 0xE83, 0xE85, 0xE89, 0xE8B, 0xE8D, 0xE8E, 0xE8F, 0xE90, 0xE93, 0xE95, 0xE98, 0xEA3, 0xEA7, 0xEAC, 0xEB0, 0xEB1, 0xEB2, 0xEB7, 0xEBE, 0xEC1, 0xEC3, 0xEC7, 0xEC8, 0xECB, 0xECC, 0xECD, 0xECF, 0xEDE, 0xEE5, 0xEE7, 0xEE9, 0xEEA, 0xEEB, 0xEF3, 0xEFE, 0xF06, 0xF0F, 0xF10, 0xF14, 0xF15, 0xF16, 0xF18, 0xF25, 0xF29, 0xF2A, 0xF2D, 0xF2F, 0xF30, 0xF32, 0xF34, 0xF36, 0xF38, 0xF3B, 0xF3C, 0xF42, 0xF43, 0xF45, 0xF4E, 0xF4F, 0xF52, 0xF59, 0xF5D, 0xF60, 0xF64, 0xF66, 0xF6B, 0xF6C, 0xF6D, 0xF6E, 0xF76, 0xF78, 0xF79, 0xF7E, 0xF80, 0xF81, 0xF8A, 0xF8C, 0xF91, 0xF94, 0xF95, 0xF98, 0xF9A, 0xF9B, 0xF9C, 0xFAB, 0xFAC, 0xFB1, 0xFB2, 0xFB3, 0xFBD, 0xFBE, 0xFC5, 0xFC6, 0xFCB, 0xFCF, 0xFD7, 0xFDC, 0xFDD, 0xFDE, 0xFDF, 0xFE1, 0xFE3, 0xFE4, 0xFE9, 0xFEA, 0xFEB, 0xFEC, 0xFF1, 0xFF2, 0xFF4, 0xFF5, 0xFF6, 0xFF7, 0xFF8, 0xFF9, 0xFFB, 0xFFD, 0xFFF };
        // real, fake
        private static Dictionary<short, short> RemappedCodes = new Dictionary<short, short>();
        private static HashSet<short> OpcodeValues = new HashSet<short>();
        static (byte[] script, byte[] map) MaskScript(byte[] buffer, byte[] omap)
        {
            if(!USE_MASKING)
            {
                return (buffer, null);
            }
            (byte[] script, byte[] map) results = (buffer, null);
            int realBufStart = 0;
            while(buffer[realBufStart] != 0x80 || buffer[realBufStart + 1] != 0x47 || buffer[realBufStart + 2] != 0x53)
            {
                realBufStart += 0x10;
            }

            Dictionary<int, short> OpcodeLocations = new Dictionary<int, short>();
            for(int i = 0; i < omap.Length / 4; i++)
            {
                int pos = BitConverter.ToInt32(omap, i * 4);
                short code = BitConverter.ToInt16(buffer, realBufStart + pos);
                OpcodeLocations[realBufStart + pos] = code;
                OpcodeValues.Add(code);
            }

            results.map = Randomize();
            foreach(var kvp in OpcodeLocations)
            {
                BitConverter.GetBytes(GetMasked(kvp.Value)).CopyTo(buffer, kvp.Key);
            }

            return results;
        }

        internal static byte[] Randomize()
        {
            List<byte> data = new List<byte>();
            List<short> Numbers = Slots.ToList();
            List<int> NewNumbers = Enumerable.Range(0, 0x1000).ToList();
            short[] Reversed = new short[0x1000];
            Random r = new Random();

            foreach (var opcode in OpcodeValues)
            {
                short rval = (short)opcode;
                if (IsBlacklisted(opcode))
                {
                    Reversed[rval] = rval;
                    RemappedCodes[rval] = rval;
                    continue;
                }
                var index = r.Next(Numbers.Count);
                var val = Numbers[index];
                Numbers.RemoveAt(index);
                Reversed[val] = rval;
                NewNumbers.Remove(val);
                RemappedCodes[rval] = val;
            }

            // fills empty slots with bullshit to make sure that its not easy to identify our opcodes in the array
            for (int i = 0; i < Reversed.Length; i++)
            {
                var index = r.Next(NewNumbers.Count);
                var val = NewNumbers[index];
                if (Reversed[i] == 0)
                {
                    Reversed[i] = (short)val;
                    NewNumbers.RemoveAt(index);
                }
                data.AddRange(BitConverter.GetBytes(Reversed[i]));
            }

            return data.ToArray();
        }
        
        static bool IsBlacklisted(short opcode)
        {
            switch (opcode)
            {
                case 0xd5:
                case 0x4e:
                case 0xf0:
                case 0x62:
                case 0x10:
                case 0x46:
                case 0xa3:
                    return true;
            }
            return false;
        }

        static short GetMasked(short value)
        {
            return RemappedCodes[value];
        }

        static void Main(string[] args)
        {
            string dll_path = null;
            string script_path = null;
            string map_path = null;
            if (args.Length < 1 || !File.Exists(dll_path = args[0]))
            {
                Error("First argument must be the dll to embed a script into");
            }
            if(args.Length < 2 || !File.Exists(script_path = args[1]))
            {
                Error("Second argument must be the script to embed in the dll");
            }
            if (args.Length < 3 || !File.Exists(map_path = args[2]))
            {
                Error("Third argument must be the script opcode omap to use for the dll");
            }
            if (args.Length < 4)
            {
                Error("Fourth argument must be the output file path");
            }

            byte[] dll_buf = File.ReadAllBytes(dll_path);
            byte[] scriptData = File.ReadAllBytes(script_path);
            byte[] mapData = File.ReadAllBytes(map_path);

            var results = MaskScript(scriptData, mapData);
            mapData = results.map;

            // Protect script buffer
            for (int i = 0; i < scriptData.Length; i++) scriptData[i] ^= XOR_KEY;

            Random r = new Random();
            int dwFile = 0x100;
            bool stop_embedding = false;
            while (dll_buf[dwFile] != SECTION[0] || Encoding.ASCII.GetString(dll_buf, dwFile, 8) != SECTION)
            {
                dwFile += 8;
                if(dwFile >= dll_buf.Length)
                {
                    stop_embedding = true;
                    Console.WriteLine("WARNING: Script embed section not present. Script will not be embedded!");
                    break;
                }
            }

            if(!stop_embedding)
            {
                // generate a new section name
                byte[] sectionNewName = new byte[8];
                Encoding.ASCII.GetBytes(".data1").CopyTo(sectionNewName, 0);
                sectionNewName.CopyTo(dll_buf, dwFile);

                // generate a new random virtual size for the section
                int SectionVSize = BitConverter.ToInt32(dll_buf, dwFile + 0x8);
                int SectionRSize = BitConverter.ToInt32(dll_buf, dwFile + 0x10);
                int dwBuildSection = BitConverter.ToInt32(dll_buf, dwFile + 0x14);
                // BitConverter.GetBytes(r.Next(SectionVSize, SectionRSize)).CopyTo(dll_buf, dwFile + 0x8);

                // Write dll name to buffer
                string dllNewName = new string(Enumerable.Repeat("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", 8).Select(s => s[r.Next(s.Length)]).ToArray()) + ".dll";
                dllNewName.CopyTo(dll_buf, 0x60);
                dll_buf[0x6C] = 0;

                // iterate the rest of the dll, until we hit the build section
                while (dwFile < dwBuildSection)
                {
                    // find a target replacement and replace it
                    while (dll_buf[dwFile] != SECTION[0] && dwFile < dwBuildSection) dwFile++;
                    string cs = Encoding.ASCII.GetString(dll_buf, dwFile, 8);
                    if (cs == SECTION)
                    {
                        sectionNewName.CopyTo(dll_buf, dwFile);
                        if (dll_buf[dwFile + 8] == '$') dll_buf[dwFile + 8] = 0;
                        dwFile += 8;
                    }
                    else dwFile++;
                }

                dwFile = dwBuildSection;

                // delete the dummy proc name
                BitConverter.GetBytes(0L).CopyTo(dll_buf, dwFile + 0x10);
                BitConverter.GetBytes(0L).CopyTo(dll_buf, dwFile + 0x18);

                // we place the script at its location
                scriptData.CopyTo(dll_buf, dwFile + 0x20);

                // create txconfig and place it at its location
                var tx = txconfig.TX_VM_1C();
                txconfig.AddTXField(tx, txconfig.TX_FIELDS.TX_IncludeName, t8s64(TargetScript));
                txconfig.AddTXCommand(tx, txconfig.TX_Commands.TXC_Inject);
                txconfig.EncryptTX(tx, TX_MASK);
                tx.ToArray().CopyTo(dll_buf, dwFile + 0x20 + BUFFER_SIZE);

                // load opcode map into memory, xor it with processid, then place in its location

                if (USE_MASKING)
                {
                    for (int i = 0; i < TABLE_SIZE; i++)
                    {
                        BitConverter.GetBytes((ushort)(BitConverter.ToInt16(mapData, i * 2) ^ VM_CODEMASK)).CopyTo(mapData, i * 2);
                    }
                    mapData.CopyTo(dll_buf, dwFile + 0x20 + BUFFER_SIZE + TX_SIZE);
                }
            }

            string outPath = args[3];
            File.WriteAllBytes(outPath, dll_buf);

            string infile = outPath;
            string outfile = infile + "_protected.dll";

            Process.Start(new ProcessStartInfo()
            {
                Arguments = $"/C start /WAIT \"\" \"C:\\Program Files\\Code Virtualizer\\Virtualizer.exe\" /protect \"C:\\Program Files\\Code Virtualizer\\alpha_cv.cv\" /inputfile \"{infile}\" /outputfile \"{outfile}\" /shareconsole /isolate",
                FileName = "cmd.exe",
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden,
                RedirectStandardOutput = true
            }).WaitForExit();

            //Process.Start(new ProcessStartInfo()
            //{
            //    Arguments = $"/C start /WAIT \"\" \"C:\\Program Files\\VMProtect Professional\\VMProtect_Con.exe\" \"{infile}\" \"{outfile}\" -pf \"{infile + ".vmp"}\"",
            //    FileName = "cmd.exe",
            //    UseShellExecute = false,
            //    CreateNoWindow = true,
            //    WindowStyle = ProcessWindowStyle.Hidden,
            //    RedirectStandardOutput = true
            //}).WaitForExit();

            // rename the protected dll to the output file target name
            // if (File.Exists(infile)) File.Delete(infile);
            File.WriteAllBytes(outfile + "debug.dll", File.ReadAllBytes(outfile)); // TODO
            // Compress(File.ReadAllBytes(outfile), infile);
            //File.Delete(outfile);

            Console.WriteLine("Script embed successful!");
        }

        private static void Compress(byte[] data, string outfile)
        {
            MemoryStream ms = new MemoryStream(data);
            using (FileStream compressedFileStream = File.Create(outfile))
            {
                using (DeflateStream compressionStream = new DeflateStream(compressedFileStream, CompressionMode.Compress))
                {
                    ms.CopyTo(compressionStream);
                }
            }
            ms.Close();
        }

        static void Error(string Message)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine(Message);
            Console.ForegroundColor = ConsoleColor.White;
            Console.ReadKey(false);
            Environment.Exit(1);
        }
    }

    internal static class extensions
    {
        public static int AlignValue(this int value, int alignment) => (((value) + ((alignment) - 1)) & ~((alignment) - 1));

        public static void CopyTo(this string str, byte[] buffer, int index)
        {
            for (int i = 0; i < str.Length; i++)
                buffer[index + i] = (byte)str[i];
        }
    }
}