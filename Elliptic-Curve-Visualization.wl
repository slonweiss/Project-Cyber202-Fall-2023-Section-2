(*Define radii of torus*)
c = 4;
a = 2;

(*Torus parametric functions*)
xTorus[u_, v_] = (c + a Cos[v]) Cos[u];
yTorus[u_, v_] = (c + a Cos[v]) Sin[u];
zTorus[u_, v_] = a Sin[v];

(*Elliptic curve parameters*)
aCoeff = 1;
bCoeff = 0;

(*Elliptic curve parametric functions*)
xElliptic[t_] = t;
yElliptic[t_] = Sqrt[t^3 + aCoeff*t + bCoeff];

(*Map the elliptic curve onto the torus*)
xMapped[pt_] := xTorus[uMap[pt[[1]]], vMap[pt[[2]]]];
yMapped[pt_] := yTorus[uMap[pt[[1]]], vMap[pt[[2]]]];
zMapped[pt_] := zTorus[uMap[pt[[1]]], vMap[pt[[2]]]];

(*Finite Field and Mesh Points*)
p = 17; (*Modulus*)
fieldPoints = Tuples[Range[0, p - 1], 2];
uMap[x_] := 2 Pi x/(p - 1) + Pi;
vMap[y_] := Pi (2 y/(p - 1) - 1) + Pi;
meshPoints = Map[Function[pt, {xTorus[uMap[pt[[1]]], vMap[pt[[2]]]], yTorus[uMap[pt[[1]]], vMap[pt[[2]]]], zTorus[uMap[pt[[1]]], vMap[pt[[2]]]]}], fieldPoints];

(*Generate lines for the mesh grid with translucent lines*)
lines = {};
For[i = 1, i <= p, i++, 
  For[j = 1, j < p, j++, 
    AppendTo[lines, {Directive[Black, Opacity[0.3]], Line[{meshPoints[[p (i - 1) + j]], meshPoints[[p (i - 1) + j + 1]]}]}];
    AppendTo[lines, {Directive[Black, Opacity[0.3]], Line[{meshPoints[[p (j - 1) + i]], meshPoints[[p (j) + i]]}]}];
  ];
];

(*Define the label for the (0,0) point on the torus*)
labelPos = {xTorus[uMap[0], vMap[0]], yTorus[uMap[0], vMap[0]], zTorus[uMap[0], vMap[0]]};

EllipticCurvePointsModP[p_, a_, b_] := Module[{points = {}, y2, y}, 
  For[x = 0, x < p, x++, y2 = Mod[x^3 + a*x + b, p];
   If[MemberQ[Table[Mod[i^2, p], {i, p}], y2], 
    y = Select[Range[0, p - 1], Mod[#^2, p] == y2 &];
    points = Join[points, {x, #} & /@ y];];
  ];
  points
]

pointsOnCurve = EllipticCurvePointsModP[p, aCoeff, bCoeff];

mappedCurvePoints = Map[Function[pt, {xMapped[pt], yMapped[pt], zMapped[pt]}], pointsOnCurve];

(*Plotting*)
Show[
  ParametricPlot3D[{xTorus[u, v], yTorus[u, v], zTorus[u, v]}, {u, 0, 2 Pi}, {v, -Pi, Pi}, PlotStyle -> Directive[LightBlue, Opacity[0.2]], Mesh -> None], 
  Graphics3D[
    {
      Directive[Black, Opacity[0.3]], PointSize[Small], Point[meshPoints], lines, Text["(0,0)", labelPos, {-1, -1}],(*existing graphics elements*)
      Red, PointSize[Large], Point[mappedCurvePoints] (*newly added points in red color*)
    }, 
    Boxed -> False, Axes -> True, ImageSize -> Large
  ], 
  ParametricPlot3D[{xMapped[{u, yElliptic[u]}], yMapped[{u, yElliptic[u]}], zMapped[{u, yElliptic[u]}]}, {u, 0, p - 1}, PlotStyle -> Directive[Blue, Thickness[0.005]]]
]