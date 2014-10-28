/**
 *	cl4d - object-oriented wrapper for the OpenCL C API
 *	written in the D programming language
 *
 *	Copyright:
 *		(c) 2009-2012 Andreas Hollandt
 *
 *	License:
 *		see LICENSE.txt
 */

module cl4d.c.cl;

public import cl4d.c.cl_platform;

version(CL_VERSION_1_2)
	version = CL_VERSION_1_1;

// a helper function to make elements of enums accessable without EnumType. prefix
package string bringToCurrentScope(alias EnumType)()
{
	string res = "";
	foreach (e; __traits(allMembers, EnumType))
	{
		res ~= "alias " ~ EnumType.stringof ~ "." ~ e ~ " " ~ e ~ ";\n";
	}
    return res;
}

extern(System):

alias void*
	cl_platform_id,
	cl_device_id,
	cl_context,
	cl_command_queue,
	cl_mem,
	cl_program,
	cl_kernel,
	cl_event,
	cl_sampler;

// TODO: info types should be aliases so getInfo isn't instantiated too often for the same types?
// on the other hand aliass are needed to be type-safe, esp. for bitfields
//alias cl_uint			cl_bool;		// WARNING!  Unlike cl_ types in cl_platform.h, cl_bool is not guaranteed to be the same size as the bool in kernels.
alias cl_ulong			cl_bitfield;
alias cl_uint			cl_platform_info;
alias cl_uint			cl_device_info;
alias cl_uint			cl_device_mem_cache_type;
alias cl_uint			cl_device_local_mem_type;

alias ptrdiff_t			cl_context_properties;
alias cl_uint			cl_context_info;
alias cl_uint			cl_command_queue_info;
alias cl_uint			cl_mem_info;
alias cl_uint			cl_image_info;
alias cl_uint			cl_buffer_create_type;
alias cl_uint			cl_sampler_info;
alias cl_uint			cl_program_info;
alias cl_uint			cl_program_build_info;
alias cl_int			cl_build_status;
alias cl_uint			cl_kernel_info;
alias cl_uint			cl_kernel_arg_info;
alias cl_uint			cl_kernel_work_group_info;
alias cl_uint			cl_event_info;
alias cl_uint			cl_profiling_info;

//!
struct cl_image_format
{
	cl_channel_order	image_channel_order;
	cl_channel_type		image_channel_data_type;
}

//!
struct cl_image_desc
{
	cl_mem_object_type      image_type;
	size_t                  image_width;
	size_t                  image_height;
	size_t                  image_depth;
	size_t                  image_array_size;
	size_t                  image_row_pitch;
	size_t                  image_slice_pitch;
	cl_uint                 num_mip_levels;
	cl_uint                 num_samples;
	cl_mem                  buffer;
}

//! used in createSubBuffer
struct cl_buffer_region
{
	size_t				origin;
	size_t				size;
}

/* ************************************************************************** */

enum cl_errcode : cl_int
{
	// Error Codes
	CL_SUCCESS                                  = 0,
	CL_DEVICE_NOT_FOUND                         = -1,
	CL_DEVICE_NOT_AVAILABLE                     = -2,
	CL_COMPILER_NOT_AVAILABLE                   = -3,
	CL_MEM_OBJECT_ALLOCATION_FAILURE            = -4,
	CL_OUT_OF_RESOURCES                         = -5,
	CL_OUT_OF_HOST_MEMORY                       = -6,
	CL_PROFILING_INFO_NOT_AVAILABLE             = -7,
	CL_MEM_COPY_OVERLAP                         = -8,
	CL_IMAGE_FORMAT_MISMATCH                    = -9,
	CL_IMAGE_FORMAT_NOT_SUPPORTED               = -10,
	CL_BUILD_PROGRAM_FAILURE                    = -11,
	CL_MAP_FAILURE                              = -12,
	CL_MISALIGNED_SUB_BUFFER_OFFSET             = -13,
	CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST= -14,
	CL_COMPILE_PROGRAM_FAILURE                  = -15,
	CL_LINKER_NOT_AVAILABLE                     = -16,
	CL_LINK_PROGRAM_FAILURE                     = -17,
	CL_DEVICE_PARTITION_FAILED                  = -18,
	CL_KERNEL_ARG_INFO_NOT_AVAILABLE            = -19,

	CL_INVALID_VALUE                            = -30,
	CL_INVALID_DEVICE_TYPE                      = -31,
	CL_INVALID_PLATFORM                         = -32,
	CL_INVALID_DEVICE                           = -33,
	CL_INVALID_CONTEXT                          = -34,
	CL_INVALID_QUEUE_PROPERTIES                 = -35,
	CL_INVALID_COMMAND_QUEUE                    = -36,
	CL_INVALID_HOST_PTR                         = -37,
	CL_INVALID_MEM_OBJECT                       = -38,
	CL_INVALID_IMAGE_FORMAT_DESCRIPTOR          = -39,
	CL_INVALID_IMAGE_SIZE                       = -40,
	CL_INVALID_SAMPLER                          = -41,
	CL_INVALID_BINARY                           = -42,
	CL_INVALID_BUILD_OPTIONS                    = -43,
	CL_INVALID_PROGRAM                          = -44,
	CL_INVALID_PROGRAM_EXECUTABLE               = -45,
	CL_INVALID_KERNEL_NAME                      = -46,
	CL_INVALID_KERNEL_DEFINITION                = -47,
	CL_INVALID_KERNEL                           = -48,
	CL_INVALID_ARG_INDEX                        = -49,
	CL_INVALID_ARG_VALUE                        = -50,
	CL_INVALID_ARG_SIZE                         = -51,
	CL_INVALID_KERNEL_ARGS                      = -52,
	CL_INVALID_WORK_DIMENSION                   = -53,
	CL_INVALID_WORK_GROUP_SIZE                  = -54,
	CL_INVALID_WORK_ITEM_SIZE                   = -55,
	CL_INVALID_GLOBAL_OFFSET                    = -56,
	CL_INVALID_EVENT_WAIT_LIST                  = -57,
	CL_INVALID_EVENT                            = -58,
	CL_INVALID_OPERATION                        = -59,
	CL_INVALID_GL_OBJECT                        = -60,
	CL_INVALID_BUFFER_SIZE                      = -61,
	CL_INVALID_MIP_LEVEL                        = -62,
	CL_INVALID_GLOBAL_WORK_SIZE                 = -63,
	CL_INVALID_PROPERTY							= -64,
	CL_INVALID_IMAGE_DESCRIPTOR                 = -65,
	CL_INVALID_COMPILER_OPTIONS                 = -66,
	CL_INVALID_LINKER_OPTIONS                   = -67,
	CL_INVALID_DEVICE_PARTITION_COUNT           = -68,
	CL_INVALID_GL_SHAREGROUP_REFERENCE_KHR      = -1000
}
mixin(bringToCurrentScope!cl_errcode());

