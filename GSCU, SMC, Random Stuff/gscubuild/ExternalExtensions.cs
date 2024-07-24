using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace System
{
    public static class UtilExtensions
    {
        /// <summary>
        /// Computes the number of bytes require to pad this value
        /// </summary>
        public static int ComputePadding(int value, int alignment) => (((value) + ((alignment) - 1)) & ~((alignment) - 1)) - value;

        /// <summary>
        /// Aligns the value to the given alignment
        /// </summary>
        public static int AlignValue(this int value, int alignment) => (((value) + ((alignment) - 1)) & ~((alignment) - 1));

        public static uint AlignValue(this uint value, uint alignment) => (((value) + ((alignment) - 1)) & ~((alignment) - 1));

        ///// <summary>
        ///// Determines if a context value meets a desired value
        ///// </summary>
        ///// <param name="context"></param>
        ///// <param name="desired"></param>
        ///// <returns></returns>
        //public static bool HasContext(this uint context, ScriptContext desired)
        //{
        //    return (context & (uint)desired) > 0;
        //}

        /// <summary>
        /// Reads a string terminated by a null byte and returns the reader to the original position
        /// </summary>
        /// <returns>Read String</returns>
        public static string PeekNullTerminatedString(this BinaryReader br, long offset, int maxSize = -1)
        {
            // Create String Builder
            StringBuilder str = new StringBuilder();
            // Seek to position
            var temp = br.BaseStream.Position;
            br.BaseStream.Position = offset;
            // Current Byte Read
            int byteRead;
            // Size of String
            int size = 0;
            // Loop Until we hit terminating null character
            while ((byteRead = br.BaseStream.ReadByte()) != 0x0 && size++ != maxSize)
                str.Append(Convert.ToChar(byteRead));
            // Go back
            br.BaseStream.Position = temp;
            // Ship back Result
            return str.ToString();
        }

        /// <summary>
        /// Writes a null terminated string
        /// </summary>
        /// <param name="br"></param>
        /// <param name="str"></param>
        public static void WriteNullTerminatedString(this BinaryWriter br, string str)
        {
            foreach (byte c in Encoding.ASCII.GetBytes(str))
                br.Write(c);
            br.Write((byte)0);
        }

        /// <summary>
        /// Counts the number of lines in the given string
        /// </summary>
        public static int GetLineCount(string str)
        {
            int index = -1;
            int count = 0;
            while ((index = str.IndexOf(Environment.NewLine, index + 1)) != -1)
                count++;
            return count + 1;
        }

        public static string SanitiseString(string value) => value.Replace("/", "\\").Replace("\b", "\\b");

        /// <summary>
        /// Converts a byte array to a struct
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="data"></param>
        /// <returns></returns>
        public static T ToStruct<T>(this byte[] data) where T : struct
        {
            GCHandle handle = GCHandle.Alloc(data, GCHandleType.Pinned);
            T val = (T)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(T));
            handle.Free();
            return val;
        }

        /// <summary>
        /// Converts a byte array to a struct
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="data"></param>
        /// <returns></returns>
        public static object ToStruct(this byte[] data, Type t)
        {
            GCHandle handle = GCHandle.Alloc(data, GCHandleType.Pinned);
            object val = Marshal.PtrToStructure(handle.AddrOfPinnedObject(), t);
            handle.Free();
            return val;
        }

        /// <summary>
        /// Converts a byte array to a struct, but promises that the generic constraint is met by the programmer, instead of the compiler.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="data"></param>
        /// <returns></returns>
        public static T ToStructUnsafe<T>(this byte[] data)
        {
            GCHandle handle = GCHandle.Alloc(data, GCHandleType.Pinned);
            T val = (T)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(T));
            handle.Free();
            return val;
        }

        /// <summary>
        /// Converts a struct to a byte array
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="s"></param>
        /// <returns></returns>
        public static byte[] ToByteArray<T>(this T s) where T : struct
        {
            PointerEx size = Marshal.SizeOf(s);
            byte[] data = new byte[size];
            PointerEx dwStruct = Marshal.AllocHGlobal((int)size);
            Marshal.StructureToPtr(s, dwStruct, true);
            Marshal.Copy(dwStruct, data, 0, size);
            Marshal.FreeHGlobal(dwStruct);
            return data;
        }

        /// <summary>
        /// Converts an array of structs to a byte array
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="a_s"></param>
        /// <returns></returns>
        public static byte[] ToByteArray<T>(this T[] a_s) where T : struct
        {
            int size = Marshal.SizeOf(typeof(T));
            byte[] data = new byte[a_s.Length * size];
            for (int i = 0; i < a_s.Length; i++)
            {
                a_s[i].ToByteArray().CopyTo(data, i * size);
            }
            return data;
        }

        /// <summary>
        /// Converts a struct to a byte array, but promises that the generic constraint is met by the programmer, not the compiler.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="s"></param>
        /// <returns></returns>
        public static byte[] ToByteArrayUnsafe<T>(this T s)
        {
            PointerEx size = Marshal.SizeOf(s);
            byte[] data = new byte[size];
            PointerEx dwStruct = Marshal.AllocHGlobal((int)size);
            Marshal.StructureToPtr(s, dwStruct, true);
            Marshal.Copy(dwStruct, data, 0, size);
            Marshal.FreeHGlobal(dwStruct);
            return data;
        }

        /// <summary>
        /// Returns a null terminated byte array for the given string
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static byte[] Bytes(this string s)
        {
            return Encoding.ASCII.GetBytes(s).Append<byte>(0).ToArray();
        }

        /// <summary>
        /// Gets a null terminated string at the index specified in the buffer
        /// </summary>
        /// <param name="buffer"></param>
        /// <param name="index"></param>
        /// <returns></returns>
        public unsafe static string String(this byte[] buffer, int index = default)
        {
            fixed (byte* bytes = &buffer[index])
            {
                return new string((sbyte*)bytes);
            }
        }

        public static bool HexByte(this string input, out byte b)
        {
            return byte.TryParse(input, NumberStyles.HexNumber, CultureInfo.InvariantCulture, out b);
        }

        public static bool HexByte(this char input, out byte b)
        {
            return byte.TryParse(input.ToString(), NumberStyles.HexNumber, CultureInfo.InvariantCulture, out b);
        }

        public static byte HexByte(this string input)
        {
            return byte.Parse(input, NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        }

        public static byte HexByte(this char input)
        {
            return byte.Parse(input.ToString(), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        }

        public static bool IsHex(this char c)
        {
            c = char.ToLower(c);
            return (c >= 'a' && c <= 'f') || char.IsDigit(c);
        }

        public static string Hex(this byte[] arr)
        {
            return ByteArrayToHexViaLookup32Unsafe(arr);
        }

        // https://stackoverflow.com/questions/311165/how-do-you-convert-a-byte-array-to-a-hexadecimal-string-and-vice-versa/24343727#24343727
        // insanity of performance nerds, but I love it
        private static readonly uint[] _lookup32Unsafe = CreateLookup32Unsafe();
        private static readonly unsafe uint* _lookup32UnsafeP = (uint*)GCHandle.Alloc(_lookup32Unsafe, GCHandleType.Pinned).AddrOfPinnedObject();
        private static uint[] CreateLookup32Unsafe()
        {
            var result = new uint[256];
            for (int i = 0; i < 256; i++)
            {
                string s = i.ToString("X2");
                if (BitConverter.IsLittleEndian)
                    result[i] = ((uint)s[0]) + ((uint)s[1] << 16);
                else
                    result[i] = ((uint)s[1]) + ((uint)s[0] << 16);
            }
            return result;
        }

        private unsafe static string ByteArrayToHexViaLookup32Unsafe(byte[] bytes)
        {
            var lookupP = _lookup32UnsafeP;
            var result = new char[bytes.Length * 2];
            fixed (byte* bytesP = bytes)
            fixed (char* resultP = result)
            {
                uint* resultP2 = (uint*)resultP;
                for (int i = 0; i < bytes.Length; i++)
                {
                    resultP2[i] = lookupP[bytesP[i]];
                }
            }
            return new string(result);
        }

        /// <summary>
        /// Creates an unmanaged copy of a byte array, and then returns a handle to it. Must be freed manually.
        /// </summary>
        /// <param name="bytes"></param>
        /// <returns></returns>
        public static PointerEx Unmanaged(this byte[] bytes)
        {
            IntPtr pFile = Marshal.AllocHGlobal(bytes.Length);
            Marshal.Copy(bytes, 0, pFile, bytes.Length);
            return pFile;
        }
    }
}

