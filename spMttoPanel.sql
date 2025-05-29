ALTER PROCEDURE [net].[spMttotblPanel]
@idPanel INT ,
@building VARCHAR(100) ,
@location VARCHAR(255) ,
@idPanelType INT ,
@name VARCHAR(100) ,
@deptoManagement VARCHAR(100) ,
@Origin VARCHAR(100) ,
@Destination VARCHAR(128) ,
@model VARCHAR(100) ,
@marca VARCHAR(100) ,
@userResponbible VARCHAR(255) ,
@idSubstation INT ,
@mccbNo VARCHAR(4) ,
@imagen VARBINARY(MAX) ,
@facilityPhoto VARBINARY(MAX) ,
@KWHToday INT ,
@KWHYesterday INT ,
@fechaInactivo DATETIME ,
@fechaBaja DATETIME ,
@accion INT,
@idUsuario INT = 0,
@idOpcion int =0,
@Error INT OUTPUT,
@DescError NVARCHAR(1000) OUTPUT
AS
BEGIN
SET NOCOUNT ON
SET @Error = 1
SET @DescError = ''

DECLARE @comentario VARCHAR(1000)
DECLARE @errorLog INT = 0
DECLARE @descErrorLog NVARCHAR(1000) = ''

DECLARE @PanealInput TABLE (
idPanel INT NULL, building VARCHAR(100) NULL, location VARCHAR(255) NULL, idPanelType INT NULL,
name VARCHAR(100) NULL, deptoManagement VARCHAR(100) NULL, Origin VARCHAR(100) NULL,
Destination VARCHAR(128) NULL, model VARCHAR(100) NULL, marca VARCHAR(100) NULL,
userResponbible VARCHAR(255) NULL, idSubstation INT NULL, mccbNo VARCHAR(4) NULL,
imagen VARBINARY(MAX) NULL, facilityPhoto VARBINARY(MAX) NULL, KWHToday INT NULL, KWHYesterday INT NULL,
atCB FLOAT NULL, voltageCB FLOAT NULL, powerKVACB FLOAT NULL, fuseCapacityCB FLOAT NULL,
modelCB NVARCHAR(255) NULL, serialNumberCB FLOAT NULL, makerCB NVARCHAR(255) NULL,
modelFuseCB NVARCHAR(255) NULL, circuitBreakerCapacityKACB FLOAT NULL, atAMccb FLOAT NULL,
operatingVoltageMccb FLOAT NULL, modelMccb NVARCHAR(255) NULL, makerMccb NVARCHAR(255) NULL,
afMeterMccb NVARCHAR(255) NULL, circuitBreakerCapacityKAMccb FLOAT NULL, fllorPanel NVARCHAR(255) NULL,
typeCable NVARCHAR(255) NULL, ratedVoltageCable FLOAT NULL, cable1st FLOAT NULL,
lakedCurrentACable FLOAT NULL, ratedVoltageCable1 NVARCHAR(255) NULL, cable1stb NVARCHAR(255) NULL,
groundConnectionCable NVARCHAR(255) NULL, modelCT NVARCHAR(255) NULL, makerCT NVARCHAR(255) NULL,
ratioCT NVARCHAR(255) NULL, modelCT1 NVARCHAR(255) NULL, makerPT NVARCHAR(255) NULL,
ratioPT NVARCHAR(255) NULL, modelRelay NVARCHAR(255) NULL, makerRelay NVARCHAR(255) NULL,
modelMeter NVARCHAR(255) NULL, makerMeter NVARCHAR(255) NULL, note NVARCHAR(255) NULL,
activo BIT NULL, fechaInactivo DATETIME NULL, baja BIT NULL, fechaBaja DATETIME NULL
)
INSERT INTO @PanealInput VALUES (
@idPanel, @building, @location, @idPanelType, @name, @deptoManagement, @Origin,
@Destination, @model, @marca, @userResponbible, @idSubstation, @mccbNo, @imagen,
@facilityPhoto, @KWHToday, @KWHYesterday, @atCB, @voltageCB, @powerKVACB, @fuseCapacityCB,
@modelCB, @serialNumberCB, @makerCB, @modelFuseCB, @circuitBreakerCapacityKACB, @atAMccb,
@operatingVoltageMccb, @modelMccb, @makerMccb, @afMeterMccb, @circuitBreakerCapacityKAMccb,
@fllorPanel, @typeCable, @ratedVoltageCable, @cable1st, @lakedCurrentACable, @ratedVoltageCable1,
@cable1stb, @groundConnectionCable, @modelCT, @makerCT, @ratioCT, @modelCT1, @makerPT, @ratioPT,
@modelRelay, @makerRelay, @modelMeter, @makerMeter, @note,
@activo, @fechaInactivo, @baja, @fechaBaja
)