enum cl_bool : cl_uint
{
	CL_FALSE                                    = 0,
	CL_TRUE                                     = 1,
	CL_BLOCKING                                 = CL_TRUE,
	CL_NON_BLOCKING                             = CL_FALSE
}
mixin(bringToCurrentScope!cl_bool());

enum : cl_platform_info
{
	CL_PLATFORM_PROFILE                         = 0x0900,
	CL_PLATFORM_VERSION                         = 0x0901,
	CL_PLATFORM_NAME                            = 0x0902,
	CL_PLATFORM_VENDOR                          = 0x0903,
	CL_PLATFORM_EXTENSIONS                      = 0x0904,
}
enum cl_device_type : cl_bitfield
{
	CL_DEVICE_TYPE_DEFAULT                      = (1 << 0),
	CL_DEVICE_TYPE_CPU                          = (1 << 1),
	CL_DEVICE_TYPE_GPU                          = (1 << 2),
	CL_DEVICE_TYPE_ACCELERATOR                  = (1 << 3),
	CL_DEVICE_TYPE_CUSTOM                 		= (1 << 4),
	CL_DEVICE_TYPE_ALL                          = 0xFFFFFFFF,
}
mixin(bringToCurrentScope!cl_device_type());

enum : cl_device_info
{
	CL_DEVICE_TYPE                              = 0x1000,
	CL_DEVICE_VENDOR_ID                         = 0x1001,
	CL_DEVICE_MAX_COMPUTE_UNITS                 = 0x1002,
	CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS          = 0x1003,
	CL_DEVICE_MAX_WORK_GROUP_SIZE               = 0x1004,
	CL_DEVICE_MAX_WORK_ITEM_SIZES               = 0x1005,
	CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR       = 0x1006,
	CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT      = 0x1007,
	CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT        = 0x1008,
	CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG       = 0x1009,
	CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT      = 0x100A,
	CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE     = 0x100B,
	CL_DEVICE_MAX_CLOCK_FREQUENCY               = 0x100C,
	CL_DEVICE_ADDRESS_BITS                      = 0x100D,
	CL_DEVICE_MAX_READ_IMAGE_ARGS               = 0x100E,
	CL_DEVICE_MAX_WRITE_IMAGE_ARGS              = 0x100F,
	CL_DEVICE_MAX_MEM_ALLOC_SIZE                = 0x1010,
	CL_DEVICE_IMAGE2D_MAX_WIDTH                 = 0x1011,
	CL_DEVICE_IMAGE2D_MAX_HEIGHT                = 0x1012,
	CL_DEVICE_IMAGE3D_MAX_WIDTH                 = 0x1013,
	CL_DEVICE_IMAGE3D_MAX_HEIGHT                = 0x1014,
	CL_DEVICE_IMAGE3D_MAX_DEPTH                 = 0x1015,
	CL_DEVICE_IMAGE_SUPPORT                     = 0x1016,
	CL_DEVICE_MAX_PARAMETER_SIZE                = 0x1017,
	CL_DEVICE_MAX_SAMPLERS                      = 0x1018,
	CL_DEVICE_MEM_BASE_ADDR_ALIGN               = 0x1019,
	CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE          = 0x101A,
	CL_DEVICE_SINGLE_FP_CONFIG                  = 0x101B,
	CL_DEVICE_GLOBAL_MEM_CACHE_TYPE             = 0x101C,
	CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE         = 0x101D,
	CL_DEVICE_GLOBAL_MEM_CACHE_SIZE             = 0x101E,
	CL_DEVICE_GLOBAL_MEM_SIZE                   = 0x101F,
	CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE          = 0x1020,
	CL_DEVICE_MAX_CONSTANT_ARGS                 = 0x1021,
	CL_DEVICE_LOCAL_MEM_TYPE                    = 0x1022,
	CL_DEVICE_LOCAL_MEM_SIZE                    = 0x1023,
	CL_DEVICE_ERROR_CORRECTION_SUPPORT          = 0x1024,
	CL_DEVICE_PROFILING_TIMER_RESOLUTION        = 0x1025,
	CL_DEVICE_ENDIAN_LITTLE                     = 0x1026,
	CL_DEVICE_AVAILABLE                         = 0x1027,
	CL_DEVICE_COMPILER_AVAILABLE                = 0x1028,
	CL_DEVICE_EXECUTION_CAPABILITIES            = 0x1029,
	CL_DEVICE_QUEUE_PROPERTIES                  = 0x102A,
	CL_DEVICE_NAME                              = 0x102B,
	CL_DEVICE_VENDOR                            = 0x102C,
	CL_DRIVER_VERSION                           = 0x102D,
	CL_DEVICE_PROFILE                           = 0x102E,
	CL_DEVICE_VERSION                           = 0x102F,
	CL_DEVICE_EXTENSIONS                        = 0x1030,
	CL_DEVICE_PLATFORM                          = 0x1031,
	CL_DEVICE_DOUBLE_FP_CONFIG                  = 0x1032,
	// 0x1033 reserved for CL_DEVICE_HALF_FP_CONFIG
	CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF       = 0x1034,
	CL_DEVICE_HOST_UNIFIED_MEMORY               = 0x1035,
	CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR          = 0x1036,
	CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT         = 0x1037,
	CL_DEVICE_NATIVE_VECTOR_WIDTH_INT           = 0x1038,
	CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG          = 0x1039,
	CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT         = 0x103A,
	CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE        = 0x103B,
	CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF          = 0x103C,
	CL_DEVICE_OPENCL_C_VERSION                  = 0x103D,
	CL_DEVICE_LINKER_AVAILABLE                  = 0x103E,
	CL_DEVICE_BUILT_IN_KERNELS                  = 0x103F,
	CL_DEVICE_IMAGE_MAX_BUFFER_SIZE             = 0x1040,
	CL_DEVICE_IMAGE_MAX_ARRAY_SIZE              = 0x1041,
	CL_DEVICE_PARENT_DEVICE                     = 0x1042,
	CL_DEVICE_PARTITION_MAX_SUB_DEVICES         = 0x1043,
	CL_DEVICE_PARTITION_PROPERTIES              = 0x1044,
	CL_DEVICE_PARTITION_AFFINITY_DOMAIN         = 0x1045,
	CL_DEVICE_PARTITION_TYPE                    = 0x1046,
	CL_DEVICE_REFERENCE_COUNT                   = 0x1047,
	CL_DEVICE_PREFERRED_INTEROP_USER_SYNC       = 0x1048,
	CL_DEVICE_PRINTF_BUFFER_SIZE                = 0x1049
}

