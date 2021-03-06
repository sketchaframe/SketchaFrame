//
// CALFEM C++ libray
// Copyright (C) 1999-2006 Division of Structural Mecahnics, Lund University
//
// Written by Jonas Lindemann
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
// Comments and suggestions to jonas.lindemann@byggmek.lth.se

#include "calfem.h"

#include <iostream>
#include <iomanip>
#include <cmath>

namespace calfem {

void printMatrix(std::string name, Matrix & A)
{
	std::cout << name << " = [" << A.nrows() << "x" << A.ncols() << "]" << std::endl;
	std::cout << std::setw(10) << std::setprecision(4) << std::scientific << A;
	std::cout << std::endl;
}


void hooke(int ptype, double E, double v, Matrix &D)
{
	double a;
	switch (ptype) {
	case 1:
		a = E/(1.0 - pow(v,2));
		D.ReSize(3,3);
		D << 1.0*a << v*a << 0.0
			<< v*a << 1.0*a << 0.0
			<< 0.0 << 0.0 << a*(1.0-v)/2.0;
		break;
	case 2:
		a = E/((1.0+v)*(1.0-2.0*v));
		D.ReSize(4,4);
		D << a*(1-v) << a*v << a*v << 0.0
			<< a*v << (1.0-v)*a << a*v << 0.0
			<< a*v << a*v << (1.0-v)*a << 0.0
			<< 0.0 << 0.0 << 0.0 << a*(1.0-2.0*v)/2.0;
		break;
	case 3:
		a = E/((1.0+v)*(1.0-2.0*v));
		D.ReSize(4,4);
		D << a*(1-v) << a*v << a*v << 0.0
			<< a*v << (1.0-v)*a << a*v << 0.0
			<< a*v << a*v << (1.0-v)*a << 0.0
			<< 0.0 << 0.0 << 0.0 << a*(1.0-2.0*v)/2.0;
		break;
	case 4:
		a = E/((1.0+v)*(1.0-2.0*v));
		D.ReSize(6,6);
		D << a*(1.0-v) << a*v << a*v << 0.0 << 0.0 << 0.0
			<< a*v << a*(1.0-v) << a*v << 0.0 << 0.0 << 0.0
			<< a*v << a*v << a*(1.0-v) << 0.0 << 0.0 << 0.0
			<< 0.0 << 0.0 << 0.0 << a*0.5*(1.0-2.0*v) << 0.0 << 0.0
			<< 0.0 << 0.0 << 0.0 << 0.0 << a*0.5*(1.0-2.0*v) << 0.0 
			<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << a*0.5*(1.0-2.0*v) << 0.0;
		break;
	default:
		
		break;
	}
}

void plante(
			RowVector &ex, 
			RowVector &ey,
			RowVector &ep,
			Matrix &D,
			RowVector &eq,
			Matrix &Ke,
			ColumnVector &fe)
{
	int ptype = (int)ep(1);
	double t=ep(2);
	
	double bx = eq(1);
	double by = eq(2);
	
	Matrix C(6,6);
	
	C << 1.0 << ex(1) << ey(1) << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 1.0 << ex(1) << ey(1)
		<< 1.0 << ex(2) << ey(2) << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 1.0 << ex(2) << ey(2)
		<< 1.0 << ex(3) << ey(3) << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 1.0 << ex(3) << ey(3);
	
	Matrix AA(3,3);
	
	AA.Column(1) = 1.0;
	AA.Column(2) = ex.AsColumn();
	AA.Column(3) = ey.AsColumn();
	
	double A = 0.5*AA.LogDeterminant().Value();
	Matrix B(3,6);
	Matrix Cm;
	Matrix Dm;
	
	switch (ptype) {
	case 1:
		
		B << 0.0 << 1.0 << 0.0 << 0.0 << 0.0 << 0.0
			<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 1.0
			<< 0.0 << 0.0 << 1.0 << 0.0 << 1.0 << 0.0;

		B = B*C.i();
		
		if (D.Ncols()>3)
		{
			Cm.ReSize(D.Ncols(), D.Ncols());
			Cm = D.i();
			Dm.ReSize(3,3);
			Dm << Cm(1,1) << Cm(1,2) << Cm(1,4)
				<< Cm(2,1) << Cm(2,2) << Cm(2,4)
				<< Cm(4,1) << Cm(4,2) << Cm(4,4);
		}
		else
		{
			Dm.ReSize(D.Ncols(), D.Ncols());
			Dm = D;
		}
		
		Ke.ReSize(6,6);
		
		Ke = B.t()*Dm*B*A*t;
		fe.ReSize(6);
		
		fe << bx << by << bx << by << bx << by;
		fe = fe*t*A/3.0;
		break;
	case 2:
		
		B << 0.0 << 1.0 << 0.0 << 0.0 << 0.0 << 0.0
			<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 1.0
			<< 0.0 << 0.0 << 1.0 << 0.0 << 1.0 << 0.0;
		
		B = B*C.i();
		
		if (D.Ncols()>3)
		{
			Dm.ReSize(3,3);
			Dm << D(1,1) << D(1,2) << D(1,4)
				<< D(2,1) << D(2,2) << D(2,4)
				<< D(4,1) << D(4,2) << D(4,4);
		}
		else
		{
			Dm.ReSize(D.Ncols(), D.Ncols());
			Dm = D;
		}
		
		Ke.ReSize(6,6);
		
		Ke = B.t()*Dm*B*A*t;
		fe.ReSize(6);
		
		fe << bx << by << bx << by << bx << by;
		fe = fe*t*A/3.0;
		
		break;
	default:
		break;
	}
}
			
void plants(
	RowVector &ex,
	RowVector &ey,
	RowVector &ep,
	Matrix &D,
	RowVector &ed,
	RowVector &es,
	RowVector &et)
{
	int ptype = (int) ep(1);
		
	//int rowed = ed.Nrows();
	//int rowex = ex.Nrows();
				
	Matrix B(3,6);
	Matrix Cm;
	Matrix Dm;
				
	if (ptype==1)
	{
		// --------- plane stress --------------------------------------
			
		int colD = D.Ncols();
		if (colD>3)
		{
			Cm.ReSize(D.Ncols(), D.Ncols());
			Cm = D.i();
			Dm.ReSize(3,3);
			Dm << Cm(1,1) << Cm(1,2) << Cm(1,4)
			<< Cm(2,1) << Cm(2,2) << Cm(2,4)
			<< Cm(4,1) << Cm(4,2) << Cm(4,4);
		}
		else
		{
			Dm.ReSize(D.Ncols(), D.Ncols());
			Dm = D;
		}
					
		Matrix C(6,6);
					
		C << 1.0 << ex(1) << ey(1) << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 1.0 << ex(1) << ey(1)
		<< 1.0 << ex(2) << ey(2) << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 1.0 << ex(2) << ey(2)
		<< 1.0 << ex(3) << ey(3) << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 1.0 << ex(3) << ey(3);
					
		B << 0.0 << 1.0 << 0.0 << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 1.0
		<< 0.0 << 0.0 << 1.0 << 0.0 << 1.0 << 0.0;
					
		B = B*C.i();
					
		ColumnVector ee(3);
		ColumnVector ss;
		ss.ReSize(colD);
		ss = 0.0;
					
		ColumnVector ss_special(3);
					
		ee = B*ed.AsColumn(); // [3x6][6x1] = [3x1]
					
		if (colD>3)
		{
			ss_special = Dm*ee; 
			ss(1) = ss_special(1);
			ss(2) = ss_special(2);
			ss(4) = ss_special(3);
			ee = Cm*ss;
		}
		else
			ss = Dm*ee;			
					
		et.ReSize(ee.Ncols());
		et = ee.AsRow();
		es = ss.AsRow();
	}
	else if (ptype==2)
	{
		// --------- plane strain --------------------------------------
					
		int colD = D.Ncols();
				
		Matrix C(6,6);
					
		C << 1.0 << ex(1) << ey(1) << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 1.0 << ex(1) << ey(1)
		<< 1.0 << ex(2) << ey(2) << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 1.0 << ex(2) << ey(2)
		<< 1.0 << ex(3) << ey(3) << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 1.0 << ex(3) << ey(3);
					
		B << 0.0 << 1.0 << 0.0 << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 1.0
		<< 0.0 << 0.0 << 1.0 << 0.0 << 1.0 << 0.0;
			
		B = B*C.i();
					
		ColumnVector e(6);
		e = 0.0;
		ColumnVector ee(colD);
		ee = 0.0;
					
		e = B*ed.AsColumn(); // [3x6][6x1] = [3x1]
					
		if (colD>3)
		{
			ee(1) = e(1);
			ee(2) = e(2);
			ee(4) = e(3);
		}
		else
			ee = e;
					
		et = ee.AsRow();
		es = (D*ee).AsRow();
	}
}

void bar2s(
   RowVector &ex,
   RowVector &ey,
   RowVector &ep,
   RowVector &ed,
   double &es)
{
   //E=ep(1);  A=ep(2);
 
   //b=[ ex(2)-ex(1); ey(2)-ey(1) ];
   //L=sqrt(b'*b);

   //Kle=E*A/L*[1 -1 ;
   //          -1  1 ];

   //n=b'/L;   G=[   n      zeros(size(n));
   //             zeros(size(n))     n    ];

   //u=ed';
   //N=E*A/L*[-1 1]*G*u;
   //es=N;

	double E = ep(1);
	double A = ep(2);
	ColumnVector b(2);
	b << ex(2)-ex(1) << ey(2)-ey(1);
	double L = sqrt((b.t()*b).AsScalar());
	Matrix Kle(2,2);
	Kle << 1.0 << -1.0 
		<< -1.0 << 1.0;
	Kle = Kle * E * A / L;

	RowVector n(2);
	n = b.t()/L; 

	Matrix G(2,4);

	G << n(1) << n(2) << 0.0  << 0.0
		<< 0.0  << 0.0  << n(1) << n(2);

	ColumnVector u(4);
	u = ed.t();
	RowVector v(2);
	v << -1.0 << 1.0;
	es = E*A*(v*G*u).AsScalar()/L;
}

void bar2e(
   RowVector &ex,
   RowVector &ey,
   RowVector &ep,
   Matrix &Ke)
{
  //E=ep(1);  A=ep(2); 
  //
  //b=[ ex(2)-ex(1); ey(2)-ey(1) ];
  //L=sqrt(b'*b);
  //
  //Kle=E*A/L*[ 1 -1; 
  //           -1  1];
  //
  //n=b'/L;  G=[   n      zeros(size(n));  
  //            zeros(size(n))     n   ];
  //
  //Ke=G'*Kle*G;
	double E = ep(1);
	double A = ep(2);
	ColumnVector b(2);
	b << ex(2)-ex(1) << ey(2)-ey(1);
	double L = sqrt((b.t()*b).AsScalar());
	Matrix Kle(2,2);
	Kle << 1.0 << -1.0 << -1.0 << 1.0;
	Kle = Kle * E * A / L;
	RowVector n(2);
	n = b.t()/L; 

	Matrix G(2,4);

	G << n(1) << n(2) << 0.0  << 0.0
	  << 0.0  << 0.0  << n(1) << n(2);

	Ke = G.t()*Kle*G;
}