namespace System
{
    public struct PointerEx
    {
        public IntPtr IntPtr { get; set; }
        public PointerEx(IntPtr value)
        {
            IntPtr = value;
        }

        #region overrides
        public static implicit operator IntPtr(PointerEx px)
        {
            return px.IntPtr;
        }

        public static implicit operator PointerEx(IntPtr ip)
        {
            return new PointerEx(ip);
        }

        public static PointerEx operator +(PointerEx px, PointerEx pxo)
        {
            return px.Add(pxo);
        }

        public static PointerEx operator -(PointerEx px, PointerEx pxo)
        {
            return px.Subtract(pxo);
        }

        public static PointerEx operator &(PointerEx px, PointerEx pxo)
        {
            return IntPtr.Size == sizeof(int) ? ((int)px & (int)pxo) : ((long)px & (long)pxo);
        }

        public static bool operator ==(PointerEx px, PointerEx pxo)
        {
            return px.IntPtr == pxo.IntPtr;
        }

        public static bool operator !=(PointerEx px, PointerEx pxo)
        {
            return px.IntPtr != pxo.IntPtr;
        }

        public override int GetHashCode()
        {
            return this;
        }

        public override bool Equals(object o)
        {
            if (o is PointerEx px)
            {
                return px == this;
            }
            return false;
        }