enum cl_device_fp_config : cl_bitfield
{
	CL_FP_DENORM                                = (1 << 0),
	CL_FP_INF_NAN                               = (1 << 1),
	CL_FP_ROUND_TO_NEAREST                      = (1 << 2),
	CL_FP_ROUND_TO_ZERO                         = (1 << 3),
	CL_FP_ROUND_TO_INF                          = (1 << 4),
	CL_FP_FMA                                   = (1 << 5),
	CL_FP_SOFT_FLOAT                            = (1 << 6),
	CL_FP_CORRECTLY_ROUNDED_DIVIDE_SQRT         = (1 << 7)
}
mixin(bringToCurrentScope!cl_device_fp_config);

enum : cl_device_mem_cache_type
{
	CL_NONE                                     = 0x0,
	CL_READ_ONLY_CACHE                          = 0x1,
	CL_READ_WRITE_CACHE                         = 0x2,
}
enum : cl_device_local_mem_type
{
	CL_LOCAL                                    = 0x1,
	CL_GLOBAL                                   = 0x2,
}

enum cl_device_exec_capabilities : cl_bitfield
{
	CL_EXEC_KERNEL                              = (1 << 0),
	CL_EXEC_NATIVE_KERNEL                       = (1 << 1),
}
mixin(bringToCurrentScope!cl_device_exec_capabilities);

enum cl_command_queue_properties : cl_bitfield
{
	CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE      = (1 << 0),
	CL_QUEUE_PROFILING_ENABLE                   = (1 << 1),
}
mixin(bringToCurrentScope!cl_command_queue_properties);

//!
enum : cl_context_info
{
	CL_CONTEXT_REFERENCE_COUNT                  = 0x1080,
	CL_CONTEXT_DEVICES                          = 0x1081,
	CL_CONTEXT_PROPERTIES                       = 0x1082,
	CL_CONTEXT_NUM_DEVICES                      = 0x1083,
}

//!
enum : cl_context_properties
{
	CL_CONTEXT_PLATFORM                         = 0x1084,
	CL_CONTEXT_INTEROP_USER_SYNC                = 0x1085
}

//!
enum cl_device_partition_property : ptrdiff_t
{
	CL_DEVICE_PARTITION_EQUALLY                 = 0x1086,
	CL_DEVICE_PARTITION_BY_COUNTS               = 0x1087,
	CL_DEVICE_PARTITION_BY_COUNTS_LIST_END      = 0x0,
	CL_DEVICE_PARTITION_BY_AFFINITY_DOMAIN      = 0x1088,
}
mixin(bringToCurrentScope!cl_device_partition_property);

//!
enum cl_device_affinity_domain : cl_bitfield
{
	CL_DEVICE_AFFINITY_DOMAIN_NUMA               = (1 << 0),
	CL_DEVICE_AFFINITY_DOMAIN_L4_CACHE           = (1 << 1),
	CL_DEVICE_AFFINITY_DOMAIN_L3_CACHE           = (1 << 2),
	CL_DEVICE_AFFINITY_DOMAIN_L2_CACHE           = (1 << 3),
	CL_DEVICE_AFFINITY_DOMAIN_L1_CACHE           = (1 << 4),
	CL_DEVICE_AFFINITY_DOMAIN_NEXT_PARTITIONABLE = (1 << 5)
}
mixin(bringToCurrentScope!cl_device_affinity_domain);

//!
enum : cl_command_queue_info
{
	CL_QUEUE_CONTEXT                            = 0x1090,
	CL_QUEUE_DEVICE                             = 0x1091,
	CL_QUEUE_REFERENCE_COUNT                    = 0x1092,
	CL_QUEUE_PROPERTIES                         = 0x1093,
}

//! CL memory types
enum cl_mem_flags : cl_bitfield
{
	CL_MEM_READ_WRITE                           = (1 << 0),
	CL_MEM_WRITE_ONLY                           = (1 << 1),
	CL_MEM_READ_ONLY                            = (1 << 2),
	CL_MEM_USE_HOST_PTR                         = (1 << 3),
	CL_MEM_ALLOC_HOST_PTR                       = (1 << 4),
	CL_MEM_COPY_HOST_PTR                        = (1 << 5),
// reserved                                     = (1 << 6),
	CL_MEM_HOST_WRITE_ONLY                      = (1 << 7),
	CL_MEM_HOST_READ_ONLY                       = (1 << 8),
	CL_MEM_HOST_NO_ACCESS                       = (1 << 9)
}
mixin(bringToCurrentScope!cl_mem_flags);

//!
enum cl_mem_migration_flags : cl_bitfield
{
	CL_MIGRATE_MEM_OBJECT_HOST                  = (1 << 0),
	CL_MIGRATE_MEM_OBJECT_CONTENT_UNDEFINED     = (1 << 1)
}
mixin(bringToCurrentScope!cl_mem_migration_flags);

//!
enum cl_channel_order : cl_uint
{
	CL_R                                        = 0x10B0,
	CL_A                                        = 0x10B1,
	CL_RG                                       = 0x10B2,
	CL_RA                                       = 0x10B3,
	CL_RGB                                      = 0x10B4,
	CL_RGBA                                     = 0x10B5,
	CL_BGRA                                     = 0x10B6,
	CL_ARGB                                     = 0x10B7,
	CL_INTENSITY                                = 0x10B8,
	CL_LUMINANCE                                = 0x10B9,
	CL_Rx                                       = 0x10BA,
	CL_RGx                                      = 0x10BB,
	CL_RGBx                                     = 0x10BC,
}
mixin(bringToCurrentScope!cl_channel_order);

//!
enum cl_channel_type : cl_uint
{
	CL_SNORM_INT8                               = 0x10D0,
	CL_SNORM_INT16                              = 0x10D1,
	CL_UNORM_INT8                               = 0x10D2,
	CL_UNORM_INT16                              = 0x10D3,
	CL_UNORM_SHORT_565                          = 0x10D4,
	CL_UNORM_SHORT_555                          = 0x10D5,
	CL_UNORM_INT_101010                         = 0x10D6,
	CL_SIGNED_INT8                              = 0x10D7,
	CL_SIGNED_INT16                             = 0x10D8,
	CL_SIGNED_INT32                             = 0x10D9,
	CL_UNSIGNED_INT8                            = 0x10DA,
	CL_UNSIGNED_INT16                           = 0x10DB,
	CL_UNSIGNED_INT32                           = 0x10DC,
	CL_HALF_FLOAT                               = 0x10DD,
	CL_FLOAT                                    = 0x10DE,
}
mixin(bringToCurrentScope!cl_channel_type);

//!
enum cl_mem_object_type : cl_uint
{
	CL_MEM_OBJECT_BUFFER                        = 0x10F0,
	CL_MEM_OBJECT_IMAGE2D                       = 0x10F1,
	CL_MEM_OBJECT_IMAGE3D                       = 0x10F2,
	CL_MEM_OBJECT_IMAGE2D_ARRAY                 = 0x10F3,
	CL_MEM_OBJECT_IMAGE1D                       = 0x10F4,
	CL_MEM_OBJECT_IMAGE1D_ARRAY                 = 0x10F5,
	CL_MEM_OBJECT_IMAGE1D_BUFFER                = 0x10F6
}
mixin(bringToCurrentScope!cl_mem_object_type);

