using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using static CoD.MW3.Offsets;
using static CoD.CONST;
using static CoD.Util;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Numerics;

namespace CoD
{
    public static class MW3
    {
        internal static class Offsets
        {
            public static PointerEx XAssetPool = 0x8AB258;
            public static PointerEx XAssetSizes = 0x8AAF78;
            public static PointerEx cm = 0x1C91814 - 0x94; // CM_GetBrushModel@53EDD0 -> cm.cmodels<cm+0x94>[index] (sizeof(cmodel_t) -> 72)
            public static PointerEx g_world = 0x5FC5F9C; // gfxworld*
            public static PointerEx g_MaterialPool = 0x16EBCB0;
        }

        private static ProcessEx __game;
        internal static ProcessEx Game
        {
            get
            {
                if (__game is null || __game.BaseProcess is null || __game.BaseProcess.HasExited)
                {
                    __game = "iw5mp";

                    if (__game == null || (__game.BaseProcess?.HasExited ?? true))
                    {
                        // lets look for open-iw5 too

                        foreach (var process in System.Diagnostics.Process.GetProcessesByName("open-iw5"))
                        {
                            ProcessEx px = process;

                            if (px["binkw32.dll"] != null)
                            {
                                __game = process;
                                break;
                            }
                        }

                        if (__game == null || (__game.BaseProcess?.HasExited ?? true))
                        {
                            throw new Exception("Modern Warfare 3 process not found.");
                        }
                    }
                    __game.ExecutableOnlyQuickAlloc = false;
                    __game.UseNTAllocQuickAlloc = true;
                    __game.RPCThreadTimeoutMS = 10000;
                    __game.SetDefaultCallType(ExCallThreadType.XCTT_RIPHijack);
                }
                if (!__game.Handle)
                {
                    __game.OpenHandle(ProcessEx.PROCESS_ACCESS, true);
                }
                return __game;
            }
        }

        [StructLayout(LayoutKind.Sequential)]
        struct MaterialPool
        {
            public int free_head;
            public int pad_align;
            public Material[] Entries;
        }


        static readonly Dictionary<string, (int fieldPos, int fieldSize)> GfxDrawSurfFields = new Dictionary<string, (int, int)>
        {
            {"unused", (0, 1)},
            {"primarySortKey", (1, 6)},
            {"surfType", (7, 4)},
            {"viewModelRender", (11, 1)},
            {"sceneLightIndex", (12, 8)},
            {"useHeroLighting", (20, 1)},
            {"prepass", (21, 2)},
            {"materialSortedIndex", (23, 12)},
            {"customIndex", (35, 5)},
            {"hasGfxEntIndex", (40, 1)},
            {"reflectionProbeIndex", (41, 8)},
            {"objectId", (49, 15)},
        };

        struct GfxDrawSurf
        {
            public long packed;

            public uint this[string field]
            {
                get
                {
                    var inf = GfxDrawSurfFields[field];
                    return (uint)((packed << (64 - (inf.fieldPos + inf.fieldSize))) >> (64 - inf.fieldSize));
                }

                //set
                //{
                //    var inf = GfxDrawSurfFields[field];
                //    var mask = (~0) >> inf.
                //}
            }
        }

        [StructLayout(LayoutKind.Sequential)]
        struct MaterialInfo
        {
            public int namePointer; // 0x0, char*
            public byte gameFlags; // 0x4
            public byte sortKey; // 0x5
            public byte textureAtlasRowCount; // 0x6
            public byte textureAtlasColumnCount; // 0x7
            public GfxDrawSurf drawSurf; // 0x8
            public uint surfaceTypeBits; // 0x10
            public uint pad; // 0x14 (SIZE: 0x18)
        };

        [StructLayout(LayoutKind.Sequential)]
        unsafe struct Material // SIZE: 0x68
        {
            public MaterialInfo info; // 0x0, SIZE: 0x18
            public fixed byte stateBitsEntry[54]; // 0x18
            public byte textureCount; // 0x4E
            public byte constantCount; // 0x4F
            public byte stateBitsCount; // 0x50
            public byte stateFlags; // 0x51
            public byte cameraRegion; // 0x52
            public byte pad; // 0x53
            public int techniqueSetPointer; // 0x54, MaterialTechniqueSet*
            public int textureTablePointer; // 0x58, MaterialTextureDef*
            public int constantTablePointer; // 0x5C, MaterialConstantDef*
            public int stateBitsTablePointer; // 0x60, GfxStateBits*
            public int subMaterialsPointer; // 0x64, const char**
        };

        [StructLayout(LayoutKind.Sequential)]
        unsafe struct clipMap_t
        {
            public int namePointer; // 0x0, const char*
            public int isInUse; // 0x4
            public ClipInfo info; // 0x8
            public int pInfo; // ClipInfo*
            public uint numStaticModels;
            public int staticModelListPointer; // cStaticModel_s*
            public uint numNodes;
            public int nodesPointer; // cNode_t*
            public uint numLeafs;
            public int leafsPointer; // cLeaf_t*
            public uint vertCount;
            public int vertsPointer; // vec3_t*
            public int triCount;
            public int triIndicesPointer; // unsigned short*
            public int triEdgeIsWalkablePointer; // unsigned char*
            public int borderCount;
            public int bordersPointer; // CollisionBorder*
            public int partitionCount;
            public int partitionsPointer; // CollisionPartition*
            public int aabbTreeCount;
            public int aabbTreesPointer; // CollisionAabbTree*
            public uint numSubModels;
            public int cmodelsPointer; // cmodel_t*
            public int mapEntsPointer; // MapEnts*
            public int stagesPointer; // Stage*
            public byte stageCount;
            public MapTriggers stageTrigger;
            public ushort smodelNodeCount;
            public ushort pad;
            public int smodelNodesPointer; // SModelAabbNode*
            public fixed ushort dynEntCount[2];
            public fixed int dynEntDefListPointer[2]; // DynEntityDef*
            public fixed int dynEntPoseListPointer[2]; // DynEntityPose*
            public fixed int dynEntClientListPointer[2]; // DynEntityClient*
            public fixed int dynEntCollListPointer[2]; // DynEntityColl*
            public uint checksum;
            public fixed byte padding[20];
        };

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct GfxWorldDpvsPlanes
        {
            public int cellCount;
            public int planesPointer; // cplane_s*
            public int nodesPointer; // ushort*
            public int sceneEntCellBitsPointer; // uint*
        };

        public class GfxWorldDpvsPlanesPretty
        {
            public int cellCount { get; set; }
            public string planesPointer { get; set; }
            public string nodesPointer { get; set; }
            public string sceneEntCellBitsPointer { get; set; }

