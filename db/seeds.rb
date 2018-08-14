# encoding: UTF-8

conexion = ActiveRecord::Base.connection();

# De motores y finalmente de este
motor = ['sip', 'sal7711_gen']
motor.each do |m|
    Sip::carga_semillas_sql(conexion, m, :cambios)
    Sip::carga_semillas_sql(conexion, m, :datos)
end

# Usuario para primer ingreso sal7711 con clave sal7711
conexion.execute("INSERT INTO usuario 
  (nusuario, nombre, email, encrypted_password, password, 
    fechacreacion, created_at, updated_at, rol, confirmed_at) 
  VALUES ('sal7711', 'sal7711', 'sal7711', 
    '$2a$10$RzZB8e0HK/RF4jTnTB7kiOEa7Hc/pI.xBGaXqhjTm1YFHVFEPFKEG', 
    '', '2014-08-26', '2014-08-26', '2014-08-26', 1, '2016-08-01');")

motor = [nil]
motor.each do |m|
    Sip::carga_semillas_sql(conexion, m, :cambios)
    Sip::carga_semillas_sql(conexion, m, :datos)
end