enum : cl_mem_info
{
	CL_MEM_TYPE                                 = 0x1100,
	CL_MEM_FLAGS                                = 0x1101,
	CL_MEM_SIZE                                 = 0x1102,
	CL_MEM_HOST_PTR                             = 0x1103,
	CL_MEM_MAP_COUNT                            = 0x1104,
	CL_MEM_REFERENCE_COUNT                      = 0x1105,
	CL_MEM_CONTEXT                              = 0x1106,
	CL_MEM_ASSOCIATED_MEMOBJECT                 = 0x1107,
	CL_MEM_OFFSET                               = 0x1108,
}
enum : cl_image_info
{
	CL_IMAGE_FORMAT                             = 0x1110,
	CL_IMAGE_ELEMENT_SIZE                       = 0x1111,
	CL_IMAGE_ROW_PITCH                          = 0x1112,
	CL_IMAGE_SLICE_PITCH                        = 0x1113,
	CL_IMAGE_WIDTH                              = 0x1114,
	CL_IMAGE_HEIGHT                             = 0x1115,
	CL_IMAGE_DEPTH                              = 0x1116,
	CL_IMAGE_ARRAY_SIZE                         = 0x1117,
	CL_IMAGE_BUFFER                             = 0x1118,
	CL_IMAGE_NUM_MIP_LEVELS                     = 0x1119,
	CL_IMAGE_NUM_SAMPLES                        = 0x111A
}

//! specifies how out-of-range image coordinates are handled when reading from an image
enum cl_addressing_mode : cl_uint
{
	CL_ADDRESS_NONE                             = 0x1130,
	CL_ADDRESS_CLAMP_TO_EDGE                    = 0x1131,
	CL_ADDRESS_CLAMP                            = 0x1132,
	CL_ADDRESS_REPEAT                           = 0x1133,
	CL_ADDRESS_MIRRORED_REPEAT                  = 0x1134,
}
mixin(bringToCurrentScope!cl_addressing_mode);

//! specifies the type of filter that must be applied when reading an image
enum cl_filter_mode : cl_uint
{
	CL_FILTER_NEAREST                           = 0x1140,
	CL_FILTER_LINEAR                            = 0x1141,
}
mixin(bringToCurrentScope!cl_filter_mode);

enum : cl_sampler_info
{
	CL_SAMPLER_REFERENCE_COUNT                  = 0x1150,
	CL_SAMPLER_CONTEXT                          = 0x1151,
	CL_SAMPLER_NORMALIZED_COORDS                = 0x1152,
	CL_SAMPLER_ADDRESSING_MODE                  = 0x1153,
	CL_SAMPLER_FILTER_MODE                      = 0x1154,
}
enum cl_map_flags : cl_bitfield
{
	CL_MAP_READ                                 = (1 << 0),
	CL_MAP_WRITE                                = (1 << 1),
	CL_MAP_WRITE_INVALIDATE_REGION              = (1 << 2)
}
mixin(bringToCurrentScope!cl_map_flags);

enum : cl_program_info
{
	CL_PROGRAM_REFERENCE_COUNT                  = 0x1160,
	CL_PROGRAM_CONTEXT                          = 0x1161,
	CL_PROGRAM_NUM_DEVICES                      = 0x1162,
	CL_PROGRAM_DEVICES                          = 0x1163,
	CL_PROGRAM_SOURCE                           = 0x1164,
	CL_PROGRAM_BINARY_SIZES                     = 0x1165,
	CL_PROGRAM_BINARIES                         = 0x1166,
	CL_PROGRAM_NUM_KERNELS                      = 0x1167,
	CL_PROGRAM_KERNEL_NAMES                     = 0x1168,
}
enum : cl_program_build_info
{
	CL_PROGRAM_BUILD_STATUS                     = 0x1181,
	CL_PROGRAM_BUILD_OPTIONS                    = 0x1182,
	CL_PROGRAM_BUILD_LOG                        = 0x1183,
	CL_PROGRAM_BINARY_TYPE                      = 0x1184
}

enum cl_program_binary_type : cl_uint
{
	CL_PROGRAM_BINARY_TYPE_NONE                 = 0x0,
	CL_PROGRAM_BINARY_TYPE_COMPILED_OBJECT      = 0x1,
	CL_PROGRAM_BINARY_TYPE_LIBRARY              = 0x2,
	CL_PROGRAM_BINARY_TYPE_EXECUTABLE           = 0x4
}
mixin(bringToCurrentScope!cl_program_binary_type);

enum : cl_build_status
{
	CL_BUILD_SUCCESS                            = 0,
	CL_BUILD_NONE                               = -1,
	CL_BUILD_ERROR                              = -2,
	CL_BUILD_IN_PROGRESS                        = -3,
}
enum : cl_kernel_info
{
	CL_KERNEL_FUNCTION_NAME                     = 0x1190,
	CL_KERNEL_NUM_ARGS                          = 0x1191,
	CL_KERNEL_REFERENCE_COUNT                   = 0x1192,
	CL_KERNEL_CONTEXT                           = 0x1193,
	CL_KERNEL_PROGRAM                           = 0x1194,
	CL_KERNEL_ATTRIBUTES                        = 0x1195
}

enum : cl_kernel_arg_info
{
	CL_KERNEL_ARG_ADDRESS_QUALIFIER             = 0x1196,
	CL_KERNEL_ARG_ACCESS_QUALIFIER              = 0x1197,
	CL_KERNEL_ARG_TYPE_NAME                     = 0x1198,
	CL_KERNEL_ARG_TYPE_QUALIFIER                = 0x1199,
	CL_KERNEL_ARG_NAME                          = 0x119A
}

enum cl_kernel_arg_address_qualifier : cl_uint
{
	CL_KERNEL_ARG_ADDRESS_GLOBAL                = 0x119B,
	CL_KERNEL_ARG_ADDRESS_LOCAL                 = 0x119C,
	CL_KERNEL_ARG_ADDRESS_CONSTANT              = 0x119D,
	CL_KERNEL_ARG_ADDRESS_PRIVATE               = 0x119E
}
mixin(bringToCurrentScope!cl_kernel_arg_address_qualifier);

enum cl_kernel_arg_access_qualifier : cl_uint
{
	CL_KERNEL_ARG_ACCESS_READ_ONLY              = 0x11A0,
	CL_KERNEL_ARG_ACCESS_WRITE_ONLY             = 0x11A1,
	CL_KERNEL_ARG_ACCESS_READ_WRITE             = 0x11A2,
	CL_KERNEL_ARG_ACCESS_NONE                   = 0x11A3
}
mixin(bringToCurrentScope!cl_kernel_arg_access_qualifier);