            public GfxWorldDpvsPlanesPretty(GfxWorldDpvsPlanes dpvsPlanes)
            {
                cellCount = dpvsPlanes.cellCount;
                planesPointer = dpvsPlanes.planesPointer.ToString("X");
                nodesPointer = dpvsPlanes.nodesPointer.ToString("X");
                sceneEntCellBitsPointer = dpvsPlanes.sceneEntCellBitsPointer.ToString("X");
            }
        }

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct GfxWorldDraw // size: 0x54
        {
            public uint reflectionProbeCount; // 0x0
            public int reflectionProbesPointer; // 0x4, GfxImage**
            public int reflectionProbeOriginsPointer; // 0x8, GfxReflectionProbe*
            public int reflectionProbeTexturesPointer; // 0xC, GfxTexture*
            public uint reflectionProbeReferenceCount; // 0x10
            public int reflectionProbeReferenceOriginsPointer; // 0x14, GfxReflectionProbeReferenceOrigin*
            public int reflectionProbeReferencesPointer; // 0x18, GfxReflectionProbeReference*
            public int lightmapCount; // 0x1C
            public int lightmapsPointer; // 0x20, GfxLightmapArray*
            public int lightmapPrimaryTexturesPointer; // 0x24, GfxTexture*
            public int lightmapSecondaryTexturesPointer; // 0x28, GfxTexture*
            public int lightmapOverridePrimaryPointer; // 0x2C, GfxImage*
            public int lightmapOverrideSecondaryPointer; // 0x30, GfxImage*
            public uint vertexCount; // 0x34
            public GfxWorldVertexData vd; // 0x38, (size: 0x8)
            public uint vertexLayerDataSize; // 0x40
            public GfxWorldVertexLayerData vld; // 0x44, (size: 0x8)
            public uint indexCount; // 0x4C
            public int indicesPointer; // 0x50, ushort*
        }

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct GfxWorldVertexData
        {
            public int verticesPointer; // 0x0, GfxWorldVertex*
            public int worldVbPointer; // 0x4, void*
        };

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct GfxColor
        {
            public fixed byte col[4];
        }

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct PackedUnitVec
        {
            public fixed byte vec[4];
        }

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct GfxWorldVertex
        {
            public fixed float xyz[3];
            public float binormalSign;
            public GfxColor color; // size 4, 0x8
            public fixed float texCoord[2];
            public fixed float lmapCoord[2];
            public PackedUnitVec normal;
            public PackedUnitVec tangent;
        };

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct GfxWorldVertexLayerData
        {
            public int dataPointer; // 0x0, unsigned char*
            public int layerVbPointer; // 0x4, void*
        };

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct GfxWorld // GfxWorld
        {
            /// <summary>
            /// A pointer to the name of this GfxMap Asset
            /// </summary>
            public int NamePointer { get; set; } // 0x0

            /// <summary>
            /// A pointer to the name of the map 
            /// </summary>
            public int BaseNamePointer { get; set; } // 0x4

            public int PlaneCount; // 0x8
            public int NodeCount; // 0xC

            /// <summary>
            /// Number of Surfaces
            /// </summary>
            public uint SurfaceCount { get; set; } // 0x10

            public int SkyCount; // 0x14
            /// <summary>
            /// Pointer to skies
            /// </summary>
            public int Skies; // 0x18

            public int lastSunPrimaryLightIndex; // 0x1C
            public int primaryLightCount; // 0x20
            public int sortKeyLitDecal; // 0x24
            public int sortKeyEffectDecal; // 0x28
            public int sortKeyEffectAuto; // 0x2C
            public int sortKeyDistortion; // 0x30
            public GfxWorldDpvsPlanes dpvsPlanes; // 0x34 (size: 0x10)
            public int aabbTreeCountsPointer; // GfxCellTreeCount*, 0x44
            public int aabbTreesPointer; // GfxCellTree*, 0x48
            public int cellsPointer; // GfxCell*, 0x4C
            public GfxWorldDraw draw; // 0x50, size: 0x54
            public GfxLightGrid lightGrid; // 0xA4, size: 0x38
            public int modelCount; // 0xDC
            public int modelsPointer; // 0xE0, GfxBrushModel*
            public Bounds bounds; // 0xE4, (size: 0x18)
            public uint checksum; // 0xFC
            public int materialMemoryCount; // 0x100
            public int materialMemoryPointer; // 0x104, MaterialMemory*
            public sunflare_t sun; // 0x108, size: 0x60
            public fixed float outdoorLookupMatrix[16]; // 0x168, size: 0x40 (outdoorLookupMatrix -> float[4][4])
			public int outdoorImagePointer; // 0x1A8, GfxImage*
            public int cellCasterBitsPointer; // 0x1AC, unsigned int*
            public int cellHasSunLitSurfsBitsPointer; // 0x1B0, unsigned int*
            public int sceneDynModelPointer; // 0x1B4, GfxSceneDynModel*
            public int sceneDynBrushPointer; // 0x1B8, GfxSceneDynBrush*
            public int primaryLightEntityShadowVisPointer; // 0x1BC, unsigned int*
            public fixed int primaryLightDynEntShadowVisPointer[2]; // 0x1C0, unsigned int*
            public int nonSunPrimaryLightForModelDynEntPointer; // 0x1C8, unsigned char*
            public int shadowGeomPointer; // 0x1CC, GfxShadowGeometry*
            public int lightRegionPointer; // 0x1D0, GfxLightRegion*
            public GfxWorldDpvsStatic dpvs; // 0x1D4
           //         GfxWorldDpvsDynamic dpvsDyn;
           //         unsigned int mapVtxChecksum;
           //         unsigned int heroOnlyLightCount;
           //         struct GfxHeroOnlyLight* heroOnlyLights;
		   //unsigned char fogTypesAllowed;
        }

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct GfxBrushModel
        {
            public Bounds writable;
            public Bounds bounds;
            public float radius;
            public ushort surfaceCount;
            public ushort startSurfIndex;
            public ushort surfaceCountNoDecal;
            public ushort pad;
        }

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct srfTriangles_t
        {
            public uint vertexLayerData; // probably a pointer to the world vertex layer data?
            public uint firstVertex; // index of first vertex
            public ushort vertexCount;
            public ushort triCount;
            public uint baseIndex; // index of first triangle
        };

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct GfxSurface
        {
            public srfTriangles_t tris;
            public int materialPointer; // Material*
            public GfxSurfaceLightingAndFlags laf;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct GfxSurfaceLightingAndFlagsFields
        {
            public byte lightmapIndex;
            public byte reflectionProbeIndex;
            public byte primaryLightIndex;
            public byte flags;
        };

        [StructLayout(LayoutKind.Sequential)]
        public struct GfxSurfaceLightingAndFlags
        {
            GfxSurfaceLightingAndFlagsFields fields;
        };

    [StructLayout(LayoutKind.Sequential)]
        public unsafe struct GfxWorldDpvsStatic
        {
            public uint smodelCount; // 0x0
            public uint staticSurfaceCount; // 0x4
            public uint staticSurfaceCountNoDecal; // 0x8
            public uint litOpaqueSurfsBegin; // 0xC
            public uint litOpaqueSurfsEnd; // 0x10
            public uint litTransSurfsBegin; // 0x14
            public uint litTransSurfsEnd; // 0x18
            public uint shadowCasterSurfsBegin; // 0x1C
            public uint shadowCasterSurfsEnd; // 0x20
            public uint emissiveSurfsBegin; // 0x24
            public uint emissiveSurfsEnd; // 0x28
            public uint smodelVisDataCount; // 0x2C
            public uint surfaceVisDataCount; // 0x30
            public fixed int smodelVisDataPointer[3]; // 0x34, char*
            public fixed int surfaceVisDataPointer[3]; // 0x40, char*
            public int sortedSurfIndexPointer; // 0x4C, unsigned short*
            public int smodelInstsPointer; // 0x50, GfxStaticModelInst*
            public int surfacesPointer; // 0x54, GfxSurface*
            public int surfacesBoundsPointer; // 0x58, GfxSurfaceBounds*
            public int smodelDrawInstsPointer; // 0x5C, GfxStaticModelDrawInst*
            public int surfaceMaterialsPointer; // 0x60, GfxDrawSurf*
            public int surfaceCastsSunShadowPointer; // 0x64, unsigned int*
            public int usageCount; // 0x68
        };

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct sunflare_t // size: 0x60
        {
            public byte hasValidData; // 0x00
            public fixed byte align[3]; // 0x1
            public int spriteMaterialPointer; // 0x4, Material*
            public int flareMaterialPointer; // 0x8, Material*
            public float spriteSize; // 0xC
            public float flareMinSize; // 0x10
            public float flareMinDot; // 0x14
            public float flareMaxSize; // 0x18
            public float flareMaxDot; // 0x1C
            public float flareMaxAlpha; // 0x20
            public int flareFadeInTime; // 0x24
            public int flareFadeOutTime; // 0x28
            public float blindMinDot; // 0x2C
            public float blindMaxDot; // 0x30
            public float blindMaxDarken; // 0x34
            public int blindFadeInTime; // 0x38
            public int blindFadeOutTime; // 0x3C
            public float glareMinDot; // 0x40
            public float glareMaxDot; // 0x44
            public float glareMaxLighten; // 0x48
            public int glareFadeInTime; // 0x4C
            public int glareFadeOutTime; // 0x50
            public fixed float sunFxPosition[3]; // 0x54
        };

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct GfxLightGrid // size: 0x38
        {
            public byte hasLightRegions; // 0x0
            public byte useSkyForLowZ; // 0x1
            public ushort pad; // 0x2
            public uint lastSunPrimaryLightIndex; // 0x4
            public fixed ushort mins[3]; // 0x8
            public fixed ushort maxs[3]; // 0xE
            public uint rowAxis; // 0x14
            public uint colAxis; // 0x18
            public int rowDataStartPointer; // 0x1C, unsigned short*
            public uint rawRowDataSize; // 0x20
            public int rawRowDataPointer; // 0x24, unsigned char*
            public uint entryCount; // 0x28
            public int entriesPointer; // 0x2C, GfxLightGridEntry*
            public uint colorCount; // 0x30
            public int colorsPointer; // 0x34, GfxLightGridColors*
        };

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        unsafe struct GfxSky
        {
            public int SkySurfCount { get; set; }
            public int SkyStartSurfsPointer { get; set; } // g_world->dpvs.sortedSurfIndex[sky->skyStartSurfs[index]]
            public int SkyImagePointer { get; set; } // GfxImage
            public char SkySamplerState { get; set; }
        };

        [StructLayout(LayoutKind.Sequential)]
        struct MapEnts
        {
            public int unk;
            public int namePointer;
            public int entityStringPointer;
            public int numEntityChars;
            public MapTriggers trigger;
            public ClientTriggers clientTrigger;
        };
        
        [StructLayout(LayoutKind.Sequential)]
        struct MapTriggers
        {
            public int count;
            public int modelsPointer;
            public int hullCount;
            public int hullsPointer;
            public int slabCount;
            public int slabsPointer;
        }

        [StructLayout(LayoutKind.Sequential)]
        struct TriggerModel
        {
            public int contents; // unknown what the purpose is
            public ushort hullCount;
            public ushort firstHull;
        }

        [StructLayout(LayoutKind.Sequential)]
        struct TriggerHull
        {
            public Bounds bounds;
            public int contents; // unknown what the purpose is
            public ushort slabCount;
            public ushort firstSlab;
        }

        [StructLayout(LayoutKind.Sequential)]
        public unsafe struct Bounds
        {
            public fixed float midPoint[3];
            public fixed float halfSize[3];
        }

        [StructLayout(LayoutKind.Sequential)]
        unsafe struct TriggerSlab
        {
            public fixed float dir[3];
            public float midPoint;
            public float halfSize;
        }

        [StructLayout(LayoutKind.Sequential)]
        unsafe struct ClientTriggers
        {
            public MapTriggers trigger;
            public fixed uint Pad[2]; // AABBTree info
            public int triggerStringLength;
            public int triggerStringPointer;
            public int triggerStringOffsets; // uint16*
            public int triggerTypePointer; // char*
            public int originsPointer; // float[3]*
            public int scriptDelayPointer; // float* script_delay
            public int audioTriggers; // ushort* script_sound
        }

        class ClientTriggersPretty
        {
            public PrettyClientTrigger[] triggers { get; set; }
            public string triggerString { get; set; }
            public ClientTriggersPretty(ClientTriggers ct)
            {
                var triggerModels = Game.GetArray<TriggerModel>(ct.trigger.modelsPointer, ct.trigger.count);
                var triggerHulls = Game.GetArray<TriggerHull>(ct.trigger.hullsPointer, ct.trigger.hullCount);
                var triggerSlabs = Game.GetArray<TriggerSlab>(ct.trigger.slabsPointer, ct.trigger.slabCount);

                List<PrettyClientTrigger> triggers = new List<PrettyClientTrigger>();
                int index = 0;
                foreach (var trig in triggerModels)
                {

                    var hulls = triggerHulls.Skip(trig.firstHull).Take(trig.hullCount);
                    List<PrettyTriggerHull> phulls = new List<PrettyTriggerHull>();

                    foreach (var hull in hulls)
                    {
                        var slabs = triggerSlabs.Skip(hull.firstSlab).Take(hull.slabCount);
                        PrettyTriggerHull phull = new PrettyTriggerHull(hull, slabs.ToArray());
                        phulls.Add(phull);
                    }

                    triggers.Add(new PrettyClientTrigger(trig, phulls.ToArray(), Game.GetArray<float>(4 * 3 * index + ct.originsPointer, 3), 
                        Game.GetValue<float>(4 * index + ct.scriptDelayPointer), Game.GetValue<ushort>(2 * index + ct.audioTriggers), 
                        Game.GetValue<char>(index + ct.triggerTypePointer), Game.GetValue<ushort>(2 * index + ct.triggerStringOffsets), 
                        ct.triggerStringPointer));
                    index++;
                }

                triggerString = Game.GetString(ct.triggerStringPointer, ct.triggerStringLength);
                this.triggers = triggers.ToArray();
            }

            public override string ToString()
            {
                var serializeOptions = new JsonSerializerOptions
                {
                    PropertyNamingPolicy = new LowerNamePol(),
                    PropertyNameCaseInsensitive = true,
                    WriteIndented = true
                };

                return JsonSerializer.Serialize(this, typeof(ClientTriggersPretty), serializeOptions);
            }
        }

        class GfxSkyPretty
        {
            public int SkySurfCount { get; set; }
            public string SkyStartSurfsPointer { get; set; }
            public string SkyImagePointer { get; set; } // GfxImage
            public int SkySamplerState { get; set; }

            // non struct data
            public byte SkyImageMapType { get; set; }

            internal GfxSkyPretty(GfxSky sky)
            {
                SkySurfCount = sky.SkySurfCount;
                SkyStartSurfsPointer = $"{sky.SkyStartSurfsPointer:X8}";
                SkyImagePointer = $"{sky.SkyImagePointer:X8}";
                SkySamplerState = sky.SkySamplerState;

                SkyImageMapType = Game.GetValue<byte>(sky.SkyImagePointer + 0x4);
            }
        }

        class GfxWorldPretty
        {
            /// <summary>
            /// A pointer to the name of this GfxMap Asset
            /// </summary>
            public string NamePointer { get; set; }

            /// <summary>
            /// A pointer to the name of the map 
            /// </summary>
            public string MapNamePointer { get; set; }

            public int PlaneCount { get; set; }
            public int NodeCount { get; set; }

            /// <summary>
            /// Number of Surfaces
            /// </summary>
            public uint SurfaceCount { get; set; }

            public int SkyCount { get; set; }
            public string Skies { get; set; }
            public GfxSkyPretty Sky1 { get; set; }

            public int lastSunPrimaryLightIndex { get; set; }
            public int primaryLightCount { get; set; }
            public int sortKeyLitDecal { get; set; }
            public int sortKeyEffectDecal { get; set; }
            public int sortKeyEffectAuto { get; set; }
            public int sortKeyDistortion { get; set; }
            public GfxWorldDpvsPlanesPretty dpvsPlanes{ get; set; }

            internal GfxWorldPretty(GfxWorld world)
            {
                NamePointer = world.NamePointer.ToString("X8");
                MapNamePointer = world.BaseNamePointer.ToString("X8");
                PlaneCount = world.PlaneCount;
                NodeCount = world.NodeCount;
                SurfaceCount = world.SurfaceCount;
                SkyCount = world.SkyCount;
                Skies = world.Skies.ToString("X8");
                var firstSky = Game.GetStruct<GfxSky>(world.Skies);

                var serializeOptions = new JsonSerializerOptions
                {
                    PropertyNamingPolicy = new LowerNamePol(),
                    PropertyNameCaseInsensitive = true,
                    WriteIndented = true
                };
                Sky1 = new GfxSkyPretty(firstSky);
                lastSunPrimaryLightIndex = world.lastSunPrimaryLightIndex;
                primaryLightCount = world.primaryLightCount;
                sortKeyLitDecal = world.sortKeyLitDecal;
                sortKeyEffectDecal = world.sortKeyEffectDecal;
                sortKeyEffectAuto = world.sortKeyEffectAuto;
                sortKeyDistortion = world.sortKeyDistortion;
                dpvsPlanes = new GfxWorldDpvsPlanesPretty(world.dpvsPlanes);
            }
        }

        [StructLayout(LayoutKind.Sequential)]
        unsafe struct cmodel_t
        {
            public Bounds bounds;
            public float radius;
            public int clipInfoPointer;
            public cLeaf_t leaf;
        }

        [StructLayout(LayoutKind.Sequential)]
        unsafe struct cLeaf_t
        {
            public ushort firstCollAabbIndex; // 0x0
            public ushort collAabbCount; // 0x2
            public int brushContents; // 0x4
            public int terrainContents; // 0x8
            public Bounds bounds; // 0xC
            public int leafBrushNode; // 0x24
        };

        [StructLayout(LayoutKind.Sequential)]
        struct ClipInfo
        {
            public int planeCount;
            public int planesPointer;
            public uint numMaterials;
            public int materialsPointer; // ClipMaterial*
            public uint numBrushSides;
            public int brushSidesPointer; // cbrushside_t*
            public uint numBrushEdges;
            public int brushEdgesPointer;
            public uint leafBrushNodesCount;
            public int leafBrushNodesPointer; // cLeafBrushNode_s*
            public uint numLeafBrushes;
            public int leafBrushesPointer; // uint16*
            public ushort numBrushes;
            public ushort pad;
            public int brushesPointer; // cbrush_t*
            public int brushBoundsPointer; // Bounds
            public int brushContentsPointer; // int
        }

        [StructLayout(LayoutKind.Sequential)]
        struct ClipMaterial
        {
            public int namePointer; // const char*
            public int surfaceFlags;
            public int contents;
        };

        [StructLayout(LayoutKind.Sequential)]
        unsafe struct cbrush_t
        {
            public ushort numsides; // 0x0
            public ushort glassPieceIndex; // 0x2
            public int sidesPointer; // 0x4, cbrushside_t*
            public int baseAdjacentSidePointer; // 0x8, unsigned char*
            public fixed ushort axialMaterialNum[6]; // 0xC, ushort[2][3] (size: 0xC)
			public fixed byte firstAdjacentSideOffsets[6]; // 0x18, char[2][3] (size: 0x6)
            public fixed byte edgeCount[6]; // 0x1E, (size: 0x6), end: 0x14
		};

        [StructLayout(LayoutKind.Sequential)]
        struct cLeafBrushNode_s
        {
            public byte axis; // 0x0
            public byte pad; // 0x1
            public short leafBrushCount; // 0x2
            public int contents; // 0x4
            public cLeafBrushNodeData_t data; // 0x8
        };

        [StructLayout(LayoutKind.Explicit, Size=0xC)]
        unsafe struct cLeafBrushNodeData_t
        {
            [FieldOffset(0)] public cLeafBrushNodeLeaf_t leaf;
            [FieldOffset(0)] public cLeafBrushNodeChildren_t children;
        }

        [StructLayout(LayoutKind.Sequential)]
        struct cLeafBrushNodeLeaf_t
        {
            public int brushes; // unsigned short*
        };

        unsafe struct cLeafBrushNodeChildren_t
        {
            public float dist;
            public float range;
            public fixed ushort childOffset[2];
        };

        [StructLayout(LayoutKind.Sequential)]
        unsafe struct cplane_s
        {
            public fixed float normal[3];
            public float dist;
            public byte type;
            public fixed byte pad[3];
        }

        [StructLayout(LayoutKind.Sequential)]
        struct cbrushside_t
        {
            public int planePointer; // cplane_s*
            public ushort materialNum;
            public byte firstAdjacentSideOffset;
            public byte edgeCount;
        }

        class cbrushside_tPretty
        {
            public cplane_sPretty plane { get; set; }
            public ushort materialNum { get; set; }
            public byte firstAdjacentSideOffset { get; set; }
            public byte edgeCount { get; set; }
            public cbrushside_tPretty(cbrushside_t cb)
            {
                plane = new cplane_sPretty(Game.GetStruct<cplane_s>(cb.planePointer));
                materialNum = cb.materialNum;
                firstAdjacentSideOffset = (byte)cb.firstAdjacentSideOffset; 
                edgeCount = (byte)cb.edgeCount; 
            }
        }

        class cplane_sPretty
        {
            public float[] normal { get; set; }
            public float dist { get; set; }
            public byte type { get; set; }
            public cplane_sPretty(cplane_s cp)
            {
                normal = new float[3];
                unsafe
                {
                    for(int i = 0; i < 3; i++)
                    {
                        normal[i] = cp.normal[i];
                    }
                }
                dist = cp.dist;
                type = cp.type;
            }
        }

        class ClipInfoPretty
        {
            public int planeCount { get; set; }
            public cplane_sPretty[] planes { get; set; }
            public cbrushside_tPretty[] brushes { get; set; }

            public ClipInfoPretty(ClipInfo ci)
            {
                planeCount = ci.planeCount;
                // planes = new cplane_sPretty[Math.Min(20, planeCount)];

                //var splanes = Game.GetArray<cplane_s>(ci.planesPointer, Math.Min(20, planeCount));
                //for(int i = 0; i < splanes.Length; i++)
                //{
                //    planes[i] = new cplane_sPretty(splanes[i]);
                //}


            }

            public override string ToString()
            {
                var serializeOptions = new JsonSerializerOptions
                {
                    PropertyNamingPolicy = new LowerNamePol(),
                    PropertyNameCaseInsensitive = true,
                    WriteIndented = true
                };

                var worldData = JsonSerializer.Serialize(this, typeof(ClipInfoPretty), serializeOptions);
                return worldData;
            }
        }

        internal class LowerNamePol : JsonNamingPolicy
        {
            public override string ConvertName(string name) =>
                name.ToLower();
        }

        public static string GetMapName()
        {
            var world = Game.GetStruct<GfxWorld>(Game.GetValue<int>(XAssetPool + 4 * 0x15));
            return Game.GetString(world.BaseNamePointer).ToLower();
        }

        public static string GetWorldData()
        {
            var world = Game.GetStruct<GfxWorld>(Game.GetValue<int>(XAssetPool + 4 * 0x15));
            var serializeOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = new LowerNamePol(),
                PropertyNameCaseInsensitive = true,
                WriteIndented = true
            };

            var worldData = JsonSerializer.Serialize(new GfxWorldPretty(world), typeof(GfxWorldPretty), serializeOptions);
            return worldData;
        }