        public static implicit operator bool(PointerEx px)
        {
            return (long)px != 0;
        }

        public static implicit operator byte(PointerEx px)
        {
            return (byte)px.IntPtr;
        }

        public static implicit operator sbyte(PointerEx px)
        {
            return (sbyte)px.IntPtr;
        }

        public static implicit operator int(PointerEx px)
        {
            return (int)px.IntPtr.ToInt64();
        }

        public static implicit operator uint(PointerEx px)
        {
            return (uint)px.IntPtr.ToInt64();
        }

        public static implicit operator long(PointerEx px)
        {
            return px.IntPtr.ToInt64();
        }

        public static implicit operator ulong(PointerEx px)
        {
            return (ulong)px.IntPtr.ToInt64();
        }

        public static implicit operator PointerEx(int i)
        {
            return new IntPtr(i);
        }

        public static implicit operator PointerEx(uint ui)
        {
            return new IntPtr((int)ui);
        }

        public static implicit operator PointerEx(long l)
        {
            return new IntPtr(l);
        }

        public static implicit operator PointerEx(ulong ul)
        {
            return new IntPtr((long)ul);
        }

        public static bool operator true(PointerEx p)
        {
            return p;
        }

        public static bool operator false(PointerEx p)
        {
            return !p;
        }

        public override string ToString()
        {
            return IntPtr.ToInt64().ToString($"X{IntPtr.Size * 2}");
        }

        public PointerEx Clone()
        {
            return new PointerEx(IntPtr);
        }
        #endregion
    }

    /// <summary>
    /// A dummy type to signal that no return deserialization is needed for a call.
    /// </summary>
    public struct VOID
    {
#pragma warning disable CS0169
        [Diagnostics.CodeAnalysis.SuppressMessage("CodeQuality", "IDE0051:Remove unused private members", Justification = "Placeholder value to initialize struct size")]
        private PointerEx __value;
#pragma warning restore CS0169
    }
}

public static class PointerExtensions
{
    public static IntPtr Add(this IntPtr i, IntPtr offset)
    {
        if (IntPtr.Size == sizeof(int)) return IntPtr.Add(i, offset.ToInt32());
        return new IntPtr(i.ToInt64() + offset.ToInt64());
    }

    public static PointerEx Add(this PointerEx i, PointerEx offset)
    {
        return i.IntPtr.Add(offset);
    }

    public static IntPtr Subtract(this IntPtr i, IntPtr offset)
    {
        if (IntPtr.Size == sizeof(int)) return IntPtr.Subtract(i, offset.ToInt32());
        return new IntPtr(i.ToInt64() - offset.ToInt64());
    }

    public static PointerEx Subtract(this PointerEx i, PointerEx offset)
    {
        return i.IntPtr.Subtract(offset);
    }

    public static PointerEx Align(this PointerEx value, uint alignment) => (value + (alignment - 1)) & ~(alignment - 1);

    public static PointerEx ToPointer(this byte[] data)
    {
        if (IntPtr.Size < data.Length)
        {
            throw new InvalidCastException();
        }

        if (data.Length < IntPtr.Size)
        {
            byte[] _data = new byte[IntPtr.Size];
            data.CopyTo(_data, 0);
            data = _data;
        }

        if (IntPtr.Size == sizeof(long))
        {
            return BitConverter.ToInt64(data, 0);
        }

        return BitConverter.ToInt32(data, 0);
    }
}