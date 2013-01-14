#ifndef _CVec2d_h_
#define _CVec2d_h_

/**
 * Simple 3 component vector class
 *
 * CVec2d implements a 3 component vector with standard
 * operators and methods. It should also be used instead
 * of the cold IvfVector class. 
 * @author Jonas Lindemann
 */
class CVec2d {
private:
	double m_vector[2];
public:
	double getX();
	double getY();
	/** Class constructor. */
	CVec2d();
    
	/** Class constructor. */
	CVec2d(double vx, double vy);
    
	/** Class assignment constructor. */
	CVec2d(const CVec2d& v);
    
	/** Class destructor. */
	virtual ~CVec2d();
        
	/** Normalizes the vector. Length = 1.0.*/
	void normalize();
    
	/** Returns the vector length. */
	double length();
    
	/** Negate vector. */
	void negate();
    
	/** Add to vector. */
	void add(double dx, double dy);
    
	/** 
	 * Set vector from to points/vectors. 
	 * 
	 * @param pos is the starting point of the vector.
	 * @param target is the endpoint of the vector.
	 */
	void setFromPoints(CVec2d& pos, CVec2d& target);
    
	/** Return a pointer to vector components */
	double* getComponents();
    
	/** Set components of vector. */
	void setComponents(double vx, double vy);
	/** Set components of vector. */
	void setComponents(const double *v);
	/** Get vector components. */
	void getComponents(double &vx, double &vy);
	/** Get vector components. */
	void getComponents(double* v);
    
	/** Set components of vector. */
	void setComponents(int x, int y);
    
	/** Set components of vector. */
	void setComponents(const int* pos);
        
	/** Set x-component of vector */
	void setX(double value);
	/** Set y-component of vector */
	void setY(double value);
    
	/** Vector addition operator. */
	CVec2d& operator+=(CVec2d a);
	/** Vector subtraction operator. */
	CVec2d& operator-=(CVec2d a);
	/** Assignment operator. */
	CVec2d& operator=(CVec2d a);
	/** Index operator. */
	double operator[](const int idx);
    
};

/** Vector crossproduct operator. */
CVec2d operator*(CVec2d a, CVec2d b);

/** Vector scalar multiplication operator. */
CVec2d operator*(CVec2d a, double b); 

/** Vector scalar multiplication operator. */
CVec2d operator*(double a, CVec2d b);

/** Vector addition operator. */
CVec2d operator+(CVec2d a, CVec2d b);

/** Vector subtraction operator. */
CVec2d operator-(CVec2d a, CVec2d b);

#endif 
