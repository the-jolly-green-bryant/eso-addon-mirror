local Matrix={};
HomesteadEngMatrix=Matrix;
Matrix.__index=Matrix;

local function NewMatrix(rows,cols)
  local result={c=cols,r=rows};
  setmetatable(result,Matrix);
  return result;
end

local function ScalarAdd(matrix,scalar)
  assert(getmetatable(matrix)==Matrix,"Wrong type");
  local result=NewMatrix(matrix.r,matrix.c);
  for i=0,matrix.r*matrix.c-1 do
    result[i]=matrix[i]+scalar;
  end
  return result;
end

local function ScalarMul(matrix,scalar)
  assert(getmetatable(matrix)==Matrix,"Wrong type");
  local result=NewMatrix(matrix.r,matrix.c);
  for i=0,matrix.r*matrix.c-1 do
    result[i]=matrix[i]*scalar;
  end
  return result;
end

local function MatrixAdd(matrix1,matrix2)
  assert(getmetatable(matrix1)==Matrix,"Arg1 wrong type");
  assert(getmetatable(matrix2)==Matrix,"Arg2 wrong type");
  assert(matrix1.r==matrix2.r and matrix1.c==matrix2.c,"Matrix size missmatch");
  local result=NewMatrix(matrix1.r,matrix1.c);
  for i=0,matrix1.r*matrix1.c-1 do
    result[i]=matrix1[i]+matrix2[i];
  end
  return result;
end

local function CrossProduct(matrix1,matrix2)
  assert(getmetatable(matrix1)==Matrix,"Arg1 wrong type");
  assert(getmetatable(matrix2)==Matrix,"Arg2 wrong type");
  assert(matrix1.c==matrix2.r,"Matrix size missmatch");
  local result=NewMatrix(matrix1.r,matrix2.c);
  for i=0,matrix1.r-1 do
   for j=0,matrix2.c-1 do
     local acc=0;
     for k=0,matrix1.c-1 do
       acc=acc+matrix1[i*matrix1.c+k]*matrix2[k*matrix2.c+j];
     end
     result[i*result.c+j]=acc;
   end
  end
  return result;
end

function Matrix.Transpose(matrix)
  assert(getmetatable(matrix)==Matrix,"Wrong type");
  local result=NewMatrix(matrix.c,matrix.r);
  for i=0,matrix.c-1 do
    for j=0,matrix.r-1 do
      result[i*result.c+j]=matrix[j*matrix.c+i];
    end
  end
  return result;
end

function Matrix.NewZero(rows,cols)
  local result=NewMatrix(rows,cols);
  for i=0,rows*cols-1 do
    result[i]=0;
  end
  return result;
end

function Matrix.NewCoordRow(x,y,z)
  local result=NewMatrix(1,3);
  result[0]=x;
  result[1]=y;
  result[2]=z;
  return result;
end

function Matrix.NewCoordCol(x,y,z)
  local result=NewMatrix(3,1);
  result[0]=x;
  result[1]=y;
  result[2]=z;
  return result;
end

function Matrix.GetCoord(matrix)
  assert(getmetatable(matrix)==Matrix,"Wrong type");
  assert((matrix.r==1 and matrix.c==3) or (matrix.r==3 and matrix.c==1),"Wrong size");
  return matrix[0],matrix[1],matrix[2];
end

function Matrix.VecAbs(matrix)
  assert(getmetatable(matrix)==Matrix,"Wrong type");
  assert(matrix.r==1 or matrix.c==1,"Wrong size");
  local acc=0;
  for i=0,(matrix.r>1 and matrix.r or matrix.c)-1 do
    acc=acc+matrix[i]*matrix[i];
  end
  return math.sqrt(acc);
end

function Matrix.VecDot(matrix1,matrix2)
  assert(getmetatable(matrix1)==Matrix,"Arg1 wrong type");
  assert(getmetatable(matrix2)==Matrix,"Arg2 wrong type");
  assert(matrix1.c==1 or matrix1.r==1,"Arg1 must be a vector");
  assert(matrix2.c==1 or matrix2.r==1,"Arg1 must be a vector");
  local len=matrix1.c>1 and matrix1.c or matrix1.r
  assert(len==matrix2.c or len==matrix2.r,"Arg lengths must match");
  local acc=0;
  for i=0,len-1 do
    acc=acc+matrix1[i]*matrix2[i];
  end
  return acc;
end

function Matrix.NewXRot(angleRad)
  local result=NewMatrix(3,3);
  local s=math.sin(angleRad);
  local c=math.cos(angleRad);
  result[0]=1;
  result[1]=0;
  result[2]=0;
  result[3]=0;
  result[4]=c;
  result[5]=-s;
  result[6]=0;
  result[7]=s;
  result[8]=c;
  return result;
end

function Matrix.NewYRot(angleRad)
  local result=NewMatrix(3,3);
  local s=math.sin(angleRad);
  local c=math.cos(angleRad);
  result[0]=c;
  result[1]=0;
  result[2]=s;
  result[3]=0;
  result[4]=1;
  result[5]=0;
  result[6]=-s;
  result[7]=0;
  result[8]=c;
  return result;
end

function Matrix.NewZRot(angleRad)
  local result=NewMatrix(3,3);
  local s=math.sin(angleRad);
  local c=math.cos(angleRad);
  result[0]=c;
  result[1]=-s;
  result[2]=0;
  result[3]=s;
  result[4]=c;
  result[5]=0;
  result[6]=0;
  result[7]=0;
  result[8]=1;
  return result;
end

function Matrix:Get(row,col)
  return self[(row-1)*self.c+(col-1)];
end

function Matrix:Set(row,col,value)
  self[(row-1)*self.c+(col-1)]=value;
end

function Matrix.__add(value1,value2)
  if type(value1)=="number" then
    return ScalarAdd(value2,value1);
  elseif type(value2)=="number" then
    return ScalarAdd(value1,value2);
  else
    return MatrixAdd(value1,value2);
  end
end

function Matrix.__sub(value1,value2)
  if type(value1)=="number" then
    return ScalarAdd(ScalarMul(value2,-1),value1);
  elseif type(value2)=="number" then
    return ScalarAdd(value1,-value2);
  else
    return MatrixAdd(value1,ScalarMult(value2,-1));
  end
end

function Matrix.__mul(value1,value2)
  if type(value1)=="number" then
    return ScalarMul(value2,value1);
  elseif type(value2)=="number" then
    return ScalarMul(value1,value2);
  else
    return CrossProduct(value1,value2);
  end
end

function Matrix.__div(value1,value2)
  assert(type(value2)=="number","Wrong type");
  return ScalarMul(value1,1/value2);
end

function Matrix.__eq(value1,value2)
  if type(value1)~="table" or type(value2)~="table" or getmetatable(value1)~=Matrix or getmetatable(value2)~=Matrix or value1.c~=value2.c or value1.r~=value2.r then
    return false;
  end
  for i=0,value1.c*value1.r-1 do
    if value1[i]~=value2[i] then
      return false;
    end
  end
  return true;
end

function Matrix.__tostring(value)
  local result="[";
  for i=0,value.r-1 do
    result=result.."[ ";
    for j=0,value.c-1 do
      result=result..tostring(value[i*value.c+j]).." ";
    end
    result=result.."]";
  end
  return result.."]";
end

