//
//  SimpleBase.cpp
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#include "Base.h"

#include <iostream>

CBase::CBase ()
{
	m_ref = 0;
	m_parent = NULL;
}

CBase::~CBase ()
{
}

void CBase::addReference()
{
	m_ref++;
}

void CBase::deleteReference()
{
	if (m_ref>0)
		m_ref--;
}

bool CBase::isReferenced()
{
	return m_ref>0;
}

int CBase::getReferenceCount()
{
	return m_ref;
}

CBase* CBase::getParent()
{
	return m_parent;
}

void CBase::setParent(CBase *parent)
{
	m_parent = parent;
}