        public static string GetMapEnts()
        {
            var ents = Game.GetStruct<MapEnts>(Game.GetValue<int>(XAssetPool + 4 * 0x13));
            string raw = Game.GetString(ents.entityStringPointer, ents.numEntityChars);

            List<string> lines = new List<string>();
            foreach(var line in raw.Replace("\r", "").Split('\n'))
            {
                if(line.IndexOf(' ') < 0)
                {
                    lines.Add(line);
                    continue;
                }
                if(int.TryParse(line.Substring(0, line.IndexOf(' ')), out int result))
                {
                    if(IW5Keys.Tokens.ContainsKey(result))
                    {
                        lines.Add($"\"{IW5Keys.Tokens[result]}\"{line.Substring(line.IndexOf(' '))}");
                    }
                    else
                    {
                        lines.Add($"\"UNK_KEY_{result:X}\"" + line.Substring(line.IndexOf(' ')));
                    }
                    continue;
                }
                lines.Add(line);
                continue;
            }

            return string.Join("\r\n", lines);
        }

        class ClipInfoDataCache
        {
            public ClipInfo clip;
            public cLeafBrushNode_s[] leafBrushNodes;
            public cbrush_t[] brushes;
            public Bounds[] brushBounds;
            public cbrushside_t[] brushSides;
            public ClipMaterial[] materials;
        }


