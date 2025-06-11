 #include "hbclass.ch"
#define EOC ;; // END OF COMMAND. ALLOWS TO HAVE MORE THAN ONE EXPRESSION ON INDIRECT # DIRECTIVES


// #xcommand ALIGN TO [<alinhamento:center,left>] => alinha(<alinhamento>)
// function teste_alinha()
//     align to CENTRO
// return nil



// references
// C:\harbour\contrib\xhb\cstruct.ch
// C:\harbour\include\hbclass.ch
// C:\harbour\include\std.ch
// https://deepwiki.com/search/write-the-pp-directives-for-a_d1740588-2369-4e7b-831d-c5171e08a9a9

// #xcommand CREATECMD     => #xcommand NEWCMD => QOut("1") EOC QOut("2")
// procedure a()
//     CREATECMD // #xcommand NEWCMD => QOut("1") EOC QOut("2")
//     NEWCMD // QOut("1") ; QOut("2")
// return

// it is possible to inject indirect # directives in any place
// #xcommand CREATECMD     => local b EOC b := "b variable" EOC QOut(b) EOC #xcommand NEWCMD => QOut("1") EOC QOut("2")
// procedure a()
//     CREATECMD // #xcommand NEWCMD => QOut("1") EOC QOut("2")
//     NEWCMD // QOut("1") ; QOut("2")
// return




#define false .f.
#define true .t.

CLASS STRING
    METHOD New()
    method type()
    method type_matches
ENDCLASS

method new() class STRING
return self

method type() class STRING
return "STRING"

method type_matches(t) class STRING
return "STRING" == t:type()

// this pragma create classes using an F# dsl for type
// fsharp: type USAddress = {Street:string; City:string; State:string; Zip:string}
#xcommand TYPE <type_name> = <f1> of <t1> [, <f2> of <t2>] => ;
    CLASS <type_name>;;
        METHOD New(n) ;;
        method type();;
        method type_matches(t);;
        data object ;;
    ENDCLASS;;
        method New(n) class <type_name>;;
            QOUT(HB_JSONENCODE(n));;
            ::object := {;
                "type" => <"type_name">, ;
                "mutable" => n\["mutable"\], ;
                "fields" => ;
                       {;
                        <"f1"> => ;
                            {"type" => <t1>():new():type(),"value" => n\["fields"\]\[<"f1">\]\["value"\]};
                       [,<"f2"> => {"type" => <t2>():new():type(), "value" => n\["fields"\]\[<"f2">\]\["value"\]};
                        ]}};;
        return self;;
    method type() class <type_name>;;
    return upper(<"type_name">) ;;
    method type_matches(t) class <type_name>;;
    return upper(<"type_name">) == t:type();;
    #xcommand let local \<v> of \<t> <f1> \<<f1>v1> [, <f2> \<<f2>v2>] => local \<v> := \<t>():new({"mutable" => false, "fields" => {<"f1"> => {"value" => \<<f1>v1>}[,<"f2"> => {"value" => \<<f2>v2>}]}})
    // ideas for instantiating variables in a more controlable way. this would allow to create immutable variables for example
    // let creates immutable objects
    // #xcommand let local <v> of <t> => local <v> := <t>():new({"type" => "object","mutable" => false, ...})
    // #xcommand let private <v> of <t> => private <v> := <t>():new({"type" => "object","mutable" => false, ...})
    // #xcommand let <v> be <t> => <v> := <v>():set(<t>)
    // // var creates mutable objects
    // #xcommand var local <v> of <t> => local <v> := <t>():new({"type" => "object","mutable" => true, ...})
    // #xcommand var <v> be <t> => <v> := <t>
// // fsharp: type USAddress = {Street:string; City:string; State:string; Zip:string}
type USAddress = Street of STRING, City of STRING
// // fsharp: type UKAddress = {Street:string; Town:string; PostCode:string}
type UKAddress = Street of STRING, Town of STRING, PostCode of STRING
// created to demonstrate what happens when add or remove a type that is part of a union type.
type BRAddress = Street of STRING, City of STRING


procedure experiment_type()
    //{"type" => "USAddress", "mutable" => n["mutable"], "fields" => {{"Street" => {"type" => STRING():new():type(), "value" => n["fields"]["Street"]["value"]}},{"City" => {"type" => STRING():new():type(), "value" => n["fields"["City"]["value"]}}]}}
    let local address of USAddress Street "101st Street", City "California"
    ? address:type()
    ? hb_jsonencode(address:object)
