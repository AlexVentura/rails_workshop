# Poner este archivo en config/initializers/

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
	:address				=>	'smtp.gmail.com',
	:port					=>	'587',
	:authentication			=>	'login',
	:user_name				=>	'pruebas.test.dev@gmail.com', #ENV['GMAIL_USERNAME'],
	:password				=>	'2016qwerty', #ENV['GMAIL_PASSWORD'],
	:domain					=>	'lenguajemx.com',
	:enable_starttls_auto	=>	true
}