        public static string GetCModels()
        {
            var col_world = Game.GetStruct<clipMap_t>(cm);
            var cmodels = Game.GetArray<cmodel_t>(col_world.cmodelsPointer, col_world.numSubModels);
            var gfx_world = Game.GetStruct<GfxWorld>(Game.GetValue<int>(g_world));
            var rmodels = Game.GetArray<GfxBrushModel>(gfx_world.modelsPointer, gfx_world.modelCount);
            var surfs = Game.GetArray<GfxSurface>(gfx_world.dpvs.surfacesPointer, gfx_world.dpvs.staticSurfaceCount);

            Dictionary<int, ClipInfoDataCache> infoMap = new Dictionary<int, ClipInfoDataCache>(); // we think all clipinfo is the same but we shouldnt assume so
            List<string> modelInfos = new List<string>();
            Dictionary<int, string> materialsByPointer = new Dictionary<int, string>();

            // lets get world brush info too
            //{
            //    var cidc = new ClipInfoDataCache();
            //    cidc.clip = col_world.info;
            //    cidc.leafBrushNodes = Game.GetArray<cLeafBrushNode_s>(cidc.clip.leafBrushNodesPointer, cidc.clip.leafBrushNodesCount);
            //    cidc.brushes = Game.GetArray<cbrush_t>(cidc.clip.brushesPointer, (uint)cidc.clip.numBrushes);
            //    cidc.brushBounds = Game.GetArray<Bounds>(cidc.clip.brushBoundsPointer, (uint)cidc.clip.numBrushes);
            //    cidc.brushSides = Game.GetArray<cbrushside_t>(cidc.clip.brushSidesPointer, cidc.clip.numBrushSides);
            //    cidc.materials = Game.GetArray<ClipMaterial>(cidc.clip.materialsPointer, cidc.clip.numMaterials);
            //    infoMap[col_world.pInfo] = cidc;

            //    var clipinfo = cidc;

            //    var leaves = Game.GetArray<cLeaf_t>(col_world.leafsPointer, col_world.numLeafs);
            //    StringBuilder sb = new StringBuilder();

            //    sb.AppendLine($"WORLD:");
            //    int i = 0;
            //    foreach (var leaf in leaves)
            //    {
            //        cLeafBrushNode_s node;
            //        for (var index = 0; (node = clipinfo.leafBrushNodes[leaf.leafBrushNode + index]).leafBrushCount <= 0; index++) ;
            //        sb.AppendLine($"\tLEAF {i}:");
            //        sb.AppendLine($"\t\tclip.brushcount: {node.leafBrushCount}");
            //        var brushes = Game.GetArray<ushort>(node.data.leaf.brushes, node.leafBrushCount);
            //        for (int j = 0; j < node.leafBrushCount; j++)
            //        {
            //            var brush = clipinfo.brushes[brushes[j]];
            //            var bounds = clipinfo.brushBounds[brushes[j]];
            //            sb.AppendLine($"\t\tclip.brushes[{j}]:");
            //            sb.AppendLine($"\t\t\tnumSides (+6): {brush.numsides + 6}");
            //            unsafe
            //            {
            //                sb.AppendLine($"\t\t\tBounds: ({bounds.midPoint[0]}, {bounds.midPoint[1]}, {bounds.midPoint[2]})");
            //                sb.AppendLine($"\t\t\taxialMaterials[6]: m{brush.axialMaterialNum[0]} m{brush.axialMaterialNum[1]} m{brush.axialMaterialNum[2]} m{brush.axialMaterialNum[3]} m{brush.axialMaterialNum[4]} m{brush.axialMaterialNum[5]}");
            //                sb.AppendLine($"\t\t\tfirstAdjacent[6]: {brush.firstAdjacentSideOffsets[0]} {brush.firstAdjacentSideOffsets[1]} {brush.firstAdjacentSideOffsets[2]} {brush.firstAdjacentSideOffsets[3]} {brush.firstAdjacentSideOffsets[4]} {brush.firstAdjacentSideOffsets[5]}");
            //                sb.AppendLine($"\t\t\tedgeCounts[6]: {brush.edgeCount[0]} {brush.edgeCount[1]} {brush.edgeCount[2]} {brush.edgeCount[3]} {brush.edgeCount[4]} {brush.edgeCount[5]}");
            //            }

            //            if (brush.numsides > 0)
            //            {
            //                string[] additionalSides = new string[brush.numsides];
            //                int k = 0;
            //                foreach (var side in clipinfo.brushSides.Skip((brush.sidesPointer - clipinfo.clip.brushSidesPointer) / Marshal.SizeOf(typeof(cbrushside_t))).Take(brush.numsides))
            //                {
            //                    additionalSides[k] = $"m{side.materialNum}";
            //                    k++;
            //                }

            //                sb.AppendLine($"\t\t\tsideMaterials[{brush.numsides}]: {string.Join(" ", additionalSides)}");
            //            }
            //        }


            //        i++;
            //    }

            //    modelInfos.Add(sb.ToString());
            //}

            // clip models and their respective gfx hulls
            for (int i = 0; i < cmodels.Length; i++)
            {
                var cm = cmodels[i];
                var rm = rmodels[i];
                if (!infoMap.ContainsKey(cm.clipInfoPointer))
                {
                    var cidc = new ClipInfoDataCache();
                    cidc.clip = Game.GetStruct<ClipInfo>(cm.clipInfoPointer);
                    cidc.leafBrushNodes = Game.GetArray<cLeafBrushNode_s>(cidc.clip.leafBrushNodesPointer, cidc.clip.leafBrushNodesCount);
                    cidc.brushes = Game.GetArray<cbrush_t>(cidc.clip.brushesPointer, (uint)cidc.clip.numBrushes);
                    cidc.brushBounds = Game.GetArray<Bounds>(cidc.clip.brushBoundsPointer, (uint)cidc.clip.numBrushes);
                    cidc.brushSides = Game.GetArray<cbrushside_t>(cidc.clip.brushSidesPointer, cidc.clip.numBrushSides);
                    cidc.materials = Game.GetArray<ClipMaterial>(cidc.clip.materialsPointer, cidc.clip.numMaterials);
                    infoMap[cm.clipInfoPointer] = cidc;
                }

                var clipinfo = infoMap[cm.clipInfoPointer];
                cLeafBrushNode_s node;
                for (var index = 0; (node = clipinfo.leafBrushNodes[cm.leaf.leafBrushNode + index]).leafBrushCount <= 0; index++) ;
                


                // now lets dump useful data about the objects
                StringBuilder sb = new StringBuilder();

                sb.AppendLine($"MODEL {i}:");
                sb.AppendLine($"\tclip.brushcount: {node.leafBrushCount}");
                unsafe
                {
                    sb.AppendLine($"\tclip.midpoint: ({cm.bounds.midPoint[0]}, {cm.bounds.midPoint[1]}, {cm.bounds.midPoint[2]})");
                }

                var brushes = Game.GetArray<ushort>(node.data.leaf.brushes, node.leafBrushCount);
                for(int j = 0; j < node.leafBrushCount; j++)
                {
                    var brush = clipinfo.brushes[brushes[j]];
                    var bounds = clipinfo.brushBounds[brushes[j]];
                    sb.AppendLine($"\tclip.brushes[{j}]:");
                    unsafe
                    {
                        sb.AppendLine($"\t\tbounds: ({bounds.midPoint[0]}, {bounds.midPoint[1]}, {bounds.midPoint[2]}), ({bounds.halfSize[0]}, {bounds.halfSize[1]}, {bounds.halfSize[2]})");
                    }
                    sb.AppendLine($"\t\tnumSides (+6): {brush.numsides + 6}");
                    unsafe
                    {

                        sb.AppendLine($"\t\taxialMaterials[6]: m{brush.axialMaterialNum[0]} m{brush.axialMaterialNum[1]} m{brush.axialMaterialNum[2]} m{brush.axialMaterialNum[3]} m{brush.axialMaterialNum[4]} m{brush.axialMaterialNum[5]}");
                        sb.AppendLine($"\t\t\tfirstAdjacent[6]: {brush.firstAdjacentSideOffsets[0]} {brush.firstAdjacentSideOffsets[1]} {brush.firstAdjacentSideOffsets[2]} {brush.firstAdjacentSideOffsets[3]} {brush.firstAdjacentSideOffsets[4]} {brush.firstAdjacentSideOffsets[5]}");
                        sb.AppendLine($"\t\t\tedgeCounts[6]: {brush.edgeCount[0]} {brush.edgeCount[1]} {brush.edgeCount[2]} {brush.edgeCount[3]} {brush.edgeCount[4]} {brush.edgeCount[5]}");
                    }

                    if(brush.numsides > 0)
                    {
                        string[] additionalSides = new string[brush.numsides];
                        int k = 0;
                        foreach(var side in clipinfo.brushSides.Skip((brush.sidesPointer - clipinfo.clip.brushSidesPointer) / Marshal.SizeOf(typeof(cbrushside_t))).Take(brush.numsides))
                        {
                            var plane = Game.GetStruct<cplane_s>(side.planePointer);
                            unsafe
                            {
                                additionalSides[k] = $"{{ m{side.materialNum}, plane{{ n: ({plane.normal[0]}, {plane.normal[1]}, {plane.normal[2]}), d: {plane.dist}, type: {plane.type} }}, adj:{side.firstAdjacentSideOffset}, ec:{side.edgeCount} }}";
                            }
                            k++;
                        }

                        sb.AppendLine($"\t\tsides[{brush.numsides}]: {string.Join(" ", additionalSides)}");
                    }
                }

                sb.AppendLine($"\tgfx.surfcount: {rm.surfaceCount}");
                
                unsafe
                {
                    sb.AppendLine($"\tgfx.midpoint: ({rm.bounds.midPoint[0]}, {rm.bounds.midPoint[1]}, {rm.bounds.midPoint[2]})");
                }

                //if(rm.surfaceCount > 0)
                //{
                //    sb.AppendLine("\tgfx.surfaces: ");
                //}

                //for(int j = 0; j < rm.surfaceCount; j++)
                //{
                //    var surf = surfs[rm.startSurfIndex + j];
                //    sb.AppendLine($"\t\tsurfs[{j}].vertexCount: {surf.tris.vertexCount}");
                //    sb.AppendLine($"\t\tsurfs[{j}].firstVertex: {surf.tris.firstVertex}");
                //    sb.AppendLine($"\t\tsurfs[{j}].triCount: {surf.tris.triCount}");
                //    sb.AppendLine($"\t\tsurfs[{j}].baseIndex: {surf.tris.baseIndex}");


                //    if (!materialsByPointer.ContainsKey(surf.materialPointer))
                //    {
                //        materialsByPointer[surf.materialPointer] = Game.GetString(Game.GetValue<int>(surf.materialPointer));
                //    }

                //    sb.AppendLine($"\t\tsurfs[{j}].material: {materialsByPointer[surf.materialPointer]}");

                //    if (j == 0)
                //    {
                //        var verts = Game.GetArray<GfxWorldVertex>(gfx_world.draw.vd.verticesPointer + (Marshal.SizeOf(typeof(GfxWorldVertex)) * surf.tris.baseIndex), surf.tris.triCount * 3);
                //        for (int k = 0; k < verts.Length / 3; k += 3)
                //        {
                //            unsafe
                //            {
                //                // https://stackoverflow.com/questions/39269473/what-property-the-vertex-texcoord-should-have-when-calculating-tangent-space
                //                sb.AppendLine($"\t\tsurfs[{j}].tris[{k / 3}]: ({verts[k].xyz[0]}, {verts[k].xyz[1]}, {verts[k + 1].xyz[2]}) ({verts[k + 1].xyz[0]}, {verts[k + 1].xyz[1]}, {verts[k + 1].xyz[2]}) ({verts[k + 2].xyz[0]}, {verts[k + 2].xyz[1]}, {verts[k + 2].xyz[2]}) {materialsByPointer[surf.materialPointer]} <{verts[k].texCoord[0]} {verts[k].texCoord[1]}, {verts[k + 1].texCoord[0]} {verts[k + 1].texCoord[1]}, {verts[k + 2].texCoord[0]} {verts[k + 2].texCoord[1]}> ...");
                //            }
                //        }
                //    }

                //}

                modelInfos.Add(sb.ToString());
            }

            
            StringBuilder matsb = new StringBuilder();
            matsb.AppendLine("MATERIALS CACHE: ");
            foreach (var cidc in infoMap.Values)
            {
                for(int i = 0; i < cidc.materials.Length; i++)
                {
                    matsb.AppendLine($"\tMaterial {i}: {Game.GetString(cidc.materials[i].namePointer)}");
                }
            }
            modelInfos.Add(matsb.ToString());

            return string.Join("\r\n\r\n", modelInfos);
        }

