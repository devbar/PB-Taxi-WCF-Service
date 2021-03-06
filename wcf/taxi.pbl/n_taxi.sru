$PBExportHeader$n_taxi.sru
forward
global type n_taxi from NonVisualObject
end type
end forward

global type n_taxi from NonVisualObject
end type
global n_taxi n_taxi

forward prototypes
public subroutine of_setPosition (string as_cab, integer al_guest_count, decimal adc_longitude, decimal adc_latitude, integer al_accuracy, decimal adc_speed, longlong al_catchmillis)
private function datetime of_millisToDateTime (longlong al_millis)
public function s_position of_getPosition (string as_id)
public function string of_renderPdf (string as_cab)
end prototypes

public subroutine of_setPosition (string as_cab, integer al_guest_count, decimal adc_longitude, decimal adc_latitude, integer al_accuracy, decimal adc_speed, longlong al_catchmillis);long		ll_newRow
DataStore	lds_position
Transaction	ltr_trans

// init transaction
ltr_trans = f_getConnection()

// init DataStore
lds_position = create DataStore
lds_position.DataObject = "ds_position"
lds_position.SetTransObject(ltr_trans)

// insert data
ll_newRow = lds_position.InsertRow(0)

lds_position.SetItem(ll_newRow, "cab", as_cab)
lds_position.SetItem(ll_newRow, "guest_count", al_guest_count)
lds_position.SetItem(ll_newRow, "longitude", adc_longitude)
lds_position.SetItem(ll_newRow, "latitude", adc_latitude)
lds_position.SetItem(ll_newRow, "accuracy", al_accuracy)
lds_position.SetItem(ll_newRow, "speed", adc_speed)
lds_position.SetItem(ll_newRow, "catchtime", of_millisToDateTime(al_catchmillis))

lds_position.Update()

f_resetConnection(ltr_trans)
end subroutine

private function datetime of_millisToDateTime (longlong al_millis);datetime	ldtm_result
date	 	ldt_current
time		lt_current
long		ll_seconds
long		ll_minutes
long		ll_hours
long		ll_days

ldt_current = date(1970,1,1)

// millis in seconds
ll_seconds = Round(al_millis / 1000,0)

// minutes from seconds
ll_minutes = Truncate(ll_seconds/60,0)
ll_seconds -= ll_minutes * 60

// hours from minutes
ll_hours = Truncate(ll_minutes/60,0)
ll_minutes -= ll_hours * 60

// days from hours
ll_days = Truncate(ll_hours/24,0)
ll_hours -= ll_days * 24

lt_current = time (ll_hours, ll_minutes, ll_seconds)
ldt_current = RelativeDate(ldt_current, ll_days)

return datetime(ldt_current, lt_current)
end function

public function s_position of_getPosition (string as_id);s_position	lstr_position
DataStore	lds_position
transaction	ltr_tr
long		ll_id

// variable in uri template path must be of type 'string'
ll_id = long(as_id)

ltr_tr = f_getConnection()

lds_position = create DataStore
lds_position.DataObject = "ds_position"
lds_position.SetTransObject(ltr_tr)

if lds_position.Retrieve(ll_id) > 0 then
	lstr_position.id = lds_position.GetItemNumber(1, "id")
	lstr_position.cab = lds_position.GetItemString(1, "cab")
	lstr_position.guest_count = lds_position.GetItemNumber(1, "guest_count")
	lstr_position.longitude = lds_position.GetItemDecimal(1, "longitude")
	lstr_position.latitude = lds_position.GetItemDecimal(1, "latitude")
	lstr_position.accuracy = lds_position.GetItemNumber(1, "accuracy")
	lstr_position.speed = lds_position.GetItemDecimal(1, "speed")
	lstr_position.catchtime = string(lds_position.GetItemDateTime(1, "catchtime"))
else
	lstr_position.id = -1
end if

f_resetConnection(ltr_tr)

return lstr_position
end function

public function string of_renderPdf (string as_cab);DataStore	lds_report
Transaction ltr_tr
string		ls_cab, ls_url

ltr_tr = f_getConnection()

lds_report = create DataStore
lds_report.DataObject = "dr_position"
lds_report.SetTransObject(ltr_tr)
lds_report.Retrieve(as_cab)


ls_cab = as_cab.Replace(' ', '_')
lds_report.SaveAs("C:\Inetpub\pblab\taxi\ceo\" + ls_cab + ".pdf", PDF!, false)
ls_url = "http://192.168.30.24:82/taxi/ceo/" + ls_cab + ".pdf"

f_resetConnection(ltr_tr)

return ls_url
end function

on n_taxi.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_taxi.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on