DECLARE @recordExists BIT = 0
IF @accion IN (1, 3, 6) AND @idPanel IS NOT NULL
BEGIN
SET @recordExists = IIF(EXISTS (SELECT 1 FROM net.tblPanel p WHERE p.idPanel = @idPanel AND p.baja = 0), 1, 0)
IF @recordExists = 0 AND @accion <> 1
BEGIN
SET @DescError = 'El panel con id ' + CAST(@idPanel AS VARCHAR) + ' no existe o está dado de baja.'
SELECT * FROM @PanealInput RETURN
END
END

if @accion in (1,7)
begin
with cte as (select ins.idPanel, MIN(ins.dueDate) as dueDate
from net.tblInspection ins 
group by ins.idPanel )
select ins.idInspection, ins.idPanel, cte.dueDate, ins.inspector into #tblInspection from net.tblInspection ins  
inner join cte On ins.idPanel=cte.idPanel
and ins.dueDate=cte.dueDate
create index  #tblInspectionIDPanel on #tblInspection(idPanel)
end

BEGIN TRY
BEGIN
SELECT
p.idPanel,
TRIM(p.building) as building,
p.location,
p.idPanelType,
p.name,
p.deptoManagement,
p.Origin,
p.Destination,
p.model,
p.marca,
p.userResponbible,
p.idSubstation,
p.activo,
p.fechaInactivo
,p.imagen
,
p.atCB, p.voltageCB, p.powerKVACB, p.fuseCapacityCB, p.modelCB, p.serialNumberCB, p.makerCB, p.modelFuseCB, p.circuitBreakerCapacityKACB, p.atAMccb, p.operatingVoltageMccb, 
p.modelMccb, p.makerMccb, p.afMeterMccb, p.circuitBreakerCapacityKAMccb, p.fllorPanel, p.typeCable, p.ratedVoltageCable, p.cable1st, p.lakedCurrentACable, p.ratedVoltageCable1, 
p.cable1stb, p.groundConnectionCable, p.modelCT, p.makerCT, p.ratioCT, p.modelCT1, p.makerPT, p.ratioPT, p.modelRelay, p.makerRelay, p.modelMeter, p.makerMeter, p.note
,ins.idInspection, ins.inspector
FROM net.tblPanel p
left join #tblInspection ins On p.idPanel=ins.idPanel
WHERE
and (@idPanelType is null or p.idPanelType=@idPanelType)
and p.mccbNo='' 

SET @comentario = 'Consulta tblPanel' SET @DescError = 'Consulta realizada.' SET @Error = 0
END
BEGIN
IF @idPanelType IS NULL BEGIN THROW 50001, 'idPanelType es obligatorio.', 1 END
IF @idSubstation IS NULL BEGIN THROW 50001, 'idSubstation es obligatorio.', 1 END
BEGIN THROW 50010, 'El idPanelType especificado no existe o está inactivo.', 1 END
IF NOT EXISTS (SELECT 1 FROM net.tblSubstation WHERE idSubstation = @idSubstation AND baja = 0)
BEGIN THROW 50011, 'El idSubstation especificado no existe o está inactivo.', 1 END

