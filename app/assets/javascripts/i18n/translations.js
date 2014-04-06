I18n.translations || (I18n.translations = {});
I18n.translations["en"] = {"date":{"formats":{"default":"%Y-%m-%d","short":"%b %d","long":"%B %d, %Y"},"day_names":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"abbr_day_names":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"month_names":[null,"January","February","March","April","May","June","July","August","September","October","November","December"],"abbr_month_names":[null,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"order":["year","month","day"]},"time":{"formats":{"default":"%a, %d %b %Y %H:%M:%S %z","short":"%d %b %H:%M","long":"%B %d, %Y %H:%M"},"am":"am","pm":"pm"},"support":{"array":{"words_connector":", ","two_words_connector":" and ","last_word_connector":", and "}},"number":{"format":{"separator":".","delimiter":",","precision":3,"significant":false,"strip_insignificant_zeros":false},"currency":{"format":{"format":"%u%n","unit":"$","separator":".","delimiter":",","precision":2,"significant":false,"strip_insignificant_zeros":false}},"percentage":{"format":{"delimiter":"","format":"%n%"}},"precision":{"format":{"delimiter":""}},"human":{"format":{"delimiter":"","precision":3,"significant":true,"strip_insignificant_zeros":true},"storage_units":{"format":"%n %u","units":{"byte":{"one":"Byte","other":"Bytes"},"kb":"KB","mb":"MB","gb":"GB","tb":"TB"}},"decimal_units":{"format":"%n %u","units":{"unit":"","thousand":"Thousand","million":"Million","billion":"Billion","trillion":"Trillion","quadrillion":"Quadrillion"}}}},"errors":{"format":"%{attribute} %{message}","messages":{"inclusion":"is not included in the list","exclusion":"is reserved","invalid":"is invalid","confirmation":"doesn't match %{attribute}","accepted":"must be accepted","empty":"can't be empty","blank":"can't be blank","present":"must be blank","too_long":"is too long (maximum is %{count} characters)","too_short":"is too short (minimum is %{count} characters)","wrong_length":"is the wrong length (should be %{count} characters)","not_a_number":"is not a number","not_an_integer":"must be an integer","greater_than":"must be greater than %{count}","greater_than_or_equal_to":"must be greater than or equal to %{count}","equal_to":"must be equal to %{count}","less_than":"must be less than %{count}","less_than_or_equal_to":"must be less than or equal to %{count}","other_than":"must be other than %{count}","odd":"must be odd","even":"must be even","taken":"has already been taken","already_confirmed":"was already confirmed, please try signing in","confirmation_period_expired":"needs to be confirmed within %{period}, please request a new one","expired":"has expired, please request a new one","not_found":"not found","not_locked":"was not locked","not_saved":{"one":"1 error prohibited this %{resource} from being saved:","other":"%{count} errors prohibited this %{resource} from being saved:"}}},"activerecord":{"errors":{"messages":{"record_invalid":"Validation failed: %{errors}","restrict_dependent_destroy":{"one":"Cannot delete record because a dependent %{record} exists","many":"Cannot delete record because dependent %{record} exist"}}}},"datetime":{"distance_in_words":{"half_a_minute":"half a minute","less_than_x_seconds":{"one":"less than 1 second","other":"less than %{count} seconds"},"x_seconds":{"one":"1 second","other":"%{count} seconds"},"less_than_x_minutes":{"one":"less than a minute","other":"less than %{count} minutes"},"x_minutes":{"one":"1 minute","other":"%{count} minutes"},"about_x_hours":{"one":"about 1 hour","other":"about %{count} hours"},"x_days":{"one":"1 day","other":"%{count} days"},"about_x_months":{"one":"about 1 month","other":"about %{count} months"},"x_months":{"one":"1 month","other":"%{count} months"},"about_x_years":{"one":"about 1 year","other":"about %{count} years"},"over_x_years":{"one":"over 1 year","other":"over %{count} years"},"almost_x_years":{"one":"almost 1 year","other":"almost %{count} years"}},"prompts":{"year":"Year","month":"Month","day":"Day","hour":"Hour","minute":"Minute","second":"Seconds"}},"helpers":{"select":{"prompt":"Please select"},"submit":{"create":"Create %{model}","update":"Update %{model}","submit":"Save %{model}"}},"devise":{"confirmations":{"confirmed":"Your account was successfully confirmed.","send_instructions":"You will receive an email with instructions about how to confirm your account in a few minutes.","send_paranoid_instructions":"If your email address exists in our database, you will receive an email with instructions about how to confirm your account in a few minutes."},"failure":{"already_authenticated":"You are already signed in.","inactive":"Your account is not activated yet.","invalid":"Invalid email or password.","locked":"Your account is locked.","last_attempt":"You have one more attempt before your account will be locked.","not_found_in_database":"Invalid email or password.","timeout":"Your session expired. Please sign in again to continue.","unauthenticated":"You need to sign in or sign up before continuing.","unconfirmed":"You have to confirm your account before continuing."},"mailer":{"confirmation_instructions":{"subject":"Confirmation instructions"},"reset_password_instructions":{"subject":"Reset password instructions"},"unlock_instructions":{"subject":"Unlock Instructions"}},"omniauth_callbacks":{"failure":"Could not authenticate you from %{kind} because \"%{reason}\".","success":"Successfully authenticated from %{kind} account."},"passwords":{"no_token":"You can't access this page without coming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided.","send_instructions":"You will receive an email with instructions on how to reset your password in a few minutes.","send_paranoid_instructions":"If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes.","updated":"Your password was changed successfully. You are now signed in.","updated_not_active":"Your password was changed successfully."},"registrations":{"destroyed":"Bye! Your account was successfully cancelled. We hope to see you again soon.","signed_up":"Welcome! You have signed up successfully.","signed_up_but_inactive":"You have signed up successfully. However, we could not sign you in because your account is not yet activated.","signed_up_but_locked":"You have signed up successfully. However, we could not sign you in because your account is locked.","signed_up_but_unconfirmed":"A message with a confirmation link has been sent to your email address. Please open the link to activate your account.","update_needs_confirmation":"You updated your account successfully, but we need to verify your new email address. Please check your email and click on the confirm link to finalize confirming your new email address.","updated":"You updated your account successfully."},"sessions":{"signed_in":"Signed in successfully.","signed_out":"Signed out successfully."},"unlocks":{"send_instructions":"You will receive an email with instructions about how to unlock your account in a few minutes.","send_paranoid_instructions":"If your account exists, you will receive an email with instructions about how to unlock it in a few minutes.","unlocked":"Your account has been unlocked successfully. Please sign in to continue."},"shared_links":{"reset_password":"Forgot your password?","sign_up":"Sign up","sign_in":"Sign in"}},"hello":"Hello world","om":{"login":{"greeter":"Welcome stranger! Please sign in.","username":"Your username","email":"Your email","login":"Your username or email","password":"Your password"},"register":{"greeter":"Create a new account","username":"Username","email":"Email","password":"Password","password_confirmation":"Password confirm","register":"Sign up"},"navigation":{"inventory":"Inventory","systems":"Systems","services":"Services","logoff":"Exit"},"views":{"system":{"index":{"title":"Overview","new_system":"Add a new system"},"new":{"ip_lookup":{"note":"Start a nmap service scan on given target hostname or IP (\u0026 network) address. Afterwards you may want to create systems and services from the scanresult. \u003Cstrong\u003EBE ADVISED:\u003C/strong\u003E Scanning computer systems and network infrastructure you do not own may violate law.","caption":"Which target to scan?","submit_text":"Start scan","help_text":{"target":"A fully qualified domain name (FQDN) or IP address or network address (CIDR notation)"}},"html_input":{"caption":"Basic information","submit_text":"Create system","help_text":{"fqdn":"A fully qualified domain name (FQDN)","name":"A name easy to remember"}}}}},"forms":{"submit_text":{"new":"Create","update":"Update"}}}};
I18n.translations["de"] = {"hello":"Hello world","devise":{"shared_links":{"reset_password":"Passwort vergessen?","sign_up":"Account erstellen","sign_in":"Anmelden"},"confirmations":{"confirmed":"Vielen Dank für Deine Registrierung. Bitte melde dich jetzt an.","confirmed_and_signed_in":"Vielen Dank für Deine Registrierung. Du bist jetzt angemeldet.","send_instructions":"Du erhältst in wenigen Minuten eine E-Mail, mit der Du Deine Registrierung bestätigen kannst.","send_paranoid_instructions":"Falls Deine E-Mail-Adresse in unserer Datenbank existiert erhältst Du in wenigen Minuten eine E-Mail mit der Du Deine Registrierung bestätigen kannst."},"failure":{"already_authenticated":"Du bist bereits angemeldet.","inactive":"Dein Account ist nicht aktiv.","invalid":"Ungültige Anmeldedaten.","invalid_token":"Der Anmelde-Token ist ungültig.","locked":"Dein Account ist gesperrt.","not_found_in_database":"E-Mail-Adresse oder Passwort ungültig.","timeout":"Deine Sitzung ist abgelaufen, bitte melde Dich erneut an.","unauthenticated":"Du musst Dich anmelden oder registrieren, bevor Du fortfahren kannst.","unconfirmed":"Du musst Deinen Account bestätigen, bevor Du fortfahren kannst."},"mailer":{"confirmation_instructions":{"subject":"Anleitung zur Bestätigung Deines Accounts"},"reset_password_instructions":{"subject":"Anleitung um Dein Passwort zurückzusetzen"},"unlock_instructions":{"subject":"Anleitung um Deinen Account freizuschalten"}},"omniauth_callbacks":{"failure":"Du konntest nicht Deinem %{kind}-Account angemeldet werden, weil '%{reason}'.","success":"Du hast Dich erfolgreich mit Deinem %{kind}-Account angemeldet."},"passwords":{"no_token":"Du kannst diese Seite nur von dem Link aus einer E-Mail zum Passwort-Zurücksetzen aufrufen. Wenn du einen solchen Link aufgerufen hast stelle bitte sicher, dass du die vollständige Adresse aufrufst.","send_instructions":"Du erhältst in wenigen Minuten eine E-Mail mit der Anleitung, wie Du Dein Passwort zurücksetzen kannst.","send_paranoid_instructions":"Falls Deine E-Mail-Adresse in unserer Datenbank existiert erhältst Du in wenigen Minuten eine E-Mail mit der Anleitung, wie Du Dein Passwort zurücksetzen können.","updated":"Dein Passwort wurde geändert. Du bist jetzt angemeldet.","updated_not_active":"Dein Passwort wurde geändert."},"registrations":{"destroyed":"Dein Account wurde gelöscht.","signed_up":"Du hast dich erfolgreich registriert.","signed_up_but_inactive":"Du hast dich erfolgreich registriert. Wir konnten Dich noch nicht anmelden, da Dein Account inaktiv ist.","signed_up_but_locked":"Du hast dich erfolgreich registriert. Wir konnten Dich noch nicht anmelden, da Dein Account gesperrt ist.","signed_up_but_unconfirmed":"Du hast Dich erfolgreich registriert. Wir konnten Dich noch nicht anmelden, da Dein Account noch nicht bestätigt ist. Du erhältst in Kürze eine E-Mail mit der Anleitung, wie Du Deinen Account freischalten kannst.","update_needs_confirmation":"Deine Daten wurden aktualisiert, aber Du musst Deine neue E-Mail-Adresse bestätigen. Du erhälsts in wenigen Minuten eine E-Mail, mit der Du die Änderung Deiner E-Mail-Adresse abschließen kannst.","updated":"Deine Daten wurden aktualisiert."},"sessions":{"signed_in":"Erfolgreich angemeldet.","signed_out":"Erfolgreich abgemeldet."},"unlocks":{"send_instructions":"Du erhältst in wenigen Minuten eine E-Mail mit der Anleitung, wie Du Deinen Account entsperren können.","send_paranoid_instructions":"Falls Deine E-Mail-Adresse in unserer Datenbank existiert erhältst Du in wenigen Minuten eine E-Mail mit der Anleitung, wie Du Deinen Account entsperren kannst.","unlocked":"Dein Account wurde entsperrt. Du bist jetzt angemeldet."}},"errors":{"messages":{"already_confirmed":"wurde bereits bestätigt","confirmation_period_expired":"muss innerhalb %{period} bestätigt werden, bitte fordere einen neuen Link an","expired":"ist abgelaufen, bitte neu anfordern","not_found":"nicht gefunden","not_locked":"ist nicht gesperrt","not_saved":{"one":"Konnte %{resource} nicht speichern: ein Fehler.","other":"Konnte %{resource} nicht speichern: %{count} Fehler."}}},"om":{"login":{"greeter":"Willkommen Fremder! Bitte melde dich an.","username":"Dein Nutzername","email":"Deine E-Mail","login":"Nutzername oder E-Mail","password":"Dein Passwort"},"register":{"greeter":"Erstelle einen neuen Account","username":"Nutzername","email":"E-Mail","password":"Passwort","password_confirmation":"Passwort bestätigen","register":"Account erstellen"},"navigation":{"inventory":"Inventar","systems":"Systeme","services":"Dienste","logoff":"Beenden"},"views":{"system":{"index":{"title":"Systemübersicht","new_system":"Neues System hinzufügen"},"new":{"ip_lookup":{"note":"Füge Systeme und/oder Services durch einen nmap Netzwerkscan hinzu.","caption":"Welche Adresse scannen?","submit_text":"Netzwerkscan starten","help_text":{"target":"Ein vollqualifizierter Hostname (FQDN) oder IP-Adresse oder Netzwerk-Adresse (CIDR Notation)."}},"html_input":{"caption":"Basisinformationen","submit_text":"System erstellen","help_text":{"fqdn":"Ein vollqualifizierter Hostname (FQDN)","name":"Ein einprägsamer Name"}}}}},"forms":{"submit_text":{"new":"Erstellen","update":"Aktualisieren"}}}};