return

// ==========================


// https://fsharpforfunandprofit.com/posts/convenience-types/

// union type
// this pragma create classes using an F# dsl for union type
// and the DSL for fsharp like match. You can often use a discriminated union as a simpler alternative to a small object hierarchy. For example, the following discriminated union could be used instead of a Shape base class that has derived types for circle, square, and so on.
// fsharp syntax
// [ attributes ]
// type [accessibility-modifier] type-name =
//     | case-identifier1 [of [ fieldname1 : ] type1 [ * [ fieldname2 : ] type2 ...]
//     | case-identifier2 [of [fieldname3 : ]type3 [ * [ fieldname4 : ]type4 ...]
//     [ member-list ]

// fsharp example:
// type Address =
//    | US of USAddress
//    | UK of UKAddress

// funcniona at‚ uma cl usula do let matcher address
// #xcommand TYPE <type_name> = UNION <f1> of <t1> [, <f2> of <t2>] => ;
//     CLASS <type_name>;;
//         METHOD New() ;;
//         method type();;
//         data fields ;;
//         data union ;;
//     ENDCLASS;;
//         method New() class <type_name>;;
//             ::union := {"fields" => {{"field" => <"f1">, "type" => <t1>():new():type()}[,{"field" => <"f2">, "type" => <t2>():new():type()}]}};;
//         return self;;
//     method type() class <type_name>;;
//     return upper(<"type_name">) ;;
//     #xcommand let Matcher \<type_name> = match \<var_to_match> with ;
//         WHEN \<t1> -> \<caselambda1> ;
//         [;WHEN \<t2> -> \<caselambda1>] ;
//             => ;
// function ___Matcher\<type_name>(\<var_to_match>) EOC ;
//                 do case EOC ;
//                     case \<t1>():new():type_matches(\<var_to_match>) //EOC \<caselambda1>  \[;xxWHEN \<t2> -> \<caselambda1>] ;
//                             // \[,case \<t2>():new():type_matches(\<var_to_match>) EOC \<caselambda2>] EOC ;


// type Address = UNION US of USAddress, UK of UKAddress//, BR of BRAddress

//  let Matcher Address = match address with ;
//      WHEN USAddress -> qout("This is a US Address")// ;
//     //  WHEN UKAddress -> qout("This is a UK Address")
// //     // WHEN UndefinedAddress -> qout("should raise compiler error") // how could I place a compiler directive #error here?



// type Address = UNION v1
// #xcommand TYPE <type_name> = UNION <f1> of <t1> [, <f2> of <t2>] => ;
//     CLASS <type_name>;;
//         METHOD New() ;;
//         method type();;
//         data fields ;;
//         data union ;;
//     ENDCLASS;;
//          method New() class <type_name>;;
//              ::union := {{"field" => <"f1">, "type" => <t1>():new():type()} [,{"field" => <"f2">, "type" => <t2>():new():type()}]};;
//          return self;;
//     method type() class <type_name>;;
//     return upper(<"type_name">)
// type Address = UNION US of USAddress, UK of UKAddress, BR of BRAddress

// this directive works for let matcher v1
// #xcommand let Matcher <type_name> = match <var_to_match> with ;
//      WHEN <t1> -> <caselambda1> ;
//      [,WHEN <t2> -> <caselambda2>]=> ;
//      function ___Matcher<type_name>(<var_to_match>) ;;
//      do case ;;
//          case <t1>():new():type_matches(<var_to_match>) ;;
//             <caselambda1> ;;
//          [;case <t2>():new():type_matches(<var_to_match>) ; <caselambda2>] ;;
//      end ;;
//      return nil
//
//  let Matcher Address = match address with ;
//     WHEN USAddress -> qout("This is a US Address"), ;
//     WHEN UKAddress -> qout("This is a UK Address"), ;
//     WHEN BRAddress -> qout("This is a BT Address")
//     WHEN UndefinedAddress -> qout("should raise compiler error") // how could I place a compiler directive #error here?

