#pragma once
#pragma once

#include <random>
#include <cstdint>
#include <limits>
#include <chrono>

namespace sob
{
    template<typename T, typename std::enable_if<std::is_scalar<T>::value>::type* = nullptr>
    struct default_key_generator
    {
        T operator()() const
        {
            static std::default_random_engine generator((T)std::chrono::duration_cast<std::chrono::seconds>(std::chrono::steady_clock::now().time_since_epoch()).count());
            static std::uniform_int_distribution<T> distribution(std::numeric_limits<T>::min(), std::numeric_limits<T>::max());

            return static_cast<T>(distribution(generator));
        }
    };

    template<typename generator = default_key_generator<int32_t>>
    struct xor_encryption_impl
    {
        xor_encryption_impl()
        {
            m_key = generator()();
        }

        void encrypt(uint8_t* dest, uint8_t* src, size_t size) const
        {
            for (size_t i = 0; i < size; i++)
            {
                dest[i] = src[i] ^ *((uint8_t*)&m_key + i % 4);
            }
        }

        void decrypt(uint8_t* dest, uint8_t* src, size_t size) const
        {
            for (size_t i = 0; i < size; i++)
            {
                dest[i] = src[i] ^ *((uint8_t*)&m_key + i % 4);
            }
        }

        int32_t m_key;
    };

    typedef xor_encryption_impl<> default_encryption_impl;

    template<typename T, typename encryption = default_encryption_impl, typename std::enable_if<std::is_scalar<T>::value>::type* = nullptr>
    struct crypt_var
    {
        crypt_var()
        {
            set(T());
        }

        crypt_var(const T& _value)
        {
            set(_value);
        }

        crypt_var(const crypt_var<T>& _copy)
        {
            set(_copy.get());
        }

        crypt_var(crypt_var<T>&& _move)
        {
            set(_move.get());
        }

        crypt_var<T>& operator= (const crypt_var<T>& other)
        {
            crypt_var<T> temporary(other);

            set(temporary.get());

            return *this;
        }

        crypt_var<T>& operator=(const T& _value)
        {
            this->set(_value);
            return *this;
        }

        crypt_var<T>& operator= (crypt_var<T>&& other)
        {
            set(other.get());

            return *this;
        }

        operator T() const
        {
            return get();
        }

        void set(const T& _value)
        {
            T copy(_value);

            uint8_t* ptr = (uint8_t*)&copy;
            uint8_t* local = (uint8_t*)&value;

            m_encryption_impl.encrypt(local, ptr, sizeof(T));
        }

        T get() const
        {
            T copy;

            uint8_t* ptr = (uint8_t*)&copy;
            uint8_t* local = (uint8_t*)&value;

            m_encryption_impl.decrypt(ptr, local, sizeof(T));

            return copy;
        }

        T value;
        encryption m_encryption_impl;
    };
}