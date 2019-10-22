:namespace swapi
 ⍝ A namespace to cover swapi - the Star Wars API ( http://swapi.co )
 ⍝ written by Michael Baas
 ⍝ Usage:
 ⍝ 1) swapi.get''                                ⍝ list all resources (returns vector of vectors)
 ⍝ 2) swapi.get resource                         ⍝ returns one namespace for every object found
 ⍝ 3) id swapi.get resource                      ⍝ returns a specific resource
 ⍝ 4) 'schema' swapi.get resource                ⍝ returns schema for given resource
 ⍝ 5) '?search=Darth'#.swapi.get'people'         ⍝ search for a record ( https://swapi.co/documentation#search )
 ⍝ 6) swapi.get'https://swapi.co/api/planets/1/' ⍝ "raw" mode to directly give a URL (perhaps pass .url from another result)

    BaseURL←'https://swapi.co/api/'


    ∇ R←{spec}get obj;r;res;url;done;R1
      ⎕SE.UCMD'←load HttpCommand'  ⍝ load library (← means: quiet, no output)
      R←⍬
      url←BaseURL{∨/'https://'⍷0(819⌶)⍵:⍵ ⋄ ⍺,⍵,(0<≢⍵)/'/'}obj
      :If (0<≢obj)∧2=⎕NC'spec' ⋄ url,←⍕spec ⋄ :EndIf
     
      :Repeat
          res←HttpCommand.Get url
          r←⎕JSON res.Data
          :If ~done←(⊂'null')≡{0::⊂'null' ⋄ ⍵.next}r
              :If done←0=≢obj                      ⍝ special case: empty argument indicates user asks for list of root
                  R←{2⊃⎕NPARTS ¯1↓⍵}¨r.(⍎¨⎕NL ¯2)  ⍝ return the last level of the path given by URL
              :Else
                  url←r.next
                  R,←r.results
              :EndIf
          :Else
              R←R,{6::⍵ ⋄ ⍵.results}r
          :EndIf
      :Until done=1
     
      R1←1⊃,R                          ⍝ get first element of result
      :If 9=⎕NC'R1'                    ⍝ check if it is an object (and not a vtv as in case 1)
      :AndIf 2=(1⊃,R).⎕NC'url'         ⍝ and it has a url-field
          {⍵.id←2⊃⎕NPARTS ¯1↓⍵.url}¨R  ⍝ Add an "id"-field to the records (yeah, it's not HATEOAS, but convenient when learning the API)
      :EndIf                           ⍝ see https://github.com/phalt/swapi/issues/84 and https://en.wikipedia.org/wiki/HATEOAS
    ∇
:endnamespace