enum cl_kernel_arg_type_qualifer : cl_bitfield
{
	CL_KERNEL_ARG_TYPE_NONE                     = 0,
	CL_KERNEL_ARG_TYPE_CONST                    = (1 << 0),
	CL_KERNEL_ARG_TYPE_RESTRICT                 = (1 << 1),
	CL_KERNEL_ARG_TYPE_VOLATILE                 = (1 << 2)
}
mixin(bringToCurrentScope!cl_kernel_arg_type_qualifer);

enum : cl_kernel_work_group_info
{
	CL_KERNEL_WORK_GROUP_SIZE                   = 0x11B0,
	CL_KERNEL_COMPILE_WORK_GROUP_SIZE           = 0x11B1,
	CL_KERNEL_LOCAL_MEM_SIZE                    = 0x11B2,
	CL_KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE= 0x11B3,
	CL_KERNEL_PRIVATE_MEM_SIZE                  = 0x11B4,
	CL_KERNEL_GLOBAL_WORK_SIZE                  = 0x11B5
}
enum : cl_event_info
{
	CL_EVENT_COMMAND_QUEUE                      = 0x11D0,
	CL_EVENT_COMMAND_TYPE                       = 0x11D1,
	CL_EVENT_REFERENCE_COUNT                    = 0x11D2,
	CL_EVENT_COMMAND_EXECUTION_STATUS           = 0x11D3,
	CL_EVENT_CONTEXT                            = 0x11D4,
}

//!
enum cl_command_type : cl_uint
{
	CL_COMMAND_NDRANGE_KERNEL                   = 0x11F0,
	CL_COMMAND_TASK                             = 0x11F1,
	CL_COMMAND_NATIVE_KERNEL                    = 0x11F2,
	CL_COMMAND_READ_BUFFER                      = 0x11F3,
	CL_COMMAND_WRITE_BUFFER                     = 0x11F4,
	CL_COMMAND_COPY_BUFFER                      = 0x11F5,
	CL_COMMAND_READ_IMAGE                       = 0x11F6,
	CL_COMMAND_WRITE_IMAGE                      = 0x11F7,
	CL_COMMAND_COPY_IMAGE                       = 0x11F8,
	CL_COMMAND_COPY_IMAGE_TO_BUFFER             = 0x11F9,
	CL_COMMAND_COPY_BUFFER_TO_IMAGE             = 0x11FA,
	CL_COMMAND_MAP_BUFFER                       = 0x11FB,
	CL_COMMAND_MAP_IMAGE                        = 0x11FC,
	CL_COMMAND_UNMAP_MEM_OBJECT                 = 0x11FD,
	CL_COMMAND_MARKER                           = 0x11FE,
	CL_COMMAND_ACQUIRE_GL_OBJECTS               = 0x11FF,
	CL_COMMAND_RELEASE_GL_OBJECTS               = 0x1200,
	CL_COMMAND_READ_BUFFER_RECT                 = 0x1201,
	CL_COMMAND_WRITE_BUFFER_RECT                = 0x1202,
	CL_COMMAND_COPY_BUFFER_RECT                 = 0x1203,
	CL_COMMAND_USER                             = 0x1204,
	CL_COMMAND_BARRIER                          = 0x1205,
	CL_COMMAND_MIGRATE_MEM_OBJECTS              = 0x1206,
	CL_COMMAND_FILL_BUFFER                      = 0x1207,
	CL_COMMAND_FILL_IMAGE                       = 0x1208
}
mixin(bringToCurrentScope!cl_command_type());

//! used for user events etc.
enum cl_command_execution_status : cl_uint
{
	CL_COMPLETE                                 = 0x0, //! the command has completed
	CL_RUNNING                                  = 0x1, //! device is currently executing this command
	CL_SUBMITTED                                = 0x2, //! enqueued command has been submitted by the host to the device associated with the command-queue
	CL_QUEUED                                   = 0x3, //! command has been enqueued in the command-queue
}
mixin(bringToCurrentScope!cl_command_execution_status());

enum : cl_buffer_create_type
{
	CL_BUFFER_CREATE_TYPE_REGION                = 0x1220,
	
}
enum : cl_profiling_info
{
	CL_PROFILING_COMMAND_QUEUED                 = 0x1280,
	CL_PROFILING_COMMAND_SUBMIT                 = 0x1281,
	CL_PROFILING_COMMAND_START                  = 0x1282,
	CL_PROFILING_COMMAND_END                    = 0x1283
}

/********************************************************************************************************/

// Platform API
//!
cl_errcode clGetPlatformIDs(
	cl_uint          num_entries,
	cl_platform_id*  platforms,
	cl_uint*         num_platforms
);

//!
cl_errcode clGetPlatformInfo(
	cl_platform_id    platform,
	cl_platform_info  param_name,
	size_t            param_value_size,
	void*             param_value,
	size_t*           param_value_size_ret
);

// Device APIs
//!
cl_errcode clGetDeviceIDs(
	cl_platform_id    platform,
	cl_device_type    device_type,
	cl_uint           num_entries,
	cl_device_id*     devices,
	cl_uint*          num_devices
);

//!
cl_errcode clGetDeviceInfo(
	cl_device_id     device,
	cl_device_info   param_name,
	size_t           param_value_size,
	void*            param_value,
	size_t*          param_value_size_ret
);

version(CL_VERSION_1_2)
//!
cl_errcode clCreateSubDevices(
	cl_device_id                         in_device,
	const(cl_device_partition_property)* properties,
	cl_uint                              num_devices,
	cl_device_id*                        out_devices,
	cl_uint*                             num_devices_ret
);

version(CL_VERSION_1_2)
//!
cl_errcode clRetainDevice(cl_device_id device);

version(CL_VERSION_1_2)
//!
cl_errcode clReleaseDevice(cl_device_id device);

// Context APIs

/**
 *	errinfo is a pointer to an error string
 *	private_info and cb represent a pointer to binary data that is returned by the OpenCL
	implementation that can be used to log additional information helpful in debugging the error
 */
alias extern(System) void function(
	const(char)*	errinfo,
	const(void)*	private_info,
	size_t			cb,
	void*			user_data
) cl_logging_fn;

//!
cl_context clCreateContext(
	const(cl_context_properties)*    properties,
	cl_uint                          num_devices,
	const(cl_device_id)*             devices,
	cl_logging_fn                    pfn_notify,
	void*                            user_data,
	cl_errcode*                      errcode_ret
);

//!
cl_context clCreateContextFromType(
	const(cl_context_properties)*    properties,
	cl_device_type                   device_type,
	cl_logging_fn                    pfn_notify,
	void*                            user_data,
	cl_errcode*                      errcode_ret
);

//!
cl_errcode clRetainContext(
	cl_context  context
);

//!
cl_errcode clReleaseContext(
	cl_context  context
);

