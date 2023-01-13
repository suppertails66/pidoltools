set -o errexit

#soffice --headless --convert-to ods --infilter=CSV:44,34,64 $file

#mkdir -p test
#soffice --headless --convert-to csv --infilter=CSV:44,34,64 "yuna_script.ods" 
#soffice --headless --convert-to csv:"Text - txt - csv (StarCalc)" "yuna_script.ods"
#soffice --headless --convert-to xlsx --outdir test yuna_script.ods

cd script
#soffice --headless --convert-to csv --infilter=CSV:44,34,76 --outdir test yuna_script.ods
#soffice --headless --convert-to csv --infilter=CSV:44,34,76 script.xlsx
soffice --headless --convert-to csv --infilter=CSV:44,34,64 script_main.ods
soffice --headless --convert-to csv --infilter=CSV:44,34,64 script_advscene.ods
soffice --headless --convert-to csv --infilter=CSV:44,34,64 script_visual.ods
soffice --headless --convert-to csv --infilter=CSV:44,34,64 script_misc.ods
soffice --headless --convert-to csv --infilter=CSV:44,34,64 script_8x8.ods
soffice --headless --convert-to csv --infilter=CSV:44,34,64 script_credits.ods
soffice --headless --convert-to csv --infilter=CSV:44,34,64 script_creditstext.ods
soffice --headless --convert-to csv --infilter=CSV:44,34,64 script_backutil.ods
