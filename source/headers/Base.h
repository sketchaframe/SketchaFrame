//
//  SimpleBase.h
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#ifndef SimpleFrame_SimpleBase_h
#define SimpleFrame_SimpleBase_h

#include <iostream>
#include "Pointer.h"
#include "CommonDefs.h"

/**
 * Base class
 * 
 * Base class used by most ForcePAD classes.
 * Contains code for reference counting, parent pointer and
 * stream handling.
 */
class CBase {
private:
	int m_ref;
	CBase* m_parent;
public:
	/** Base class constructor.*/
	CBase ();
	/** Base class destructor.*/
	virtual ~CBase ();
    
	ClassInfoTop("CBase");
    
	/** Increase reference count by 1.*/
	void addReference();
    
	/**
	 * Decrease reference count.
	 *
	 * Count is decreased only if > 0.
	 */
	void deleteReference();
    
	/** Returns true if reference count > 0.*/
	bool isReferenced();
    
	/** Returns reference count.*/
	int getReferenceCount();
    
	/** Sets parent object. */
	void setParent(CBase* parent);
    
	/** Returns parent object. */
	virtual CBase* getParent();
    
    
	/** Virtual method for retrieving object from a stream. */
	//virtual void readFromStream(istream &in);
    
	/** Virtual method for storing object to a stream. */
	//virtual void saveToStream(ostream &out);
};


#endif
