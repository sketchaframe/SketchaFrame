//
//  pointer.h
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#ifndef SimpleFrame_Pointer_h
#define SimpleFrame_Pointer_h

/**
 * Smart pointer class
 *
 * CPointer handles the ++ reference counting scheme of
 * the CBase class. To declare a ++ smart pointer use the 
 * SmartPointer() macro. See the following example:
 *
 * \code
 * int main()
 * {
 *    CPointer<CMaterial> material = new CMaterial(); // addReference() called.
 *    CPointer<CMaterial> material2;
 *    material2 = material; // addReference() called 
 *    .
 *    .
 *    
 *    return 0;
 * } 
 * // material calls deleteReference()
 * // material2 calls deleteRefernce() and deletes CMaterial object
 * \endcode
 */
template <class T,class R> class CPointerRefBase {
private:
	T* m_object;
public:
	CPointerRefBase(T* object = 0)
	{
		m_object = object;
		if (m_object)
			m_object->R::addReference();
	}
    
	CPointerRefBase(const CPointerRefBase& object)
	{
		m_object = object.m_object;
		if (m_object)
			m_object->R::addReference();
	}
    
	virtual ~CPointerRefBase()
	{
		if (m_object)
		{
			m_object->R::deleteReference();
			if (!m_object->R::referenced())
				delete m_object;
		}
	}
    
	operator T* () const { return m_object; }
	T& operator* () const { return *m_object; }
	T* operator-> () const { return m_object; }
    
	CPointerRefBase& operator= (const CPointerRefBase& pointerRefBase)
	{
		if (m_object!=pointerRefBase.m_object)
		{
			if (m_object)
			{
				m_object->R::deleteReference();
				if (!m_object->R::referenced())
					delete m_object;
			}
            
			m_object = pointerRefBase.m_object;
            
			if (m_object)
				m_object->R::addReference();
		}
		return *this;
	}
    
	CPointerRefBase& operator= (T* object)
	{
		if (m_object!=object)
		{
			if (m_object)
			{
				m_object->R::deleteReference();
				if (!m_object->R::referenced())
					delete m_object;
			}
            
			m_object = object;
            
			if (m_object)
				m_object->R::addReference();
		}
		return *this;
	}
    
	bool operator== (T* object) const { return m_object == object; }
	bool operator!= (T* object) const { return m_object != object; }
	bool operator== (const CPointerRefBase& pointerRefBase) const 
	{
		return m_object == pointerRefBase.m_object;
	}
    
	bool operator!= (const CPointerRefBase& pointerRefBase) const
	{
		return m_object != pointerRefBase.m_object;
	}
};

template <class T> class CPointer {
private:
	T* m_object;
public:
	CPointer(T* object = 0)
	{
		m_object = object;
		if (m_object)
			m_object->addReference();
	}
    
	CPointer(const CPointer& object)
	{
		m_object = object.m_object;
		if (m_object)
			m_object->addReference();
	}
    
	virtual ~CPointer()
	{
		if (m_object)
		{
			m_object->deleteReference();
			if (!m_object->isReferenced())
				delete m_object;
		}
	}
    
	operator T* () const { return m_object; }
	T& operator* () const { return *m_object; }
	T* operator-> () const { return m_object; }
    
	CPointer& operator= (const CPointer& pointer)
	{
		if (m_object!=pointer.m_object)
		{
			if (m_object)
			{
				m_object->deleteReference();
				if (!m_object->isReferenced())
					delete m_object;
			}
            
			m_object = pointer.m_object;
            
			if (m_object)
				m_object->addReference();
		}
		return *this;
	}
    
	CPointer& operator= (T* object)
	{
		if (m_object!=object)
		{
			if (m_object)
			{
				m_object->deleteReference();
				if (!m_object->isReferenced())
					delete m_object;
			}
            
			m_object = object;
            
			if (m_object)
				m_object->addReference();
		}
		return *this;
	}
    
	bool operator== (T* object) const { return m_object == object; }
	bool operator!= (T* object) const { return m_object != object; }
	bool operator== (const CPointer& pointer) const 
	{
		return m_object == pointer.m_object;
	}
    
	bool operator!= (const CPointer& pointer) const
	{
		return m_object != pointer.m_object;
	}
};

#endif