// // type Address = UNION + let matcher v1
// #xcommand TYPE <type_name> = UNION <f1> of <t1> [, <f2> of <t2>] => ;
//     CLASS <type_name>;;
//         METHOD New() ;;
//         method type();;
//         data fields ;;
//         data union ;;
//     ENDCLASS;;
//          method New() class <type_name>;;
//              ::union := {{"field" => <"f1">, "type" => <t1>():new():type()} [,{"field" => <"f2">, "type" => <t2>():new():type()}]};;
//          return self;;
//     method type() class <type_name>;;
//     return upper(<"type_name">)  ;;
//     #xcommand let Matcher <type_name> = match \<var_to_match> with WHEN <t1> -> \<caselambda<t1>> [, WHEN <t2> -> \<caselambda<t2>>] => ;
//         function ___Matcher_<type_name>(\<var_to_match>) EOC ;
//         do case EOC;
//             case <t1>():new():type_matches(\<var_to_match>) EOC;
//                 \<caselambda<t1>> ;
//             [EOC case <t2>():new():type_matches(\<var_to_match>) ] EOC ; 
//         end EOC ;
//         return nil


// type Address = UNION + let matcher v2
#xcommand TYPE <type_name> = UNION <f1> of <t1> [, <f2> of <t2>] => ;
    CLASS <type_name>;;
        METHOD New() ;;
        method type();;
        data fields ;;
        data union ;;
    ENDCLASS;;
         method New() class <type_name>;;
             ::union := {{"field" => <"f1">, "type" => <t1>():new():type()} [,{"field" => <"f2">, "type" => <t2>():new():type()}]};;
         return self;;
    method type() class <type_name>;;
    return upper(<"type_name">)  ;;
    #xcommand let Matcher \<matcher_name> of <type_name> = match \<*x*> => #warning match <type_name> is not exausted. ;;
    #xcommand let Matcher \<matcher_name> of <type_name> = match \<var_to_match> with WHEN <t1> -> \<caselambda<t1>> [, WHEN <t2> -> \<caselambda<t2>>] => ;
        function ___Matcher_\<matcher_name>(\<var_to_match>) EOC ;
        do case EOC;
            case <t1>():new():type_matches(\<var_to_match>) EOC;
                \<caselambda<t1>> ;
            [EOC case <t2>():new():type_matches(\<var_to_match>) ] EOC ; 
        end EOC ;
        return nil ;;
    #xcommand MATCH \<matcher_name> \<v> => ___Matcher_\<matcher_name>(\<v>)
            
// fsharp like DSL for union type
type Address = UNION US of USAddress, UK of UKAddress, BR of BRAddress

// fsharp like DSL for matcher
let Matcher AddressMatcher1 of Address = match address with ;
    WHEN USAddress -> qout("This is a US Address"), ;
    WHEN UKAddress -> qout("This is a UK Address"), ;
    WHEN BRAddress -> qout("This is a BT Address")


let Matcher AddressMatcher2 of Address = match address2 with ;
    WHEN USAddress -> qout("This is a US Address"), ;
    WHEN UKAddress -> qout("This is a UK Address") //         W0001  match Address is not exausted.


procedure main()
    experiment_type()
    experiment_match()
return

procedure experiment_match()
    let local address of USAddress Street "101st Street", City "California"
    MATCH AddressMatcher1 address
    // ideally, a compiler error should be raised when a type different than the defined on the matcher is passed here.
    // this should be illegal
    MATCH AddressMatcher1 "a" 
return

// ===========================
// experiment with matching
// this works to invalidate any let Matcher Address = match.
// I hope that this will give me a better control over the compiler error messages.
// #xcommand let Matcher <type_name> = match <*x*> => #warning match <type_name> is not exausted.

// let Matcher Address = match address with ;
//     WHEN USAddress -> qout("This is a US Address"), ;
//     WHEN UKAddress -> qout("This is a UK Address"), ;
//     WHEN BRAddress -> qout("This is a BT Address")
// ===========================

// ===========================
// experiment with matching
// #xcommand let Matcher Address = match <var_to_match> with WHEN USAddress -> <caselambdaUSAddress>, WHEN UKAddress -> <caselambdaUKAddress>, WHEN BRAddress -> <caselambdaBRAddress> => procedure experiment() ; qout("hello") ; return
//
// let Matcher Address = match address with ;
//     WHEN USAddress -> qout("This is a US Address"), ;
//     WHEN UKAddress -> qout("This is a UK Address"), ;
//     WHEN BRAddress -> qout("This is a BT Address")
// ===========================