        private static List<string> planeInfos = new List<string>();
        private static string masterArrayID = null;
        private static List<string> masterArrayPins = new List<string>();
        private static List<string> structPins = new List<string>();
        public static string GetDebugPlanes()
        {
            StringBuilder sb = new StringBuilder();
            //sb.AppendLine("Begin Object Class=/Script/BlueprintGraph.K2Node_MakeArray Name=\"K2Node_MakeArray_MASTER\"");
            //sb.AppendLine($"   NumInputs={masterArrayPins.Count}");
            //sb.AppendLine("   NodePosX=2160");
            //sb.AppendLine("   NodePosY=848");
            //sb.AppendLine($"   NodeGuid={getDebugGUID()}");
            //sb.AppendLine("   CustomProperties Pin (PinId=979462DD481F58E7BE0B029A181D40EB,PinName=\"Array\",Direction=\"EGPD_Output\",PinType.PinCategory=\"struct\",PinType.PinSubCategory=\"\",PinType.PinSubCategoryObject=UserDefinedStruct'\"/Game/StarterContent/Shapes/UnrealL.UnrealL\"',PinType.PinSubCategoryMemberReference=(),PinType.PinValueType=(),PinType.ContainerType=Array,PinType.bIsReference=False,PinType.bIsConst=False,PinType.bIsWeakPointer=False,PinType.bIsUObjectWrapper=False,PersistentGuid=00000000000000000000000000000000,bHidden=False,bNotConnectable=False,bDefaultValueIsReadOnly=False,bDefaultValueIsIgnored=False,bAdvancedView=False,bOrphanedPin=False,)");

            //for(int i = 0; i < planeInfos.Count; i++)
            //{
            //    sb.AppendLine($"   CustomProperties Pin (PinId={masterArrayPins[i]},PinName=\"[{i}]\",PinType.PinCategory=\"struct\",PinType.PinSubCategory=\"\",PinType.PinSubCategoryObject=UserDefinedStruct'\"/Game/StarterContent/Shapes/UnrealL.UnrealL\"',PinType.PinSubCategoryMemberReference=(),PinType.PinValueType=(),PinType.ContainerType=None,PinType.bIsReference=False,PinType.bIsConst=False,PinType.bIsWeakPointer=False,PinType.bIsUObjectWrapper=False,LinkedTo=(K2Node_MakeStruct_{i} {structPins[i]},),PersistentGuid=00000000000000000000000000000000,bHidden=False,bNotConnectable=False,bDefaultValueIsReadOnly=False,bDefaultValueIsIgnored=False,bAdvancedView=False,bOrphanedPin=False,)");
            //}

            //sb.AppendLine("End Object");

            //for(int i = 0; i < planeInfos.Count; i++)
            //{
            //    sb.AppendLine(planeInfos[i]);
            //}

            for (int i = 0; i < planeInfos.Count; i++)
            {
                sb.AppendLine($"BRUSH {i + 1}");
                sb.AppendLine(planeInfos[i]);
                sb.AppendLine($"END BRUSH {i + 1}");
            }

            return sb.ToString();
        }


        class PrettyBounds
        {
            public string midPoint { get; set; }
            public string halfSize { get; set; }
            public PrettyBounds(Bounds bounds)
            {
                unsafe
                {
                    midPoint = $"({bounds.midPoint[0]}, {bounds.midPoint[1]}, {bounds.midPoint[2]})";
                    halfSize = $"({bounds.halfSize[0]}, {bounds.halfSize[1]}, {bounds.halfSize[2]})";
                }
            }
        }

        class PrettyTriggerSlab
        {
            public string dir { get; set; }
            public float midPoint { get; set; }
            public float halfSize { get; set; } 
            public PrettyTriggerSlab(TriggerSlab slab)
            {
                unsafe
                {
                    dir = $"({slab.dir[0]}, {slab.dir[1]}, {slab.dir[2]})";
                }
                midPoint = slab.midPoint;
                halfSize = slab.halfSize;
            }
        }

        class PrettyTriggerHull
        {
            public PrettyBounds bounds { get; set; }
            public string contents { get; set; }
            public PrettyTriggerSlab[] Slabs { get; set; }
            public PrettyTriggerHull(TriggerHull hull, TriggerSlab[] slabs)
            {
                bounds = new PrettyBounds(hull.bounds);
                contents = hull.contents.ToString("X");
                Slabs = new PrettyTriggerSlab[slabs.Length];

                for(int i = 0; i < slabs.Length; i++)
                {
                    Slabs[i] = new PrettyTriggerSlab(slabs[i]);
                }
            }
        }

        class PrettyTrigger
        {
            public string contents { get; set; }
            public int hullCount { get; set; }
            public PrettyTriggerHull[] Hulls { get; set; }
            public PrettyTrigger(TriggerModel mod, PrettyTriggerHull[] hulls)
            {
                contents = mod.contents.ToString("X");
                hullCount = mod.hullCount;
                Hulls = hulls;
            }

            public override string ToString()
            {
                var serializeOptions = new JsonSerializerOptions
                {
                    PropertyNamingPolicy = new LowerNamePol(),
                    PropertyNameCaseInsensitive = true,
                    WriteIndented = true
                };

                return JsonSerializer.Serialize(this, typeof(PrettyTrigger), serializeOptions);
            }
        }

        class PrettyClientTrigger : PrettyTrigger
        {
            public string origin { get; set; }
            public float script_delay { get; set; }
            public ushort audio_trigger { get; set; }
            public char triggerType { get; set; }
            public string trigger_string { get; set; }
            public PrettyClientTrigger(TriggerModel mod, PrettyTriggerHull[] hulls, float[] origin, float scriptDelay, ushort audioTriggerIndex, char triggerType, ushort triggerStringOffset, int triggerStringPointer) : base(mod, hulls)
            {
                this.origin = $"({origin[0]}, {origin[1]}, {origin[2]})";
                script_delay = scriptDelay;
                audio_trigger = audioTriggerIndex;
                this.triggerType = triggerType;
                trigger_string = Game.GetString(triggerStringOffset + triggerStringPointer);
            }
        }

        public static string DebugGetTriggers()
        {
            var ents = Game.GetStruct<MapEnts>(Game.GetValue<int>(XAssetPool + 4 * 0x13));

            var triggerModels = Game.GetArray<TriggerModel>(ents.trigger.modelsPointer, ents.trigger.count);
            var triggerHulls = Game.GetArray<TriggerHull>(ents.trigger.hullsPointer, ents.trigger.hullCount);
            var triggerSlabs = Game.GetArray<TriggerSlab>(ents.trigger.slabsPointer, ents.trigger.slabCount);

            List<PrettyTrigger> triggers = new List<PrettyTrigger>();

            foreach(var trig in triggerModels)
            {
                
                var hulls = triggerHulls.Skip(trig.firstHull).Take(trig.hullCount);
                List<PrettyTriggerHull> phulls = new List<PrettyTriggerHull>();

                foreach(var hull in hulls)
                {
                    var slabs = triggerSlabs.Skip(hull.firstSlab).Take(hull.slabCount);
                    PrettyTriggerHull phull = new PrettyTriggerHull(hull, slabs.ToArray());
                    phulls.Add(phull);
                }
                triggers.Add(new PrettyTrigger(trig, phulls.ToArray()));
            }

            return $"Num triggers: {ents.trigger.count}\r\n\r\n" + string.Join("\r\n\r\n", triggers);
        }

        public static string DebugGetClientTriggers()
        {
            return new ClientTriggersPretty(Game.GetStruct<MapEnts>(Game.GetValue<int>(XAssetPool + 4 * 0x13)).clientTrigger).ToString();
        }

