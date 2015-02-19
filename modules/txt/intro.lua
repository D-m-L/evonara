function initMsgs()
  m = {}
  m[1] = _navi:new('Alright!|,|, Here is our |c{mblue}message system|c{white}|,, working |c{mblue}CORRECTLY|c{white}|,. |nPress |c{mgreen}'..arc.btn.ent..'|c{white} to continue.',
    {x=sw/2, y=sh/2, alx='m', alxb='m', alyb='m', wbox=sw/2})
  m[2] = _navi:new("Let's see the features. Consult |c{mred}main.lua|c{white} to  understand some of the options.|nFor a more complete review, see the |c{mred}manual.txt|c{white}.|mWe can |c{mgreen}change text color|c{white}, add pauses,|: and start text |non a new line. We can also request a keypress,|! and finally, continue the message|min the next message box. All done using string |c{mpurple}formatters|c{white}.",
    {x=sw/2, y=sh/2, alx='m', alxb='m', alyb='m', nrows=2, wbox=sw/2})
  m[3] = _navi:new('For instance, add a picture or set the width, or number of rows.',
    {x=10, y = sh/2, wbox=sw/2, nrows=3, name='litearc', face=litearc.face, face_pos = 'r'})
  m[4] = _navi:new('|c{mblue}Some messages cannot be skipped. This may be good for certain cutscenes where timing is important.',
    {x=sw/2, y = sh/2, alx='m', alxb='m', alyb='m', wbox=sw, box=false, skip=false, wait=2})
  m[5] = _navi:new("Let's see.|,.|,.|, Pick your favorite color:",
    {x=10, y = sh/2, wbox=300, nrows=4, name='litearc', face=img.avatar, nvchs=3,
      choices={	'green',
        'blue',
        "yellow",}})
  m_correct = _navi:new('Correct! |,|,...', 
    {x=160, y=140, w=160, alxb='m', alyb='m'})
  m_wrong = _navi:new('Nope, sorry!', {x=160, y=140, w=100, alxb='m', alyb='m'})
  m2 = _navi:new('Anyway, that\'s it! Again, read the manual for more info as I didn\'t show off everything. And please report any bugs or give suggestions in the forum topic (see the |c{mred}manual.txt|c{white} file for a link). Thanks!',
    {x=160, y=140, alxb='m', alyb='m', w=200})
end