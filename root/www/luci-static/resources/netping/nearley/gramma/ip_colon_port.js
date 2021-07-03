// Generated automatically by nearley, version 2.20.1
// http://github.com/Hardmath123/nearley
(function () {
function id(x) { return x[0]; }
var grammar = {
    Lexer: undefined,
    ParserRules: [
    {"name": "MAIN", "symbols": ["IP", {"literal":":"}, "PORT"]},
    {"name": "IP", "symbols": ["NUMBER", {"literal":"."}, "NUMBER", {"literal":"."}, "NUMBER", {"literal":"."}, "NUMBER"]},
    {"name": "NUMBER", "symbols": ["From_0_to_255"]},
    {"name": "From_0_to_255", "symbols": [/[0-9]/]},
    {"name": "From_0_to_255", "symbols": [/[1-9]/, /[0-9]/]},
    {"name": "From_0_to_255", "symbols": [{"literal":"1"}, /[0-9]/, /[0-9]/]},
    {"name": "From_0_to_255", "symbols": [{"literal":"2"}, /[0-5]/, /[0-5]/]},
    {"name": "PORT", "symbols": [/[0-9]/]},
    {"name": "PORT", "symbols": [/[1-9]/, /[0-9]/]},
    {"name": "PORT", "symbols": [/[1-9]/, /[0-9]/, /[0-9]/]},
    {"name": "PORT", "symbols": [/[1-9]/, /[0-9]/, /[0-9]/, /[0-9]/]},
    {"name": "PORT", "symbols": [/[1-5]/, /[0-9]/, /[0-9]/, /[0-9]/, /[0-9]/]},
    {"name": "PORT", "symbols": [{"literal":"6"}, /[0-5]/, /[0-5]/, /[0-3]/, /[0-5]/]}
]
  , ParserStart: "MAIN"
}
if (typeof module !== 'undefined'&& typeof module.exports !== 'undefined') {
   module.exports = grammar;
} else {
   window.ip_colon_port = grammar;
}
})();
