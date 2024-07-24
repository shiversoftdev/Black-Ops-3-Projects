// dllmain.cpp : Defines the entry point for the DLL application.
#include "framework.h"

#include "d3d/d3d9.h"
#include "d3d/d3dx9.h"
#include <stdio.h>
#pragma comment (lib, "d3d9.lib")
#pragma comment (lib, "d3dx9d.lib")

enum MAPTYPES
{
	MAPTYPE_NONE = 0x0,
	MAPTYPE_INVALID1 = 0x1,
	MAPTYPE_1D = 0x2,
	MAPTYPE_2D = 0x3,
	MAPTYPE_3D = 0x4,
	MAPTYPE_CUBE = 0x5,
	MAPTYPE_COUNT = 0x6,
};

struct Picmip
{
	char platform[2];
};

struct GfxImageLoadDef
{
	char levelCount;
	char pad[3];
	int flags;
	int format;
	int resourceSize;
	char data[1];
};

struct CardMemory
{
	int platform[2];
};

union GfxTexture
{
	IDirect3DBaseTexture9* basemap;
	IDirect3DTexture9* map;
	IDirect3DVolumeTexture9* volmap;
	IDirect3DCubeTexture9* cubemap;
	GfxImageLoadDef* loadDef;
};

struct GfxImage
{
	GfxTexture texture;
	char mapType;
	char semantic;
	char category;
	unsigned char flags;
	Picmip picmip;
	bool noPicmip;
	char track;
	CardMemory cardMemory;
	unsigned short width;
	unsigned short height;
	unsigned short depth;
	unsigned char levelCount;
	const char* name;
};


BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

EXPORT int IW5_D3DXSaveTextureToFile(char* destFile, D3DXIMAGE_FILEFORMAT format, GfxImage* gfxImage)
{
    return D3DXSaveTextureToFile(destFile, format, gfxImage->texture.basemap, 0);
}

EXPORT int IW5_SaveCubemapImagePngCollection(char* destFileTemplate, GfxImage* gfxImage)
{
	if (gfxImage->mapType == MAPTYPE_CUBE)
	{
		for (auto i = 0; i < 6; ++i)
		{
			IDirect3DSurface9* surface = nullptr;
			char buff[MAX_PATH]{};
			sprintf(buff, "%s_%d.png", destFileTemplate, i);
			auto res = gfxImage->texture.cubemap->GetCubeMapSurface(D3DCUBEMAP_FACES(i), 0, &surface);
			if (res == D3D_OK && surface)
			{
				D3DXSaveSurfaceToFileA(buff, D3DXIFF_PNG, surface, nullptr, nullptr);
				surface->Release();
			}
			else
			{
				return res;
			}
		}
		return 0;
	}
	return -1;
}