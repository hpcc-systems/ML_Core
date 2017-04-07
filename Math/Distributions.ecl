//Normal, Student and Chi Squared distributions for tests
IMPORT $.^.Constants AS Core_Const;
IMPORT $ AS Math;

EXPORT Distributions := MODULE
  /**
   * Cumulative Distribution of the standard normal distribution, the
   *probability that a normal random variable will be smaller than x
   * standard deviations above or below the mean.
   * Taken from C/C++ Mathematical Algorithms for Scientists and
   *Engineers, n. Shammas, McGraw-Hill, 1995
   * @param x the number of standard deviations
   * @returns probability of exceeding x.
   */
  EXPORT REAL8 Normal_CDF(REAL8 x) := DEFINE FUNCTION
    b1 := 0.319381530;
    b2 :=-0.356563782;
    b3 := 1.781477937;
    b4 :=-1.821255978;
    b5 := 1.330274429;
    xp1 := 1.0 / (1.0 + 0.2316419*ABS(x));
    xp2 := xp1*xp1;
    xp3 := xp2*xp1;
    xp4 := xp3*xp1;
    xp5 := xp4*xp1;
    term_sum := xp1*b1 + xp2*b2 + xp3*b3 + xp4*b4 + xp5*b5;
    recip_sqrt_2_pi := 0.39894228040143;
    rslt0 := exp(-x*x/2) * recip_sqrt_2_pi * term_sum;
    rslt := IF(x>=0.0, 1-rslt0, rslt0);
    RETURN rslt;
  END;

  /**
   * Normal Distribution Percentage Point Function.
   * Translated from C/C++ Mathematical Algorithms for Scientists and
   * Engineers, N. Shammas, McGraw-Hill, 1995
   * @param x probability
   * @returns number of standard deviations from the mean
   */
  EXPORT REAL8 Normal_PPF(REAL8 x) := DEFINE FUNCTION
    p0 := -0.322232431088;
    p1 := -1.0;
    p2 := -0.342242088547;
    p3 := -0.204231210245e-1;
    p4 := -0.453642210148e-4;
    q0 :=  0.993484626060e-1;
    q1 :=  0.588581570495;
    q2 :=  0.531103462366;
    q3 :=  0.103537752850;
    q4 :=  0.38560700634e-2;
    x0 := MAP(x<=0.0 => 0.0001, x>=1.0 => 0.9999, x);
    xp := SQRT(-2.0 * LN(IF(x0<=0.5, x0, 1-x0)));
    numerator := ((((p4*xp+p3)*xp+p2)*xp+p1)*xp+p0);
    denominator := ((((q4*xp+q3)*xp+q2)*xp+q1)*xp+q0);
    rslt0 := xp + numerator/denominator;
    RETURN MAP(x0=0.5  => 0.0,
               x0<0.5  => -rslt0,
               rslt0);
  END;

  // Helper for Students distribution
  REAL8 Sum_Terms(INTEGER4 df, REAL8 c, REAL8 csq) := BEGINC++
    #option pure;
    double work_sum = (df%2==0) ? 1.0  : c;
    double work_term = (df%2==0) ? 1.0  : c;
    int start = (df%2==0) ? 2  : 3;
    int stop = (df - 2);
    for (int i=start; i<=stop; i+=2) {
      work_term *= csq * (((double)(i-1.0))/((double)i));
      work_sum  += work_term;
    }
    return work_sum;
  ENDC++;
  /**
   * Students t distribution integral evaluated between negative
   * infinity and x.
   * Translated from NIST SEL DATAPAC Fortran TCDF.f source
   * @param x value of the evaluation
   * @param df degrees of freedom
   * @returns the probability that a value will be less than the
   * specified value
   */
  EXPORT REAL8 T_CDF(REAL8 x, REAL8 df) := DEFINE FUNCTION
    INTEGER4 DF_Cut := 1000;
    REAL8 PI := Core_Const.Pi;
    INTEGER4 ndf := (INTEGER4) df;
    BOOLEAN isEven := ndf%2 = 0;
    // Small and moderate df definitions
    REAL8 sd := SQRT(df/(df-2.0));
    REAL8 z := x/sd;
    REAL8 c := SQRT(df/(x*x+df));
    REAL8 csq := df/(x*x+df);
    REAL8 s := x/SQRT(x*x+df);
    REAL8 sum_terms := MAP(
        df=1  => (2/PI)*(ATAN(x)),
        df=2  => s,
        df=3  => (2/PI)*(ATAN(x/SQRT(df))+(c*s)),
        isEven=> Sum_Terms(df, c, csq) * s,
        (2/PI)*(ATAN(x/SQRT(df)) + Sum_Terms(df, c, csq)*s));
    // Large df asymptoptic approximation definitions
    REAL8 DCONST := 0.3989422804;
    REAL8 B11 := 0.25;
    REAL8 B21 := 0.01041666666667;
    REAL8 B22 := 3.0;
    REAL8 B23 := -7.0;
    REAL8 B24 := -5.0;
    REAL8 B25 := -3.0;
    REAL8 B31 := 0.00260416666667;
    REAL8 B32 := 1.0;
    REAL8 B33 := -11.0;
    REAL8 B34 := 14.0;
    REAL8 B35 := 6.0;
    REAL8 B36 := -3.0;
    REAL8 B37 := -15.0;
    REAL8 d1 := x;
    REAL8 d3 := d1 * x * x;
    REAL8 d5 := d3 * x * x;
    REAL8 d7 := d5 * x * x;
    REAL8 d9 := d7 * x * x;
    REAL8 d11:= d9 * x * x;
    REAL8 df_2 := df * df;
    REAL8 df_3 := df_2 * df;
    REAL8 Term1 := B11*(d3+d1)/df;
    REAL8 Term2 := B21*(B22*d7+B23*d5+B24*d3+B25*d1)/df_2;
    REAL8 Term3 := B31*(B32*d11+B33*d9+B34*d7+B35*d5+B36*d3+B37*d1)/df_3;
    REAL8 Norm_CDF := Normal_CDF(x);
    T_CDF := MAP(df <= 0                             => 0.0,
                df BETWEEN 3 AND 9     AND z<= -3000 => 0.0,
                df BETWEEN 3 AND 9     AND z>=  3000 => 1.0,
                df BETWEEN 10 AND 1000 AND z<= -150  => 0.0,
                df BETWEEN 10 AND 1000 AND z>=  150  => 1.0,
                df BETWEEN 1 AND 1000                => 0.5+sum_terms/2.0,
                Norm_CDF-(EXP(-x*x*0.5))*(Term1+Term2+Term3)*DCONST);
    RETURN T_CDF;
  END;

  // Inverse T helper functions
  REAL8 df3_helper(REAL8 trm, REAL8 init_z) := BEGINC++
    #option pure;
    #include <math.h>
    const double root_3 = sqrt(3);
    double c = cos(init_z);
    double s = sin(init_z);
    double z = init_z;
    for (int i=0; i<15; i++) {
      z = z-(z+s*c-trm)/(2.0*c*c);
      c = cos(z);
      s = sin(z);
    }
    return root_3*s/c;
  ENDC++;
  REAL8 df4_helper(REAL8 trm, REAL8 init_z) := BEGINC++
    #option pure;
    #include <math.h>
    double c = cos(init_z);
    double s = sin(init_z);
    double z = init_z;
    for (int i=0; i<15; i++) {
      z = z-((1.0+0.5*c*c)*s-trm)/(1.5*c*c*c);
      c = cos(z);
      s = sin(z);
    }
    return sqrt(4)*s/c;
  ENDC++;
  REAL8 df5_helper(REAL8 trm, REAL8 init_z) := BEGINC++
    #option pure;
    #include <math.h>
    double c = cos(init_z);
    double s = sin(init_z);
    double z = init_z;
    for (int i=0; i<15; i++) {
      z = z-(z+(c+(2.0/3.0)*c*c*c)*s-trm)/((8.0/3.0)*c*c*c*c);
      c = cos(z);
      s = sin(z);
    }
    return sqrt(5)*s/c;
  ENDC++;
  REAL8 df6_helper(REAL8 trm, REAL8 init_z) := BEGINC++
    #option pure;
    #include <math.h>
    double c = cos(init_z);
    double s = sin(init_z);
    double z = init_z;
    for (int i=0; i<15; i++) {
      z = z-((1.0+0.5*c*c+0.375*c*c*c*c)*s-trm)/((15.0/8.0)*c*c*c*c*c);
      c = cos(z);
      s = sin(z);
    }
    return sqrt(6)*s/c;
  ENDC++;
  REAL8 dk_helper(REAL8 x, INTEGER4 df, REAL8 mf) := BEGINC++
    #option pure;
    #include<math.h>
    const double last_position = 12; // lowest prob < 0.000001
    const double step = last_position/100000;
    double position = 0;
    double cdf = 0.5;
    double target = (x<0.5) ? 1.0-x :  x;
    while (cdf < target && position <=last_position) {
      double this_point = (2*position+step)/2;
      cdf += mf*pow(1+(this_point*this_point/df), -0.5*(df+1))*step;
      position += step;
    }
    if (cdf > target) position-= step/2;
    position = (x<0.5)  ? -position  : position;
    return position;
  ENDC++;
  /**
   * Percentage point function for the T distribution.
   * Translated from NIST SEL DATAPAC Fortran TPPF.f source
   */
  EXPORT REAL8 T_PPF(REAL8 x, REAL8 df) := DEFINE FUNCTION
    REAL8 PI := Core_Const.Pi; //3.14159265358979;
    REAL8 ROOT_2 := Core_Const.Root_2; //1.414213562373095;
    REAL8 B21 :=  0.25;
    REAL8 B31 :=  0.01041666666667;
    REAL8 B32 :=  5.0;
    REAL8 B33 :=  16.0;
    REAL8 B34 :=  3.0;
    REAL8 B41 :=  0.00260416666667;
    REAL8 B42 :=  3.0;
    REAL8 B43 :=  19.0;
    REAL8 B44 :=  17.0;
    REAL8 B45 := -15.0;
    REAL8 B51 :=  0.00001085069444;
    REAL8 B52 :=  79.0;
    REAL8 B53 :=  776.0;
    REAL8 B54 :=  1482.0;
    REAL8 B55 := -1920.0;
    REAL8 B56 := -945.0;
    REAL8 Norm_PPF := Normal_PPF(x);
    // df 7 and higher
    d1 := Norm_PPF;
    d2 := d1 * d1;
    d3 := d1 * d2;
    d5 := d3 * d2;
    d7 := d5 * d2;
    d9 := d7 * d2;
    df_2 := df * df;
    df_3 := df_2 * df;
    df_4 := df_3 * df;
    trm1 := d1;
    trm2 := B21*(d3+d1)/df;
    trm3 := B31*(B32*d5+B33*d3+B34*d1)/df_2;
    trm4 := B41*(B42*d7+B43*d5+B44*d3+B45*d1)/df_3;
    trm5 := B51*(B52*d9+B53*d7+B54*d5+B55*d3+B56*d1)/df_4;
    trms := trm1 + trm2 + trm3 + trm4 + trm5;
    // df 3, 4, 5, and 6 cases
    init_z := ATAN(Norm_PPF/SQRT(df));
    // df 7 to 50
    INTEGER4 ndf := (INTEGER4) df;
    BOOLEAN isEven := ndf&1 = 0;
    REAL8 m_factor := Math.DoubleFac(ndf-1)
                    /(IF(isEven,2,PI)*SQRT(ndf)*Math.DoubleFac(ndf-2));
    //
    rslt := MAP(df=1    => -COS(PI*x)/SIN(PI*x),
                df=2    => ((ROOT_2/2.0)*(2.0*x-1.0))/SQRT(x*(1.0-x)),
                df=3    => df3_helper((PI*(x-0.5)), init_z),
                df=4    => df4_helper((2.0*(x-0.5)), init_z),
                df=5    => df5_helper((PI*(x-0.5)), init_z),
                df=6    => df6_helper((2.0*(x-0.5)), init_z),
                df BETWEEN 7 AND 50 => dk_helper(x, ndf, m_factor),
                trms);
    RETURN rslt;
  END;

  // helper functions for Chi Squared
  REAL8 Low_DF_Sum(INTEGER4 df, REAL8 x) := BEGINC++
    #option pure;
    #include <math.h>
    if (x <= 0) return 0;
    if (df <=0) return 0;
    double chi = sqrt(x);
    double term_sum = (df%2==0) ? 1.0  : 0.0;
    double term = (df%2==0) ? 1.0  : 1.0/chi;
    int start = (df%2==0) ? 2  : 1;
    int stop = (df%2==0) ? (df-2)  : (df-1);
    for (int i=start; i<=stop; i+=2) {
      term *= x/((double)i);
      term_sum += term;
    }
    return term_sum;
  ENDC++;
  /**
   * The cumulative distribution function for the Chi Square
   * distribution.
   * the CDF for the specfied degrees of freedom.
   * Translated from the NIST SEL DATAPAC Fortran subroutine CHSCDF.
   */
  EXPORT REAL8 Chi2_CDF(REAL8 x, REAL8 df) := DEFINE FUNCTION
    INTEGER4 DF_Cut := 1000;
    REAL8 PI := Core_Const.Pi; //3.14159265358979;
    INTEGER4 ndf := (INTEGER4) df;
    BOOLEAN isEven := ndf%2 = 0;
    REAL8 sd := SQRT(2*df);
    REAL8 z := (x-df)/sd;
    // definitions for cases above the cut line for degrees of freedom
    REAL8 DPWR := 0.33333333333333;
    REAL8 dfact := 4.5 * df;
    REAL8 adj_point_gt_x := (POWER(x/df,DPWR)-1.0+1.0/dfact)*SQRT(dfact);
    REAL8 high_df_gt_x := Normal_CDF(adj_point_gt_x);
    REAL8 dw := SQRT(x - df-df*LN(x/df));
    REAL8 root_rdf1 := SQRT(2.0/df);
    REAL8 root_rdf2 := root_rdf1 * root_rdf1;
    REAL8 root_rdf3 := root_rdf2 * root_rdf1;
    REAL8 root_rdf4 := root_rdf3 * root_rdf1;
    REAL8 d1 := dw;
    REAL8 d2 := d1 * dw;
    REAL8 d3 := d2 * dw;
    REAL8 B11 :=  0.33333333333333;
    REAL8 B21 := -0.02777777777778;
    REAL8 B31 := -0.00061728395061;
    REAL8 B32 := -13.0;
    REAL8 B41 := 0.00018004115226;
    REAL8 B42 := 6.0;
    REAL8 B43 := 17.0;
    REAL8 trm0 := dw;
    REAL8 trm1 := B11*root_rdf1;
    REAL8 trm2 := B21*d1*root_rdf2;
    REAL8 trm3 := B31*(d2+B32)*root_rdf3;
    REAL8 trm4 := B41*(B42*d3+B43*d1)*root_rdf4;
    REAL8 high_df_le_x := Normal_CDF(trm0+trm1+trm2+trm3+trm4);
    // definitions for cases below the cut line for degrees of freedom
    REAL8 chi := SQRT(x);
    REAL8 low_even := Low_DF_Sum(ndf, x)*EXP(-x/2.0);
    REAL8 low_odd := (1.0-Normal_CDF(chi))*2.0 + (SQRT(2.0/PI)*low_even);
    // determine the result based upon the case
    rslt := MAP(x <= 0        => 0.0,
        df<10 AND z < -200    => 0.0,
        df>=10 AND z < -100   => 0.0,
        df<10 AND z > 200     => 1.0,
        df>=10 AND z > 100    => 1.0,
        df < DF_cut AND isEven=> 1.0 - low_even,
        df < df_Cut           => 1.0 - low_odd,
        df >=df_cut AND x<=df => high_df_gt_x,
        high_df_le_x);
     //cdf := Math.lowerGamma(df/2, x/2) / Math.gamma(df/2);
     RETURN rslt;
  END;

  // helpers for Chi squared PPF
  REAL8 df_lt_crit(REAL8 x, REAL8 df) := BEGINC++
    #option pure;
    #include <math.h>
      const int max_iter = 30000;
      const int max_bisect = 1000;
      const double half_df = df / 2.0;
      const double min_delta = 0.0000000001;
      double G = tgamma(half_df);
      // now ready to iterate to find percentage point value
      int iter = 0;
      double curr_point = 0.0;
      double step = pow(x*half_df*G, 2.0/df);
      double min_pos = 0;
      double max_pos = 0;
      // determine upper and lower limits
      while (iter<max_iter && curr_point < x) {
        min_pos = max_pos;
        max_pos += step;
        double term_sum = 2.0/df;
        double term = 2.0/df;
        double cut1 = max_pos - half_df;
        double cut2 = max_pos*10000000000.0;
        for (long j=1; j<10000 && ((double)j)<cut1+(cut2*term/term_sum); j++) {
          term = max_pos*term/(half_df+((double)j));
          term_sum += term;
        }
        curr_point = pow(max_pos, half_df) * exp(-max_pos) * term_sum / G;
        iter++;
      }
      // search by bisection
      double target_pos = (min_pos+max_pos) / 2.0;
      curr_point = pow(target_pos, half_df)*exp(-target_pos)*(2.0/half_df)/G;
      double delta = 2*min_delta;
      iter = 0;
      while (iter<max_bisect && delta>min_delta && curr_point!=x) {
        double term_sum = 2.0/df;
        double term = 2.0/df;
        double cut1 = target_pos - half_df;
        double cut2 = target_pos*10000000000.0;
        for (int j=1; j<10000.0 && ((double)j)<(cut1+(cut2*term/term_sum)); j++) {
          term = target_pos*term/(half_df+((double)j));
          term_sum += term;
        }
        curr_point = pow(target_pos, half_df) * exp(-target_pos) * term_sum / G;
        if (curr_point==x) return 2.0 * target_pos;
        if (curr_point < x) min_pos = target_pos;
        else max_pos = target_pos;
        iter++;
        target_pos = (max_pos + min_pos) / 2.0;
        delta = (target_pos>min_pos)  ? target_pos-min_pos  : min_pos-target_pos;
      }
      return 2.0 * target_pos;
  ENDC++;
  /**
   * The Chi Squared PPF function.
   * Translated from the NIST SEL DATAPAC Fortran subroutine CHSPPF.
   */
  EXPORT REAL8 Chi2_PPF(REAL8 x, REAL8 df) := FUNCTION
    critical := 100;
    x0 := MAP(x<=0.0 => 0.0001, x>=1.0 => 0.9999, x);
    REAL8 k := 2.0/9.0;
    xq := Normal_PPF(x0);
    wrk := 1.0 -k/df + xq*SQRT(k/df);
    df_ge_crit := df * wrk * wrk * wrk;
    rslt := IF(df<critical, df_lt_crit(x, df), df_ge_crit);
    RETURN rslt;
  END;
END;