//!
cl_errcode clGetContextInfo(
	cl_context          context,
	cl_context_info     param_name,
	size_t              param_value_size,
	void*               param_value,
	size_t*             param_value_size_ret
);

// Command Queue APIs
//!
cl_command_queue clCreateCommandQueue(
	cl_context                      context,
	cl_device_id                    device,
	cl_command_queue_properties     properties,
	cl_errcode*                     errcode_ret
);

//!
cl_errcode clRetainCommandQueue(
	cl_command_queue  command_queue
);

//!
cl_errcode clReleaseCommandQueue(
	cl_command_queue  command_queue
);

//!
cl_errcode clGetCommandQueueInfo(
	cl_command_queue       command_queue,
	cl_command_queue_info  param_name,
	size_t                 param_value_size,
	void *                 param_value,
	size_t *               param_value_size_ret
);

// Memory Object APIs
//!
cl_mem clCreateBuffer(
	cl_context    context,
	cl_mem_flags  flags,
	size_t        size,
	void*         host_ptr,
	cl_errcode*   errcode_ret
);

version(CL_VERSION_1_1)
//!
cl_mem clCreateSubBuffer(
	cl_mem					buffer,
	cl_mem_flags			flags,
	cl_buffer_create_type	buffer_create_type,
	const(void)*			buffer_create_info,
	cl_errcode*				errcode_ret);

version(CL_VERSION_1_2) {} else
{
//!
cl_mem clCreateImage2D(
	cl_context               context,
	cl_mem_flags             flags,
	const(cl_image_format)*  image_format,
	size_t                   image_width,
	size_t                   image_height,
	size_t                   image_row_pitch,
	void*                    host_ptr,
	cl_errcode*              errcode_ret
);
//!
cl_mem clCreateImage3D(
	cl_context               context,
	cl_mem_flags             flags,
	const(cl_image_format)*  image_format,
	size_t                   image_width,
	size_t                   image_height,
	size_t                   image_depth,
	size_t                   image_row_pitch,
	size_t                   image_slice_pitch,
	void*                    host_ptr,
	cl_errcode*              errcode_ret
);
}

version(CL_VERSION_1_2)
//!
cl_mem clCreateImage(
	cl_context             context,
	cl_mem_flags           flags,
	const cl_image_format* image_format,
	const cl_image_desc*   image_desc,
	void*                  host_ptr,
	cl_errcode*            errcode_ret
);

//!
cl_errcode clRetainMemObject(
	cl_mem  memobj
);

//!
cl_errcode clReleaseMemObject(
	cl_mem  memobj
);

//!
cl_errcode clGetSupportedImageFormats(
	cl_context            context,
	cl_mem_flags          flags,
	cl_mem_object_type    image_type,
	cl_uint               num_entries,
	cl_image_format*      image_formats,
	cl_uint*              num_image_formats
);

//!
cl_errcode clGetMemObjectInfo(
	cl_mem            memobj,
	cl_mem_info       param_name,
	size_t            param_value_size,
	void*             param_value,
	size_t*           param_value_size_ret
);

//!
cl_errcode clGetImageInfo(
	cl_mem            image,
	cl_image_info     param_name,
	size_t            param_value_size,
	void *            param_value,
	size_t *          param_value_size_ret
);

//!
alias extern(System) void function(
	cl_mem memobj,
	void* user_data) mem_notify_fn;

version(CL_VERSION_1_1)
//!
cl_errcode clSetMemObjectDestructorCallback(
	cl_mem	memobj,
	mem_notify_fn pfn_notify,
	void*	user_data);

// Sampler APIs
//!
cl_sampler clCreateSampler(
	cl_context           context,
	cl_bool              normalized_coords,
	cl_addressing_mode   addressing_mode,
	cl_filter_mode       filter_mode,
	cl_errcode*          errcode_ret
);

//!
cl_errcode clRetainSampler(
	cl_sampler  sampler
);

//!
cl_errcode clReleaseSampler(
	cl_sampler  sampler
);

//!
cl_errcode clGetSamplerInfo(
	cl_sampler          sampler,
	cl_sampler_info     param_name,
	size_t              param_value_size,
	void*               param_value,
	size_t*             param_value_size_ret
);

// Program Object APIs
//!
cl_program clCreateProgramWithSource(
	cl_context         context,
	cl_uint            count,
	const(char*)*      strings,
	const(size_t)*     lengths,
	cl_errcode*        errcode_ret
);

//!
cl_program clCreateProgramWithBinary(
	cl_context             context,
	cl_uint                num_devices,
	const(cl_device_id)*   device_list,
	const(size_t)*         lengths,
	const(ubyte*)*         binaries,
	cl_int*                binary_status,
	cl_errcode*            errcode_ret
);

version(CL_VERSION_1_2)
//!
cl_program clCreateProgramWithBuiltInKernels(
	cl_context           context,
	cl_uint              num_devices,
	const(cl_device_id)* device_list,
	const(char)*         kernel_names,
	cl_errcode*          errcode_ret
);
//!
cl_errcode clRetainProgram(
	cl_program  program
);

//!
cl_errcode clReleaseProgram(
	cl_program  program
);

//!
alias extern(System) void function(
	cl_program		  program,
	void*			  user_data
) prg_notify_fn;

//!
cl_errcode clBuildProgram(
	cl_program				program,
	cl_uint					num_devices,
	const(cl_device_id)*	device_list,
	const(char)*			options,
	prg_notify_fn			pfn_notify,
	void*					user_data
);

version(CL_VERSION_1_2) {} else
//!
cl_errcode clUnloadCompiler();

version(CL_VERSION_1_2)
{
//!
cl_errcode clCompileProgram(
	cl_program           program,
	cl_uint              num_devices,
	const(cl_device_id)* device_list,
	const(char)*         options,
	cl_uint              num_input_headers,
	const(cl_program)*   input_headers,
	const(char)**        header_include_names,
	prg_notify_fn        pfn_notify,
	void *               user_data
);

//!
cl_program clLinkProgram(
	cl_context           context,
	cl_uint              num_devices,
	const(cl_device_id)* device_list,
	const(char)*         options,
	cl_uint              num_input_programs,
	const(cl_program)*   input_programs,
	prg_notify_fn        pfn_notify,
	void*                user_data,
	cl_errcode*          errcode_ret
);

//!
cl_errcode clUnloadPlatformCompiler(cl_platform_id platform);
}

//!
cl_errcode clGetProgramInfo(
	cl_program          program,
	cl_program_info     param_name,
	size_t              param_value_size,
	void*               param_value,
	size_t*             param_value_size_ret
);

//!
cl_errcode clGetProgramBuildInfo(
	cl_program             program,
	cl_device_id           device,
	cl_program_build_info  param_name,
	size_t                 param_value_size,
	void*                  param_value,
	size_t*                param_value_size_ret
);

// Kernel Object APIs
//!
cl_kernel clCreateKernel(
	cl_program       program,
	const(char)*     kernel_name,
	cl_errcode*      errcode_ret
);