        public static void DumpSkyImageTesting()
        {
            var world = Game.GetStruct<GfxWorld>(Game.GetValue<int>(XAssetPool + 4 * 0x15));
            var firstSky = Game.GetStruct<GfxSky>(world.Skies);
            var dllPath = Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location), "D3dx9d_43.dll");
            var imagePath = Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location), "test.png");

            if(!File.Exists(dllPath))
            {
                using (var stream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("CoD.D3dx9d_43.dll"))
                {
                    using (var file = new FileStream("D3dx9d_43.dll", FileMode.Create, FileAccess.Write))
                    {
                        stream.CopyTo(file);
                    }
                }
            }

            var module = Game["D3dx9d_43.dll"];
            if(module is null)
            {
                module = Game.LoadAndRegisterDllRemote(Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location), "D3dx9d_43.dll"));
            }
            
            Game.Call(module["D3DXSaveTextureToFileA"], imagePath, 3, Game.GetValue<int>(firstSky.SkyImagePointer), 0);
        }

        public static void BeginDump(Map map, string bo3_root_directory)
        {
            // register iw5 helper
            var dllPath = Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location), "Mappa2L_IW5.dll");

            if(File.Exists(dllPath))
            {
                try
                {
                    File.Delete(dllPath);
                }
                catch
                {
                    Game.CallStd<VOID>(Game["kernel32.dll"]["FreeLibrary"], Game["Mappa2L_IW5.dll"].BaseAddress);
                    Game.Refresh();
                    File.Delete(dllPath);
                }
            }

            if (!File.Exists(dllPath))
            {
                using (var stream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("CoD.Mappa2L_IW5.dll"))
                {
                    using (var file = new FileStream("Mappa2L_IW5.dll", FileMode.Create, FileAccess.Write))
                    {
                        stream.CopyTo(file);
                    }
                }
            }

            var module = Game["Mappa2L_IW5.dll"];
            if (module is null)
            {
                module = Game.LoadAndRegisterDllRemote(Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location), "Mappa2L_IW5.dll"));
            }

            dllPath = Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location), "D3dx9d_43.dll");
            if (!File.Exists(dllPath))
            {
                using (var stream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("CoD.D3dx9d_43.dll"))
                {
                    using (var file = new FileStream("D3dx9d_43.dll", FileMode.Create, FileAccess.Write))
                    {
                        stream.CopyTo(file);
                    }
                }
            }

            module = Game["D3dx9d_43.dll"];
            if (module is null)
            {
                module = Game.LoadAndRegisterDllRemote(Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location), "D3dx9d_43.dll"));
            }

            EnvironmentEx.DLog("[MW3] Precaching arrays...");
            PrecacheStructs();

            EnvironmentEx.DLog("[MW3] Precaching materials...");
            PrecacheMaterials();

            EnvironmentEx.DLog("[MW3] Dumping Map Ents...");
            ImportMapEnts(map, bo3_root_directory);

            EnvironmentEx.DLog("[MW3] Dumping Skybox...");
            DumpSky(map, bo3_root_directory);

            EnvironmentEx.DLog("[MW3] Dumping Pending assets...");
            DumpPendingAssets(map, bo3_root_directory);
            EnvironmentEx.DLog("[MW3] Dump complete.");
        }

        static GfxWorld G_World;
        static GfxBrushModel[] G_BrushModels;
        static GfxSurface[] G_Surfaces;

        static clipMap_t CM_World;
        static cLeafBrushNode_s[] CM_LeafBrushNodes;
        static cbrush_t[] CM_Brushes;
        static cmodel_t[] CM_Models;
        static Bounds[] CM_BrushBounds;
        static cbrushside_t[] CM_BrushSides;
        static ClipMaterial[] CM_Materials;
        static MaterialPool Materials;
        static Dictionary<int, string> StringCache = new Dictionary<int, string>();
        static string[] MaterialNames;

        public static void PrecacheStructs()
        {
            G_World = Game.GetStruct<GfxWorld>(Game.GetValue<int>(g_world));
            G_BrushModels = Game.GetArray<GfxBrushModel>(G_World.modelsPointer, G_World.modelCount);
            G_Surfaces = Game.GetArray<GfxSurface>(G_World.dpvs.surfacesPointer, G_World.dpvs.staticSurfaceCount);

            CM_World = Game.GetStruct<clipMap_t>(cm);
            CM_LeafBrushNodes = Game.GetArray<cLeafBrushNode_s>(CM_World.info.leafBrushNodesPointer, CM_World.info.leafBrushNodesCount);
            CM_Brushes = Game.GetArray<cbrush_t>(CM_World.info.brushesPointer, (uint)CM_World.info.numBrushes);
            CM_Models = Game.GetArray<cmodel_t>(CM_World.cmodelsPointer, CM_World.numSubModels);
            CM_BrushBounds = Game.GetArray<Bounds>(CM_World.info.brushBoundsPointer, (uint)CM_World.info.numBrushes);
            CM_BrushSides = Game.GetArray<cbrushside_t>(CM_World.info.brushSidesPointer, CM_World.info.numBrushSides);
            CM_Materials = Game.GetArray<ClipMaterial>(CM_World.info.materialsPointer, CM_World.info.numMaterials);

            for(int i = 0; i < CM_Materials.Length; i++)
            {
                GetGameStringCached(CM_Materials[i].namePointer);
            }
        }

        public static void PrecacheMaterials()
        {
            // TODO gfximagesemantic
            Materials.free_head = Game.GetValue<int>(g_MaterialPool);

            int numMaterials = (Materials.free_head - (g_MaterialPool + 0x8)) / Marshal.SizeOf(typeof(Material)); // should be 0x68
            Materials.Entries = Game.GetArray<Material>(g_MaterialPool + 0x8, numMaterials);
            MaterialNames = new string[numMaterials];
            for (int i = 0; i < Materials.Entries.Length; i++)
            {
                MaterialNames[i] = GetGameStringCached(Materials.Entries[i].info.namePointer);
            }
        }

        public static string GetGameStringCached(int pointer)
        {
            if(StringCache.ContainsKey(pointer))
            {
                return StringCache[pointer];
            }
            return StringCache[pointer] = Game.GetString(pointer);
        }

        public static string GetMats()
        {
            PrecacheMaterials();

            StringBuilder sb = new StringBuilder();

            for (int i = 0; i < Materials.Entries.Length; i++)
            {
                sb.AppendLine($"MATERIAL {i} \"{MaterialNames[i]}\"");
                sb.AppendLine($"\t SurfaceTypeBits: 0x{Materials.Entries[i].info.surfaceTypeBits:X}");
                sb.AppendLine($"\t GameFlags: 0x{Materials.Entries[i].info.gameFlags:X}");

                sb.AppendLine();
            }

            return sb.ToString();
        }

        public static void DumpSky(Map map, string bo3_root_directory)
        {
            Ensure(bo3_root_directory, IMAGE_ASSET_DIR);

            string image_asset_name = GDT_IMAGE($"{map.MapName}_sky", Games.mw3);
            string image_relative_path = Path.Combine(IMAGE_ASSET_DIR, $"{image_asset_name}").Replace("\\", "\\\\").Replace("/", "\\\\");
            string filename = Path.Combine(bo3_root_directory, image_relative_path);
            var world = G_World;
            var firstSky = Game.GetStruct<GfxSky>(world.Skies);
            var res = Game.Call<int>(Game["Mappa2L_IW5.dll"]["IW5_SaveCubemapImagePngCollection"], filename, firstSky.SkyImagePointer);

            if(res != 0)
            {
                throw new Exception($"Failed to export skybox... cubemap exporting failed ({res})!");
            }

            var img0 = Image.FromFile($"{filename}_0.png");
            img0.RotateFlip(RotateFlipType.Rotate90FlipNone);
            img0.Save($"{filename}_0.png");

            var img1 = Image.FromFile($"{filename}_1.png");
            img1.RotateFlip(RotateFlipType.Rotate270FlipNone);
            img1.Save($"{filename}_1.png");

            var img2 = Image.FromFile($"{filename}_2.png");
            img2.RotateFlip(RotateFlipType.Rotate180FlipNone);
            img2.Save($"{filename}_2.png");

            var img5 = Image.FromFile($"{filename}_5.png");
            img5.RotateFlip(RotateFlipType.Rotate180FlipNone);
            img5.Save($"{filename}_5.png");

            int exitCode = Cube2Sphere($"{filename}_2.png", $"{filename}_3.png", $"{filename}_0.png", $"{filename}_1.png", $"{filename}_4.png", $"{filename}_5.png", 4096, 2048, $"{filename}");

            if(exitCode != 0)
            {
                throw new Exception($"Failed to export skybox... conversion failed ({exitCode})!");
            }

            File.Copy($"{filename}0001.png", $"{filename}.png", true);
            File.Delete($"{filename}0001.png");

            var finalImageFlipped = Image.FromFile($"{filename}.png");
            finalImageFlipped.RotateFlip(RotateFlipType.RotateNoneFlipX);
            finalImageFlipped.Save($"{filename}.png");

            exitCode = PNGToEXR($"{filename}.png");

            if (exitCode != 0)
            {
                throw new Exception($"Failed to export skybox... conversion failed for EXR ({exitCode})!");
            }

            File.Delete($"{filename}.png");

            var image_asset = map.Assets.Create(image_asset_name, "image");
            image_asset["baseImage"] = $"{image_relative_path}.exr";
            image_asset["coreSemantic"] = "HDR";
            image_asset["semantic"] = "HDR";
            image_asset["imageType"] = "Texture";
            image_asset["streamable"] = "0";
            image_asset["noPicMip"] = "1"; // PC high res
            image_asset["legallyApproved"] = "1";
            image_asset["clampU"] = "1";
            image_asset["clampV"] = "1";
            image_asset["noMipMaps"] = "1";

            string mtl_asset_name = GDT_MATERIAL($"{map.MapName}_sky", Games.mw3);
            string model_asset_name = GDT_MODEL($"{map.MapName}_sky", Games.mw3);
            var model_asset = map.Assets.Create(model_asset_name, "xmodel");
            foreach (var prop in GDT.SkyboxDefaultProps())
            {
                model_asset[prop.Item1] = prop.Item2;
            }
            model_asset["skinOverride"] = $"mtl_skybox_default {mtl_asset_name}\\r\\n";

            var mtl_asset = map.Assets.Create(mtl_asset_name, "material");
            foreach (var prop in GDT.SkyboxDefaultMaterialProps())
            {
                mtl_asset[prop.Item1] = prop.Item2;
            }
            mtl_asset["colorMap"] = image_asset_name;
            mtl_asset["skyRotation"] = $"0";

            var worldSettings = map.MP.FindEnt("// entity 0");
            map.Skybox = new SkyboxOverride();

            if (worldSettings.Props.ContainsKey("\"skycolor\""))
            {
                var ssi_baked_name = GDT_SSI($"{map.MapName}_sky_b", Games.mw3);
                var ssi_baked = map.Assets.Create(ssi_baked_name, "ssi");
                foreach (var prop in GDT.SkyboxSSIDefaultProps())
                {
                    ssi_baked[prop.Item1] = prop.Item2;
                }
                ssi_baked["skyboxmodel"] = model_asset_name;
                ssi_baked["colorSRGB"] = $"{worldSettings.Props["\"skycolor\""].Value.Substring(1, worldSettings.Props["\"skycolor\""].Value.Length - 2)} 1\"";
                ssi_baked["stops"] = ((float.Parse(ssi_baked["stops"]) * float.Parse(worldSettings.Props["\"skylight\""].Value.Replace("\"", "")))).ToString();
                if (worldSettings.Props.ContainsKey("\"sundirection\""))
                {
                    var split = worldSettings.Props["\"sundirection\""].Value.Replace("\"", "").Split(' ');

                    ssi_baked["pitch"] = ((int)float.Parse(split[0])).ToString();
                    ssi_baked["yaw"] = ((int)float.Parse(split[1])).ToString();
                }
                map.Skybox.SSIBaked = ssi_baked_name;
            }

            if (worldSettings.Props.ContainsKey("\"suncolor\""))
            {
                var ssi_runtime_name = GDT_SSI($"{map.MapName}_sky_r", Games.mw3);
                var ssi_runtime = map.Assets.Create(ssi_runtime_name, "ssi");
                foreach (var prop in GDT.SkyboxSSIDefaultProps())
                {
                    ssi_runtime[prop.Item1] = prop.Item2;
                }
                ssi_runtime["skyboxmodel"] = model_asset_name;
                ssi_runtime["colorSRGB"] = $"{worldSettings.Props["\"suncolor\""].Value.Substring(1, worldSettings.Props["\"suncolor\""].Value.Length - 2)} 1";
                ssi_runtime["stops"] = ((float.Parse(ssi_runtime["stops"]) * float.Parse(worldSettings.Props["\"sunlight\""].Value.Replace("\"", "")))).ToString();

                if(worldSettings.Props.ContainsKey("\"sundirection\""))
                {
                    var split = worldSettings.Props["\"sundirection\""].Value.Replace("\"", "").Split(' ');

                    ssi_runtime["pitch"] = ((int)float.Parse(split[0])).ToString();
                    ssi_runtime["yaw"] = ((int)float.Parse(split[1])).ToString();
                }
               
                map.Skybox.SSIRuntime = ssi_runtime_name;
            }

            map.Skybox.SkyboxModel = model_asset_name;

            // TODO: adjust volume_sun to surround the entire map based on bounds calculations on ent data about the map (so we have to dump skybox last!)
            // TODO: adjust umbra volume to match this size too

            // TODO: "sunradiosity" "0.8" (is this the sun penumbra from radiant?)
        }

        private static int[][][] TriggerTransforms =
        {
            new int[][]{ new int[] { 1, 1, -1 }, new int[] { -1, 1, -1 }, new int[] { -1, -1, -1 } },
            new int[][]{ new int[] { -1, -1, 1 }, new int[] { -1, 1, 1 }, new int[] { 1, 1, 1 } },
            new int[][]{ new int[] { -1, -1, 1 }, new int[] { 1, -1, 1 }, new int[] { 1, -1, -1 } },
            new int[][]{ new int[] { 1, -1, 1 }, new int[] { 1, 1, 1 }, new int[] { 1, 1, -1 } },
            new int[][]{ new int[] { 1, 1, 1 }, new int[] { -1, 1, 1 }, new int[] { -1, 1, -1 } },
            new int[][]{ new int[] { -1, 1, 1 }, new int[] { -1, -1, 1 }, new int[] { -1, -1, -1 } }
        };

        public static void ImportMapEnts(Map map, string bo3_root_directory)
        {
            string mapEnts = GetMapEnts();
            var entMatrix = IWMap.EntMatrixFromList(mapEnts);

            // should have a list of converters for properties which changed between mw3 and bo3 and other important stuff

            if (entMatrix.Count > 0)
            {
                map.ForBoth((IWMap iwmap) =>
                {
                    var ent = iwmap.FindEnt("// entity 0");

                    // copy worldspawn keys
                    foreach(var prop in entMatrix[0])
                    {
                        ent.SetStringProp(prop.Key, prop.Value);
                    }
                });
            }

            var ents = Game.GetStruct<MapEnts>(Game.GetValue<int>(XAssetPool + 4 * 0x13));

            var triggerModels = Game.GetArray<TriggerModel>(ents.trigger.modelsPointer, ents.trigger.count);
            var triggerHulls = Game.GetArray<TriggerHull>(ents.trigger.hullsPointer, ents.trigger.hullCount);
            planeInfos = new List<string>(); // debugging purposes only
            masterArrayPins = new List<string>();
            structPins = new List<string>();
            masterArrayID = getDebugGUID();

            for (int i = 1; i < entMatrix.Count; i++)
            {
                map.ForBoth((IWMap iwmap) =>
                {
                    var ent = iwmap.AddEnt();
                    if (entMatrix[i].ContainsKey("\"model\"") && entMatrix[i]["\"model\""].StartsWith("\"*"))
                    {
                        var origin_string = entMatrix[i]["\"origin\""];
                        var split = origin_string.Substring(1, origin_string.Length - 2).Split(' ');
                        var origin = new float[] { float.Parse(split[0]), float.Parse(split[1]), float.Parse(split[2]) };

                        foreach (var prop in entMatrix[i])
                        {
                            if (prop.Key == "\"model\"" || (prop.Key == "\"origin\""))
                            {
                                continue;
                            }
                            ent.SetStringProp(prop.Key, prop.Value);
                        }

                        int index = int.Parse(entMatrix[i]["\"model\""].Substring(2, entMatrix[i]["\"model\""].Length - 3));
                        if (index > CM_Models.Length)
                        {
                            throw new Exception("Index for clipmodel was out of bounds.");
                        }

                        if(G_BrushModels[index].surfaceCount > 0)
                        {
                            throw new Exception("Brush model has a gfx component.");
                        }

                        cLeafBrushNode_s node;
                        var cmodel = CM_Models[index];
                        for (var x = 0; (node = CM_LeafBrushNodes[cmodel.leaf.leafBrushNode + x]).leafBrushCount <= 0; x++); // grab the correct node for the brush
                        
                        var brushes = Game.GetArray<ushort>(node.data.leaf.brushes, node.leafBrushCount);

                        for (int j = 0; j < node.leafBrushCount; j++)
                        {
                            var brush = CM_Brushes[brushes[j]];
                            var bounds = CM_BrushBounds[brushes[j]];

                            var mapbrush = ent.AddBrush();

                            DumpBModelTris(mapbrush, brush, bounds, origin);
                        }

                        return;
                    }

                    if (entMatrix[i].ContainsKey("\"model\"") && entMatrix[i]["\"model\""].StartsWith("\"?"))
                    {
                        // resolve the brush data, create a brush, and destroy this prop (trigger)
                        var origin_string = entMatrix[i]["\"origin\""];
                        var split = origin_string.Substring(1, origin_string.Length - 2).Split(' ');
                        var origin = new float[] { float.Parse(split[0]), float.Parse(split[1]), float.Parse(split[2]) };
                        foreach (var prop in entMatrix[i])
                        {
                            if (prop.Key == "\"model\"" || (prop.Key == "\"origin\""))
                            {
                                continue;
                            }
                            ent.SetStringProp(prop.Key, prop.Value);
                        }

                        int index = int.Parse(entMatrix[i]["\"model\""].Substring(2, entMatrix[i]["\"model\""].Length - 3));
                        if(index > triggerModels.Length)
                        {
                            throw new Exception("Index for trigger model was out of bounds.");
                        }

                        var tm = triggerModels[index];
                        
                        foreach(var hull in triggerHulls.Skip(tm.firstHull).Take(tm.hullCount))
                        {
                            var brush = ent.AddBrush();
                            List<IWMTri> tris = new List<IWMTri>();
                            
                            foreach(var transform in TriggerTransforms)
                            {
                                var tri = brush.AddTri();
                                tris.Add(tri);

                                foreach(var direction in transform)
                                {
                                    unsafe
                                    {
                                        tri.Verts.Add((origin[0] + hull.bounds.midPoint[0] + direction[0] * hull.bounds.halfSize[0], origin[1] + hull.bounds.midPoint[1] + direction[1] * hull.bounds.halfSize[1], origin[2] + hull.bounds.midPoint[2] + direction[2] * hull.bounds.halfSize[2]));
                                    }
                                }
                            }

                            foreach (var tri in tris)
                            {
                                tri.Tex = "trigger";
                                tri.TexScaleX = tri.TexScaleY = 64;
                                tri.LightMapTex = "lightmap_gray";
                                tri.LightScaleX = tri.LightScaleY = 16384;
                            }
                        }

                        return;
                    }

                    foreach (var prop in entMatrix[i])
                    {
                        if (prop.Key == "\"model\"")
                        {                            
                            // register the xmodel as something we should dump and include in our GDT
                            string model_name = prop.Value.Substring(1, prop.Value.Length - 2);
                            PendingXModels.Add(model_name);

                            ent.SetStringProp(prop.Key, $"\"{GDT_MODEL(model_name, Games.mw3)}\"");
                            continue;
                        }

                        ent.SetStringProp(prop.Key, prop.Value);
                    }
                });
            }
        }

        class BSideWrapper
        {
            public Vector4 plane;
            public Vector4 oPlane;
            public ushort matIndex;
            public byte edgeCount;
            public bool isAxial;

            private List<Vector3> Points = new List<Vector3>();

            public override string ToString()
            {
                return $"{plane} : m{matIndex}";
            }

            public void AddPoint(Vector3 p)
            {
                if (Points.Count >= 3)
                {
                    return;
                }

                if (Points.Count == 2)
                {
                    Vector3 v1 = Points[1] - Points[0];
                    Vector3 v2 = p - Points[0];

                    if(Math.Abs(Vector3.Cross(v1, v2).Length()) <= 0.001) // colinear
                    {
                        return;
                    }
                }
                Points.Add(p);
            }

            public bool SortPoints()
            {
                if(Points.Count < 3)
                {
                    if(isAxial)
                    {
                        return false;
                    }
                    throw new Exception("Unexpected point count for plane!");
                }

                Vector3 center = new Vector3();

                foreach(var p in Points)
                {
                    center += p;
                }

                center /= Points.Count;

                var normal = new Vector3(plane.X, plane.Y, plane.Z);

                Points.Sort((Vector3 a, Vector3 b) => Vector3.Dot(normal, Vector3.Cross(center - a, center - b)) > 0.00001 ? 1 : -1);
                return true;
            }

            public List<Vector3> ToVerts(Vector3 origin)
            {
                List<Vector3> newPoints = new List<Vector3>();
                foreach(var p in Points)
                {
                    newPoints.Add(p + origin);
                }
                return newPoints;
            }
        }

        static string getDebugGUID()
        {
            return Guid.NewGuid().ToString().Replace("{", "").Replace("}", "").Replace("-", "");
        }

        static unsafe void DumpBModelTris(IWMBrush mapbrush, cbrush_t brush, Bounds brushBounds, float[] origin)
        {
            // 1. Form all the planes
            List<BSideWrapper> planes = new List<BSideWrapper>();
            var mid = new Vector3(brushBounds.midPoint[0], brushBounds.midPoint[1], brushBounds.midPoint[2]);
            var translation = mid;

            // Axial Planes (-x, x, -y, y, -z, z)
            BSideWrapper negX = new BSideWrapper();
            negX.isAxial = true;
            negX.plane.X = -1;
            negX.plane.Y = negX.plane.Z = 0;
            negX.plane.W = brushBounds.halfSize[0] - translation.X;
            negX.matIndex = brush.axialMaterialNum[0];
            negX.edgeCount = brush.edgeCount[0];
            planes.Add(negX);

            BSideWrapper posX = new BSideWrapper();
            posX.isAxial = true;
            posX.plane.X = 1;
            posX.plane.Y = posX.plane.Z = 0;
            posX.plane.W = translation.X + brushBounds.halfSize[0];
            posX.matIndex = brush.axialMaterialNum[1];
            posX.edgeCount = brush.edgeCount[1];
            planes.Add(posX);

            BSideWrapper negY = new BSideWrapper();
            negY.isAxial = true;
            negY.plane.Y = -1;
            negY.plane.X = negY.plane.Z = 0;
            negY.plane.W = brushBounds.halfSize[1] - translation.Y;
            negY.matIndex = brush.axialMaterialNum[2];
            negY.edgeCount = brush.edgeCount[2];
            planes.Add(negY);

            BSideWrapper posY = new BSideWrapper();
            posY.isAxial = true;
            posY.plane.Y = 1;
            posY.plane.X = posY.plane.Z = 0;
            posY.plane.W = brushBounds.halfSize[1] + translation.Y;
            posY.matIndex = brush.axialMaterialNum[3];
            posY.edgeCount = brush.edgeCount[3];
            planes.Add(posY);

            BSideWrapper negZ = new BSideWrapper();
            negZ.isAxial = true;
            negZ.plane.Z = -1;
            negZ.plane.X = negZ.plane.Y = 0;
            negZ.plane.W = brushBounds.halfSize[2] - translation.Z;
            negZ.matIndex = brush.axialMaterialNum[4];
            negZ.edgeCount = brush.edgeCount[4];
            planes.Add(negZ);

            BSideWrapper posZ = new BSideWrapper();
            posZ.isAxial = true;
            posZ.plane.Z = 1;
            posZ.plane.X = posZ.plane.Y = 0;
            posZ.plane.W = brushBounds.halfSize[2] + translation.Z;
            posZ.matIndex = brush.axialMaterialNum[5];
            posZ.edgeCount = brush.edgeCount[5];
            planes.Add(posZ);

            // Additional planes
            if (brush.numsides > 0)
            {
                var index = (brush.sidesPointer - CM_World.info.brushSidesPointer) / Marshal.SizeOf(typeof(cbrushside_t));
                foreach(var side in CM_BrushSides.Skip(index).Take(brush.numsides))
                {
                    BSideWrapper sideW = new BSideWrapper();
                    var plane = Game.GetStruct<cplane_s>(side.planePointer);
                    sideW.oPlane = new Vector4(plane.normal[0], plane.normal[1], plane.normal[2], plane.dist);

                    var norm = new Vector3(plane.normal[0], plane.normal[1], plane.normal[2]);

                    //var point = norm * plane.dist;
                    //point += mid;
                    //var len = Vector3.Dot(norm, point);


                    sideW.plane.X = plane.normal[0];
                    sideW.plane.Y = plane.normal[1];
                    sideW.plane.Z = plane.normal[2];
                    sideW.plane.W = plane.dist;
                    sideW.matIndex = side.materialNum;
                    sideW.edgeCount = side.edgeCount;
                    planes.Add(sideW);
                }
            }

            // 2. Intersect all the planes and push vertices into wrappers (see corvid for easiest method) (may need brush vert snapping like in engine though)
            var n = planes.Count;
            HashSet<int> intersectionMatrix = new HashSet<int>();
            
            for(int i = 0; i < n - 2; i++)
            {
                for(int j = 0; j < n - 1; j++)
                {
                    for(int k = 0; k < n; k++)
                    {
                        if(i == k || i == j || j == k)
                        {
                            continue;
                        }

                        int combination = (i << 16) | (j << 8) | k;

                        if(intersectionMatrix.Contains(combination))
                        {
                            continue;
                        }

                        // prevent plane from being intersected again
                        intersectionMatrix.Add((i << 16) | (j << 8) | k);
                        intersectionMatrix.Add((i << 16) | (k << 8) | j);
                        intersectionMatrix.Add((j << 16) | (i << 8) | k);
                        intersectionMatrix.Add((j << 16) | (k << 8) | i);
                        intersectionMatrix.Add((k << 16) | (j << 8) | i);
                        intersectionMatrix.Add((k << 16) | (i << 8) | j);

                        var normal1 = new Vector3(planes[i].plane.X, planes[i].plane.Y, planes[i].plane.Z);
                        var normal2 = new Vector3(planes[j].plane.X, planes[j].plane.Y, planes[j].plane.Z);
                        var normal3 = new Vector3(planes[k].plane.X, planes[k].plane.Y, planes[k].plane.Z);
                        var determinant =
                        (
                            (
                                normal1.X * normal2.Y * normal3.Z +
                                normal1.Y * normal2.Z * normal3.X +
                                normal1.Z * normal2.X * normal3.Y
                            )
                            -
                            (
                                normal1.Z * normal2.Y * normal3.X +
                                normal1.Y * normal2.X * normal3.Z +
                                normal1.X * normal2.Z * normal3.Y
                            )
                        );

                        if(Math.Abs(determinant) <= 0.00001)
                        {
                            continue; // singular
                        }

                        var point = 
                        (
                            Vector3.Cross(normal2, normal3) * planes[i].plane.W +
                            Vector3.Cross(normal3, normal1) * planes[j].plane.W +
                            Vector3.Cross(normal1, normal2) * planes[k].plane.W
                        ) / determinant;

                        // check if point is in front of any plane (this is irrelevant for radiant, right? all that matters is that the winding order is correct...)
                        var bad = false;
                        //for(int ii = 0; ii < planes.Count; ii++)
                        //{
                        //    var norm = new Vector3(planes[ii].plane.X, planes[ii].plane.Y, planes[ii].plane.Z);
                        //    var point_on_plane = norm * planes[ii].plane.W;
                        //    var res = Vector3.Dot(norm, point - point_on_plane);

                        //    if(res < 0.00001) // 0 or close to 0 is on the plane, negative dot is behind the plane
                        //    {
                        //        continue;
                        //    }

                        //    bad = true;
                        //    break;
                        //}

                        // add to applicable surfaces
                        if (!bad)
                        {
                            planes[i].AddPoint(point);
                            planes[j].AddPoint(point);
                            planes[k].AddPoint(point); 
                        }
                    }
                }
            }

            // setup debug blueprint data
            // planeInfos

            StringBuilder pisb = new StringBuilder();
            var stringResource = new StreamReader(System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("CoD.DebugBPNode.txt")).ReadToEnd();
            var splitinfo = stringResource.Split('^');
            var structPinTemplate = splitinfo[3].Substring(2);
            var arrayPinTemplate = splitinfo[2].Substring(2, splitinfo[2].Length - 4);
            var arrayTemplate = splitinfo[1].Substring(2, splitinfo[1].Length - 4);
            var vec4template = splitinfo[0].Substring(0, splitinfo[0].Length - 2);
            int count = 0;
            int baseY = 352;
            List<string> arrayPins = new List<string>();
            List<string> vec4nodes = new List<string>();
            string structVec4PinGuid = getDebugGUID();
            foreach (var plane in planes)
            {
                var outPinGuid = getDebugGUID();
                var connectPinGuid = getDebugGUID();
                var planeVec4String = string.Format(vec4template, "", count, 2016, baseY + count * 160, getDebugGUID(), getDebugGUID(), getDebugGUID(), getDebugGUID(), getDebugGUID(), getDebugGUID(), outPinGuid, plane.plane.X, plane.plane.Y, plane.plane.Z, plane.plane.W, connectPinGuid, planeInfos.Count);
                var planeNodeString = string.Format(arrayPinTemplate, "", connectPinGuid, $"[{count}]", $"K2Node_CallFunction_{count} {outPinGuid}");
                vec4nodes.Add(planeVec4String);
                arrayPins.Add(planeNodeString);
                count++;
            }

            string arrayGuid = getDebugGUID();
            string arrayString = string.Format(arrayTemplate, planeInfos.Count, count, 2432, 560, getDebugGUID(), string.Join("\r\n", arrayPins), arrayGuid, planeInfos.Count, structVec4PinGuid);
            vec4nodes.Insert(0, arrayString);

            string masterPinID = getDebugGUID();
            string structOutGuid = getDebugGUID();
            masterArrayPins.Add(getDebugGUID());
            structPins.Add(structOutGuid);
            string structPin = string.Format(structPinTemplate, planeInfos.Count, 2532, 560, getDebugGUID(), structOutGuid, structVec4PinGuid, planeInfos.Count, arrayGuid, getDebugGUID(), getDebugGUID(), getDebugGUID(), origin[0], origin[1], origin[2], masterPinID);
            vec4nodes.Insert(0, structPin);

            planeInfos.Add(string.Join("\r\n", vec4nodes));

            var vOrigin = new Vector3(origin[0], origin[1], origin[2]);
            foreach (var plane in planes)
            {
                // 3. Clean up tris (force 3 points per plane, sort)
                try
                {
                    if (!plane.SortPoints())
                    {
                        EnvironmentEx.DLog($"WARNING: Brush {planeInfos.Count + 1} at ({origin[0]}, {origin[1]}, {origin[2]}) face plane '{plane}' was culled because it didnt contain enough points to render.");
                        continue;
                    }
                }
                catch
                {
                    // build debug brush node data for the planes to paste into UE4
                    EnvironmentEx.DLog($"WARNING: Brush {planeInfos.Count + 1} at ({origin[0]}, {origin[1]}, {origin[2]}) face plane '{plane}' was culled because it didnt contain enough points to render.");
                    // TODO throw;
                    continue;
                }

                var tri = mapbrush.AddTri();
                tri.Tex = "default";
                tri.TexScaleX = tri.TexScaleY = 64;
                // TODO tri.Tex = "trigger";
                // TODO tri.TexScaleX = tri.TexScaleY = 64; // grab these from the material->texturetable[0].u.image (.width, .height)
                tri.LightMapTex = "lightmap_gray";
                tri.LightScaleX = tri.LightScaleY = 16384;

                // 4. offset them all by the origin of the object
                // TODO: need to also offset them by their own brush bounds box (I think??)
                var verts = plane.ToVerts(vOrigin);

                // 5. add the tris to the mapbrush and setup all the remaining params, including the mat
                for(int i = 0; i < 3; i++)
                {
                    tri.Verts.Add((verts[i].X, verts[i].Y, verts[i].Z));
                }

                // 6. send mat to pending asset dump
                // TODO: need these dumped ahead of time so we know text scale and stuff
            }

            // TODO
        }

        private static HashSet<string> PendingXModels = new HashSet<string>();
        /// <summary>
        /// Dump and register the remaining assets such as xmodels, etc.
        /// </summary>
        /// <param name="map"></param>
        /// <param name="bo3_root_directory"></param>
        public static void DumpPendingAssets(Map map, string bo3_root_directory)
        {
            // TODO: dump pending xmodels, along with their materials, anims, etc.
        }
    }
}
