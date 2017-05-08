var username = 123456789; // Do not store real username into Source code repository!
var password = "my-secret-password"; // Do not store real password into  Source code repository!

var onLoadScript = function(){
  var loginInput = document.getElementsByName("userid")[0];
  var passwordInput = document.getElementsByName("userpwd_page")[0];
  var submit = document.getElementsByClassName("btn-login")[0];
  loginInput.setAttribute("value",username);
  passwordInput.setAttribute("value",password);
  //submit.click();
}

if ( document.readyState === "complete" ) {
  onLoadScript();
}else{
  document.addEventListener('DOMContentLoaded', onLoadScript);
}
