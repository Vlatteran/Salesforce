/*createComponentController.js*/
({
    login : function(component, event, helper) {
        console.log("login success, showing user")
        $A.createComponent(
            "c:showUser",{'user' : component.get("v.user")},
            function(showUser, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body[0] = showUser;
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
    
    doInit : function(component, event, helper) {
        $A.createComponent(
            "c:LogInOrRegister",{
                'user' : component.get("v.user"),
                'parent' : component
            },
            function(LogInOrRegister, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push();
                    body.push(LogInOrRegister);
                    component.set("v.body", body);
                }else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    }
})