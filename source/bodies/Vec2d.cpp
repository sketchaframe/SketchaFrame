#include "Vec2d.h"

#include <cmath>

#ifndef M_PI
#define M_PI 3.1415926535897932384626433832795
#endif

CVec2d::CVec2d()
{
	setComponents(0.0, 0.0);
}

CVec2d::CVec2d(double vx, double vy)
{
	m_vector[0] = vx;
	m_vector[1] = vy;
}

CVec2d::CVec2d(const CVec2d& v)
{
	m_vector[0] = v.m_vector[0];
	m_vector[1] = v.m_vector[1];
}

CVec2d::~CVec2d()
{
    
}

void CVec2d::setComponents(double vx, double vy)
{
	m_vector[0] = vx;
	m_vector[1] = vy;
}

void CVec2d::setComponents(const double *v)
{
	m_vector[0] = v[0];
	m_vector[1] = v[1];
}

void CVec2d::setComponents(int x, int y)
{
	m_vector[0] = (double)x;
	m_vector[1] = (double)y;
}

void CVec2d::setComponents(const int* pos)
{
	m_vector[0] = (double)pos[0];
	m_vector[1] = (double)pos[1];
}

void CVec2d::getComponents(double &vx, double &vy)
{
	vx = m_vector[0];
	vy = m_vector[1];
}

CVec2d& CVec2d::operator+=(CVec2d a)
{
	m_vector[0] += a.m_vector[0];
	m_vector[1] += a.m_vector[1];
	return *this;
}

CVec2d& CVec2d::operator=(CVec2d a)
{
	m_vector[0] = a.m_vector[0];
	m_vector[1] = a.m_vector[1];
	return *this;
}


CVec2d& CVec2d::operator-=(CVec2d a)
{
	m_vector[0] -= a.m_vector[0];
	m_vector[1] -= a.m_vector[1];
	return *this;
}

CVec2d operator+(CVec2d a, CVec2d b)
{
	CVec2d r = a;
	return r += b;
}

CVec2d operator-(CVec2d a, CVec2d b)
{
	CVec2d r = a;
	return r -= b;
}

double CVec2d::operator[](const int idx)
{
	if ((idx>=0)&&(idx<2))
		return m_vector[idx];
	else
		return 0.0;
}

CVec2d operator*(CVec2d a, CVec2d b)
{
    // Not defined yet.
    
    /*
	double c1, c2, c3;
    
	c1 = a[1] * b[2] - a[2] * b[1];
	c2 = a[2] * b[0] - a[0] * b[2];
	c3 = a[0] * b[1] - a[1] * b[0];
	*/
	CVec2d r(0.0, 0.0);
    
	return r;
}

CVec2d operator*(CVec2d a, double b)
{
	CVec2d r(a[0]*b, a[1]*b);
    
	return r;
}

CVec2d operator*(double a, CVec2d b)
{
	CVec2d r(b[0]*a, b[1]*a);
    
	return r;
}

void CVec2d::getComponents(double *v)
{
	v[0] = m_vector[0];
	v[1] = m_vector[1];
}

double CVec2d::length()
{
	return sqrt(pow(m_vector[0],2.0) + pow(m_vector[1],2.0) );
}

void CVec2d::normalize()
{
	double quote = 1.0/length();
    
	m_vector[0] = m_vector[0] * quote;
	m_vector[1] = m_vector[1] * quote;
}

void CVec2d::negate()
{
	m_vector[0] = - m_vector[0];
	m_vector[1] = - m_vector[1];
}

void CVec2d::setX(double value)
{
	m_vector[0] = value;
}

void CVec2d::setY(double value)
{
	m_vector[1] = value;
}

void CVec2d::setFromPoints(CVec2d &pos, CVec2d &target)
{
	CVec2d r;
	r = target - pos;
	r.getComponents(m_vector);
}

void CVec2d::add(double dx, double dy)
{
	m_vector[0] += dx;
	m_vector[1] += dy;
}

double* CVec2d::getComponents()
{
	return &m_vector[0];
}

double CVec2d::getX()
{
	return m_vector[0];
}

double CVec2d::getY()
{
	return m_vector[1];
}