    void beam2e(
                //fe not implemented yet
               RowVector &ex,
               RowVector &ey,
               RowVector &ep,
               Matrix &Ke)
    {

        double E = ep(1);
        double A = ep(2);
        double I = ep(3);
                
        ColumnVector n1(2);
        ColumnVector bb(2);
        bb << ex(2)-ex(1) << ey(2)-ey(1);
        double L = sqrt((bb.t()*bb).AsScalar());
        
        double a = E*A/L;   
        double b = 12.0*E*I/pow(L,3);
        double c = 6.0*E*I/pow(L,2);
        double d = 2.0*E*I/L;
      

        Matrix Kle(6,6);
        Kle 
            << a << 0.0 << 0.0 << -a << 0.0 << 0.0
            << 0.0 << b << c << 0.0 << -b << c
            << 0.0 << c << 2*d << 0.0 << -c << d
            << -a << 0.0 << 0.0 << a << 0.0 << 0.0
            << 0.0 << -b << -c << 0.0 << b << -c
            << 0.0 << c << d << 0.0 << -c << 2*d;
        
        RowVector n(2);
        n = bb.t()/L; 
        
        Matrix G(6,6);
        //n1 = nxx = nyy //n2=nyx // nxy=-n2
        
        G << n(1) << n(2) << 0.0  << 0.0 << 0.0  << 0.0
        << -n(2) << n(1) << 0.0  << 0.0 << 0.0  << 0.0
        << 0 << 0 << 1.0  << 0.0 << 0.0  << 0.0
        << 0 << 0 << 0.0  << n(1) << n(2)  << 0.0
        << 0 << 0 << 0.0  << -n(2) << n(1)  << 0.0
        << 0 << 0 << 0.0  << 0.0 << 0.0  << 1.0;
        
        Ke = G.t()*Kle*G;
    }    
    
    
    void beam2s(
                RowVector &ex,
                RowVector &ey,
                Matrix &edi,
                ColumnVector a,
                int res)
    