// ===========================
// experiment with matching
// #xcommand let Matcher Address = match <var_to_match> with WHEN <v> -> <l> [,WHEN <v> -> <l>] => procedure experiment() ; qout("hello") ; return
//
// let Matcher Address = match address with ;
//     WHEN USAddress -> qout("This is a US Address"), ;
//     WHEN UKAddress -> qout("This is a UK Address"), ;
//     WHEN BRAddress -> qout("This is a BT Address")
// ===========================


// ===========================
// gives syntax error if using an invalid when clause but it is not exhaustive.
// #xcommand let Matcher Address = match <var_to_match> with WHEN <when_clause:USAddress,UKAddress,BRAddress> -> <l> [,WHEN <when_clause_2:USAddress,UKAddress,BRAddress> -> <l_2>] => procedure experiment() ; qout("hello") ; return
// let Matcher Address = match address with ;
//     WHEN USAddress -> qout("This is a US Address"), ;
//     WHEN UKAddress -> qout("This is a UK Address")
// ===========================


// , ;
//     WHEN UndefinedAddress -> qout("should raise compiler error") // how could I place a compiler directive #error here?


// quando tirei o [#] do xcommand para testar, produziu:
// xcommand let Matcher Address = match <var_to_match> with ;
//     WHEN USAddress -> <caselambda1> ;
//     ,WHEN UKAddress -> <caselambda2>;
//     ,WHEN BRAddress -> <caselambda2> => ;;
//     function ___MatcherAddress(<var_to_match>) ;
//         do case ;
//             case USAddress():new():type_matches(<var_to_match>) ;
//                 <caselambda1> ; ;
//             case UKAddress():new():type_matches(<var_to_match>) ;
//                 <caselambda2> ;
//             case BRAddress():new():type_matches(<var_to_match>) ;
//                 <caselambda2> ;
//         end ;
//     return nil

// precisei corrigir
// #xcommand let Matcher Address = match <var_to_match> with ;
//     WHEN USAddress -> <caselambda1> ;
//     ,WHEN UKAddress -> <caselambda2>;
//     ,WHEN BRAddress -> <caselambda3> => ;
//     function ___MatcherAddress(<var_to_match>) ;;
//         do case ;;
//             case USAddress():new():type_matches(<var_to_match>) ;;
//                 <caselambda1> ;;
//             case UKAddress():new():type_matches(<var_to_match>) ;; 
//                 <caselambda2> ;;
//             case BRAddress():new():type_matches(<var_to_match>) ;;
//                 <caselambda3> ;;
//         end ;;
//     return nil






















// #xcommand TYPE <type_name> = UNION <case_identifier1> OF <type1> [, <case_identifier2> OF <type2>] => ;
//     CLASS <type_name> ;;
//         DATA <case_identifier1> ;;
//      [;DATA <case_identifier2>] ;;
//      ENDCLASS ;;
//      #xcommand let Matcher\<type_name> = match \<var_to_match> with ;
//         WHEN \<type1> -> \<caselambda1> ;
//         \[WHEN \<type2> -> \<caselambda2>\] ;
//         => ;
//         function ___Matcher\<type_name>(\<var_to_match>) EOC ;
//             do case EOC ;
//                 case <type1>():new():type_matches(\<var_to_match>) EOC \<caselambda1> EOC ;
//                 \[case <type2>():new():type_matches(\<var_to_match>) EOC \<caselambda2>\] EOC ;
    
    
//     // \<type_name> = EOC ;
//     // match \<var_to_match> with => EOC ;
//     //     function ___Matcher\<type_name> var_to_match EOC;


// // #xcommand let Matcher Address = match <var_to_match> with ;
// //     WHEN USAddress -> <case1lambda> ;
// //     WHEN UKAddress -> <case2lambda> ;
// //     => ;
// //     function _MatcherAddress(<var_to_match>) ;;
// //     do case;;  
// //         case USAddress():new():type_matches(<var_to_match>);;  
// //             <case1lambda>;;  
// //         [case UKAddress():new():type_matches(<var_to_match>);;  
// //             <case2lambda>;;];;
// //         end;;
// //         return nil;;

// type Address = UNION US of USAddress, UK of UKAddress, BR of BRAddress

