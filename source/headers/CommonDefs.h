//
//  CommonDefs.h
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#ifndef SimpleFrame_CommonDefs_h
#define SimpleFrame_CommonDefs_h

#define StdPointer(classname) \
class classname; \
typedef classname* classname##Ptr

#define SmartPointer(classname) \
class classname; \
typedef CPointer<classname> classname##Ptr; \
typedef classname* classname##StdPtr;

#define SmartPointerRefBase(classname,refbase) \
class classname; \
typedef CPointerRefBase<classname,refbase> classname##Ptr; \
typedef classname* classname##StdPtr;

#define ClassInfo(classname,parent) \
const std::string getClassNameThis() { return classname; } \
virtual const std::string getClassName() { return classname; } \
virtual bool isClass(const std::string& name) { \
std::string className; \
className = getClassNameThis(); \
if (!className.empty()) { \
if (className == name) \
return true; \
else \
return parent::isClass(name); \
}\
else \
return false; \
}

#define ClassInfoTop(classname) \
void getClassNameThis(std::string& name) { name = classname; } \
const std::string getClassNameThis() { return classname; } \
virtual void getClassName(std::string& name) { name = classname; } \
virtual const std::string getClassName() { return classname; } \
virtual bool isClass(const std::string& name) { \
std::string className = ""; \
className = getClassNameThis(); \
if (!className.empty()) { \
if (className == name) \
return true; \
else \
return false; \
}\
else \
return false; \
}

#endif