    {
        
        ColumnVector bb(2);
        bb << ex(2)-ex(1) << ey(2)-ey(1);
        double L = sqrt((bb.t()*bb).AsScalar());
        
        RowVector n(2);
        //n1 = nxx = nyy //n2=nyx // nxy=-n2
        n = bb.t()/L;
        

        Matrix G(6,6);
        G=0.0;
        //n1 = nxx = nyy //n2=nyx // nxy=-n2
        
        G << n(1) << n(2) << 0.0  << 0.0 << 0.0  << 0.0
        << -n(2) << n(1) << 0.0  << 0.0 << 0.0  << 0.0
        << 0 << 0 << 1.0  << 0.0 << 0.0  << 0.0
        << 0 << 0 << 0.0  << n(1) << n(2)  << 0.0
        << 0 << 0 << 0.0  << -n(2) << n(1)  << 0.0
        << 0 << 0 << 0.0  << 0.0 << 0.0  << 1.0;
        
        Matrix Gmini(2,2);
        //n1 = nxx = nyy //n2=nyx // nxy=-n2
        
        Gmini << n(1) << n(2)
        << -n(2) << n(1);
        
        Matrix C(6,6);
        
        C << 1.0 << 0.0 << 0.0  << 0.0 << 0.0  << 0.0
        << 0.0 << 0.0 << 1.0  << 0.0 << 0.0  << 0.0
        << 0.0 << 0.0 << 0.0  << 1.0 << 0.0  << 0.0
        << 1.0 << L << 0.0  << 0.0 << 0.0  << 0.0
        << 0.0 << 0.0 << 1.0  << L << pow(L,2)  << pow(L,3)
        << 0.0 << 0.0 << 0.0  << 1.0 << 2*L  << 3*pow(L,2);
        
        ColumnVector u(6);
        u=G*a;
        
        ColumnVector m(6);
        m=C.i()*u;
        
        ColumnVector eci;
        eci.resize(res);
        eci = 0.0;
        
        edi.resize(res, 2);
        edi = 0.0;

        for (int i=1; i<=res;i++) {
            
            eci(i) = (i-1.0)*L/(res-1.0);
            
            Matrix Nshape(2,6);
            
            Nshape << 1.0 << eci(i) << 0.0  << 0.0 << 0.0  << 0.0
            << 0.0 << 0.0 << 1.0  << eci(i) << pow(eci(i),2)  << pow(eci(i),3);
            
            edi.row(i)=(Gmini.t()*Nshape*m).AsRow();
            
        }

        
    }
    
    
    
    void beam2s(
                RowVector &ex, 
                RowVector &ey, 
                RowVector &ep,
                Matrix &edi,
                ColumnVector &eci,                
                ColumnVector &a,
                ColumnVector &f,                
                int res,
                Matrix &es,
                ColumnVector &mForce,
                double &nForce)