//!
cl_errcode clCreateKernelsInProgram(
	cl_program      program,
	cl_uint         num_kernels,
	cl_kernel*      kernels,
	cl_uint*        num_kernels_ret
);

//!
cl_errcode clRetainKernel(
	cl_kernel     kernel
);

//!
cl_errcode clReleaseKernel(
	cl_kernel    kernel
);

//!
cl_errcode clSetKernelArg(
	cl_kernel     kernel,
	cl_uint       arg_indx,
	size_t        arg_size,
	const(void)*  arg_value
);

//!
cl_errcode clGetKernelInfo(
	cl_kernel        kernel,
	cl_kernel_info   param_name,
	size_t           param_value_size,
	void*            param_value,
	size_t*          param_value_size_ret
);

version(CL_VERSION_1_2)
//!
cl_errcode clGetKernelArgInfo(
	cl_kernel           kernel,
	cl_uint             arg_indx,
	cl_kernel_arg_info  param_name,
	size_t              param_value_size,
	void*               param_value,
	size_t*             param_value_size_ret
);

//!
cl_errcode clGetKernelWorkGroupInfo(
	cl_kernel                   kernel,
	cl_device_id                device,
	cl_kernel_work_group_info   param_name,
	size_t                      param_value_size,
	void*                       param_value,
	size_t*                     param_value_size_ret
);

// Event Object APIs
//!
cl_errcode clWaitForEvents(
	cl_uint              num_events,
	const(cl_event)*     event_list
);

//!
cl_errcode clGetEventInfo(
	cl_event          event,
	cl_event_info     param_name,
	size_t            param_value_size,
	void*             param_value,
	size_t*           param_value_size_ret
);

version(CL_VERSION_1_1)
//!
cl_event clCreateUserEvent(
	cl_context	context,
	cl_errcode*	errcode_ret);

//!
cl_errcode clRetainEvent(
	cl_event  event
);

//!
cl_errcode clReleaseEvent(
	cl_event  event
);

version(CL_VERSION_1_1)
//!
cl_errcode clSetUserEventStatus(
	cl_event	event,
	cl_command_execution_status execution_status);

/**
 *	callback function type for clSetEventCallback, called asynchronously, must return promptly
 *
 *	Params:
 *		event = the event object for which the callback function is invoked
 *		command_exec_status = execution status of command for which this callback function is invoked
 *			If the callback is called as the result of the command associated with
 *			event being abnormally terminated, an appropriate error code for the error that caused
 *			the termination will be passed to event_command_exec_status instead
 */
alias extern(System) void function(
	cl_event event,
	cl_int command_exec_status,
	void*) evt_notify_fn;

//!
version(CL_VERSION_1_1)
cl_errcode clSetEventCallback( cl_event	event,
                    cl_int			command_exec_callback_type,
                    evt_notify_fn	pfn_notify,
                    void*			user_data);

// Profiling APIs
//!
cl_errcode clGetEventProfilingInfo(
	cl_event             event,
	cl_profiling_info    param_name,
	size_t               param_value_size,
	void*                param_value,
	size_t*              param_value_size_ret
);

// Flush and Finish APIs
//!
cl_errcode clFlush(
	cl_command_queue  command_queue
);

//!
cl_errcode clFinish(
	cl_command_queue  command_queue
);

// Enqueued Commands APIs
//!
cl_errcode clEnqueueReadBuffer(
	cl_command_queue     command_queue,
	cl_mem               buffer,
	cl_bool              blocking_read,
	size_t               offset,
	size_t               size,
	void*                ptr,
	cl_uint              num_events_in_wait_list,
	const(cl_event)*     event_wait_list,
	cl_event*            event
);

version(CL_VERSION_1_1)
//!
cl_errcode clEnqueueReadBufferRect(
	cl_command_queue	command_queue,
	cl_mem				buffer,
	cl_bool				blocking_read,
	const(size_t)*		buffer_offset,	// size_t[3]
	const(size_t)*		host_offset,	// size_t[3]
	const(size_t)*		region,			// size_t[3]
	size_t				buffer_row_pitch,
	size_t				buffer_slice_pitch,
	size_t				host_row_pitch,
	size_t				host_slice_pitch,
	void*				ptr,
	cl_uint				num_events_in_wait_list,
	const(cl_event)*	event_wait_list,
	cl_event*			event);

//!
cl_errcode clEnqueueWriteBuffer(
	cl_command_queue	command_queue,
	cl_mem				buffer,
	cl_bool             blocking_write,
	size_t              offset,
	size_t              size,
	const(void)*        ptr,
	cl_uint             num_events_in_wait_list,
	const(cl_event)*    event_wait_list,
	cl_event*           event
);

version(CL_VERSION_1_1)
//!
cl_errcode clEnqueueWriteBufferRect(
	cl_command_queue	command_queue,
	cl_mem				buffer,
	cl_bool				blocking_write,
	const(size_t)*		buffer_offset,	// size_t[3]
	const(size_t)*		host_offset,	// size_t[3]
	const(size_t)*		region,			// size_t[3]
	size_t				buffer_row_pitch,
	size_t				buffer_slice_pitch,
	size_t				host_row_pitch,
	size_t				host_slice_pitch,
	const(void)*		ptr,
	cl_uint				num_events_in_wait_list,
	const(cl_event)*	event_wait_list,
	cl_event *			event);

version(CL_VERSION_1_2)
//!
cl_errcode clEnqueueFillBuffer(
	cl_command_queue    command_queue,
	cl_mem              buffer,
	const(void)*        pattern,
	size_t              pattern_size,
	size_t              offset,
	size_t              size,
	cl_uint             num_events_in_wait_list,
	const(cl_event)*    event_wait_list,
	cl_event*           event
);

//!
cl_errcode clEnqueueCopyBuffer(
	cl_command_queue     command_queue,
	cl_mem               src_buffer,
	cl_mem               dst_buffer,
	size_t               src_offset,
	size_t               dst_offset,
	size_t               size,
	cl_uint              num_events_in_wait_list,
	const(cl_event)*     event_wait_list,
	cl_event*            event
);

version(CL_VERSION_1_1)
//!
cl_errcode clEnqueueCopyBufferRect(
		cl_command_queue	command_queue,
		cl_mem				src_buffer,
		cl_mem				dst_buffer,
		const(size_t)*		src_origin,
		const(size_t)*		dst_origin,
		const(size_t)*		region,
		size_t				src_row_pitch,
		size_t				src_slice_pitch,
		size_t				dst_row_pitch,
		size_t				dst_slice_pitch,
		cl_uint				num_events_in_wait_list,
		const(cl_event)*	event_wait_list,
		cl_event*			event);

