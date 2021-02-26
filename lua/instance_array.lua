local instanceSourceLocations = Interface.GetOpArg("user.instanceSourceLocations")
local pointCloudLocation = Interface.GetOpArg("user.pointCloudLocation"):getValue()

local points = Interface.GetAttr("geometry.point.P", pointCloudLocation):getNearestSample(Interface.GetCurrentTime())
local variant = Interface.GetAttr("geometry.arbitrary.variant.value", pointCloudLocation):getNearestSample(Interface.GetCurrentTime())
local orient = Interface.GetAttr("geometry.arbitrary.orient.value", pointCloudLocation):getNearestSample(Interface.GetCurrentTime())
local pscale = Interface.GetAttr("geometry.arbitrary.pscale.value", pointCloudLocation):getNearestSample(Interface.GetCurrentTime())

Interface.SetAttr('type', StringAttribute('instance array'))
Interface.SetAttr('geometry.instanceSource', instanceSourceLocations)

local instanceSourceLength = #instanceSourceLocations:getNearestSample(Interface.GetCurrentTime()) 
 
local indexArray = {}
local xform = {}
local rotate = {}
local scale = {}

for i=0,#points/3-1 do
   
   indexArray[#indexArray+1] = variant[i+1] - 1

   --- TRANSLATE ---
   x = points[3*i+1]
   y = points[3*i+2]
   z = points[3*i+3]
   
   xform[#xform + 1] = x
   xform[#xform + 1] = y
   xform[#xform + 1] = z

   --- SCALE ---
   x_scale = pscale[3*i+1]
   y_scale = pscale[3*i+2]
   z_scale = pscale[3*i+3]

   scale[#scale + 1] = x_scale
   scale[#scale + 1] = y_scale
   scale[#scale + 1] = z_scale

   --- ROTATE ---
   x_orient = orient[4*i+1]
   y_orient = orient[4*i+2]
   z_orient = orient[4*i+3]
   w_orient = orient[4*i+4]

   angle = math.deg(2 * math.acos(w_orient))

   x_rotate = x_orient / math.sqrt(1-w_orient*w_orient)
   if (x_rotate ~= x_rotate) then
      x_rotate = 0
   end

   y_rotate = y_orient / math.sqrt(1-w_orient*w_orient)
   if (y_rotate ~= y_rotate) then
      y_rotate = 0
   end

   z_rotate = z_orient / math.sqrt(1-w_orient*w_orient)
   if (z_rotate ~= z_rotate) then
      z_rotate = 0
   end

   rotate[#rotate+1] = angle
   rotate[#rotate+1] = x_rotate
   rotate[#rotate+1] = y_rotate
   rotate[#rotate+1] = z_rotate


end
Interface.SetAttr('geometry.instanceIndex', IntAttribute(indexArray, 1))
Interface.SetAttr('geometry.instanceTranslate', DoubleAttribute(xform, 1))
Interface.SetAttr('geometry.instanceRotateX', DoubleAttribute(rotate, 1))
Interface.SetAttr('geometry.instanceScale', DoubleAttribute(scale, 1))