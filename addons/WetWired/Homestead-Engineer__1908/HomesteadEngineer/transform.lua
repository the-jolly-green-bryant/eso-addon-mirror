local Matrix=HomesteadEngMatrix;

HomesteadEngTransform={};
local Transform=HomesteadEngTransform;

function Transform.FwdTransform(subject,applyTransform)
  local rev=Matrix.Transpose(applyTransform);
  local coord=rev*Matrix.NewCoordCol(subject.x-applyTransform.x,subject.y-applyTransform.y,subject.z-applyTransform.z);
  local rot=rev*subject;
  rot.x=coord[0];
  rot.y=coord[1];
  rot.z=coord[2];
  return rot;
end

function Transform.RevTransform(subject,applyTransform)
  local coord=applyTransform*Matrix.NewCoordCol(subject.x,subject.y,subject.z);
  local rot=applyTransform*subject;
  rot.x=coord[0]+applyTransform.x;
  rot.y=coord[1]+applyTransform.y;
  rot.z=coord[2]+applyTransform.z;
  return rot;
end

function Transform.CoordToTransform(x,y,z,p,w,r)
  local result=Matrix.NewYRot(w)*Matrix.NewXRot(p)*Matrix.NewZRot(r);
  result.x=x;
  result.y=y;
  result.z=z;
  return result;
end

function Transform.TransformToCoord(subject)
  return subject.x,
         subject.y,
         subject.z,
         -math.asin(subject[5]),
         -math.atan2(-subject[2],subject[8]),
         -math.atan2(-subject[3],subject[4]);

end
