﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoD
{
    public sealed class GDT
    {
        private Dictionary<string, Dictionary<string, GDTAsset>> AssetDatabase = new Dictionary<string, Dictionary<string, GDTAsset>>();

        private static Dictionary<string, List<(string, string)>> AssetPropDefaults = new Dictionary<string, List<(string, string)>>();

        static GDT()
        {
            RegisterProps("ssi", ("bounceCount", "4"), ("colorSRGB", "0 0 0 1"), ("dynamicShadow", "1"), ("enablesun", "1"), 
                ("ev", "0"), ("evcmp", "0"), ("evmax", "31"), ("evmin", "-32"), ("lensFlare", ""), 
                ("lensFlarePitchOffset", "0"), ("lensFlareYawOffset", "0"), ("penumbra_inches", "1"), 
                ("pitch", "0"), ("skyboxmodel", ""), ("spec_comp", "0"), ("stops", "15"), ("sunCookieAngle", "0"), 
                ("sunCookieIntensity", "0"), ("sunCookieLightDefName", ""), ("sunCookieOffsetX", "0"), ("sunCookieOffsetY", "0"), 
                ("sunCookieRotation", "0"), ("sunCookieScale", "0"), ("sunCookieScrollX", "0"), ("sunCookieScrollY", "0"), ("sunVolumetricCookie", "0"), ("type", "ssi"), ("yaw", "0"));

            RegisterProps("image", ("arabicUnsafe", "0"), ("baseImage", ""), ("clampU", "0"), ("clampV", "0"), ("colorSRGB", "0"), 
                ("compositeChannel1", ""), ("compositeChannel2", ""), ("compositeChannel3", ""), ("compositeChannel4", ""), 
                ("compositeImage1", ""), ("compositeImage2", ""), ("compositeImage3", ""), ("compositeImage4", ""), ("compositeSample1", ""), 
                ("compositeSample2", ""), ("compositeSample3", ""), ("compositeSample4", ""), ("compositeType", ""), ("compressionMethod", "compressed"), 
                ("coreSemantic", "Linear4ch"), ("doNotResize", "0"), ("forceStreaming", "0"), ("fromAlpha", "0"), ("germanUnsafe", "0"), 
                ("glossVarianceScale", "1"), ("himipStreaming", "0"), ("imageType", "Texture"), ("japaneseUnsafe", "0"), ("legallyApproved", "0"), 
                ("matureContent", "0"), ("mipBase", "1/1"), ("mipMask", ""), ("mipMode", "Average"), ("mipNorm", "0"), ("noMipMaps", "0"), ("noPicMip", "0"), 
                ("premulAlpha", "0"), ("semantic", "2d"), ("streamable", "1"), ("textureAtlasColumnCount", "1"), ("textureAtlasRowCount", "1"), ("type", "image"));

            RegisterProps("xmodel", ("arabicUnsafe", "0"), ("autogenLod4", "1"), ("autogenLod4Percent", "7"), ("autogenLod5", "1"), ("autogenLod5Percent", "4"), 
                ("autogenLod6", "1"), ("autogenLod6Percent", "2"), ("autogenLod7", "1"), ("autogenLod7Percent", "1"), ("autogenLowestLod", "1"), 
                ("autogenLowestLodPercent", "12"), ("autogenLowLod", "1"), ("autogenLowLodPercent", "25"), ("autogenMediumLod", "1"), ("autogenMediumLodPercent", "50"), 
                ("boneControllers", ""), ("boneStabilizers", ""), ("BulletCollisionFile", ""), ("BulletCollisionLOD", "None"), ("BulletCollisionRigid", "0"), 
                ("CollisionMap", ""), ("cullOutDiameter", "0"), ("cullOutOffsetCP", "1"), ("cullOutOffsetMP", "1"), ("customAutogenParams", "0"), ("DetailShadows", "0"), 
                ("doNotUse", "0"), ("dropLOD", "Auto"), ("filename", ""), ("forceLod4Rigid", "0"), ("forceLod5Rigid", "0"), ("forceLod6Rigid", "0"), ("forceLod7Rigid", "0"), 
                ("forceLowestLodRigid", "0"), ("forceLowLodRigid", "0"), ("forceMediumLodRigid", "0"), ("forceResident", "0"), ("fp32", "0"), ("germanUnsafe", "0"), 
                ("heroAsset", "0"), ("heroLighting", "0"), ("highLodDist", "0"), ("hitBoxModel", ""), ("isSiege", "0"), ("japaneseUnsafe", "0"), ("lod4Dist", "0"), 
                ("lod4File", ""), ("lod5Dist", "0"), ("lod5File", ""), ("lod6Dist", "0"), ("lod6File", ""), ("lod7Dist", "0"), ("lod7File", ""), ("LODBiasOffsetCP", "0"), 
                ("LODBiasOffsetMP", "0"), ("LODBiasPercent", "0"), ("LodColorPriority", "0.008"), ("lodNormalPriority", "1.54"), ("lodPositionPriority", "12"), ("lodPresets", "performance"), 
                ("LodUvPriority", "3.5"), ("lowestLod", ""), ("lowestLodDist", "0"), ("lowLod", ""), ("lowLodDist", "0"), ("materials", ""), ("mediumLod", ""), 
                ("mediumLodDist", "0"), ("noCastShadow", "0"), ("noOutdoorOcclude", "0"), ("notInEditor", "0"), ("physicsConstraints", ""), ("physicsPreset", ""), 
                ("preserveOriginalUVs", "0"), ("scale", "1"), ("scaleCollMap", "0"), ("ShadowLOD", "Auto"), ("skinOverride", ""), ("submodel0_Name", ""), ("submodel0_OffsetPitch", "0"), 
                ("submodel0_OffsetRoll", "0"), ("submodel0_OffsetX", "0"), ("submodel0_OffsetY", "0"), ("submodel0_OffsetYaw", "0"), ("submodel0_OffsetZ", "0"), 
                ("submodel0_ParentTag", ""), ("submodel10_Name", ""), ("submodel10_OffsetPitch", "0"), ("submodel10_OffsetRoll", "0"), ("submodel10_OffsetX", "0"), ("submodel10_OffsetY", "0"), 
                ("submodel10_OffsetYaw", "0"), ("submodel10_OffsetZ", "0"), ("submodel10_ParentTag", ""), ("submodel11_Name", ""), ("submodel11_OffsetPitch", "0"), ("submodel11_OffsetRoll", "0"), 
                ("submodel11_OffsetX", "0"), ("submodel11_OffsetY", "0"), ("submodel11_OffsetYaw", "0"), ("submodel11_OffsetZ", "0"), ("submodel11_ParentTag", ""), ("submodel12_Name", ""), 
                ("submodel12_OffsetPitch", "0"), ("submodel12_OffsetRoll", "0"), ("submodel12_OffsetX", "0"), ("submodel12_OffsetY", "0"), ("submodel12_OffsetYaw", "0"), ("submodel12_OffsetZ", "0"), 
                ("submodel12_ParentTag", ""), ("submodel13_Name", ""), ("submodel13_OffsetPitch", "0"), ("submodel13_OffsetRoll", "0"), ("submodel13_OffsetX", "0"), ("submodel13_OffsetY", "0"), 
                ("submodel13_OffsetYaw", "0"), ("submodel13_OffsetZ", "0"), ("submodel13_ParentTag", ""), ("submodel14_Name", ""), ("submodel14_OffsetPitch", "0"), ("submodel14_OffsetRoll", "0"), 
                ("submodel14_OffsetX", "0"), ("submodel14_OffsetY", "0"), ("submodel14_OffsetYaw", "0"), ("submodel14_OffsetZ", "0"), ("submodel14_ParentTag", ""), ("submodel15_Name", ""), 
                ("submodel15_OffsetPitch", "0"), ("submodel15_OffsetRoll", "0"), ("submodel15_OffsetX", "0"), ("submodel15_OffsetY", "0"), ("submodel15_OffsetYaw", "0"), ("submodel15_OffsetZ", "0"), 
                ("submodel15_ParentTag", ""), ("submodel1_Name", ""), ("submodel1_OffsetPitch", "0"), ("submodel1_OffsetRoll", "0"), ("submodel1_OffsetX", "0"), ("submodel1_OffsetY", "0"), 
                ("submodel1_OffsetYaw", "0"), ("submodel1_OffsetZ", "0"), ("submodel1_ParentTag", ""), ("submodel2_Name", ""), ("submodel2_OffsetPitch", "0"), ("submodel2_OffsetRoll", "0"), 
                ("submodel2_OffsetX", "0"), ("submodel2_OffsetY", "0"), ("submodel2_OffsetYaw", "0"), ("submodel2_OffsetZ", "0"), ("submodel2_ParentTag", ""), ("submodel3_Name", ""), ("submodel3_OffsetPitch", "0"), 
                ("submodel3_OffsetRoll", "0"), ("submodel3_OffsetX", "0"), ("submodel3_OffsetY", "0"), ("submodel3_OffsetYaw", "0"), ("submodel3_OffsetZ", "0"), ("submodel3_ParentTag", ""), 
                ("submodel4_Name", ""), ("submodel4_OffsetPitch", "0"), ("submodel4_OffsetRoll", "0"), ("submodel4_OffsetX", "0"), ("submodel4_OffsetY", "0"), ("submodel4_OffsetYaw", "0"), 
                ("submodel4_OffsetZ", "0"), ("submodel4_ParentTag", ""), ("submodel5_Name", ""), ("submodel5_OffsetPitch", "0"), ("submodel5_OffsetRoll", "0"), ("submodel5_OffsetX", "0"), 
                ("submodel5_OffsetY", "0"), ("submodel5_OffsetYaw", "0"), ("submodel5_OffsetZ", "0"), ("submodel5_ParentTag", ""), ("submodel6_Name", ""), ("submodel6_OffsetPitch", "0"), 
                ("submodel6_OffsetRoll", "0"), ("submodel6_OffsetX", "0"), ("submodel6_OffsetY", "0"), ("submodel6_OffsetYaw", "0"), ("submodel6_OffsetZ", "0"), ("submodel6_ParentTag", ""), 
                ("submodel7_Name", ""), ("submodel7_OffsetPitch", "0"), ("submodel7_OffsetRoll", "0"), ("submodel7_OffsetX", "0"), ("submodel7_OffsetY", "0"), ("submodel7_OffsetYaw", "0"), 
                ("submodel7_OffsetZ", "0"), ("submodel7_ParentTag", ""), ("submodel8_Name", ""), ("submodel8_OffsetPitch", "0"), ("submodel8_OffsetRoll", "0"), ("submodel8_OffsetX", "0"), ("submodel8_OffsetY", "0"), 
                ("submodel8_OffsetYaw", "0"), ("submodel8_OffsetZ", "0"), ("submodel8_ParentTag", ""), ("submodel9_Name", ""), ("submodel9_OffsetPitch", "0"), ("submodel9_OffsetRoll", "0"), ("submodel9_OffsetX", "0"), 
                ("submodel9_OffsetY", "0"), ("submodel9_OffsetYaw", "0"), ("submodel9_OffsetZ", "0"), ("submodel9_ParentTag", ""), ("type", "rigid"), ("usage_attachment", "0"), ("usage_hero", "0"), ("usage_view", "0"), 
                ("usage_weapon", "0"), ("usage_zombie_body", "0"), ("usage_zombie_world_prop", "0"));

            RegisterProps("material", ("adsZscaleOn", "0"), ("aiClip", "0"), ("aiSightClip", "0"), ("alphaDissolveInt", "255"), ("alphaDissolveMarginAbove", "0"), 
                ("alphaMap", ""), ("alphaRevealMap", ""), ("alphaRevealRamp", "0.5"), ("alphaRevealSoftEdge", "0.01"), ("alphaTexture", "0"), ("arabicUnsafe", "0"), 
                ("areaLight", "0"), ("backlightScatterColor", "1 1 1 1"), ("bulletClip", "0"), ("camoDetailMap", ""), ("camoMaskMap", ""), ("canShootClip", "0"), 
                ("caulk", "0"), ("causticMap", ""), ("cg00_w", "0"), ("cg00_x", "0"), ("cg00_y", "0"), ("cg00_z", "0"), ("cg01_w", "0"), ("cg01_x", "0"), ("cg01_y", "0"), 
                ("cg01_z", "0"), ("cg02_w", "0"), ("cg02_x", "0"), ("cg02_y", "0"), ("cg02_z", "0"), ("cg03_w", "0"), ("cg03_x", "0"), ("cg03_y", "0"), ("cg03_z", "0"), 
                ("cg04_w", "0"), ("cg04_x", "0"), ("cg04_y", "0"), ("cg04_z", "0"), ("cg05_w", "0"), ("cg05_x", "0"), ("cg05_y", "0"), ("cg05_z", "0"), ("cg06_w", "0"), 
                ("cg06_x", "0"), ("cg06_y", "0"), ("cg06_z", "0"), ("cg07_w", "0"), ("cg07_x", "0"), ("cg07_y", "0"), ("cg07_z", "0"), ("cg08_w", "0"), ("cg08_x", "0"), 
                ("cg08_y", "0"), ("cg08_z", "0"), ("cg09_w", "0"), ("cg09_x", "0"), ("cg09_y", "0"), ("cg09_z", "0"), ("cg10_w", "0"), ("cg10_x", "0"), ("cg10_y", "0"), 
                ("cg10_z", "0"), ("cg11_w", "0"), ("cg11_x", "0"), ("cg11_y", "0"), ("cg11_z", "0"), ("cg12_w", "0"), ("cg12_x", "0"), ("cg12_y", "0"), ("cg12_z", "0"), 
                ("cg13_w", "0"), ("cg13_x", "0"), ("cg13_y", "0"), ("cg13_z", "0"), ("cg14_w", "0"), ("cg14_x", "0"), ("cg14_y", "0"), ("cg14_z", "0"), ("cg15_w", "0"), 
                ("cg15_x", "0"), ("cg15_y", "0"), ("cg15_z", "0"), ("cg16_w", "0"), ("cg16_x", "0"), ("cg16_y", "0"), ("cg16_z", "0"), ("cg17_w", "0"), ("cg17_x", "0"), 
                ("cg17_y", "0"), ("cg17_z", "0"), ("cg18_w", "0"), ("cg18_x", "0"), ("cg18_y", "0"), ("cg18_z", "0"), ("cg19_w", "0"), ("cg19_x", "0"), ("cg19_y", "0"), 
                ("cg19_z", "0"), ("cg20_w", "0"), ("cg20_x", "0"), ("cg20_y", "0"), ("cg20_z", "0"), ("cg21_w", "0"), ("cg21_x", "0"), ("cg21_y", "0"), ("cg21_z", "0"), 
                ("cg22_w", "0"), ("cg22_x", "0"), ("cg22_y", "0"), ("cg22_z", "0"), ("cg23_w", "0"), ("cg23_x", "0"), ("cg23_y", "0"), ("cg23_z", "0"), ("cg24_w", "0"), 
                ("cg24_x", "0"), ("cg24_y", "0"), ("cg24_z", "0"), ("cg25_w", "0"), ("cg25_x", "0"), ("cg25_y", "0"), ("cg25_z", "0"), ("cg26_w", "0"), ("cg26_x", "0"), 
                ("cg26_y", "0"), ("cg26_z", "0"), ("cg27_w", "0"), ("cg27_x", "0"), ("cg27_y", "0"), ("cg27_z", "0"), ("cg28_w", "0"), ("cg28_x", "0"), ("cg28_y", "0"), 
                ("cg28_z", "0"), ("cg29_w", "0"), ("cg29_x", "0"), ("cg29_y", "0"), ("cg29_z", "0"), ("cg30_w", "0"), ("cg30_x", "0"), ("cg30_y", "0"), ("cg30_z", "0"), 
                ("cg31_w", "0"), ("cg31_x", "0"), ("cg31_y", "0"), ("cg31_z", "0"), ("cinematicGamma", "0"), ("clampU", "0"), ("clampV", "0"), ("cloudDarkColor", "0.5 0.5 0.5 0.5"), 
                ("cloudLayer1Blend0", "1"), ("cloudLayer1Blend1", "0"), ("cloudLayer1Distance", "12288"), ("cloudLayer1Feather", "4096"), ("cloudLayer1Height", "8000"), 
                ("cloudLayer1UScale", "2048"), ("cloudLayer1UScroll", "0"), ("cloudLayer1VScale", "2048"), ("cloudLayer1VScroll", "0"), ("cloudLayer2Blend0", "1"), 
                ("cloudLayer2Blend1", "0"), ("cloudLayer2Distance", "12288"), ("cloudLayer2Feather", "4096"), ("cloudLayer2Height", "6000"), ("cloudLayer2UScale", "2048"), 
                ("cloudLayer2UScroll", "0"), ("cloudLayer2VScale", "2048"), ("cloudLayer2VScroll", "0"), ("cloudLightColor", "1 1 1 1"), ("cloudLiningColor", "1 0.75 0.5 1"), 
                ("cloudLiningSize", "16"), ("cloudMask1UScale", "65536"), ("cloudMask1UScroll", "0.5"), ("cloudMask1VScale", "65536"), ("cloudMask1VScroll", "0.5"), 
                ("cloudMask2UScale", "65536"), ("cloudMask2UScroll", "0.5"), ("cloudMask2VScale", "65536"), ("cloudMask2VScroll", "0.5"), ("colorDetailMap", ""), ("colorDetailScaleX", "8"), 
                ("colorDetailScaleY", "8"), ("colorMap", ""), ("colorMap00", ""), ("colorMap01", ""), ("colorMap02", ""), ("colorMap03", ""), ("colorMap04", ""), ("colorMap05", ""), 
                ("colorMap06", ""), ("colorMap07", ""), ("colorMap08", ""), ("colorMap09", ""), ("colorMap10", ""), ("colorMap11", ""), ("colorMap12", ""), ("colorMap13", ""), 
                ("colorMap14", ""), ("colorMap15", ""), ("colorObjMax", "1 1 0.5 1"), ("colorObjMaxBaseBlend", "1"), ("colorObjMin", "0.25 0.15 0 1"), ("colorObjMinBaseBlend", "1"), 
                ("colorTint", "1 1 1 1"), ("colorTint1", "1 1 1 1"), ("colorTint2", "1 1 1 1"), ("colorTint3", "1 1 1 1"), ("colorTint4", "1 1 1 1"), ("colorWriteAlpha", "Enable"), 
                ("colorWriteBlue", "Enable"), ("colorWriteGreen", "Enable"), ("colorWriteRed", "Enable"), ("columnCount", "1"), ("converterOnlyNormal", "0"), ("cosinePowerMap", ""), 
                ("customString", ""), ("customTemplate", ""), ("depthMultiplier", "3"), ("desaturationAmount", "0"), ("detail", "0"), ("detail1ScaleX", "8"), ("detail1ScaleY", "8"), 
                ("detail2ScaleX", "8"), ("detail2ScaleY", "8"), ("detail3ScaleX", "8"), ("detail3ScaleY", "8"), ("detailMap", ""), ("detailScaleHeight", "1"), ("detailScaleHeight1", "1"), 
                ("detailScaleHeight2", "1"), ("detailScaleHeight3", "1"), ("detailScaleX", "8"), ("detailScaleY", "8"), ("dFlowColorB", "1"), ("dFlowColorG", "1"), ("dFlowColorR", "1"), 
                ("dFlowDepthFeather", "0.3125"), ("dFlowFrameBufferOps", "0"), ("dFlowIndexOfRefraction", "1.333"), ("dFlowNormalScale", "1"), ("dFlowNormalUVScaleU", "1"), ("dFlowNormalUVScaleV", "1"), 
                ("dFlowSpecLobeAWeight", "0.625"), ("dFlowSpecLobeRoughnessA", "0.02"), ("dFlowSpecLobeRoughnessB", "0.123"), ("dFlowSpeed", "0.25"), ("dFlowTextureFraction", "0.15"), 
                ("dFlowThinFilmDepth", "0.5"), ("dFlowThinFilmEnable", "0"), ("dFlowThinFilmNormalScale", "1"), ("dFlowThinFilmPeriod", "60"), ("dFlowThinFilmWaveLengthB", "440"), 
                ("dFlowThinFilmWaveLengthG", "550"), ("dFlowThinFilmWaveLengthR", "600"), ("dFlowUVScaleU", "1"), ("dFlowUVScaleV", "1"), ("distFalloff", "0"), ("distFalloffBeginDistance", "200"), 
                ("distFalloffEndDistance", "10"), ("distortionColorBehavior", "scales distortion strength*"), ("distortionScaleX", "0.5"), ("distortionScaleY", "0.5"), ("doNotUse", "0"), 
                ("doubleSidedLighting", "0"), ("drawToggle", "0"), ("dummy", "0"), ("emissiveFalloff", "0"), ("emissiveIncompetence", "0"), ("enableGTAO", "0"), ("enemyMaterial", ""), 
                ("envMapExponent", "1"), ("envMapMax", "1"), ("envMapMin", "1"), ("eyeOffsetDepth", "0"), ("failedPBR", "0"), ("falloff", "0"), ("falloffBeginAngle", "35"), ("falloffBeginColor", "1 1 1 1"), 
                ("falloffEndAngle", "65"), ("falloffEndColor", "0.5 0.5 0.5 0.5"), ("filterColor", "aniso2x (mip linear)"), ("filterColor00", "linear (mip nearest)"), 
                ("filterColor01", "linear (mip nearest)"), ("filterColor02", "linear (mip nearest)"), ("filterColor03", "linear (mip nearest)"), ("filterColor04", "linear (mip nearest)"), 
                ("filterColor05", "linear (mip nearest)"), ("filterColor06", "linear (mip nearest)"), ("filterColor07", "linear (mip nearest)"), ("filterColor08", "linear (mip nearest)"), 
                ("filterColor09", "linear (mip nearest)"), ("filterColor10", "linear (mip nearest)"), ("filterColor11", "linear (mip nearest)"), ("filterColor12", "linear (mip nearest)"), 
                ("filterColor13", "linear (mip nearest)"), ("filterColor14", "linear (mip nearest)"), ("filterColor15", "linear (mip nearest)"), ("filterColorDetail", "linear (mip linear)"), 
                ("filterDetail", "aniso2x (mip linear)"), ("filterNormal", "aniso2x (mip linear)"), ("filterOcc", "linear (mip nearest)"), ("filterReveal", "linear (mip nearest)"), 
                ("filterSpecular", "linear (mip nearest)"), ("filterTransition", "linear (mip nearest)"), ("fixedGloss", "0"), ("flagRipple1ScrollU", "0"), ("flagRipple1ScrollV", "0"), 
                ("flagRipple2ScrollU", "0"), ("flagRipple2ScrollV", "0"), ("flagRippleHeight", "1"), ("flagRippleScale", "1"), ("flagW", "0"), ("flagX", "1"), ("flagY", "0"), ("flagZ", "0.5"), 
                ("flickerLookupMap", ""), ("flickerMax", "1"), ("flickerMin", "0"), ("flickerPower", "1"), ("flickerSeedU", "0"), ("flickerSeedV", "0"), ("flickerSpeed", "1"), 
                ("foamColor", "1 1 1 1"), ("foamMapEnable", "0"), ("foamWaveIncrease", "0"), ("gCheckBox00", "0"), ("gCheckBox01", "0"), ("gCheckBox02", "0"), ("gCheckBox03", "0"), 
                ("gCheckBox04", "0"), ("gCheckBox05", "0"), ("gCheckBox06", "0"), ("gCheckBox07", "0"), ("gColor00_B", "1"), ("gColor00_G", "1"), ("gColor00_R", "1"), ("gColor01_B", "1"), 
                ("gColor01_G", "1"), ("gColor01_R", "1"), ("gColor02_B", "1"), ("gColor02_G", "1"), ("gColor02_R", "1"), ("gColor03_B", "1"), ("gColor03_G", "1"), ("gColor03_R", "1"), 
                ("gColor04_B", "1"), ("gColor04_G", "1"), ("gColor04_R", "1"), ("gColor05_B", "1"), ("gColor05_G", "1"), ("gColor05_R", "1"), ("gColor06_B", "1"), ("gColor06_G", "1"), 
                ("gColor06_R", "1"), ("gColor07_B", "1"), ("gColor07_G", "1"), ("gColor07_R", "1"), ("gColorStops00", "0"), ("gColorStops01", "0"), ("gColorStops02", "0"), ("gColorStops03", "0"), 
                ("gColorStops04", "0"), ("gColorStops05", "0"), ("gColorStops06", "0"), ("gColorStops07", "0"), ("gCustomReflectionProbe", "0"), ("gCustomReflectionProbeB", "1"), 
                ("gCustomReflectionProbeBias", "0"), ("gCustomReflectionProbeG", "1"), ("gCustomReflectionProbeR", "1"), ("gCustomReflectionProbeScaleB", "1"), ("gCustomReflectionProbeScaleG", "1"), 
                ("gCustomReflectionProbeScaleR", "1"), ("gCustomReflectionProbeStops", "0"), ("gDepthFeather", "10"), ("gDistortion00", "0"), ("gDistortion01", "0"), ("gDistortion02", "0"), 
                ("gDistortion03", "0"), ("germanUnsafe", "0"), ("gFoamScrollAngle0", "90"), ("gFoamScrollAngle1", "180"), ("gFoamScrollAngle2", "270"), ("gFoamScrollAngle3", "0"), ("gFoamScrollSpeed0", "25"), 
                ("gFoamScrollSpeed1", "29.75"), ("gFoamScrollSpeed2", "25.0625"), ("gFoamScrollSpeed3", "38.25"), ("gFoamUVNoiseAngle0", "90"), ("gFoamUVNoiseAngle1", "180"), ("gFoamUVNoiseScale0", "100"), 
                ("gFoamUVNoiseScale1", "100"), ("gFoamUVNoiseSpeed0", "0.125"), ("gFoamUVNoiseSpeed1", "0.0125"), ("gFoamUVScale0", "1024"), ("gFoamUVScale1", "1795"), ("gFoamUVScale2", "3142"), ("gFoamUVScale3", "5497"), 
                ("gHorizonDistance", "10000"), ("glossRangeMax", "13"), ("glossRangeMax1", "17"), ("glossRangeMax2", "17"), ("glossRangeMax3", "17"), ("glossRangeMin", "0"), ("glossRangeMin1", "0"), ("glossRangeMin2", "0"), 
                ("glossRangeMin3", "0"), ("glossSurfaceType", "<custom>"), ("gNormalScale00", "1"), ("gNormalScale01", "1"), ("gNormalScale02", "1"), ("gNormalScale03", "1"), ("gReflectionRay0", "50"), ("gReflectionRay1", "100"), 
                ("gReflectionRay2", "200"), ("gRefractionAmount", "8"), ("grimeAnglePitch", "0"), ("grimeAngleYaw", "0"), ("gScale0", "0"), ("gScale1", "0"), ("gScale2", "0"), ("gScale3", "0"), 
                ("gScale4", "0"), ("gScale5", "0"), ("gScale6", "0"), ("gScale7", "0"), ("gSharedU_Offset00", "0"), ("gSharedU_Offset01", "0"), ("gSharedU_Offset02", "0"), ("gSharedU_Offset03", "0"), 
                ("gSharedU_Scale00", "1"), ("gSharedU_Scale01", "1"), ("gSharedU_Scale02", "1"), ("gSharedU_Scale03", "1"), ("gSharedV_Offset00", "0"), ("gSharedV_Offset01", "0"), ("gSharedV_Offset02", "0"), 
                ("gSharedV_Offset03", "0"), ("gSharedV_Scale00", "1"), ("gSharedV_Scale01", "1"), ("gSharedV_Scale02", "1"), ("gSharedV_Scale03", "1"), ("gSpecIndexOfRefraction", "1.333"), 
                ("gSpecLobeAWeight", "0.375"), ("gSpecLobeRoughnessA", "0.05"), ("gSpecLobeRoughnessB", "0.1875"), ("gUVScaleOffSet00_OffsetU", "0"), ("gUVScaleOffSet00_OffsetV", "0"), ("gUVScaleOffSet00_ScaleU", "128"), 
                ("gUVScaleOffSet00_ScaleV", "128"), ("gUVScaleOffSet01_OffsetU", "0"), ("gUVScaleOffSet01_OffsetV", "0"), ("gUVScaleOffSet01_ScaleU", "128"), ("gUVScaleOffSet01_ScaleV", "128"), 
                ("gUVScaleOffSet02_OffsetU", "0"), ("gUVScaleOffSet02_OffsetV", "0"), ("gUVScaleOffSet02_ScaleU", "128"), ("gUVScaleOffSet02_ScaleV", "128"), ("gUVScaleOffSet03_OffsetU", "0"), 
                ("gUVScaleOffSet03_OffsetV", "0"), ("gUVScaleOffSet03_ScaleU", "128"), ("gUVScaleOffSet03_ScaleV", "128"), ("gUVScroll00_Angle", "0"), ("gUVScroll00_ScaleU", "512"), ("gUVScroll00_ScaleV", "512"), 
                ("gUVScroll00_Speed", "1"), ("gUVScroll01_Angle", "0"), ("gUVScroll01_ScaleU", "512"), ("gUVScroll01_ScaleV", "512"), ("gUVScroll01_Speed", "1"), ("gUVScroll02_Angle", "0"), 
                ("gUVScroll02_ScaleU", "256"), ("gUVScroll02_ScaleV", "256"), ("gUVScroll02_Speed", "1"), ("gUVScroll03_Angle", "0"), ("gUVScroll03_ScaleU", "256"), ("gUVScroll03_ScaleV", "256"), 
                ("gUVScroll03_Speed", "1"), ("gWetnessNormalStrength", "0.25"), ("gWetnessRoughnessLobe0", "0.05"), ("hasEditorMaterial", "0"), ("heatmap", ""), ("heroAsset", "0"), ("heroLight", "0"), 
                ("ignoreScriptVectors", "0"), ("imageTime", "1"), ("invertFalloff", "0"), ("itemClip", "0"), ("japaneseUnsafe", "0"), ("kelvinMax", "1800"), ("kelvinMin", "768"), ("layerSortDecal", "Debris (top)"), 
                ("levelsInputMax", "255"), ("levelsInputMax1", "255"), ("levelsInputMin", "0"), ("levelsInputMin1", "0"), ("levelsOutputMax", "255"), ("levelsOutputMax1", "255"), ("levelsOutputMin", "0"), 
                ("levelsOutputMin1", "0"), ("lightDemoteHint", "0"), ("lightPortal", "0"), ("locale_afghanistan", "0"), ("locale_angola", "0"), ("locale_antarctica", "0"), ("locale_carrier", "0"), ("locale_core", "0"), 
                ("locale_cuba", "0"), ("locale_kyrgyzstan", "0"), ("locale_la", "0"), ("locale_mp_dlc", "0"), ("locale_myanmar", "0"), ("locale_nepal", "0"), ("locale_nicaragua", "0"), ("locale_pakistan", "0"), 
                ("locale_panama", "0"), ("locale_ship", "0"), ("locale_singapore", "0"), ("locale_test", "0"), ("locale_tools", "0"), ("locale_yemen", "0"), ("locale_zombie", "0"), ("materialCategory", "Geometry"), 
                ("materialType", ""), ("matureContent", "0"), ("maxRayDepth", "1000"), ("missileClip", "0"), ("mount", "0"), ("noCastShadow", "0"), ("noDraw", "0"), ("noDrop", "0"), ("noDynamicLight", "0"), 
                ("noFallDamage", "0"), ("noFog", "0"), ("noImpact", "0"), ("noMarks", "0"), ("nonColliding", "0"), ("nonSolid", "0"), ("noPenetrate", "0"), ("noReceiveDynamicShadow", "0"), ("normalFlattening", "1"), 
                ("normalHeightScale", "1"), ("normalMap", ""), ("normalsFlowScaleMin", "0"), ("normalVarianceScale", "1"), ("noSteps", "0"), ("notInBoats", "0"), ("objectiveColorsEnabled", "0"), ("occMap", ""), 
                ("oceanSunBrightness", "10"), ("oceanSunSize", "0.0125"), ("onlyCastShadow", "0"), ("onlyCastSunShadow", "0"), ("orientNormalsToFlow", "0"), ("origin", "0"), ("outdoorOccluder", "0"), ("outdoorOnly", "0"), 
                ("overwaterOpacityScale", "0.75"), ("physicsGeom", "0"), ("playerClip", "0"), ("playerVehicleClip", "0"), ("portal", "0"), ("reflectionMapEnable", "0"), ("reflectionProbeAmount", "1"), ("revealScaleX", "1"), 
                ("revealScaleY", "1"), ("rowCount", "1"), ("scaleNormalsWithFlow", "0"), ("scaleRGB", "8"), ("scatterColorB", "0.145"), ("scatterColorG", "0.195"), ("scatterColorR", "0.145"), ("screenReflection", "0"), 
                ("seethruprlx_alphapower", "12"), ("seethruprlx_height", "0.06"), ("seethruprlx_solidrad", "0.1"), ("showAdvancedOptions", "<none>*"), ("sky", "0"), ("skyCenterX", "0"), ("skyCenterY", "0"), 
                ("skyCenterZ", "0"), ("skyFogFraction", "1"), ("skyHalfSpace", "1"), ("skyRotation", "0"), ("skyScaleRGB", "8"), ("skySize", "8000"), ("skyStops", "3"), ("slick", "0"), ("sort", "<default>*"), 
                ("specAmount", "1"), ("specColorDesaturate1", "1"), ("specColorDesaturate2", "1"), ("specColorDesaturate3", "1"), ("specColorIntensity1", "0"), ("specColorIntensity2", "0"), ("specColorIntensity3", "0"), 
                ("specColorMap", ""), ("specColorStrength", "100"), ("specColorTint", "0.760757 0.764664 0.764664 1"), ("specColorTint1", "0.760757 0.764664 0.764664 1"), ("specColorTint2", "0.760757 0.764664 0.764664 1"), 
                ("specColorTint3", "0.760757 0.764664 0.764664 1"), ("specDetailMap", ""), ("specDetailScaleX", "8"), ("specDetailScaleY", "8"), ("specDetailStrength", "100"), ("specMapEnable", "0"), ("specReflectionMap", ""), 
                ("specTint_b", "0.2"), ("specTint_g", "0.2"), ("specTint_r", "0.2"), ("spotLightWeight", "0"), ("ssrRayDepthScale", "1"), ("ssrRayStepSize", "20"), ("stairs", "0"), ("stencil", "Disable"), ("stencilFunc1", "Always"), 
                ("stencilFunc2", "Always"), ("stencilOpFail1", "Keep"), ("stencilOpFail2", "Keep"), ("stencilOpPass1", "Keep"), ("stencilOpPass2", "Keep"), ("stencilOpZFail1", "Keep"), ("stencilOpZFail2", "Keep"), ("structural", "0"), 
                ("surfaceClimbType", "<none>"), ("surfaceType", "<error>"), ("sw_codetexture_00", ""), ("sw_codetexture_01", ""), ("sw_codetexture_02", ""), ("sw_codetexture_03", ""), ("sw_codetexture_04", ""), ("sw_codetexture_05", ""), 
                ("sw_codetexture_06", ""), ("sw_codetexture_07", ""), ("sw_codetexture_08", ""), ("sw_codetexture_09", ""), ("sw_codetexture_10", ""), ("sw_codetexture_11", ""), ("sw_codetexture_12", ""), ("sw_codetexture_13", ""), 
                ("sw_codetexture_14", ""), ("sw_codetexture_15", ""), ("sw_static_bool_00", "0"), ("sw_static_bool_01", "0"), ("sw_static_bool_02", "0"), ("sw_static_bool_03", "0"), ("sw_static_bool_04", "0"), ("sw_static_bool_05", "0"), 
                ("sw_static_bool_06", "0"), ("sw_static_bool_07", "0"), ("sw_static_bool_08", "0"), ("sw_static_bool_09", "0"), ("sw_static_bool_10", "0"), ("sw_static_bool_11", "0"), ("sw_static_bool_12", "0"), ("sw_static_bool_13", "0"), 
                ("sw_static_bool_14", "0"), ("sw_static_bool_15", "0"), ("sw_static_enum_00", ""), ("sw_static_enum_01", ""), ("sw_static_enum_02", ""), ("sw_static_enum_03", ""), ("sw_static_enum_04", ""), ("sw_static_enum_05", ""), 
                ("sw_static_enum_06", ""), ("sw_static_enum_07", ""), ("sw_static_enum_08", ""), ("sw_static_enum_09", ""), ("sw_static_enum_10", ""), ("sw_static_enum_11", ""), ("sw_static_enum_12", ""), ("sw_static_enum_13", ""), 
                ("sw_static_enum_14", ""), ("sw_static_enum_15", ""), ("sw_static_float_00", "0"), ("sw_static_float_01", "0"), ("sw_static_float_02", "0"), ("sw_static_float_03", "0"), ("sw_static_float_04", "0"), ("sw_static_float_05", "0"), 
                ("sw_static_float_06", "0"), ("sw_static_float_07", "0"), ("sw_static_float_08", "0"), ("sw_static_float_09", "0"), ("sw_static_float_10", "0"), ("sw_static_float_11", "0"), ("sw_static_float_12", "0"), 
                ("sw_static_float_13", "0"), ("sw_static_float_14", "0"), ("sw_static_float_15", "0"), ("sw_static_int_00", "0"), ("sw_static_int_01", "0"), ("sw_static_int_02", "0"), ("sw_static_int_03", "0"), 
                ("sw_static_int_04", "0"), ("sw_static_int_05", "0"), ("sw_static_int_06", "0"), ("sw_static_int_07", "0"), ("sw_static_int_08", "0"), ("sw_static_int_09", "0"), ("sw_static_int_10", "0"), ("sw_static_int_11", "0"), 
                ("sw_static_int_12", "0"), ("sw_static_int_13", "0"), ("sw_static_int_14", "0"), ("sw_static_int_15", "0"), ("sway_x", "1"), ("sway_y", "1"), ("template", "material.template"), ("tensionCompressHeight", "1"), 
                ("tensionPower", "1"), ("tensionStrength", "1"), ("tensionStretchHeight", "1"), ("tessSize", "0"), ("texScroll", "0"), ("texTile00", "tile both*"), ("texTile01", "tile both*"), ("texTile02", "tile both*"), 
                ("texTile03", "tile both*"), ("texTile04", "tile both*"), ("texTile05", "tile both*"), ("texTile06", "tile both*"), ("texTile07", "tile both*"), ("texTile08", "tile both*"), ("texTile09", "tile both*"), ("texTile10", "tile both*"), 
                ("texTile11", "tile both*"), ("texTile12", "tile both*"), ("texTile13", "tile both*"), ("texTile14", "tile both*"), ("texTile15", "tile both*"), ("textureAtlasColumnCount", "1"), ("textureAtlasFrameRate", "1"), 
                ("textureAtlasRowCount", "1"), ("thermalMaterial", ""), ("tileColor", "tile both*"), ("tileNormal", "tile both*"), ("tileOcc", "tile both*"), ("tileReveal", "tile both*"), ("tileSpecular", "tile both*"), 
                ("tileTransition", "tile both*"), ("tilingHeight", "<auto>"), ("tilingWidth", "<auto>"), ("transColorMap", ""), ("transColorTint", "1 1 1 1"), ("transGlossMap", ""), ("transGlossRangeMax", "13"), ("transGlossRangeMin", "0"), 
                ("translucentShadowOpacity", "32"), ("transNormalHeightScale", "1"), ("transNormalMap", ""), ("transparent", "0"), ("transRevealMap", ""), ("transRevealRamp", "0.5"), ("transRevealSoftEdge", "0.01"), ("transScaleX", "8"), 
                ("transScaleY", "8"), ("transSpecColorTint", "0.760757 0.764664 0.764664 1"), ("transSpecMap", ""), ("treeCanopyDisablePrepass", "0"), ("treeCanopyEnableSway", "0"), ("treeCanopyMinimumSway", "0"), ("treeCanopyNewVertexControl", "0"), 
                ("treeCanopyRadialLighting", "0.5"), ("treeCanopyScaleRotationAngles", "0.1"), ("treeCanopyScatterColor", "0.7 0.83 0.36 0"), ("treeCanopySpecularGloss", "0.3"), ("treeCanopySwayRange", "0.2"), ("umbraOccluder", "0"), 
                ("umbraTarget", "0"), ("underwaterOpacityScale", "0.75"), ("usage", "<not in editor>"), ("uScale", "1"), ("uScroll", "0"), ("uScroll1", "0"), ("useAlphaDissolve", "0"), ("useAlphaReveal", "0"), ("useAsCamo", "0"), ("useLegacyNormalEncoding", "0"), 
                ("useLoopedScreenspaceReflection", "0"), ("useOldHDRScale", "0"), ("useParticleCloudVerticalAlign", "0"), ("useScreenspaceReflection", "0"), ("useSpotLight", "0"), ("useSpotLightShadow", "0"), ("useUVRotate", "0"), ("useUVScroll", "0"), 
                ("useWorldOffsets1", "1"), ("useWorldOffsets2", "1"), ("useWorldOffsets3", "1"), ("utilityClip", "0"), ("uvMotionToggle1", "0"), ("uvMotionToggle2", "0"), ("uvMotionToggle3", "0"), ("uvMotionToggle4", "0"), ("uvRotationRate", "0"), 
                ("uvRotationRate1", "0"), ("uvRotationRate2", "0"), ("uvScrollAngle", "0"), ("uvScrollAngle1", "0"), ("uvScrollRate", "0"), ("vehicleClip", "0"), ("vertexAlphaAO", "0"), ("vScale", "1"), ("vScroll", "0"), ("vScroll1", "0"), 
                ("waterBobAmount", "5"), ("waterBobSpeed", "0"), ("waterBobWaveLength", "8192"), ("waterColor", "0.19 0.3 0.15 0"), ("waterDepthFeather", "1"), ("waterDetailNormalFadeMax", "0"), ("waterDetailNormalFadeMin", "0"), 
                ("waterDetailNormalScale", "0.25"), ("waterDetailNormalScrollAngleA", "7"), ("waterDetailNormalScrollAngleB", "173"), ("waterDetailNormalScrollSpeedA", "0"), ("waterDetailNormalScrollSpeedB", "0"), 
                ("waterDetailNormalTextureScale", "512"), ("waterDetailNormalTextureScaleB", "512"), ("waterFarColorB", "0.415"), ("waterFarColorG", "0.415"), ("waterFarColorR", "0.415"), ("waterFarDistance", "10000"), 
                ("waterFeather", "0.05"), ("waterFoamLayer0Scale", "1024"), ("waterFoamLayer0Scroll", "25"), ("waterFoamLayer1Scale", "1795"), ("waterFoamLayer1Scroll", "-29.75"), ("waterFoamLayer2Scale", "3142"), ("waterFoamLayer2Scroll", "-35.0625"),
                ("waterFoamLayer3Scale", "5497"), ("waterFoamLayer3Scroll", "38.25"), ("waterFoamMax", "10"), ("waterFoamMin", "0.5"), ("waterGroundColor", "0.26 0.27 0.11 0"), ("waterNearColorB", "0.145"), ("waterNearColorG", "0.145"), 
                ("waterNearColorR", "0.145"), ("waterNormalScale", "0.25"), ("waterNormalScrollAngleA", "3"), ("waterNormalScrollAngleB", "177"), ("waterNormalScrollSpeedA", "0"), ("waterNormalScrollSpeedB", "0"), ("waterNormalTextureScale", "2048"), 
                ("waterNormalTextureScaleB", "2048"), ("waterOcean", "0"), ("waterOpacity", "0"), ("waterOpacityAmount", "0.75"), ("waterRefract", "30"), ("waterRefractionAmount", "0"), ("waterRoughness", "0.1"), ("waterScrollX0", "-1.98"), 
                ("waterScrollX1", "4.44"), ("waterScrollX2", "3.44"), ("waterScrollY0", "1.32"), ("waterScrollY1", "-5.18"), ("waterScrollY2", "3.18"), ("waterShadowAdjust", "0"), ("waterShadowOffset", "0"), ("waterSkyColor", "0.63 0.77 0.77 0"), 
                ("waterSpecularAmount", "1"), ("waterSpecularRoughnessA", "0.0625"), ("waterSpecularRoughnessB", "0.1875"), ("waterThinFilm", "0"), ("waterThinFilmAmount", "0.05"), ("waterThinFilmDepth", "0.25"), 
                ("waterVertexGerstnerWaveAmplitude0", "0"), ("waterVertexGerstnerWaveAmplitude1", "0"), ("waterVertexGerstnerWaveAmplitude2", "0"), ("waterVertexGerstnerWaveAmplitude3", "0"), ("waterVertexGerstnerWaveAngle0", "0"), 
                ("waterVertexGerstnerWaveAngle1", "0"), ("waterVertexGerstnerWaveAngle2", "0"), ("waterVertexGerstnerWaveAngle3", "0"), ("waterVertexGerstnerWavePhase0", "0"), ("waterVertexGerstnerWavePhase1", "0"), 
                ("waterVertexGerstnerWavePhase2", "0"), ("waterVertexGerstnerWavePhase3", "0"), ("waterVertexGerstnerWaves", "0"), ("waterVertexGerstnerWaveSpeed0", "0"), ("waterVertexGerstnerWaveSpeed1", "0"), ("waterVertexGerstnerWaveSpeed2", "0"), 
                ("waterVertexGerstnerWaveSpeed3", "0"), ("waterVertexGerstnerWaveSteepness0", "0"), ("waterVertexGerstnerWaveSteepness1", "0"), ("waterVertexGerstnerWaveSteepness2", "0"), ("waterVertexGerstnerWaveSteepness3", "0"), 
                ("waterVertexGerstnerWaveWavelength0", "0"), ("waterVertexGerstnerWaveWavelength1", "0"), ("waterVertexGerstnerWaveWavelength2", "0"), ("waterVertexGerstnerWaveWavelength3", "0"), ("waterWeaveAmount", "5"), ("waterWeaveSpeed", "0"), 
                ("waterWeaveWaveLength", "8192"), ("wetnessInvert", "0"), ("zFeather", "0"), ("zFeatherComputeSprites", "0"), ("zFeatherDepth", "40"), ("zFeatherMaskViewModel", "0"), ("zFeatherOverride", "0"), ("zFeatherPlane", "0"), 
                ("zFeatherPlaneDir", "1"), ("zFeatherViewModel", "0"), ("zoomMax", "1"), ("zoomMin", "1"), ("zoomRate", "0"));
        }

        private GDT()
        {         
        }

        public static GDT FromLines(string[] lines)
        {
            GDT gdt = new GDT();

            for (int i = 1; i < lines.Length - 1; i++)
            {
                if(lines[i].Trim().Length < 1)
                {
                    continue;
                }

                if (lines[i].StartsWith("{"))
                {
                    continue;
                }

                if (lines[i].StartsWith("}"))
                {
                    break;
                }

                GDTAsset asset = new GDTAsset();
                var header = lines[i].Trim();
                asset.Name = header.Substring(1, header.IndexOf('"', 1) - 1);
                if(header.IndexOf("(") > 0)
                {
                    var start =  header.IndexOf("(") + 3;
                    asset["gdf"] = header.Substring(start, header.LastIndexOf('.') - start);
                }
                else if(header.IndexOf("[") > 0)
                {
                    var start = header.IndexOf("(") + 3;
                    string name = header.Substring(header.IndexOf("[") + 3, header.LastIndexOf('"') - start);
                    var other = gdt.FindAssetByName(name);
                    foreach(var propname in other.Props.Keys)
                    {
                        asset[propname] = other[propname];
                    }
                }
                else
                {
                    throw new NotImplementedException();
                }

                i += 2; // skip open bracket
                
                while(!lines[i].StartsWith("\t}"))
                {
                    var line = lines[i].Trim();
                    var propName = line.Substring(1, line.IndexOf('"', 1) - 1);
                    var propVal = line.Substring(propName.Length + 4, line.Length - (propName.Length + 5));
                    asset[propName] = propVal;
                    i++;
                }

                foreach(var prop in AssetPropDefaults[asset["gdf"]])
                {
                    if(!asset.Props.ContainsKey(prop.Item1))
                    {
                        throw new Exception($"Asset '{asset.Name}' in gdt does not contain all the properties necessary for its type '{asset["type"]}' (missing '{prop.Item1}').");
                    }
                }

                if(!gdt.AssetDatabase.ContainsKey(asset["gdf"]))
                {
                    gdt.AssetDatabase[asset["gdf"]] = new Dictionary<string, GDTAsset>();
                }

                gdt.AssetDatabase[asset["gdf"]][asset.Name] = asset;
            }

            return gdt;
        }

        public GDTAsset FindAssetByName(string name)
        {
            foreach(var list in AssetDatabase)
            {
                if(list.Value.ContainsKey(name))
                {
                    return list.Value[name];
                }
            }
            return null;
        }

        private static void RegisterProps(string gdfName, params (string, string)[] propNames)
        {
            if(!AssetPropDefaults.ContainsKey(gdfName))
            {
                AssetPropDefaults[gdfName] = new List<(string, string)>();
            }
            AssetPropDefaults[gdfName].AddRange(propNames);
        }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("{\n");
            foreach(var list in AssetDatabase.Values)
            {
                foreach(var asset in list.Values)
                {
                    sb.Append(asset.ToString());
                }
            }
            sb.Append("}\n");
            return sb.ToString();
        }

        public GDTAsset Create(string name, string type)
        {
            if (!AssetPropDefaults.ContainsKey(type))
            {
                throw new Exception($"Unexpected asset type '{type}'");
            }
            if(!AssetDatabase.ContainsKey(type))
            {
                AssetDatabase[type] = new Dictionary<string, GDTAsset>();
            }
            AssetDatabase[type][name] = new GDTAsset();
            AssetDatabase[type][name]["gdf"] = type;
            foreach (var propDefault in AssetPropDefaults[type])
            {
                AssetDatabase[type][name][propDefault.Item1] = propDefault.Item2;
            }
            AssetDatabase[type][name].Name = name;
            return AssetDatabase[type][name];
        }

        public static (string, string)[] SkyboxDefaultProps()
        {
            return new (string, string)[] { ("arabicUnsafe", "0"), ("autogenLod4", "0"), ("autogenLod4Percent", "8"), ("autogenLod5", "0"), ("autogenLod5Percent", "4"), ("autogenLod6", "0"), ("autogenLod6Percent", "2"), ("autogenLod7", "0"), ("autogenLod7Percent", "1"), ("autogenLowestLod", "0"), ("autogenLowestLodPercent", "15"), ("autogenLowLod", "0"), ("autogenLowLodPercent", "30"), ("autogenMediumLod", "0"), ("autogenMediumLodPercent", "50"), ("boneControllers", ""), ("boneStabilizers", ""), ("BulletCollisionFile", ""), ("BulletCollisionLOD", "None"), ("BulletCollisionRigid", "0"), ("CollisionMap", ""), ("cullOutDiameter", "0"), ("cullOutOffsetCP", "1"), ("cullOutOffsetMP", "1"), ("customAutogenParams", "0"), ("DetailShadows", "0"), ("doNotUse", "0"), ("dropLOD", "Auto"), ("filename", "t6_props\\\\vista\\\\skybox\\\\t6_skybox.xmodel_bin"), ("forceLod4Rigid", "0"), ("forceLod5Rigid", "0"), ("forceLod6Rigid", "0"), ("forceLod7Rigid", "0"), ("forceLowestLodRigid", "0"), ("forceLowLodRigid", "0"), ("forceMediumLodRigid", "0"), ("forceResident", "0"), ("fp32", "0"), ("germanUnsafe", "0"), ("heroAsset", "0"), ("heroLighting", "0"), ("highLodDist", "0"), ("hitBoxModel", ""), ("isSiege", "0"), ("japaneseUnsafe", "0"), ("lod4Dist", "0"), ("lod4File", ""), ("lod5Dist", "0"), ("lod5File", ""), ("lod6Dist", "0"), ("lod6File", ""), ("lod7Dist", "0"), ("lod7File", ""), ("LODBiasOffsetCP", "0"), ("LODBiasOffsetMP", "0"), ("LODBiasPercent", "0"), ("LodColorPriority", "0.008"), ("lodNormalPriority", "1.54"), ("lodPositionPriority", "12"), ("lodPresets", "custom"), ("LodUvPriority", "3.5"), ("lowestLod", ""), ("lowestLodDist", "0"), ("lowLod", ""), ("lowLodDist", "0"), ("materials", "mtl_skybox_default\\r\\n"), ("mediumLod", ""), ("mediumLodDist", "0"), ("noCastShadow", "0"), ("noOutdoorOcclude", "0"), ("notInEditor", "0"), ("physicsConstraints", ""), ("physicsPreset", ""), ("preserveOriginalUVs", "0"), ("scale", "1"), ("scaleCollMap", "0"), ("ShadowLOD", "Auto"), ("skinOverride", "mtl_skybox_default mtl_skybox_default_day\\r\\n"), ("submodel0_Name", ""), ("submodel0_OffsetPitch", "0"), ("submodel0_OffsetRoll", "0"), ("submodel0_OffsetX", "0"), ("submodel0_OffsetY", "0"), ("submodel0_OffsetYaw", "0"), ("submodel0_OffsetZ", "0"), ("submodel0_ParentTag", ""), ("submodel1_Name", ""), ("submodel1_OffsetPitch", "0"), ("submodel1_OffsetRoll", "0"), ("submodel1_OffsetX", "0"), ("submodel1_OffsetY", "0"), ("submodel1_OffsetYaw", "0"), ("submodel1_OffsetZ", "0"), ("submodel1_ParentTag", ""), ("submodel10_Name", ""), ("submodel10_OffsetPitch", "0"), ("submodel10_OffsetRoll", "0"), ("submodel10_OffsetX", "0"), ("submodel10_OffsetY", "0"), ("submodel10_OffsetYaw", "0"), ("submodel10_OffsetZ", "0"), ("submodel10_ParentTag", ""), ("submodel11_Name", ""), ("submodel11_OffsetPitch", "0"), ("submodel11_OffsetRoll", "0"), ("submodel11_OffsetX", "0"), ("submodel11_OffsetY", "0"), ("submodel11_OffsetYaw", "0"), ("submodel11_OffsetZ", "0"), ("submodel11_ParentTag", ""), ("submodel12_Name", ""), ("submodel12_OffsetPitch", "0"), ("submodel12_OffsetRoll", "0"), ("submodel12_OffsetX", "0"), ("submodel12_OffsetY", "0"), ("submodel12_OffsetYaw", "0"), ("submodel12_OffsetZ", "0"), ("submodel12_ParentTag", ""), ("submodel13_Name", ""), ("submodel13_OffsetPitch", "0"), ("submodel13_OffsetRoll", "0"), ("submodel13_OffsetX", "0"), ("submodel13_OffsetY", "0"), ("submodel13_OffsetYaw", "0"), ("submodel13_OffsetZ", "0"), ("submodel13_ParentTag", ""), ("submodel14_Name", ""), ("submodel14_OffsetPitch", "0"), ("submodel14_OffsetRoll", "0"), ("submodel14_OffsetX", "0"), ("submodel14_OffsetY", "0"), ("submodel14_OffsetYaw", "0"), ("submodel14_OffsetZ", "0"), ("submodel14_ParentTag", ""), ("submodel15_Name", ""), ("submodel15_OffsetPitch", "0"), ("submodel15_OffsetRoll", "0"), ("submodel15_OffsetX", "0"), ("submodel15_OffsetY", "0"), ("submodel15_OffsetYaw", "0"), ("submodel15_OffsetZ", "0"), ("submodel15_ParentTag", ""), ("submodel2_Name", ""), ("submodel2_OffsetPitch", "0"), ("submodel2_OffsetRoll", "0"), ("submodel2_OffsetX", "0"), ("submodel2_OffsetY", "0"), ("submodel2_OffsetYaw", "0"), ("submodel2_OffsetZ", "0"), ("submodel2_ParentTag", ""), ("submodel3_Name", ""), ("submodel3_OffsetPitch", "0"), ("submodel3_OffsetRoll", "0"), ("submodel3_OffsetX", "0"), ("submodel3_OffsetY", "0"), ("submodel3_OffsetYaw", "0"), ("submodel3_OffsetZ", "0"), ("submodel3_ParentTag", ""), ("submodel4_Name", ""), ("submodel4_OffsetPitch", "0"), ("submodel4_OffsetRoll", "0"), ("submodel4_OffsetX", "0"), ("submodel4_OffsetY", "0"), ("submodel4_OffsetYaw", "0"), ("submodel4_OffsetZ", "0"), ("submodel4_ParentTag", ""), ("submodel5_Name", ""), ("submodel5_OffsetPitch", "0"), ("submodel5_OffsetRoll", "0"), ("submodel5_OffsetX", "0"), ("submodel5_OffsetY", "0"), ("submodel5_OffsetYaw", "0"), ("submodel5_OffsetZ", "0"), ("submodel5_ParentTag", ""), ("submodel6_Name", ""), ("submodel6_OffsetPitch", "0"), ("submodel6_OffsetRoll", "0"), ("submodel6_OffsetX", "0"), ("submodel6_OffsetY", "0"), ("submodel6_OffsetYaw", "0"), ("submodel6_OffsetZ", "0"), ("submodel6_ParentTag", ""), ("submodel7_Name", ""), ("submodel7_OffsetPitch", "0"), ("submodel7_OffsetRoll", "0"), ("submodel7_OffsetX", "0"), ("submodel7_OffsetY", "0"), ("submodel7_OffsetYaw", "0"), ("submodel7_OffsetZ", "0"), ("submodel7_ParentTag", ""), ("submodel8_Name", ""), ("submodel8_OffsetPitch", "0"), ("submodel8_OffsetRoll", "0"), ("submodel8_OffsetX", "0"), ("submodel8_OffsetY", "0"), ("submodel8_OffsetYaw", "0"), ("submodel8_OffsetZ", "0"), ("submodel8_ParentTag", ""), ("submodel9_Name", ""), ("submodel9_OffsetPitch", "0"), ("submodel9_OffsetRoll", "0"), ("submodel9_OffsetX", "0"), ("submodel9_OffsetY", "0"), ("submodel9_OffsetYaw", "0"), ("submodel9_OffsetZ", "0"), ("submodel9_ParentTag", ""), ("type", "rigid"), ("usage_attachment", "0"), ("usage_hero", "0"), ("usage_view", "0"), ("usage_weapon", "0"), ("usage_zombie_body", "0"), ("usage_zombie_world_prop", "0") };
        }

        public static (string, string)[] SkyboxDefaultMaterialProps()
        {
            return new (string, string)[] { ("adsZscaleOn", "0"), ("aiClip", "0"), ("aiSightClip", "0"), ("alphaDissolveInt", "255"), ("alphaDissolveMarginAbove", "0"), ("alphaMap", ""), ("alphaRevealMap", ""), ("alphaRevealRamp", "0.5"), ("alphaRevealSoftEdge", "0.01"), ("alphaTexture", "0"), ("arabicUnsafe", "0"), ("areaLight", "0"), ("backlightScatterColor", "1 1 1 1"), ("bulletClip", "0"), ("camoDetailMap", ""), ("camoMaskMap", ""), ("canShootClip", "0"), ("caulk", "0"), ("causticMap", ""), ("cg00_w", "2.5"), ("cg00_x", "2.5"), ("cg00_y", "2.5"), ("cg00_z", "2.5"), ("cg01_w", "2.5"), ("cg01_x", "2.5"), ("cg01_y", "2.5"), ("cg01_z", "2.5"), ("cg02_w", "2.5"), ("cg02_x", "2.5"), ("cg02_y", "2.5"), ("cg02_z", "2.5"), ("cg03_w", "2.5"), ("cg03_x", "2.5"), ("cg03_y", "2.5"), ("cg03_z", "2.5"), ("cg04_w", "2.5"), ("cg04_x", "2.5"), ("cg04_y", "2.5"), ("cg04_z", "2.5"), ("cg05_w", "2.5"), ("cg05_x", "2.5"), ("cg05_y", "2.5"), ("cg05_z", "2.5"), ("cg06_w", "2.5"), ("cg06_x", "2.5"), ("cg06_y", "2.5"), ("cg06_z", "2.5"), ("cg07_w", "2.5"), ("cg07_x", "2.5"), ("cg07_y", "2.5"), ("cg07_z", "2.5"), ("cg08_w", "2.5"), ("cg08_x", "2.5"), ("cg08_y", "2.5"), ("cg08_z", "2.5"), ("cg09_w", "2.5"), ("cg09_x", "2.5"), ("cg09_y", "2.5"), ("cg09_z", "2.5"), ("cg10_w", "2.5"), ("cg10_x", "2.5"), ("cg10_y", "2.5"), ("cg10_z", "2.5"), ("cg11_w", "2.5"), ("cg11_x", "2.5"), ("cg11_y", "2.5"), ("cg11_z", "2.5"), ("cg12_w", "2.5"), ("cg12_x", "2.5"), ("cg12_y", "2.5"), ("cg12_z", "2.5"), ("cg13_w", "2.5"), ("cg13_x", "2.5"), ("cg13_y", "2.5"), ("cg13_z", "2.5"), ("cg14_w", "2.5"), ("cg14_x", "2.5"), ("cg14_y", "2.5"), ("cg14_z", "2.5"), ("cg15_w", "2.5"), ("cg15_x", "2.5"), ("cg15_y", "2.5"), ("cg15_z", "2.5"), ("cg16_w", "2.5"), ("cg16_x", "2.5"), ("cg16_y", "2.5"), ("cg16_z", "2.5"), ("cg17_w", "2.5"), ("cg17_x", "2.5"), ("cg17_y", "2.5"), ("cg17_z", "2.5"), ("cg18_w", "2.5"), ("cg18_x", "2.5"), ("cg18_y", "2.5"), ("cg18_z", "2.5"), ("cg19_w", "2.5"), ("cg19_x", "2.5"), ("cg19_y", "2.5"), ("cg19_z", "2.5"), ("cg20_w", "2.5"), ("cg20_x", "2.5"), ("cg20_y", "2.5"), ("cg20_z", "2.5"), ("cg21_w", "2.5"), ("cg21_x", "2.5"), ("cg21_y", "2.5"), ("cg21_z", "2.5"), ("cg22_w", "2.5"), ("cg22_x", "2.5"), ("cg22_y", "2.5"), ("cg22_z", "2.5"), ("cg23_w", "2.5"), ("cg23_x", "2.5"), ("cg23_y", "2.5"), ("cg23_z", "2.5"), ("cg24_w", "2.5"), ("cg24_x", "2.5"), ("cg24_y", "2.5"), ("cg24_z", "2.5"), ("cg25_w", "2.5"), ("cg25_x", "2.5"), ("cg25_y", "2.5"), ("cg25_z", "2.5"), ("cg26_w", "2.5"), ("cg26_x", "2.5"), ("cg26_y", "2.5"), ("cg26_z", "2.5"), ("cg27_w", "2.5"), ("cg27_x", "2.5"), ("cg27_y", "2.5"), ("cg27_z", "2.5"), ("cg28_w", "2.5"), ("cg28_x", "2.5"), ("cg28_y", "2.5"), ("cg28_z", "2.5"), ("cg29_w", "2.5"), ("cg29_x", "2.5"), ("cg29_y", "2.5"), ("cg29_z", "2.5"), ("cg30_w", "2.5"), ("cg30_x", "2.5"), ("cg30_y", "2.5"), ("cg30_z", "2.5"), ("cg31_w", "2.5"), ("cg31_x", "2.5"), ("cg31_y", "2.5"), ("cg31_z", "2.5"), ("cinematicGamma", "0"), ("clampU", "0"), ("clampV", "0"), ("cloudDarkColor", "0.500000 0.500000 0.500000 0.500000"), ("cloudLayer1Blend0", "1"), ("cloudLayer1Blend1", "0"), ("cloudLayer1Distance", "19000"), ("cloudLayer1Feather", "16384"), ("cloudLayer1Height", "2000"), ("cloudLayer1UScale", "4000"), ("cloudLayer1UScroll", "0.006"), ("cloudLayer1VScale", "4000"), ("cloudLayer1VScroll", "0.006"), ("cloudLayer2Blend0", "0"), ("cloudLayer2Blend1", "0"), ("cloudLayer2Distance", "12288"), ("cloudLayer2Feather", "4096"), ("cloudLayer2Height", "1000"), ("cloudLayer2UScale", "2048"), ("cloudLayer2UScroll", "0"), ("cloudLayer2VScale", "2048"), ("cloudLayer2VScroll", "0"), ("cloudLightColor", "1.000000 1.000000 1.000000 1.000000"), ("cloudLiningColor", "1.000000 0.750000 0.500000 1.000000"), ("cloudLiningSize", "16"), ("cloudMask1UScale", "65536"), ("cloudMask1UScroll", "0.5"), ("cloudMask1VScale", "65536"), ("cloudMask1VScroll", "0.5"), ("cloudMask2UScale", "65536"), ("cloudMask2UScroll", "0.5"), ("cloudMask2VScale", "65536"), ("cloudMask2VScroll", "0.5"), ("colorDetailMap", ""), ("colorDetailScaleX", "8"), ("colorDetailScaleY", "8"), ("colorMap", "skybox_default_day_ft"), ("colorMap00", "$whitetransparent"), ("colorMap01", ""), ("colorMap02", "$whitetransparent"), ("colorMap03", ""), ("colorMap04", ""), ("colorMap05", ""), ("colorMap06", ""), ("colorMap07", ""), ("colorMap08", ""), ("colorMap09", ""), ("colorMap10", ""), ("colorMap11", ""), ("colorMap12", ""), ("colorMap13", ""), ("colorMap14", ""), ("colorMap15", ""), ("colorObjMax", "1.000000 1.000000 0.500000 1.000000"), ("colorObjMaxBaseBlend", "1"), ("colorObjMin", "0.250000 0.150000 0.000000 1.000000"), ("colorObjMinBaseBlend", "1"), ("colorTint", "1.000000 1.000000 1.000000 1.000000"), ("colorTint1", "1 1 1 1"), ("colorTint2", "1 1 1 1"), ("colorTint3", "1 1 1 1"), ("colorTint4", "1 1 1 1"), ("colorWriteAlpha", "Enable"), ("colorWriteBlue", "Enable"), ("colorWriteGreen", "Enable"), ("colorWriteRed", "Enable"), ("columnCount", "1"), ("converterOnlyNormal", "0"), ("cosinePowerMap", ""), ("customString", ""), ("customTemplate", ""), ("depthMultiplier", "3"), ("desaturationAmount", "0"), ("detail", "0"), ("detail1ScaleX", "8"), ("detail1ScaleY", "8"), ("detail2ScaleX", "8"), ("detail2ScaleY", "8"), ("detail3ScaleX", "8"), ("detail3ScaleY", "8"), ("detailMap", ""), ("detailScaleHeight", "1"), ("detailScaleHeight1", "1"), ("detailScaleHeight2", "1"), ("detailScaleHeight3", "1"), ("detailScaleX", "8"), ("detailScaleY", "8"), ("dFlowColorB", "1"), ("dFlowColorG", "1"), ("dFlowColorR", "1"), ("dFlowDepthFeather", "0.3125"), ("dFlowFrameBufferOps", "0"), ("dFlowIndexOfRefraction", "1.333"), ("dFlowNormalScale", "1"), ("dFlowNormalUVScaleU", "1"), ("dFlowNormalUVScaleV", "1"), ("dFlowSpecLobeAWeight", "0.625"), ("dFlowSpecLobeRoughnessA", "0.02"), ("dFlowSpecLobeRoughnessB", "0.123"), ("dFlowSpeed", "0.25"), ("dFlowTextureFraction", "0.15"), ("dFlowThinFilmDepth", "0.5"), ("dFlowThinFilmEnable", "0"), ("dFlowThinFilmNormalScale", "1"), ("dFlowThinFilmPeriod", "60"), ("dFlowThinFilmWaveLengthB", "440"), ("dFlowThinFilmWaveLengthG", "550"), ("dFlowThinFilmWaveLengthR", "600"), ("dFlowUVScaleU", "1"), ("dFlowUVScaleV", "1"), ("distFalloff", "0"), ("distFalloffBeginDistance", "200"), ("distFalloffEndDistance", "10"), ("distortionColorBehavior", "scales distortion strength*"), ("distortionScaleX", "0.5"), ("distortionScaleY", "0.5"), ("doNotUse", "0"), ("doubleSidedLighting", "0"), ("drawToggle", "0"), ("dummy", "0"), ("emissiveFalloff", "0"), ("emissiveIncompetence", "0"), ("enableGTAO", "0"), ("enemyMaterial", ""), ("envMapExponent", "1"), ("envMapMax", "1"), ("envMapMin", "1"), ("eyeOffsetDepth", "0"), ("failedPBR", "0"), ("falloff", "0"), ("falloffBeginAngle", "35"), ("falloffBeginColor", "1.000000 1.000000 1.000000 1.000000"), ("falloffEndAngle", "65"), ("falloffEndColor", "0.500000 0.500000 0.500000 0.500000"), ("filterColor", "aniso2x (mip linear)"), ("filterColor00", "linear (mip linear)"), ("filterColor01", "linear (mip linear)"), ("filterColor02", "linear (mip linear)"), ("filterColor03", "linear (mip linear)"), ("filterColor04", "linear (mip linear)"), ("filterColor05", "linear (mip linear)"), ("filterColor06", "linear (mip linear)"), ("filterColor07", "linear (mip linear)"), ("filterColor08", "linear (mip linear)"), ("filterColor09", "linear (mip linear)"), ("filterColor10", "linear (mip linear)"), ("filterColor11", "linear (mip linear)"), ("filterColor12", "linear (mip linear)"), ("filterColor13", "linear (mip linear)"), ("filterColor14", "linear (mip linear)"), ("filterColor15", "linear (mip linear)"), ("filterColorDetail", "aniso2x (mip linear)"), ("filterDetail", "aniso2x (mip linear)"), ("filterNormal", "aniso2x (mip linear)"), ("filterOcc", "linear (mip linear)"), ("filterReveal", "linear (mip linear)"), ("filterSpecular", "linear (mip linear)"), ("filterTransition", "linear (mip nearest)"), ("fixedGloss", "0"), ("flagRipple1ScrollU", "0"), ("flagRipple1ScrollV", "0"), ("flagRipple2ScrollU", "0"), ("flagRipple2ScrollV", "0"), ("flagRippleHeight", "1"), ("flagRippleScale", "1"), ("flagW", "0"), ("flagX", "1"), ("flagY", "0"), ("flagZ", "0"), ("flickerLookupMap", ""), ("flickerMax", "1"), ("flickerMin", "0"), ("flickerPower", "1"), ("flickerSeedU", "0"), ("flickerSeedV", "0"), ("flickerSpeed", "1"), ("foamColor", "1 1 1 1"), ("foamMapEnable", "0"), ("foamWaveIncrease", "0"), ("gCheckBox00", "0"), ("gCheckBox01", "0"), ("gCheckBox02", "0"), ("gCheckBox03", "0"), ("gCheckBox04", "0"), ("gCheckBox05", "0"), ("gCheckBox06", "0"), ("gCheckBox07", "0"), ("gColor00_B", "1"), ("gColor00_G", "1"), ("gColor00_R", "1"), ("gColor01_B", "1"), ("gColor01_G", "1"), ("gColor01_R", "1"), ("gColor02_B", "1"), ("gColor02_G", "1"), ("gColor02_R", "1"), ("gColor03_B", "1"), ("gColor03_G", "1"), ("gColor03_R", "1"), ("gColor04_B", "1"), ("gColor04_G", "1"), ("gColor04_R", "1"), ("gColor05_B", "1"), ("gColor05_G", "1"), ("gColor05_R", "1"), ("gColor06_B", "1"), ("gColor06_G", "1"), ("gColor06_R", "1"), ("gColor07_B", "1"), ("gColor07_G", "1"), ("gColor07_R", "1"), ("gColorStops00", "0"), ("gColorStops01", "0"), ("gColorStops02", "0"), ("gColorStops03", "0"), ("gColorStops04", "0"), ("gColorStops05", "0"), ("gColorStops06", "0"), ("gColorStops07", "0"), ("gCustomReflectionProbe", "0"), ("gCustomReflectionProbeB", "1"), ("gCustomReflectionProbeBias", "0"), ("gCustomReflectionProbeG", "1"), ("gCustomReflectionProbeR", "1"), ("gCustomReflectionProbeScaleB", "1"), ("gCustomReflectionProbeScaleG", "1"), ("gCustomReflectionProbeScaleR", "1"), ("gCustomReflectionProbeStops", "0"), ("gDepthFeather", "10"), ("gDistortion00", "0"), ("gDistortion01", "0"), ("gDistortion02", "0"), ("gDistortion03", "0"), ("germanUnsafe", "0"), ("gFoamScrollAngle0", "90"), ("gFoamScrollAngle1", "180"), ("gFoamScrollAngle2", "270"), ("gFoamScrollAngle3", "0"), ("gFoamScrollSpeed0", "25"), ("gFoamScrollSpeed1", "29.75"), ("gFoamScrollSpeed2", "25.0625"), ("gFoamScrollSpeed3", "38.25"), ("gFoamUVNoiseAngle0", "90"), ("gFoamUVNoiseAngle1", "180"), ("gFoamUVNoiseScale0", "13"), ("gFoamUVNoiseScale1", "31"), ("gFoamUVNoiseSpeed0", "0.125"), ("gFoamUVNoiseSpeed1", "0.0125"), ("gFoamUVScale0", "1024"), ("gFoamUVScale1", "1795"), ("gFoamUVScale2", "3142"), ("gFoamUVScale3", "5497"), ("gHorizonDistance", "10000"), ("glossRangeMax", "17.0"), ("glossRangeMax1", "17"), ("glossRangeMax2", "17"), ("glossRangeMax3", "17"), ("glossRangeMin", "0.0"), ("glossRangeMin1", "0"), ("glossRangeMin2", "0"), ("glossRangeMin3", "0"), ("glossSurfaceType", "<full>"), ("gNormalScale00", "1"), ("gNormalScale01", "1"), ("gNormalScale02", "1"), ("gNormalScale03", "1"), ("gReflectionRay0", "50"), ("gReflectionRay1", "100"), ("gReflectionRay2", "200"), ("gRefractionAmount", "8"), ("grimeAnglePitch", "0"), ("grimeAngleYaw", "0"), ("gScale0", "0"), ("gScale1", "0"), ("gScale2", "0"), ("gScale3", "0"), ("gScale4", "0"), ("gScale5", "0"), ("gScale6", "0"), ("gScale7", "0"), ("gSharedU_Offset00", "0"), ("gSharedU_Offset01", "0"), ("gSharedU_Offset02", "0"), ("gSharedU_Offset03", "0"), ("gSharedU_Scale00", "1"), ("gSharedU_Scale01", "1"), ("gSharedU_Scale02", "1"), ("gSharedU_Scale03", "1"), ("gSharedV_Offset00", "0"), ("gSharedV_Offset01", "0"), ("gSharedV_Offset02", "0"), ("gSharedV_Offset03", "0"), ("gSharedV_Scale00", "1"), ("gSharedV_Scale01", "1"), ("gSharedV_Scale02", "1"), ("gSharedV_Scale03", "1"), ("gSpecIndexOfRefraction", "1.333"), ("gSpecLobeAWeight", "0.375"), ("gSpecLobeRoughnessA", "0.05"), ("gSpecLobeRoughnessB", "0.1875"), ("gUVScaleOffSet00_OffsetU", "0"), ("gUVScaleOffSet00_OffsetV", "0"), ("gUVScaleOffSet00_ScaleU", "128"), ("gUVScaleOffSet00_ScaleV", "128"), ("gUVScaleOffSet01_OffsetU", "0"), ("gUVScaleOffSet01_OffsetV", "0"), ("gUVScaleOffSet01_ScaleU", "128"), ("gUVScaleOffSet01_ScaleV", "128"), ("gUVScaleOffSet02_OffsetU", "0"), ("gUVScaleOffSet02_OffsetV", "0"), ("gUVScaleOffSet02_ScaleU", "128"), ("gUVScaleOffSet02_ScaleV", "128"), ("gUVScaleOffSet03_OffsetU", "0"), ("gUVScaleOffSet03_OffsetV", "0"), ("gUVScaleOffSet03_ScaleU", "128"), ("gUVScaleOffSet03_ScaleV", "128"), ("gUVScroll00_Angle", "0"), ("gUVScroll00_ScaleU", "512"), ("gUVScroll00_ScaleV", "512"), ("gUVScroll00_Speed", "1"), ("gUVScroll01_Angle", "0"), ("gUVScroll01_ScaleU", "512"), ("gUVScroll01_ScaleV", "512"), ("gUVScroll01_Speed", "1"), ("gUVScroll02_Angle", "0"), ("gUVScroll02_ScaleU", "256"), ("gUVScroll02_ScaleV", "256"), ("gUVScroll02_Speed", "1"), ("gUVScroll03_Angle", "0"), ("gUVScroll03_ScaleU", "256"), ("gUVScroll03_ScaleV", "256"), ("gUVScroll03_Speed", "1"), ("gWetnessNormalStrength", "0.25"), ("gWetnessRoughnessLobe0", "0.05"), ("hasEditorMaterial", "0"), ("heatmap", ""), ("heroAsset", "0"), ("heroLight", "0"), ("ignoreScriptVectors", "0"), ("imageTime", "1"), ("invertFalloff", "0"), ("itemClip", "0"), ("japaneseUnsafe", "0"), ("kelvinMax", "1800"), ("kelvinMin", "768"), ("layerSortDecal", "Debris (top)"), ("levelsInputMax", "255"), ("levelsInputMax1", "255"), ("levelsInputMin", "0"), ("levelsInputMin1", "0"), ("levelsOutputMax", "255"), ("levelsOutputMax1", "255"), ("levelsOutputMin", "0"), ("levelsOutputMin1", "0"), ("lightDemoteHint", "0"), ("lightPortal", "0"), ("locale_afghanistan", "0"), ("locale_angola", "0"), ("locale_antarctica", "0"), ("locale_carrier", "0"), ("locale_core", "0"), ("locale_cuba", "0"), ("locale_kyrgyzstan", "0"), ("locale_la", "0"), ("locale_mp_dlc", "0"), ("locale_myanmar", "0"), ("locale_nepal", "0"), ("locale_nicaragua", "0"), ("locale_pakistan", "0"), ("locale_panama", "0"), ("locale_ship", "0"), ("locale_singapore", "0"), ("locale_test", "0"), ("locale_tools", "0"), ("locale_yemen", "0"), ("locale_zombie", "0"), ("materialCategory", "Geometry"), ("materialType", "sky_latlong_hdr"), ("matureContent", "0"), ("maxRayDepth", "1000"), ("missileClip", "0"), ("mount", "0"), ("noCastShadow", "1"), ("noDraw", "0"), ("noDrop", "0"), ("noDynamicLight", "1"), ("noFallDamage", "0"), ("noFog", "0"), ("noImpact", "1"), ("noMarks", "1"), ("nonColliding", "1"), ("nonSolid", "0"), ("noPenetrate", "0"), ("noReceiveDynamicShadow", "0"), ("normalFlattening", "1"), ("normalHeightScale", "1"), ("normalMap", ""), ("normalsFlowScaleMin", "0"), ("normalVarianceScale", "1"), ("noSteps", "0"), ("notInBoats", "0"), ("objectiveColorsEnabled", "0"), ("occMap", ""), ("oceanSunBrightness", "10"), ("oceanSunSize", "0.0125"), ("onlyCastShadow", "0"), ("onlyCastSunShadow", "0"), ("orientNormalsToFlow", "0"), ("origin", "0"), ("outdoorOccluder", "0"), ("outdoorOnly", "0"), ("overwaterOpacityScale", "0.75"), ("physicsGeom", "0"), ("playerClip", "0"), ("playerVehicleClip", "0"), ("portal", "0"), ("reflectionMapEnable", "0"), ("reflectionProbeAmount", "1"), ("revealScaleX", "1"), ("revealScaleY", "1"), ("rowCount", "1"), ("scaleNormalsWithFlow", "0"), ("scaleRGB", "8"), ("scatterColorB", "0.145"), ("scatterColorG", "0.195"), ("scatterColorR", "0.145"), ("screenReflection", "0"), ("seethruprlx_alphapower", "12"), ("seethruprlx_height", "0.06"), ("seethruprlx_solidrad", "0.1"), ("showAdvancedOptions", "<none>*"), ("sky", "0"), ("skyCenterX", "0"), ("skyCenterY", "0"), ("skyCenterZ", "0"), ("skyFogFraction", "1"), ("skyHalfSpace", "1"), ("skyRotation", "75"), ("skyScaleRGB", "2048"), ("skySize", "65000"), ("skyStops", "13.5"), ("slick", "0"), ("sort", "sky"), ("specAmount", "0.5"), ("specColorDesaturate1", "1"), ("specColorDesaturate2", "1"), ("specColorDesaturate3", "1"), ("specColorIntensity1", "0"), ("specColorIntensity2", "0"), ("specColorIntensity3", "0"), ("specColorMap", ""), ("specColorStrength", "100"), ("specColorTint", "0.715943 0.726103 0.724779 1"), ("specColorTint1", "0.715943 0.726103 0.724779 1"), ("specColorTint2", "0.760757 0.764664 0.764664 1"), ("specColorTint3", "0.760757 0.764664 0.764664 1"), ("specDetailMap", ""), ("specDetailScaleX", "8"), ("specDetailScaleY", "8"), ("specDetailStrength", "100"), ("specMapEnable", "0"), ("specReflectionMap", ""), ("specTint_b", "0.2"), ("specTint_g", "0.2"), ("specTint_r", "0.2"), ("spotLightWeight", "0"), ("ssrRayDepthScale", "1"), ("ssrRayStepSize", "20"), ("stairs", "0"), ("stencil", "Disable"), ("stencilFunc1", "Always"), ("stencilFunc2", "Always"), ("stencilOpFail1", "Keep"), ("stencilOpFail2", "Keep"), ("stencilOpPass1", "Keep"), ("stencilOpPass2", "Keep"), ("stencilOpZFail1", "Keep"), ("stencilOpZFail2", "Keep"), ("structural", "0"), ("surfaceClimbType", "<none>"), ("surfaceType", "<none>"), ("sw_codetexture_00", ""), ("sw_codetexture_01", ""), ("sw_codetexture_02", ""), ("sw_codetexture_03", ""), ("sw_codetexture_04", ""), ("sw_codetexture_05", ""), ("sw_codetexture_06", ""), ("sw_codetexture_07", ""), ("sw_codetexture_08", ""), ("sw_codetexture_09", ""), ("sw_codetexture_10", ""), ("sw_codetexture_11", ""), ("sw_codetexture_12", ""), ("sw_codetexture_13", ""), ("sw_codetexture_14", ""), ("sw_codetexture_15", ""), ("sw_static_bool_00", "0"), ("sw_static_bool_01", "0"), ("sw_static_bool_02", "0"), ("sw_static_bool_03", "0"), ("sw_static_bool_04", "0"), ("sw_static_bool_05", "0"), ("sw_static_bool_06", "0"), ("sw_static_bool_07", "0"), ("sw_static_bool_08", "0"), ("sw_static_bool_09", "0"), ("sw_static_bool_10", "0"), ("sw_static_bool_11", "0"), ("sw_static_bool_12", "0"), ("sw_static_bool_13", "0"), ("sw_static_bool_14", "0"), ("sw_static_bool_15", "0"), ("sw_static_enum_00", ""), ("sw_static_enum_01", ""), ("sw_static_enum_02", ""), ("sw_static_enum_03", ""), ("sw_static_enum_04", ""), ("sw_static_enum_05", ""), ("sw_static_enum_06", ""), ("sw_static_enum_07", ""), ("sw_static_enum_08", ""), ("sw_static_enum_09", ""), ("sw_static_enum_10", ""), ("sw_static_enum_11", ""), ("sw_static_enum_12", ""), ("sw_static_enum_13", ""), ("sw_static_enum_14", ""), ("sw_static_enum_15", ""), ("sw_static_float_00", "0"), ("sw_static_float_01", "0"), ("sw_static_float_02", "0"), ("sw_static_float_03", "0"), ("sw_static_float_04", "0"), ("sw_static_float_05", "0"), ("sw_static_float_06", "0"), ("sw_static_float_07", "0"), ("sw_static_float_08", "0"), ("sw_static_float_09", "0"), ("sw_static_float_10", "0"), ("sw_static_float_11", "0"), ("sw_static_float_12", "0"), ("sw_static_float_13", "0"), ("sw_static_float_14", "0"), ("sw_static_float_15", "0"), ("sw_static_int_00", "0"), ("sw_static_int_01", "0"), ("sw_static_int_02", "0"), ("sw_static_int_03", "0"), ("sw_static_int_04", "0"), ("sw_static_int_05", "0"), ("sw_static_int_06", "0"), ("sw_static_int_07", "0"), ("sw_static_int_08", "0"), ("sw_static_int_09", "0"), ("sw_static_int_10", "0"), ("sw_static_int_11", "0"), ("sw_static_int_12", "0"), ("sw_static_int_13", "0"), ("sw_static_int_14", "0"), ("sw_static_int_15", "0"), ("sway_x", "1"), ("sway_y", "1"), ("template", "material.template"), ("tensionCompressHeight", "1"), ("tensionPower", "1"), ("tensionStrength", "1"), ("tensionStretchHeight", "1"), ("tessSize", "0"), ("texScroll", "0"), ("texTile00", "tile both*"), ("texTile01", "tile both*"), ("texTile02", "tile both*"), ("texTile03", "tile both*"), ("texTile04", "tile both*"), ("texTile05", "tile both*"), ("texTile06", "tile both*"), ("texTile07", "tile both*"), ("texTile08", "tile both*"), ("texTile09", "tile both*"), ("texTile10", "tile both*"), ("texTile11", "tile both*"), ("texTile12", "tile both*"), ("texTile13", "tile both*"), ("texTile14", "tile both*"), ("texTile15", "tile both*"), ("textureAtlasColumnCount", "1"), ("textureAtlasFrameRate", "1"), ("textureAtlasRowCount", "1"), ("thermalMaterial", ""), ("tileColor", "no tile"), ("tileNormal", "tile both*"), ("tileOcc", "tile both*"), ("tileReveal", "tile both*"), ("tileSpecular", "tile both*"), ("tileTransition", "tile both*"), ("tilingHeight", "<auto>"), ("tilingWidth", "<auto>"), ("transColorMap", ""), ("transColorTint", "1 1 1 1"), ("transGlossMap", ""), ("transGlossRangeMax", "13"), ("transGlossRangeMin", "0"), ("translucentShadowOpacity", "0.5"), ("transNormalHeightScale", "1"), ("transNormalMap", ""), ("transparent", "0"), ("transRevealMap", ""), ("transRevealRamp", "0.5"), ("transRevealSoftEdge", "0.01"), ("transScaleX", "8"), ("transScaleY", "8"), ("transSpecColorTint", "0.760757 0.764664 0.764664 1"), ("transSpecMap", ""), ("treeCanopyDisablePrepass", "0"), ("treeCanopyEnableSway", "0"), ("treeCanopyMinimumSway", "0"), ("treeCanopyNewVertexControl", "0"), ("treeCanopyRadialLighting", "0.5"), ("treeCanopyScaleRotationAngles", "0.1"), ("treeCanopyScatterColor", "0.700000 0.830000 0.360000 0.000000"), ("treeCanopySpecularGloss", "0.3"), ("treeCanopySwayRange", "0.2"), ("umbraOccluder", "0"), ("umbraTarget", "0"), ("underwaterOpacityScale", "0.75"), ("usage", "<not in editor>"), ("uScale", "1"), ("uScroll", "0"), ("uScroll1", "0"), ("useAlphaDissolve", "0"), ("useAlphaReveal", "0"), ("useAsCamo", "0"), ("useLegacyNormalEncoding", "0"), ("useLoopedScreenspaceReflection", "0"), ("useOldHDRScale", "0"), ("useParticleCloudVerticalAlign", "0"), ("useScreenspaceReflection", "0"), ("useSpotLight", "0"), ("useSpotLightShadow", "0"), ("useUVRotate", "0"), ("useUVScroll", "0"), ("useWorldOffsets1", "1"), ("useWorldOffsets2", "1"), ("useWorldOffsets3", "1"), ("utilityClip", "0"), ("uvMotionToggle1", "0"), ("uvMotionToggle2", "0"), ("uvMotionToggle3", "0"), ("uvMotionToggle4", "0"), ("uvRotationRate", "0"), ("uvRotationRate1", "0"), ("uvRotationRate2", "0"), ("uvScrollAngle", "0"), ("uvScrollAngle1", "0"), ("uvScrollRate", "0"), ("vehicleClip", "0"), ("vertexAlphaAO", "0"), ("vScale", "1"), ("vScroll", "0"), ("vScroll1", "0"), ("waterBobAmount", "5"), ("waterBobSpeed", "0"), ("waterBobWaveLength", "8192"), ("waterColor", "0.190000 0.300000 0.150000 0.000000"), ("waterDepthFeather", "0"), ("waterDetailNormalFadeMax", "0"), ("waterDetailNormalFadeMin", "0"), ("waterDetailNormalScale", "0.25"), ("waterDetailNormalScrollAngleA", "7"), ("waterDetailNormalScrollAngleB", "173"), ("waterDetailNormalScrollSpeedA", "0"), ("waterDetailNormalScrollSpeedB", "0"), ("waterDetailNormalTextureScale", "512"), ("waterDetailNormalTextureScaleB", "512"), ("waterFarColorB", "0.145"), ("waterFarColorG", "0.145"), ("waterFarColorR", "0.145"), ("waterFarDistance", "10000"), ("waterFeather", "0.05"), ("waterFoamLayer0Scale", "1024"), ("waterFoamLayer0Scroll", "25"), ("waterFoamLayer1Scale", "1795"), ("waterFoamLayer1Scroll", "-29.75"), ("waterFoamLayer2Scale", "3142"), ("waterFoamLayer2Scroll", "-35.0625"), ("waterFoamLayer3Scale", "5497"), ("waterFoamLayer3Scroll", "38.25"), ("waterFoamMax", "10"), ("waterFoamMin", "0.5"), ("waterGroundColor", "0.260000 0.270000 0.110000 0.000000"), ("waterNearColorB", "0.145"), ("waterNearColorG", "0.145"), ("waterNearColorR", "0.145"), ("waterNormalScale", "0.25"), ("waterNormalScrollAngleA", "3"), ("waterNormalScrollAngleB", "177"), ("waterNormalScrollSpeedA", "0"), ("waterNormalScrollSpeedB", "0"), ("waterNormalTextureScale", "2048"), ("waterNormalTextureScaleB", "2048"), ("waterOcean", "0"), ("waterOpacity", "0"), ("waterOpacityAmount", "0.75"), ("waterRefract", "30"), ("waterRefractionAmount", "0"), ("waterRoughness", "0.1"), ("waterScrollX0", "-1.98"), ("waterScrollX1", "4.44"), ("waterScrollX2", "3.44"), ("waterScrollY0", "1.32"), ("waterScrollY1", "-5.18"), ("waterScrollY2", "3.18"), ("waterShadowAdjust", "0"), ("waterShadowOffset", "0"), ("waterSkyColor", "0.630000 0.770000 0.770000 0.000000"), ("waterSpecularAmount", "1"), ("waterSpecularRoughnessA", "0.0625"), ("waterSpecularRoughnessB", "0.1875"), ("waterThinFilm", "0"), ("waterThinFilmAmount", "0.05"), ("waterThinFilmDepth", "0.25"), ("waterVertexGerstnerWaveAmplitude0", "0"), ("waterVertexGerstnerWaveAmplitude1", "0"), ("waterVertexGerstnerWaveAmplitude2", "0"), ("waterVertexGerstnerWaveAmplitude3", "0"), ("waterVertexGerstnerWaveAngle0", "0"), ("waterVertexGerstnerWaveAngle1", "0"), ("waterVertexGerstnerWaveAngle2", "0"), ("waterVertexGerstnerWaveAngle3", "0"), ("waterVertexGerstnerWavePhase0", "0"), ("waterVertexGerstnerWavePhase1", "0"), ("waterVertexGerstnerWavePhase2", "0"), ("waterVertexGerstnerWavePhase3", "0"), ("waterVertexGerstnerWaves", "0"), ("waterVertexGerstnerWaveSpeed0", "0"), ("waterVertexGerstnerWaveSpeed1", "0"), ("waterVertexGerstnerWaveSpeed2", "0"), ("waterVertexGerstnerWaveSpeed3", "0"), ("waterVertexGerstnerWaveSteepness0", "0"), ("waterVertexGerstnerWaveSteepness1", "0"), ("waterVertexGerstnerWaveSteepness2", "0"), ("waterVertexGerstnerWaveSteepness3", "0"), ("waterVertexGerstnerWaveWavelength0", "0"), ("waterVertexGerstnerWaveWavelength1", "0"), ("waterVertexGerstnerWaveWavelength2", "0"), ("waterVertexGerstnerWaveWavelength3", "0"), ("waterWeaveAmount", "5"), ("waterWeaveSpeed", "0"), ("waterWeaveWaveLength", "8192"), ("wetnessInvert", "0"), ("zFeather", "0"), ("zFeatherComputeSprites", "0"), ("zFeatherDepth", "40"), ("zFeatherMaskViewModel", "0"), ("zFeatherOverride", "0"), ("zFeatherPlane", "0"), ("zFeatherPlaneDir", "1"), ("zFeatherViewModel", "0"), ("zoomMax", "1"), ("zoomMin", "1"), ("zoomRate", "0") };
        }

        public static (string, string)[] SkyboxSSIDefaultProps()
        {
            return new (string, string)[] { ("bounceCount", "4"), ("colorSRGB", "1 0.976400000000001 0.949000000000001 1"), ("dynamicShadow", "1"), ("enablesun", "1"), ("ev", "15"), ("evcmp", "0"), ("evmax", "16"), ("evmin", "1"), ("lensFlare", ""), ("lensFlarePitchOffset", "0"), ("lensFlareYawOffset", "0"), ("penumbra_inches", "1.5"), ("pitch", "125"), ("skyboxmodel", "skybox_default_day"), ("spec_comp", "0"), ("stops", "14"), ("sunCookieAngle", "0"), ("sunCookieIntensity", "0"), ("sunCookieLightDefName", ""), ("sunCookieOffsetX", "0"), ("sunCookieOffsetY", "0"), ("sunCookieRotation", "0"), ("sunCookieScale", "0"), ("sunCookieScrollX", "0"), ("sunCookieScrollY", "0"), ("sunVolumetricCookie", "0"), ("type", "ssi"), ("yaw", "150") };
        }
    }

    public sealed class GDTAsset
    {
        public Dictionary<string, string> Props = new Dictionary<string, string>();
        public string Name { get; set; }

        public string this[string name]
        {
            get
            {
                return Props[name];
            }
            set
            {
                Props[name] = value;
            }
        }

        public override string ToString()
        {
            return $"\t\"{Name}\" ( \"{this["gdf"]}.gdf\" )\n\t{{\n{SerializeProps()}\t}}\n";
        }

        private string SerializeProps()
        {
            StringBuilder sb = new StringBuilder();

            foreach(var prop in Props)
            {
                if(prop.Key == "gdf")
                {
                    continue;
                }
                sb.Append($"\t\t\"{prop.Key}\" \"{prop.Value}\"\n");
            }
            return sb.ToString();
        }
    }
}