//!
cl_errcode clEnqueueReadImage(
	cl_command_queue      command_queue,
	cl_mem                image,
	cl_bool               blocking_read,
	const(size_t)*        origin, // size_t[3]
	const(size_t)*        region, // size_t[3]
	size_t                row_pitch,
	size_t                slice_pitch,
	void*                 ptr,
	cl_uint               num_events_in_wait_list,
	const(cl_event)*      event_wait_list,
	cl_event*             event
);

//!
cl_errcode clEnqueueWriteImage(
	cl_command_queue     command_queue,
	cl_mem               image,
	cl_bool              blocking_write,
	const(size_t)*       origin, // size_t[3]
	const(size_t)*       region, // size_t[3]
	size_t               input_row_pitch,
	size_t               input_slice_pitch,
	const(void)*         ptr,
	cl_uint              num_events_in_wait_list,
	const(cl_event)*     event_wait_list,
	cl_event*            event
);

version(CL_VERSION_1_2)
//!
cl_errcode clEnqueueFillImage(
	cl_command_queue   command_queue,
	cl_mem             image,
	const(void)*       fill_color,
	const(size_t)*[3]  origin,
	const(size_t)*[3]  region,
	cl_uint            num_events_in_wait_list,
	const(cl_event)*   event_wait_list,
	cl_event*          event
);

//!
cl_errcode clEnqueueCopyImage(
	cl_command_queue      command_queue,
	cl_mem                src_image,
	cl_mem                dst_image,
	const(size_t)*        src_origin, // size_t[3]
	const(size_t)*        dst_origin, // size_t[3]
	const(size_t)*        region, // size_t[3]
	cl_uint               num_events_in_wait_list,
	const(cl_event)*      event_wait_list,
	cl_event*             event
);

//!
cl_errcode clEnqueueCopyImageToBuffer(
	cl_command_queue  command_queue,
	cl_mem            src_image,
	cl_mem            dst_buffer,
	const(size_t)*    src_origin, // size_t[3]
	const(size_t)*    region, // size_t[3]
	size_t            dst_offset,
	cl_uint           num_events_in_wait_list,
	const(cl_event)*  event_wait_list,
	cl_event*         event
);

//!
cl_errcode clEnqueueCopyBufferToImage(
	cl_command_queue  command_queue,
	cl_mem            src_buffer,
	cl_mem            dst_image,
	size_t            src_offset,
	const(size_t)*    dst_origin, // size_t[3]
	const(size_t)*    region, // size_t[3]
	cl_uint           num_events_in_wait_list,
	const(cl_event)*  event_wait_list,
	cl_event*         event
);

//!
void* clEnqueueMapBuffer(
	cl_command_queue  command_queue,
	cl_mem            buffer,
	cl_bool           blocking_map,
	cl_map_flags      map_flags,
	size_t            offset,
	size_t            size,
	cl_uint           num_events_in_wait_list,
	const(cl_event)*  event_wait_list,
	cl_event*         event,
	cl_errcode*       errcode_ret
);

//!
void* clEnqueueMapImage(
	cl_command_queue   command_queue,
	cl_mem             image,
	cl_bool            blocking_map,
	cl_map_flags       map_flags,
	const(size_t)*     origin, // size_t[3]
	const(size_t)*     region, // size_t[3]
	size_t*            image_row_pitch,
	size_t*            image_slice_pitch,
	cl_uint            num_events_in_wait_list,
	const(cl_event)*   event_wait_list,
	cl_event*          event,
	cl_errcode*        errcode_ret
);

//!
cl_errcode clEnqueueUnmapMemObject(
	cl_command_queue  command_queue,
	cl_mem            memobj,
	void*             mapped_ptr,
	cl_uint           num_events_in_wait_list,
	const(cl_event)*  event_wait_list,
	cl_event*         event
);

version(CL_VERSION_1_2)
//!
cl_errcode clEnqueueMigrateMemObjects(
	cl_command_queue        command_queue,
	cl_uint                 num_mem_objects,
	const(cl_mem)*          mem_objects,
	cl_mem_migration_flags  flags,
	cl_uint                 num_events_in_wait_list,
	const(cl_event)*        event_wait_list,
	cl_event*               event
);

//!
cl_errcode clEnqueueNDRangeKernel(
	cl_command_queue  command_queue,
	cl_kernel         kernel,
	cl_uint           work_dim,
	const(size_t)*    global_work_offset,
	const(size_t)*    global_work_size,
	const(size_t)*    local_work_size,
	cl_uint           num_events_in_wait_list,
	const(cl_event)*  event_wait_list,
	cl_event*         event
);

//!
cl_errcode clEnqueueTask(
	cl_command_queue   command_queue,
	cl_kernel          kernel,
	cl_uint            num_events_in_wait_list,
	const(cl_event)*   event_wait_list,
	cl_event*          event
);

alias extern(System) void function(
	void*
) nativeKernelFunc;

//!
cl_errcode clEnqueueNativeKernel(
	cl_command_queue   command_queue,
	nativeKernelFunc   user_func,
	void*              args,
	size_t             cb_args,
	cl_uint            num_mem_objects,
	const(cl_mem)*     mem_list,
	const(void*)*      args_mem_loc,
	cl_uint            num_events_in_wait_list,
	const(cl_event)*   event_wait_list,
	cl_event*          event
);

version(CL_VERSION_1_2) {} else
{
//!
cl_errcode clEnqueueMarker(
	cl_command_queue     command_queue,
	cl_event*            event
);

//!
cl_errcode clEnqueueWaitForEvents(
	cl_command_queue  command_queue,
	cl_uint           num_events,
	const(cl_event)*  event_list
);

//!
cl_errcode clEnqueueBarrier(
	cl_command_queue  command_queue
);
}

version(CL_VERSION_1_2)
//!
cl_errcode clEnqueueMarkerWithWaitList(
	cl_command_queue  command_queue,
	cl_uint           num_events_in_wait_list,
	const(cl_event)*  event_wait_list,
	cl_event*         event
);

version(CL_VERSION_1_2)
//!
cl_errcode clEnqueueBarrierWithWaitList(
	cl_command_queue  command_queue,
	cl_uint           num_events_in_wait_list,
	const(cl_event)*  event_wait_list,
	cl_event*         event
);

alias extern(System) void function(
	cl_context program,
	cl_uint    printf_data_len,
	char*      printf_data_ptr,
	void*      user_data) PrintfCallback;

version(CL_VERSION_1_2)
//!
cl_errcode clSetPrintfCallback(
	cl_context         context,
	PrintfCallback     pfn_notify,
	void*              user_data
);

/**
 *	Extension function access
 *
 *	Returns the extension function address for the given function name,
 *	or null if a valid function can not be found. The client must
 *	check to make sure the address is not null, before using or
 *	calling the returned function address.
 */
version(CL_VERSION_1_2)
void* clGetExtensionFunctionAddressForPlatform(
	cl_platform_id platform,
	const(char)*   func_name
);
else
void* clGetExtensionFunctionAddress(const(char)* func_name);