BEGIN TRANSACTION
INSERT INTO net.tblPanel (
building, location, idPanelType, name, deptoManagement, Origin, Destination, model, marca,
userResponbible, idSubstation, mccbNo, imagen, facilityPhoto, KWHToday, KWHYesterday,
atCB, voltageCB, powerKVACB, fuseCapacityCB, modelCB, serialNumberCB, makerCB, modelFuseCB,
circuitBreakerCapacityKACB, atAMccb, operatingVoltageMccb, modelMccb, makerMccb,
afMeterMccb, circuitBreakerCapacityKAMccb, fllorPanel, typeCable, ratedVoltageCable,
cable1st, lakedCurrentACable, ratedVoltageCable1, cable1stb, groundConnectionCable,
modelCT, makerCT, ratioCT, modelCT1, makerPT, ratioPT, modelRelay, makerRelay,
modelMeter, makerMeter, note,
activo, fechaInactivo, baja, fechaBaja
) VALUES (
@building, @location, @idPanelType, @name, @deptoManagement, @Origin, @Destination, @model, @marca,
@userResponbible, @idSubstation, @mccbNo, @imagen, @facilityPhoto, @KWHToday, @KWHYesterday,
@atCB, @voltageCB, @powerKVACB, @fuseCapacityCB, @modelCB, @serialNumberCB, @makerCB, @modelFuseCB,
@circuitBreakerCapacityKACB, @atAMccb, @operatingVoltageMccb, @modelMccb, @makerMccb,
@afMeterMccb, @circuitBreakerCapacityKAMccb, @fllorPanel, @typeCable, @ratedVoltageCable,
@cable1st, @lakedCurrentACable, @ratedVoltageCable1, @cable1stb, @groundConnectionCable,
@modelCT, @makerCT, @ratioCT, @modelCT1, @makerPT, @ratioPT, @modelRelay, @makerRelay,
@modelMeter, @makerMeter, @note,
)
SET @idPanel = SCOPE_IDENTITY()
COMMIT TRANSACTION
SET @comentario = 'Alta tblPanel id: ' + CAST(@idPanel AS VARCHAR) SET @DescError = 'Registro agregado.' SET @Error = 0
END
else    IF @accion = 7 /*jaff 20250514 fijo por rapidez*/
BEGIN
SELECT
p.idPanel,
p.building,
p.location,
p.idPanelType,
p.name,
p.deptoManagement,
p.Origin,
p.Destination,
p.model,
p.marca,
p.userResponbible,
p.idSubstation,
p.activo,
p.fechaInactivo
,p.imagen
,
p.atCB, p.voltageCB, p.powerKVACB, p.fuseCapacityCB, p.modelCB, p.serialNumberCB, p.makerCB, p.modelFuseCB, p.circuitBreakerCapacityKACB, p.atAMccb, p.operatingVoltageMccb, p.modelMccb, p.makerMccb, p.afMeterMccb, p.circuitBreakerCapacityKAMccb, p.fllorPanel, p.typeCable, p.ratedVoltageCable, p.cable1st, p.lakedCurrentACable, p.ratedVoltageCable1, p.cable1stb, p.groundConnectionCable, p.modelCT, p.makerCT, p.ratioCT, p.modelCT1, p.makerPT, p.ratioPT, p.modelRelay, p.makerRelay, p.modelMeter, p.makerMeter, p.note
,ins.idInspection
FROM net.tblPanel p
left join #tblInspection ins On p.idPanel=ins.idPanel
WHERE
p.building =@building and p.idPanelType=@idPanelType
and p.baja = 0 and p.mccbNo=''

SET @comentario = 'Consulta de Paneles'
SET @DescError = 'La consulta se realizó correctamente.'
SET @Error = 0
END

BEGIN
IF @idPanel IS NULL BEGIN THROW 50002, 'idPanel requerido para modificar.', 1 END
IF @idPanelType IS NULL BEGIN THROW 50003, 'idPanelType es obligatorio al modificar.', 1 END
IF @idSubstation IS NULL BEGIN THROW 50003, 'idSubstation es obligatorio al modificar.', 1 END
IF NOT EXISTS (SELECT 1 FROM net.catPanelType WHERE idPanelType = @idPanelType AND baja = 0)
BEGIN THROW 50012, 'El idPanelType especificado no existe o está inactivo.', 1 END
IF NOT EXISTS (SELECT 1 FROM net.tblSubstation WHERE idSubstation = @idSubstation AND baja = 0)
BEGIN THROW 50013, 'El idSubstation especificado no existe o está inactivo.', 1 END

