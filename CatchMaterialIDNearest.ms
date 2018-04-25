plugin simpleMeshMod CatchMaterialIDNearest
	name:"CatchMaterialIDNearest"
	classID:#(0x4AFEB76F, 0x21AE85C9)
	category:"Max Creation Graph"
	usePBValidity:true
(
	local pluginDefinitionFile -- the plugin definition file
	local pluginInstance -- the plugin instance created from the plugin definition
	local _meshWrapper -- the dotnet wrapper around the stack mesh pointer
	local argsType = dotNetClass "System.Object[]" -- used when creating args array
	local dotnet_ValueToDotNetObject = dotnet.ValueToDotNetObject
	local tmHandler
	--simulation locals
	local _lastTime = 0.0
	local interactiveMode = false

	-- function wrappers
	local _meshWrapper_SetValue
	local pluginInstance_UpdateMesh

	-- value wrapper local and function wrapper declarations
	local meshWrapper, meshWrapper_SetValue
	local hitMeshWrapper, hitMeshWrapper_SetValue
	local modifierTransformWrapper, modifierTransformWrapper_SetValue


	parameters main rollout:params
	(
		hitMesh ui:hitMesh type:#node useNodeOsValidity:true useNodeTmValidity:true
		RayLength ui:RayLength default:1 type:#float animatable:true
		_dummy type:#boolean invisibleInTV:true -- this exists to enable easy invalidation of the object
		pluginGraph type:#filename assettype:#MaxCreationGraph readOnly:true enumAsAsset:true 
		pluginGraphDependencies type:#filenametab assettype:#MaxCreationGraph readOnly:true enumAsAsset:true tabSize:0 tabSizeVariable:true
	)



	fn RunSimLoop updateFxn = (
		local result = ok
		try (
			result = updateFxn ()
		)
		catch()
		return result
	)

	fn initialize = 
	(
		pluginDefinitionFile = @"D:\Project\mcg\MCGRaytraceMatID\CatchMaterialIDNearest.maxtool"
		local c = dotNetClass "Viper3dsMaxBridge.ModifierPluginInstance"
		local cid = this.classId
		local refMakerWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.ReferenceMaker"
		refMakerWrapper = refMakerWrapperClass._CreateWrapper this
		pluginInstance = c.CreateInstance cid[1] cid[2] pluginDefinitionFile refMakerWrapper
		pluginInstance_UpdateMesh = pluginInstance.UpdateMesh
		local meshWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.Mesh"
		_meshWrapper = meshWrapperClass._CreateWrapper undefined
		_meshWrapper_SetValue = _meshWrapper._SetValue
		pluginGraph = pluginDefinitionFile
		pluginGraphDependencies = #(@"C:\Users\josep\Autodesk\3ds Max 2018\Max Creation Graph\Compounds\GetMaterialByRayTrace.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2018\MaxCreationGraph\Compounds\SceneNode_Mesh_in_World_Space.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue
		local hitMeshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.INode"
		hitMeshWrapper = hitMeshWrapperClass._CreateWrapper (undefined)
		hitMeshWrapper_SetValue = hitMeshWrapper._SetValue
		local modifierTransformWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Matrix3"
		modifierTransformWrapper = modifierTransformWrapperClass._CreateWrapper (matrix3 1)
		modifierTransformWrapper_SetValue = modifierTransformWrapper._SetValue

	)

	on create do 
	(
		initialize()
	)

	on clone fromObj do 
	(
		initialize()
	)

	on load do 
	(
		initialize()
	)

	on update do 
	(
		initialize()
	)

	rollout params "Parameters"
	(
		pickbutton hitMesh "hitMesh" autodisplay:true type:#node toolTip:"hitMesh" width:140
		on hitMesh rightclick do ( hitMesh.object = undefined; )
		spinner RayLength "RayLength" range:[0, 10000, 1] type:#float

	)




	rollout MCG_Editor "MCG Editor"(
		button MCG_Editor_btn "Open in MCG Editor"
		on MCG_Editor_btn pressed do
		(
			if (doesFileExist pluginDefinitionFile) then 
			(
				geBridge = dotNetClass "ProceduralContentActions.PCGraphEditorBridge"
				geBridge.LoadGraph pluginDefinitionFile
			)
			else (
				local msgStream = stringstream ""
				format "File '%' is missing.\n" pluginDefinitionFile to:msgStream
				local msgStr = msgStream as string
				if GetQuietMode() then
					format msgStr
				else
					MessageBox msgStr title: "Missing maxtool file" beep:false
			)
		)
	)


	fn updateMesh = 
	(
		if (tmHandler == undefined) then ( tmHandler = when transform owningNode changes do _dummy = not _dummy )
		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(meshWrapper, hitMeshWrapper, modifierTransformWrapper, RayLength) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		hitMeshWrapper_SetValue hitMesh
		meshWrapper_SetValue mesh
		modifierTransformWrapper_SetValue owningNode.Transform

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)
