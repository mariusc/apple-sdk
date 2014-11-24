#include <stddef.h>     // C Standard

/*!
 *  @abstract Global enumerator specifying all the supported <code>CObjType</code>s.
 *
 *  @constant CObjTypeString <code>enum</code> value representing a <code>CObjString</code>.
 */
enum CObjType {
    CObjTypeString
};

/*!
 *  @abstract Structure specifying how the global <code>CClass</code> constant objects will be implemented.
 *
 *  @field type An <code>enum</code> identifying the object.
 */
struct CClass
{
    enum CObjType type;
};

/*! @abstract Global definition identifying the <code>CObjString</code> objects. */
extern struct CClass const* const CClassString;

#pragma mark - CCore

/*!
 *  @abstract Structure share by all of the CBasics objects types.
 *
 *  @field objClass Constant Structure identifying the object type.
 *  @field retained The number of actives objects. Once it reaches 0, the object will be deallocated.
 */
struct CCore
{
    struct CClass const* objClass;
    size_t retained;
};

/*!
 *  @abstract This macro is replaced with a <code>struct CCore</code> compound literal containing the passed arguments.
 *
 *  @param objClassPtr Global constant pointer identifying the type of C Object.
 *  @param numActives  How many retain counts do you want the object to be set with.
 */
#define ccore(objClassPtr, numActives)     ((struct CCore){.objClass=objClassPtr, .retained=numActives})

/*!
 *  @abstract This macro adds one to the retain count.
 *
 *  @param structure <code>CCore</code> structure identifying a C object.
 */
#define ccore_retain(coreStruct)            (coreStruct.retained++)

/*!
 *  @abstract This macro adds one to the retain count.
 *
 *  @param structure     <code>CCore</code> structure identifying a C object.
 */
#define ccore_release(coreStruct)    if (--(coreStruct.retained) == 0)