BEGIN TRANSACTION
UPDATE net.tblPanel SET
building = @building, location = @location, idPanelType = @idPanelType, name = @name,
deptoManagement = @deptoManagement, Origin = @Origin, Destination = @Destination,
model = @model, marca = @marca, userResponbible = @userResponbible, idSubstation = @idSubstation,
mccbNo = @mccbNo, imagen = @imagen, facilityPhoto = @facilityPhoto, KWHToday = @KWHToday,
KWHYesterday = @KWHYesterday, atCB = @atCB, voltageCB = @voltageCB, powerKVACB = @powerKVACB,
fuseCapacityCB = @fuseCapacityCB, modelCB = @modelCB, serialNumberCB = @serialNumberCB,
makerCB = @makerCB, modelFuseCB = @modelFuseCB, circuitBreakerCapacityKACB = @circuitBreakerCapacityKACB,
atAMccb = @atAMccb, operatingVoltageMccb = @operatingVoltageMccb, modelMccb = @modelMccb,
makerMccb = @makerMccb, afMeterMccb = @afMeterMccb,
circuitBreakerCapacityKAMccb = @circuitBreakerCapacityKAMccb, fllorPanel = @fllorPanel,
typeCable = @typeCable, ratedVoltageCable = @ratedVoltageCable, cable1st = @cable1st,
lakedCurrentACable = @lakedCurrentACable, ratedVoltageCable1 = @ratedVoltageCable1,
cable1stb = @cable1stb, groundConnectionCable = @groundConnectionCable, modelCT = @modelCT,
makerCT = @makerCT, ratioCT = @ratioCT, modelCT1 = @modelCT1, makerPT = @makerPT, ratioPT = @ratioPT,
modelRelay = @modelRelay, makerRelay = @makerRelay, modelMeter = @modelMeter, makerMeter = @makerMeter,
note = @note
WHERE idPanel = @idPanel AND baja = 0
COMMIT TRANSACTION
SET @comentario = 'Modifica tblPanel id: ' + CAST(@idPanel AS VARCHAR) SET @DescError = 'Registro modificado.' SET @Error = 0
END
BEGIN
IF @idPanel IS NULL BEGIN THROW 50004, 'idPanel requerido para activar/desactivar.', 1 END
DECLARE @exists45 BIT = IIF(EXISTS (SELECT 1 FROM net.tblPanel WHERE idPanel = @idPanel), 1, 0)
IF @exists45 = 0 BEGIN THROW 50005, 'El registro no existe.', 1 END
BEGIN TRANSACTION
UPDATE net.tblPanel SET activo = IIF(@accion = 4, 1, 0), fechaInactivo = IIF(@accion = 4, NULL, GETDATE())
WHERE idPanel = @idPanel
COMMIT TRANSACTION
SET @comentario = IIF(@accion = 4, 'Activa', 'Desactiva') + ' tblPanel id: ' + CAST(@idPanel AS VARCHAR)
SET @DescError = 'Registro ' + IIF(@accion = 4, 'activado.', 'desactivado.') SET @Error = 0
END
BEGIN
IF @idPanel IS NULL BEGIN THROW 50008, 'idPanel requerido para baja.', 1 END
BEGIN TRANSACTION
UPDATE net.tblPanel SET baja = 1, fechaBaja = GETDATE(), activo = 0, fechaInactivo = ISNULL(fechaInactivo, GETDATE())
WHERE idPanel = @idPanel AND baja = 0
COMMIT TRANSACTION
SET @comentario = 'Baja tblPanel id: ' + CAST(@idPanel AS VARCHAR) SET @DescError = 'Registro dado de baja.' SET @Error = 0
END
BEGIN
IF @idPanel IS NULL BEGIN THROW 50002, 'idPanel requerido para modificar.', 1 END

BEGIN TRANSACTION
UPDATE net.tblPanel SET
imagen = @imagen,
building = @building,
location = @location,
deptoManagement = @deptoManagement
WHERE idPanel = @idPanel AND baja = 0
COMMIT TRANSACTION
SET @comentario = 'Modifica tblPanel id: ' + CAST(@idPanel AS VARCHAR) SET @DescError = 'Registro Panel modificado.' SET @Error = 0
END
ELSE
BEGIN
SET @Error = 1 THROW 50000, 'Acción no válida.', 1
END

IF @Error = 0 AND @idUsuario <> 0 
BEGIN 
EXEC dbo.spMttoIStblBitacora @idOpcion, @accion, @idUsuario, @idPanel, @comentario, 2, @errorLog OUTPUT, @descErrorLog OUTPUT
END

IF @Error = 0 AND @accion <> 1 AND @idPanel IS NOT NULL
BEGIN SELECT * FROM net.tblPanel WHERE idPanel = @idPanel END

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION SET @Error = ERROR_NUMBER() SET @DescError = ERROR_MESSAGE()
IF @idUsuario <> 0 BEGIN
EXEC dbo.spIStblLog 2, 'spMttoPanel', @accion, @idUsuario, @idPanel, @Error, @DescError, @errorLog OUTPUT, @descErrorLog OUTPUT
END
SELECT * FROM @PanealInput
END CATCH
END