// let Matcher Address = match address with ;
//     WHEN USAddress -> qout("This is a US Address") ;
//     WHEN UKAddress -> qout("This is a UK Address")
//     // WHEN UndefinedAddress -> qout("should raise compiler error") // how could I place a compiler directive #error here?


// // /*
// // CLASS Address
// //     DATA US
// //     DATA UK
// // ENDCLASS
// // */

// // // DSL for fsharp like match. You can often use a discriminated union as a simpler alternative to a small object hierarchy. For example, the following discriminated union could be used instead of a Shape base class that has derived types for circle, square, and so on.
// // #command let <vmethod> <vvar> = match <discard> with WHEN <case_identifier1> -> <case1lambda> [WHEN <case_identifier2> -> <case2lambda>] => ;  
// // function <vmethod>(<vvar>);;  
// //     do case;;  
// //         case <case_identifier1>:new():type_matches(<vvar>);;  
// //             <case1lambda>;;  
// //         [case <case_identifier2>:new():type_matches(<vvar>);;  
// //             <case2lambda>;;];;
// //         end;;
// //         return nil;;

// // // Instead of a virtual method to compute an area or perimeter, as you would use in an object-oriented implementation, you can use pattern matching to branch to appropriate formulas to compute these quantities. In the following example, different formulas are used to compute the area, depending on the shape.
// // // used WHEN here because | did not work

// // match working. need to create directive the factory
// // #xcommand let Matcher Address = match <var_to_match> with ;
// //     WHEN USAddress -> <case1lambda> ;
// //     WHEN UKAddress -> <case2lambda> ;
// //  => ;
// //     function _MatcherAddress(<var_to_match>) ;;
// //     do case;;  
// //         case USAddress():new():type_matches(<var_to_match>);;  
// //             <case1lambda>;;  
// //         [case UKAddress():new():type_matches(<var_to_match>);;  
// //             <case2lambda>;;];;
// //         end;;
// //         return nil;;


// let Matcher Address =  match address with ;
//         WHEN USAddress -> qout("This is a US Address") ;
//         WHEN UKAddress -> qout("This is a UK Address")
//         WHEN UndefinedAddress -> qout("should raise compiler error") // how could I place a compiler directive #error here?







// // // For now, I use simple assignment, but I intend to use classes to validate type contracts. something like
// // // #command let <var> = <var_contents> => <var>:setValue(<var_contents>) // and this will raise error if the type contract is not fullfilled. 
// // #command let <var> = <var_contents> => <var> := <var_contents>
// // PROCEDURE Main()
// //     local my_address
// //     let my_address = Address():new()
// //     matcher Address my_address
// // return

// // // // este c¢digo ‚ ser interessante por ter controle c¡clico nos pragmas
// // // // Ele avisa via em tempo de compila‡Æo ao realizar um case inesperado.
// // // function compiler_should_raise_error_on_invalid_case(employee)
// // //     // por brevidade, nÆo criei as diretivas pra o match, mas aqui estou simulando:
// // //     // match my_payment as PAYMENT. isso criaria as seguintes diretivas:
// // //     #command case <var1> => ;
// // //         #warning "invalid" ; <@> case <var1>
// // //     // aqui fa‡o a suposi‡Æo que typeof usa string para verificar o tipo, mas isso pode ser usado de outras formas, incluindo invocando a classe. ex.: Money():new():type
// // //     #command case MONEY [<var1>] => ;
// // //             DECLARED case typeof(my_payment,"MONEY") [<var1>]
// // //     #command case CREDIT_CARD [<var1>] => ;
// // //             DECLARED case typeof(my_payment,"CREDIT_CARD") [<var1>]
// // //     #command DECLARED case [<var1>] => ;
// // //             <@> case [<var1>]
// // //     do case
// // //         case MONEY
// // //             ? "MONEY"
// // //         case MONEY .and. my_payment:value > 0
// // //             ? "MONEY .and. my_payment:value > 0"
// // //         case INVALID_PAYMENT
// // //             // should render compiler error
// // //         case CREDIT_CARD .and. my_payment:value > 0
// // //             ? "CREDIT_CARD .and. my_payment:value > 0"
// // //     endcase
// // // return nil
// // // // endregion recursividade, referˆncia c¡clica, referencia ciclica