    {

        ColumnVector bb(2);
        bb << ex(2)-ex(1) << ey(2)-ey(1);
        double L = sqrt((bb.t()*bb).AsScalar());
        
        RowVector n(2);
        //n1 = nxx = nyy //n2=nyx // nxy=-n2        
        n = bb.t()/L; 
        
        double E = ep(1);
        double A = ep(2);
        double I = ep(3);
        
        Matrix G(6,6);
        G=0.0;
        //n1 = nxx = nyy //n2=nyx // nxy=-n2
        
        G << n(1) << n(2) << 0.0  << 0.0 << 0.0  << 0.0
        << -n(2) << n(1) << 0.0  << 0.0 << 0.0  << 0.0
        << 0 << 0 << 1.0  << 0.0 << 0.0  << 0.0
        << 0 << 0 << 0.0  << n(1) << n(2)  << 0.0
        << 0 << 0 << 0.0  << -n(2) << n(1)  << 0.0
        << 0 << 0 << 0.0  << 0.0 << 0.0  << 1.0;
        
        Matrix Gmini(2,2);
        //n1 = nxx = nyy //n2=nyx // nxy=-n2
        
        Gmini << n(1) << n(2)
        << -n(2) << n(1); 
        
        Matrix C(6,6);
        
        C << 1.0 << 0.0 << 0.0  << 0.0 << 0.0  << 0.0
        << 0.0 << 0.0 << 1.0  << 0.0 << 0.0  << 0.0
        << 0.0 << 0.0 << 0.0  << 1.0 << 0.0  << 0.0
        << 1.0 << L << 0.0  << 0.0 << 0.0  << 0.0
        << 0.0 << 0.0 << 1.0  << L << pow(L,2)  << pow(L,3)
        << 0.0 << 0.0 << 0.0  << 1.0 << 2*L  << 3*pow(L,2);
        
        ColumnVector u(6);
        u=G*a;
        
        ColumnVector m(6);
        m=C.i()*u;
        
        eci.resize(res);
        eci = 0.0;
        
        edi.resize(res, 2);
        edi = 0.0;
        
        mForce.resize(res);
        mForce = 0.0;
        
        ColumnVector fLocal(6);
        fLocal=0.0;
        
        for (int i=1; i<=res;i++) {
            
            eci(i) = (i-1.0)*L/(res-1.0);
            
            Matrix Nshape(2,6);
            
            Nshape << 1.0 << eci(i) << 0.0  << 0.0 << 0.0  << 0.0
            << 0.0 << 0.0 << 1.0  << eci(i) << pow(eci(i),2)  << pow(eci(i),3);

            edi.row(i)=(Gmini.t()*Nshape*m).AsRow();
            
            fLocal=G*f;

        }

        
        
        //Get the local Ka=f system figured out
        
        double a2 = E*A/L;
        double b = 12.0*E*I/pow(L,3);
        double c = 6.0*E*I/pow(L,2);
        double d = 2.0*E*I/L;
        
        
        Matrix Kle(6,6);
        Kle
        << a2 << 0.0 << 0.0 << -a2 << 0.0 << 0.0
        << 0.0 << b << c << 0.0 << -b << c
        << 0.0 << c << 2*d << 0.0 << -c << d
        << -a2 << 0.0 << 0.0 << a2 << 0.0 << 0.0
        << 0.0 << -b << -c << 0.0 << b << -c
        << 0.0 << c << d << 0.0 << -c << 2*d;
        
        ColumnVector fInnerForces(6);
        
        fInnerForces = Kle*u;
        
        mForce(1)=fInnerForces(3);
        mForce(2)=-fInnerForces(6);
        nForce=-fInnerForces(1);
        
}  

    
void beam3e(
			RowVector &ex, 
			RowVector &ey, 
			RowVector &ez,
			RowVector &eo,
			RowVector &ep,
			RowVector &eq,
			Matrix &Ke,
			ColumnVector &fe)
{
	ColumnVector bb(3);
	bb << ex(2)-ex(1) << ey(2)-ey(1) << ez(2)-ez(1);
	double L = sqrt( (bb.t() * bb).AsScalar() );
	
	RowVector n1 = (bb/L).t();
	
	double lc = sqrt((eo*eo.t()).AsScalar());
	RowVector n3 = eo/lc;
	
	double qx = eq(1);
	double qy = eq(2);
	double qz = eq(3);
	double qw = eq(4);
	
	double E = ep(1);   double Gs = ep(2);
	double A = ep(3);
	double Iy = ep(4);	double Iz = ep(5);
	double Kv = ep(6);
	
	double a = E*A/L;   
	double b = 12.0*E*Iz/pow(L,3);
	double c = 6.0*E*Iz/pow(L,2);
	double d = 12.0*E*Iy/pow(L,3);
	double e = 6.0*E*Iy/pow(L,2);
	double f = Gs*Kv/L;
	double g = 2.0*E*Iy/L;
	double h = 2*E*Iz/L;
	
	Matrix Kle(12,12);
	
	Kle << a << 0 << 0 << 0 << 0 << 0 << -a << 0 << 0 << 0 << 0 << 0
		<< 0 << b << 0 << 0 << 0 << c << 0 << -b << 0 << 0 << 0 << c 
        << 0 << 0 << d << 0 <<-e << 0 << 0 << 0 << -d << 0 << -e << 0 
        << 0 << 0 << 0 << f << 0 << 0 << 0 << 0 << 0 << -f << 0 << 0 
        << 0 << 0 << -e << 0 << 2*g << 0 << 0 << 0 << e << 0 << g << 0 
        << 0 << c << 0 << 0 << 0 << 2*h << 0 << -c << 0 << 0 << 0 << h 
        << -a << 0 << 0 << 0 << 0 << 0 << a << 0 << 0 << 0 << 0 << 0 
        << 0 << -b << 0 << 0 << 0 << -c << 0 << b << 0 << 0 << 0 << -c 
        << 0 << 0 << -d << 0 << e << 0 << 0 << 0 << d << 0 << e << 0 
        << 0 << 0 << 0 << -f << 0 << 0 << 0 << 0 << 0 << f << 0 << 0 
        << 0 << 0 << -e << 0 << g << 0 << 0 << 0 << e << 0 << 2*g << 0 
        << 0 << c << 0 << 0 << 0 << h << 0 << -c << 0 << 0 << 0 << 2*h;
	
	ColumnVector fle(12);
	
	fle << qx 
		<< qy 
		<< qz 
		<< qw 
		<< -qz*L/6.0
		<< qy*L/6.0 
		<< qx 
		<< qy 
		<< qz 
		<< qw 
		<< qz*L/6.0 
		<< -qy*L/6.0;
	fle = fle*L/2.0;
	
	RowVector n2(3);
	
	n2 <<  n3(2)*n1(3)-n3(3)*n1(2)
		<< -n1(3)*n3(1)+n1(1)*n3(3)
		<< n3(1)*n1(2)-n1(1)*n3(2);
	
	Matrix An(3,3);
	
	An.Row(1) = n1;
	An.Row(2) = n2;
	An.Row(3) = n3;
	
	Matrix G(12,12);
	
	G = 0.0;
	
	G.SubMatrix(1,3,1,3) = An;
	G.SubMatrix(4,6,4,6) = An;
	G.SubMatrix(7,9,7,9) = An;
	G.SubMatrix(10,12,10,12) = An;
	
	Ke = G.t() * Kle * G;
	fe = G.t() * fle;
}

void beam3s(
			RowVector &ex, 
			RowVector &ey, 
			RowVector &ez,
			RowVector &eo,
			RowVector &ep,
			RowVector &ed,
			RowVector &eq,
			int n,
			Matrix &es,
			Matrix &edi,
			ColumnVector &eci)
{
	ColumnVector bb(3);
	bb << ex(2)-ex(1) << ey(2)-ey(1) << ez(2)-ez(1);
	double L = sqrt( (bb.t() * bb).AsScalar() );
	
	RowVector n1 = (bb/L).t();
	
	double lc = sqrt((eo*eo.t()).AsScalar());
	RowVector n3 = eo/lc;
	
	double qx = eq(1);
	double qy = eq(2);
	double qz = eq(3);
	double qw = eq(4);
	
	double E = ep(1);   double Gs = ep(2);
	double A = ep(3);
	double Iy = ep(4);	double Iz = ep(5);
	double Kv = ep(6);
	
	RowVector n2(3);
	
	n2 <<  n3(2)*n1(3)-n3(3)*n1(2)
		<< -n1(3)*n3(1)+n1(1)*n3(3)
		<< n3(1)*n1(2)-n1(1)*n3(2);
	
	Matrix An(3,3);
	
	An.Row(1) = n1;
	An.Row(2) = n2;
	An.Row(3) = n3;
	
	Matrix G(12,12);
	
	G = 0.0;
	
	G.SubMatrix(1,3,1,3) = An;
	G.SubMatrix(4,6,4,6) = An;
	G.SubMatrix(7,9,7,9) = An;
	G.SubMatrix(10,12,10,12) = An;
	
	ColumnVector u(12);
	ColumnVector diffSol(12);
	
	diffSol << 0.0
		<< 0.0
		<< 0.0
		<< 0.0
		<< 0.0
		<< 0.0
        << -qx*pow(L,2)/2.0/E/A
        <<  qy*pow(L,4)/24.0/E/Iz
        <<  qz*pow(L,4)/24.0/E/Iy
        << -qw*pow(L,2)/2.0/Gs/Kv
        << -qz*pow(L,3)/6.0/E/Iy
        <<  qy*pow(L,3)/6.0/E/Iz;
	
	u = G*ed.AsColumn() - diffSol;

	Matrix C(12,12);
	
	C << 0.0   << 1.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 1.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 1.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 1.0
		<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << -1.0 << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 0.0 << 1.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0
		<< L   << 1.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << pow(L,3) << pow(L,2) << L << 1.0 << 0.0  << 0.0 << 0.0 << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << pow(L,3) << pow(L,2) << L << 1.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0   << 0.0 << 0.0 << L << 1.0
		<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << -3.0*pow(L,2) << -2.0*L << -1.0 << 0.0 << 0.0 << 0.0
		<< 0.0 << 0.0 << 3.0*pow(L,2) << 2.0*L << 1 << 0.0 << 0.0  << 0.0  << 0.0 << 0.0 << 0 << 0.0;
	
	ColumnVector m(12);
	
	m = C.i()*u;
	
	es.ReSize(n,6);
	es = 0.0;
	edi.ReSize(n,4);
	edi = 0.0;
	eci.ReSize(n);
	eci = 0.0;
	
	int i;
	for (i=1; i<=n; i++)
	{
		eci(i) = (i-1.0)*L/(n-1.0);
		double x = eci(i);
		
		Matrix T1(6,12);
		
		T1 << E*A << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0
			<< 0.0 << 0.0 << -6.0*E*Iz << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0
			<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << -6.0*E*Iy << 0.0 << 0.0 << 0.0 << 0.0 << 0.0
			<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << Gs*Kv << 0.0
			<< 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << -6.0*E*Iy*x << -2.0*E*Iy << 0.0 << 0.0 << 0.0 << 0.0
			<< 0.0 << 0.0 << 6.0*E*Iz*x << 2.0*E*Iz << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0;		
		
		ColumnVector T2(6);

		T2 << -qx*x
			<< -qy*x
			<< -qz*x
			<< -qw*x
			<< -qz*pow(x,2)/2.0
			<< qy*pow(x,2)/2.0;
		
		es.Row(i) = (T1*m+T2).t();
		
		Matrix T3(4,12);
		
		T3 << x << 1.0  << 0.0   << 0.0  << 0.0 << 0.0  << 0.0   << 0.0  << 0.0 << 0.0 << 0.0 << 0.0
			<< 0.0 << 0.0 << pow(x,3) << pow(x,2) << x << 1.0  << 0.0   << 0.0  << 0.0 << 0.0 << 0.0 << 0.0
			<< 0.0 << 0.0  << 0.0   << 0.0  << 0.0 << 0.0 << pow(x,3) << pow(x,2) << x << 1.0 << 0.0 << 0.0
			<< 0.0 << 0.0  << 0.0   << 0.0  << 0.0 << 0.0  << 0.0   << 0.0  << 0.0 << 0.0 << x << 1.0;
		
		ColumnVector T4(4);
		
		T4 << -qx*pow(x,2)/2.0/E/A
			<< qy*pow(x,4)/24.0/E/Iz
			<< qz*pow(x,4)/24.0/E/Iy
			<< -qw*pow(x,2)/2.0/Gs/Kv;
		
		edi.Row(i) = (T3*m + T4).t();
	}
}

void flw2te(
			RowVector &ex, 
			RowVector &ey,
			double ep,
			Matrix &D,
			double eq,
			Matrix &Ke,
			ColumnVector &fe)
{
	double t = ep;

	Matrix C(3,3);
	
	C << 1.0 << ex(1) << ey(1) 
		<< 1.0 << ex(2) << ey(2) 
		<< 1.0 << ex(3) << ey(3);

	Matrix B(2,3);

	B 
		<< 0.0 << 1.0 << 0.0
		<< 0.0 << 0.0 << 1.0;

	B = B*C.i();

	double A = 0.5*C.LogDeterminant().Value();

	Ke.ReSize(3,3);
	Ke = B.t()*D*B*A*t;
	
	fe.ReSize(3);
	
	double f = eq*A*t/3.0;

	fe << f << f << f;
}

void flw2ts(
			RowVector &ex, 
			RowVector &ey,
			Matrix &D,
			RowVector &ed,
			RowVector &es,
			RowVector &et
)
{
	Matrix C(3,3);
	
	C << 1.0 << ex(1) << ey(1) 
		<< 1.0 << ex(2) << ey(2) 
		<< 1.0 << ex(3) << ey(3);

	Matrix B(2,3);

	B 
		<< 0.0 << 1.0 << 0.0
		<< 0.0 << 0.0 << 1.0;

	B = B*C.i();

	ColumnVector qt = B*ed.AsColumn();
	ColumnVector qs = -D*qt;

	es = qs.t();
	et = qt.t();
}

void assem(
		   RowVector &Topo, 
		   SymmetricBandMatrix &K, 
		   Matrix &Ke, 
		   ColumnVector &f, 
		   ColumnVector &fe)
{
	int i, j;
	
	for (i=1; i<=Ke.Nrows(); i++)
		for (j=i; j<=Ke.Ncols(); j++)
			if ((Topo(i)>0)&&(Topo(j)>0))
				K((int)Topo(i),(int)Topo(j)) = K((int)Topo(i),(int)Topo(j)) + Ke(i,j);
		
	for (i=1; i<=fe.Nrows(); i++)
		if (Topo(i)>0)
			f((int)Topo(i)) = f((int)Topo(i)) + fe(i);
}

    
    
void assemEquilibrium(
             ColumnVector lockedDOF,
             int nrDOF,
             int nrElements,
             Matrix topo,
             Matrix &H)
{
    H.ReSize(nrDOF-lockedDOF.size(), nrElements);
    
}
    
    
void assemSystem(
		   RowVector &Topo, 
		   SimpleIntArray& dofMapping,
		   SymmetricBandMatrix &K, 
		   Matrix &Ke, 
		   ColumnVector &f, 
		   ColumnVector &fe)
{
	int i, j;
	
	for (i=1; i<=Ke.Nrows(); i++)
		for (j=i; j<=Ke.Ncols(); j++)
			if ((Topo(i)>0)&&(Topo(j)>0))
				K((int)Topo(i),(int)Topo(j)) = K((int)Topo(i),(int)Topo(j)) + Ke(i,j);
		
	for (i=1; i<=fe.Nrows(); i++)
		if (Topo(i)>0)
			f((int)Topo(i)) = f((int)Topo(i)) + fe(i);
}

void assem(
		   RowVector &Topo, 
		   SymmetricBandMatrix &K, 
		   Matrix &Ke)
{
	int i, j;
	
	for (i=1; i<=Ke.Nrows(); i++)
		for (j=i; j<=Ke.Ncols(); j++)
			if ((Topo(i)>0)&&(Topo(j)>0))
            {
                K((int)Topo(i),(int)Topo(j)) = K((int)Topo(i),(int)Topo(j)) + Ke(i,j);
            }

}


double maxValue(RowVector& rowVector)
{
	int i;
	double maxValue = -1e300;
	
	for (i=1; i<=rowVector.Ncols(); i++)
		if (rowVector(i)>maxValue)
			maxValue = rowVector(i);
		
		return maxValue;
}

double minValue(RowVector& rowVector)
{
	int i;
	double minValue = 1e300;
	
	for (i=1; i<=rowVector.Ncols(); i++)
		if (rowVector(i)<minValue)
			minValue = rowVector(i);
		
		return minValue;
}

void plani4e(
			RowVector &ex, 
			RowVector &ey,
			RowVector &ep,
			Matrix &D,
			RowVector &eq,
			Matrix &Ke,
			ColumnVector &fe)
{
	int ptype = (int)ep(1); 
	double t = ep(2);  
	int ir = (int)ep(3);  
	int ngp = ir*ir;

	RowVector b = eq;

	double g1, g2;
	double w1, w2;

	Matrix gp;
	Matrix w;

	if (ir==1)
	{
		g1 = 0.0; w1=2.0;
		gp.resize(1,2);
		w.resize(1,2);
		gp << g1 << g1;
		w << w1 << w1;
	}
	else if (ir==2)
	{
		g1=0.577350269189626;
		w1=1.0;

		gp.resize(4,2);
		w.resize(4,2);

		gp 
			<< -g1 << -g1
			<< g1 << -g1
			<< -g1 << g1
			<< g1 << g1;

		w 
			<< w1 << w1
			<< w1 << w1
			<< w1 << w1
			<< w1 << w1;

		PrintMatrix(gp);
		PrintMatrix(w);
	}
	else if (ir==3)
	{
		g1=0.774596669241483; g2=0.;
		w1=0.555555555555555; w2=0.888888888888888;		

		gp.resize(9,2);
		w.resize(9,2);

		gp 
			<< -g1 << -g1
			<< -g2 << -g1
			<< g1 << -g1
			<< -g1 << g2
			<< g2 << g2
			<< g1 << g2
			<< -g1 << g1
			<< g2 << g1
			<< g1 << g1;

		w 
			<< w1 << w1
			<< w2 << w1
			<< w1 << w1
			<< w1 << w2
			<< w2 << w2
			<< w1 << w2
			<< w1 << w1
			<< w2 << w1
			<< w1 << w1;

	}

	ColumnVector wp(gp.nrows());
	wp = SP(w.column(1), w.column(2));
	ColumnVector xsi = gp.column(1);
	ColumnVector eta = gp.column(2);
	int r2 = ngp*2;

	Matrix N(gp.nrows(),4);
	N.column(1) = SP(1-xsi,1-eta)/4.0;
	N.column(2) = SP(1+xsi,1-eta)/4.0;
	N.column(3) = SP(1+xsi,1+eta)/4.0;
	N.column(4) = SP(1-xsi,1+eta)/4.0;

	PrintMatrix(N);

	Matrix dNr(r2,4);
	dNr = 0.0;

	ColumnVector m1 = -(1-eta)/4;
	ColumnVector m2 =  (1-eta)/4;
	ColumnVector m3 =  (1+eta)/4;
	ColumnVector m4 = -(1+eta)/4;

	ColumnVector n1 = -(1-xsi)/4;
	ColumnVector n2 = -(1+xsi)/4;
	ColumnVector n3 =  (1+xsi)/4;
	ColumnVector n4 =  (1-xsi)/4;

	unsigned int i, j;

	j = 1;
	for (i=1; i<(unsigned int)r2; i+=2)
	{
		dNr(i,1) = m1(j);
		dNr(i,2) = m2(j);
		dNr(i,3) = m3(j);
		dNr(i,4) = m4(j);
		j++;
	}

	j = 1;
	for (i=2; i<(unsigned int)r2+1; i+=2)
	{
		dNr(i,1) = n1(j);
		dNr(i,2) = n2(j);
		dNr(i,3) = n3(j);
		dNr(i,4) = n4(j);
		j++;
	}

	PrintMatrix(dNr);

	//  JT=dNr*[ex;ey]';  [3x4]x[[2x4]'] = [3x4]x[4x2] = [3x2]
	//           
	Matrix JT = dNr*(ex.t()|ey.t()); // [3x4]x[[4x2] = [3x2] Ok

	PrintMatrix(JT);

	Matrix Dm;

	if (ptype==1) 
	{
		if (D.ncols()>3)
		{
			Matrix Cm = D.i();
			Dm.resize(3,3);

			Dm << Cm(1,1) << Cm(1,2) << 0.0 << Cm(1,4);
			Dm << Cm(2,1) << Cm(2,2) << 0.0 << Cm(2,4);
			Dm << 0.0     << 0.0     << 0.0 << 0.0;
			Dm << Cm(4,1) << Cm(4,2) << 0.0 << Cm(1,4);

			Dm = Dm.i();		}
		else
		{
			Dm = D;
		}

		PrintMatrix(Dm);

		Ke = 0.0;
		fe = 0.0;

		for (i=1; i<=(unsigned int)ngp; i++)
		{
			Matrix J = (JT.row(2*i-1) & JT.row(2*i));
			PrintMatrix(J);
			double detJ = J.determinant();

			Matrix Jinv = J.i();
			PrintMatrix(Jinv);

			Matrix dNrdNr = dNr.row(2*i-1) & dNr.row(2*i);
			PrintMatrix(dNrdNr);
			
			//  [2x2] x [2x4] = [2x4]
			Matrix dNx = Jinv*(dNr.row(2*i-1) & dNr.row(2*i));

			PrintMatrix(dNx);

			Matrix B(3,8);

			B << dNx(1,1) << 0.0      << dNx(1,2) << 0.0      << dNx(1,3) << 0.0      << dNx(1,4) << 0.0
			  << 0.0      << dNx(2,1) << 0.0      << dNx(2,2) << 0.0      << dNx(2,3) << 0.0      << dNx(2,4)
			  << dNx(2,1) << dNx(1,1) << dNx(2,2) << dNx(1,2) << dNx(2,3) << dNx(1,3) << dNx(2,4) << dNx(1,4);

			PrintMatrix(B);

			Matrix N2(2,8);

			N2 << N(i,1) << 0.0    << N(i,2) << 0.0    << N(i,3) << 0.0    << N(i,4) << 0.0
			   << 0.0    << N(i,1) << 0.0    << N(i,2) << 0.0    << N(i,3) << 0.0    << N(i,4);

			Ke = Ke + B.t()*Dm*B*detJ*wp(i)*t;
			fe = fe + N2.t()*b.t()*detJ*wp(i)*t;
		}
	}
	else
	{

	}
}

void plani4s(
			RowVector &ex, 
			RowVector &ey,
			RowVector &ep,
			Matrix &D,
			RowVector &ed,
			Matrix &es,
			Matrix &et)
{
	int ptype = (int)ep(1); 
	//double t = ep(2);
	int ir = (int)ep(3);  
	int ngp = ir*ir;

	double g1, g2;
	double w1, w2;

	Matrix gp;
	Matrix w;

	if (ir==1)
	{
		g1 = 0.0; w1=2.0;
		gp.resize(1,2);
		w.resize(1,2);
		gp << g1 << g1;
		w << w1 << w1;
	}
	else if (ir==2)
	{
		g1=0.577350269189626;
		w1=1.0;

		gp.resize(4,2);
		w.resize(4,2);

		gp 
			<< -g1 << -g1
			<< g1 << -g1
			<< -g1 << g1
			<< g1 << g1;

		w 
			<< w1 << w1
			<< w1 << w1
			<< w1 << w1
			<< w1 << w1;

		PrintMatrix(gp);
		PrintMatrix(w);
	}
	else if (ir==3)
	{
		g1=0.774596669241483; g2=0.;
		w1=0.555555555555555; w2=0.888888888888888;		

		gp.resize(9,2);
		w.resize(9,2);

		gp 
			<< -g1 << -g1
			<< -g2 << -g1
			<< g1 << -g1
			<< -g1 << g2
			<< g2 << g2
			<< g1 << g2
			<< -g1 << g1
			<< g2 << g1
			<< g1 << g1;

		w 
			<< w1 << w1
			<< w2 << w1
			<< w1 << w1
			<< w1 << w2
			<< w2 << w2
			<< w1 << w2
			<< w1 << w1
			<< w2 << w1
			<< w1 << w1;

	}

	ColumnVector wp(gp.nrows());
	wp = SP(w.column(1), w.column(2));
	ColumnVector xsi = gp.column(1);
	ColumnVector eta = gp.column(2);
	int r2 = ngp*2;

	Matrix N(gp.nrows(),4);
	N.column(1) = SP(1-xsi,1-eta)/4.0;
	N.column(2) = SP(1+xsi,1-eta)/4.0;
	N.column(3) = SP(1+xsi,1+eta)/4.0;
	N.column(4) = SP(1-xsi,1+eta)/4.0;

	PrintMatrix(N);

	Matrix dNr(r2,4);
	dNr = 0.0;

	ColumnVector m1 = -(1-eta)/4;
	ColumnVector m2 =  (1-eta)/4;
	ColumnVector m3 =  (1+eta)/4;
	ColumnVector m4 = -(1+eta)/4;

	ColumnVector n1 = -(1-xsi)/4;
	ColumnVector n2 = -(1+xsi)/4;
	ColumnVector n3 =  (1+xsi)/4;
	ColumnVector n4 =  (1-xsi)/4;

	unsigned int i, j;

	j = 1;
	for (i=1; i<(unsigned int)r2; i+=2)
	{
		dNr(i,1) = m1(j);
		dNr(i,2) = m2(j);
		dNr(i,3) = m3(j);
		dNr(i,4) = m4(j);
		j++;
	}

	j = 1;
	for (i=2; i<(unsigned int)r2+1; i+=2)
	{
		dNr(i,1) = n1(j);
		dNr(i,2) = n2(j);
		dNr(i,3) = n3(j);
		dNr(i,4) = n4(j);
		j++;
	}	

	PrintMatrix(dNr);

	//  JT=dNr*[ex;ey]';  [3x4]x[[2x4]'] = [3x4]x[4x2] = [3x2]
	//           
	Matrix JT = dNr*(ex.t()|ey.t()); // [3x4]x[[4x2] = [3x2] Ok

	PrintMatrix(JT);

	Matrix Dm;

	if (ptype==1) 
	{
		if (D.ncols()>3)
		{
			Matrix Cm = D.i();
			Dm.resize(3,3);

			Dm << Cm(1,1) << Cm(1,2) << 0.0 << Cm(1,4);
			Dm << Cm(2,1) << Cm(2,2) << 0.0 << Cm(2,4);
			Dm << 0.0     << 0.0     << 0.0 << 0.0;
			Dm << Cm(4,1) << Cm(4,2) << 0.0 << Cm(1,4);

			Dm = Dm.i();		}
		else
		{
			Dm = D;
		}

		PrintMatrix(Dm);

		es.resize(ngp, Dm.nrows());
		et.resize(ngp, Dm.nrows());

		for (i=1; i<=(unsigned int)ngp; i++)
		{
			Matrix J = (JT.row(2*i-1) & JT.row(2*i));
			PrintMatrix(J);
			//double detJ = J.determinant();

			Matrix Jinv = J.i();
			PrintMatrix(Jinv);

			Matrix dNrdNr = dNr.row(2*i-1) & dNr.row(2*i);
			PrintMatrix(dNrdNr);
			
			//  [2x2] x [2x4] = [2x4]
			Matrix dNx = Jinv*(dNr.row(2*i-1) & dNr.row(2*i));

			PrintMatrix(dNx);

			Matrix B(3,8);

			B << dNx(1,1) << 0.0      << dNx(1,2) << 0.0      << dNx(1,3) << 0.0      << dNx(1,4) << 0.0
			  << 0.0      << dNx(2,1) << 0.0      << dNx(2,2) << 0.0      << dNx(2,3) << 0.0      << dNx(2,4)
			  << dNx(2,1) << dNx(1,1) << dNx(2,2) << dNx(1,2) << dNx(2,3) << dNx(1,3) << dNx(2,4) << dNx(1,4);

			// B[3,8] x Ed[8,1] = [3,1]

			et.row(i) = (B * ed.t()).t();
			es.row(i) = (Dm * et.row(i).t()).t();
		}
	}
	else
	{

	}
}

ReturnMatrix matrixMax3(Matrix A, double b)
{
	Matrix C;
	int i, j;
	int rows = A.nrows();
	int cols = A.ncols();

	C.ReSize(A.nrows(), A.ncols());

	for (i=1; i<=rows; i++)
		for (j=1; j<=cols; j++)
			if (A(i,j)>b)
				C(i,j) = A(i,j);
			else
				C(i,j) = b;
	
	C.release(); return C;
}

ReturnMatrix matrixMax2(double a, Matrix B)
{
	Matrix C;
	int i, j;
	int rows = B.nrows();
	int cols = B.ncols();

	C.ReSize(B.nrows(), B.ncols());

	for (i=1; i<=rows; i++)
		for (j=1; j<=cols; j++)
			if (a>B(i,j))
				C(i,j) = a;
			else
				C(i,j) = B(i,j);
	
	C.release(); return C;
}

ReturnMatrix matrixMax1(Matrix A, Matrix B)
{
	Matrix C;
	int i, j;
	int rows = A.nrows();
	int cols = A.ncols();

	if ((A.nrows()==B.nrows())&&(A.ncols()==B.ncols()))
	{
		C.ReSize(A.nrows(), A.ncols());

		for (i=1; i<=rows; i++)
			for (j=1; j<=cols; j++)
				if (A(i,j)>B(i,j))
					C(i,j) = A(i,j);
				else
					C(i,j) = B(i,j);
	}
	
	C.release(); return C;
}

ReturnMatrix matrixMin3(Matrix A, double b)
{
	Matrix C;
	int i, j;
	int rows = A.nrows();
	int cols = A.ncols();

	C.ReSize(A.nrows(), A.ncols());

	for (i=1; i<=rows; i++)
		for (j=1; j<=cols; j++)
			if (A(i,j)<b)
				C(i,j) = A(i,j);
			else
				C(i,j) = b;
	
	C.release(); return C;
}

ReturnMatrix matrixMin2(double a, Matrix B)
{
	Matrix C;
	int i, j;
	int rows = B.nrows();
	int cols = B.ncols();

	C.ReSize(B.nrows(), B.ncols());

	for (i=1; i<=rows; i++)
		for (j=1; j<=cols; j++)
			if (a<B(i,j))
				C(i,j) = a;
			else
				C(i,j) = B(i,j);
	
	C.release(); return C;
}

ReturnMatrix matrixMin1(Matrix A, Matrix B)
{
	Matrix C;
	int i, j;
	int rows = A.nrows();
	int cols = A.ncols();

	if ((A.nrows()==B.nrows())&&(A.ncols()==B.ncols()))
	{
		C.ReSize(A.nrows(), A.ncols());

		for (i=1; i<=rows; i++)
			for (j=1; j<=cols; j++)
				if (A(i,j)<B(i,j))
					C(i,j) = A(i,j);
				else
					C(i,j) = B(i,j);
	}
	
	C.release(); return C;
}

ReturnMatrix matrixSqrt(Matrix A)
{
	Matrix C;
	int i, j;
	int rows = A.nrows();
	int cols = A.ncols();

	C.ReSize(A.nrows(), A.ncols());

	for (i=1; i<=rows; i++)
		for (j=1; j<=cols; j++)
			C(i,j) = sqrt(A(i,j));
	
	C.release(); return C;
}

ReturnMatrix elementMultiply(Matrix A, Matrix B)
{
	Matrix C;
	int i, j;
	int rows = A.nrows();
	int cols = A.ncols();

	C.ReSize(A.nrows(), A.ncols());

	for (i=1; i<=rows; i++)
		for (j=1; j<=cols; j++)
			C(i,j) = A(i,j) * B(i,j);
	
	C.release(); return C;
}

void assignWhereLessThan(Matrix& toMatrix, Matrix& condMatrix, Matrix& valueMatrix, double lessThanValue)
{
	Matrix C;
	int i, j;
	int rows = toMatrix.nrows();
	int cols = toMatrix.ncols();

	for (i=1; i<=rows; i++)
		for (j=1; j<=cols; j++)
		{
			if (condMatrix(i,j)<lessThanValue)
				toMatrix(i,j) = valueMatrix(i,j);
		}
	
}

void assignWhereGreaterThan(Matrix& toMatrix, Matrix& condMatrix, Matrix& valueMatrix, double greaterThanValue)
{
	Matrix C;
	int i, j;
	int rows = toMatrix.nrows();
	int cols = toMatrix.ncols();

	for (i=1; i<=rows; i++)
		for (j=1; j<=cols; j++)
		{
			if (condMatrix(i,j)>greaterThanValue)
				toMatrix(i,j) = valueMatrix(i,j);
		}
	
}

void assignWhereGreaterThan(Matrix& toMatrix, Matrix& condMatrix, double value, double greaterThanValue)
{
	Matrix C;
	int i, j;
	int rows = toMatrix.nrows();
	int cols = toMatrix.ncols();

	for (i=1; i<=rows; i++)
		for (j=1; j<=cols; j++)
		{
			if (condMatrix(i,j)>greaterThanValue)
				toMatrix(i,j) = value;
		}
	
}

void writeRowVector(const std::string& name, RowVector &v, std::ostream &out, bool matlab)
{
	if (matlab)
		out << name << " = [" << std::endl;
	else
		out << name << " = matrix([[" << std::endl;

	int i;

	for (i=1; i<=v.Ncols(); i++)
			if (i<v.Nrows())
				out << "\t " << v(i) << " ," << std::endl;
			else
				out << "\t " << v(i) << std::endl;

	if (matlab)
		out << "]';" << endl;
	else
		out << "]])" << endl;
}

void writeColVector(const std::string& name, ColumnVector &v, std::ostream &out, bool matlab)
{
	if (matlab)
		out << name << " = [" << std::endl;
	else
		out << name << " = matrix([" << std::endl;

	int i;

	for (i=1; i<=v.Nrows(); i++)
		if (matlab)
			out << v(i) << std::endl;
		else
			if (i<v.Nrows())
				out << "\t[ " << v(i) << " ]," << std::endl;
			else
				out << "\t[ " << v(i) << "]" << std::endl;

	if (matlab)
		out << "];" << endl;
	else
		out << "])" << endl;
}

void writeMatrix(const std::string& name, Matrix &m, std::ostream &out, bool matlab)
{
	if (matlab)
		out << name << " = [" << std::endl;
	else
		out << name << " = matrix([" << std::endl;

	int i, j;

	for (i=1; i<=m.Nrows(); i++)
	{
		for (j=1; j<=m.Ncols(); j++)
		{
			//std::cout << "row = " << i << " col = " << j << std::endl;
			if (matlab)
				out << m(i,j) << " ";
			else
			{
				if (j==1)
					out << "\t[ ";
				
				if (j<m.Ncols())
					out << m(i,j) << ", ";
				else
					out << m(i,j) << " ],";
			}
		}
		if (matlab)
			out << ";" << std::endl;
		else
			out << std::endl;
	}
	if (matlab)
		out << "];" << endl;
	else
		out << "])" << endl;
}

void writeMatrix(const std::string& name, SymmetricBandMatrix &m, std::ostream &out, bool matlab)
{
	if (matlab)
		out << name << " = [" << std::endl;
	else
		out << name << " = matrix([" << std::endl;

	int i, j;

	for (i=1; i<=m.Nrows(); i++)
	{
		for (j=1; j<=m.Ncols(); j++)
		{
			//std::cout << "row = " << i << " col = " << j << std::endl;
			if (matlab)
				out << m(i,j) << " ";
			else
			{
				if (j==1)
					out << "\t[ ";
				
				if (j<m.Ncols())
					out << m(i,j) << ", ";
				else
					out << m(i,j) << " ],";
			}
		}
		if (matlab)
			out << ";" << std::endl;
		else
			out << std::endl;
	}
	if (matlab)
		out << "];" << endl;
	else
		out << "])" << endl;
}

} // namespace calfem

