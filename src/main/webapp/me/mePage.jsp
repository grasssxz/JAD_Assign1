<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.time.*, java.time.format.*" %>


<%! 
  public String generateCode() {
      return java.util.UUID.randomUUID()
               .toString()
               .replace("-", "")
               .substring(0, 12);
  }
%>
<%
/* ===============================
   1. DB CONNECTION
================================*/
Class.forName("com.mysql.cj.jdbc.Driver");
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";
Connection conn = DriverManager.getConnection(connURL);

String ctx = request.getContextPath();

/* ===============================
   2. GET LOGGED-IN MEMBER
================================*/
Integer memberId = (Integer) session.getAttribute("member_id");
String username = (String) session.getAttribute("username");

if (memberId == null || username == null) {
    response.sendRedirect(ctx + "/login/login.html");
    return;
}

/* ===============================
   3. LOAD USER INFO (profile + family_id)
================================*/
String profilePic = ctx + "/home/Images/profile.jpg";
Integer familyId = null;
String message = null;

PreparedStatement psUser = conn.prepareStatement(
    "SELECT id, profile_pic, family_id, status FROM member WHERE id=?"
);
psUser.setInt(1, memberId);
ResultSet rsUser = psUser.executeQuery();

if (rsUser.next()) {
	String pp = rsUser.getString("profile_pic");
	if (pp != null && !pp.isEmpty()) {
	    profilePic = ctx + "/home/Images/" + pp;
	}

	// FIX: family_id may be BIGINT → must cast safely
	Object famObj = rsUser.getObject("family_id");
	if (famObj != null) {
	    familyId = ((Number) famObj).intValue();
	}

	String status = rsUser.getString("status");

    if ("deactivated".equalsIgnoreCase(status)) {
        message = "Your account is deactivated. Please contact admin.";
    }

}
rsUser.close();
psUser.close();

/* ===============================
   4. HANDLE ACTIONS
================================*/
String action = request.getParameter("action");


/* PROFILE UPDATE (username / password)*/
if ("updateUsername".equals(action)) {
 String newUsername = request.getParameter("new_username");

 if (newUsername == null || newUsername.trim().isEmpty()) {
     message = "Username cannot be empty.";
 } else {
     // check duplicate username
     PreparedStatement psCheckU = conn.prepareStatement(
         "SELECT COUNT(*) FROM member WHERE username=? AND id<>?"
     );
     psCheckU.setString(1, newUsername.trim());
     psCheckU.setInt(2, memberId);
     ResultSet rsCheckU = psCheckU.executeQuery();

     int cnt = 0;
     if (rsCheckU.next()) cnt = rsCheckU.getInt(1);
     rsCheckU.close();
     psCheckU.close();

     if (cnt > 0) {
         message = "Username already taken. Choose another.";
     } else {
         PreparedStatement psUpU = conn.prepareStatement(
             "UPDATE member SET username=? WHERE id=?"
         );
         psUpU.setString(1, newUsername.trim());
         psUpU.setInt(2, memberId);
         psUpU.executeUpdate();
         psUpU.close();

         // update session so page shows new name immediately
         session.setAttribute("username", newUsername.trim());
         username = newUsername.trim();
         out.print("<script>alert('Username updated successfully.'); window.location.href='mePage.jsp';</script>");
         return;
     }
 }
}

if ("updatePassword".equals(action)) {
 String oldPass = request.getParameter("old_password");
 String newPass = request.getParameter("new_password");
 String confirmPass = request.getParameter("confirm_password");

 if (oldPass == null || newPass == null || confirmPass == null ||
     oldPass.isEmpty() || newPass.isEmpty() || confirmPass.isEmpty()) {
     message = "Please fill in all password fields.";
 } else if (!newPass.equals(confirmPass)) {
     message = "New password and confirm password do not match.";
 } else {
     // get current password from DB
     PreparedStatement psGetP = conn.prepareStatement(
         "SELECT password FROM member WHERE id=?"
     );
     psGetP.setInt(1, memberId);
     ResultSet rsGetP = psGetP.executeQuery();

     String currentPass = null;
     if (rsGetP.next()) currentPass = rsGetP.getString("password");
     rsGetP.close();
     psGetP.close();

     if (currentPass == null || !currentPass.equals(oldPass)) {
         message = "Old password is incorrect.";
     } else {
         PreparedStatement psUpP = conn.prepareStatement(
             "UPDATE member SET password=? WHERE id=?"
         );
         psUpP.setString(1, newPass);
         psUpP.setInt(2, memberId);
         psUpP.executeUpdate();
         psUpP.close();

         out.print("<script>alert('password updated successfully.'); window.location.href='mePage.jsp';</script>");
         return;     }
 }
}


/* A) CREATE FAMILY */
if ("createFamily".equals(action)) {
    if (familyId != null) {
        message = "You are already in a family.";
    } else {
        String newCode = generateCode();

        PreparedStatement psFam = conn.prepareStatement(
            "INSERT INTO family (family_code, created_by) VALUES (?, ?)",
            Statement.RETURN_GENERATED_KEYS
        );
        psFam.setString(1, newCode);
        psFam.setInt(2, memberId);
        psFam.executeUpdate();

        int newFamilyId = -1;
        ResultSet rsKey = psFam.getGeneratedKeys();
        if (rsKey.next()) newFamilyId = rsKey.getInt(1);
        rsKey.close();
        psFam.close();

        if (newFamilyId > 0) {
            PreparedStatement psJoin = conn.prepareStatement(
                "UPDATE member SET family_id=? WHERE id=?"
            );
            psJoin.setInt(1, newFamilyId);
            psJoin.setInt(2, memberId);
            psJoin.executeUpdate();
            psJoin.close();

            familyId = newFamilyId;
            message = "Family created! Your family code is: " + newCode;
        }
    }
}

/* B) JOIN FAMILY */
if ("joinFamily".equals(action)) {
    if (familyId != null) {
        message = "You are already in a family.";
    } else {
        String inputCode = request.getParameter("family_code");

        PreparedStatement psFind = conn.prepareStatement(
            "SELECT id FROM family WHERE family_code=?"
        );
        psFind.setString(1, inputCode);
        ResultSet rsFind = psFind.executeQuery();

        if (rsFind.next()) {
            int foundFamilyId = rsFind.getInt("id");

            PreparedStatement psJoin = conn.prepareStatement(
                "UPDATE member SET family_id=? WHERE id=?"
            );
            psJoin.setInt(1, foundFamilyId);
            psJoin.setInt(2, memberId);
            psJoin.executeUpdate();
            psJoin.close();

            familyId = foundFamilyId;
            message = "Joined family successfully!";
        } else {
            message = "Invalid family code.";
        }

        rsFind.close();
        psFind.close();
    }
}

/* C) Leave family */
if ("leaveFamily".equals(action)) {

    if (familyId == null) {
        message = "You are not in a family.";
    } else {

        // 1. Remove user from family
        PreparedStatement psLeave = conn.prepareStatement(
            "UPDATE member SET family_id = NULL WHERE id = ?"
        );
        psLeave.setInt(1, memberId);
        psLeave.executeUpdate();
        psLeave.close();

        // 2. Check if family is now empty
        PreparedStatement psCount = conn.prepareStatement(
            "SELECT COUNT(*) FROM member WHERE family_id = ?"
        );
        psCount.setInt(1, familyId);
        ResultSet rsCount = psCount.executeQuery();

        int count = 0;
        if (rsCount.next()) count = rsCount.getInt(1);

        rsCount.close();
        psCount.close();

        // 3. Delete family if empty
        if (count == 0) {
            PreparedStatement psDeleteFam = conn.prepareStatement(
                "DELETE FROM family WHERE id = ?"
            );
            psDeleteFam.setInt(1, familyId);
            psDeleteFam.executeUpdate();
            psDeleteFam.close();
        }

        // 4. Reset local variable
        familyId = null;
        message = "You have left the family.";
    }
}


/* ===============================
   5. IF IN FAMILY: LOAD FAMILY CODE + MEMBERS
================================*/
String familyCode = null;
List<String> familyMembers = new ArrayList<>();

if (familyId != null) {
    // get code
    PreparedStatement psCode = conn.prepareStatement(
        "SELECT family_code FROM family WHERE id=?"
    );
    psCode.setInt(1, familyId);
    ResultSet rsCode = psCode.executeQuery();
    if (rsCode.next()) familyCode = rsCode.getString("family_code");
    rsCode.close();
    psCode.close();

    // get all family members
    PreparedStatement psMembers = conn.prepareStatement(
        "SELECT username FROM member WHERE family_id=? AND status='activated' ORDER BY username"
    );
    psMembers.setInt(1, familyId);
    ResultSet rsMembers = psMembers.executeQuery();
    while (rsMembers.next()) {
        familyMembers.add(rsMembers.getString("username"));
    }
    rsMembers.close();
    psMembers.close();
}


%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Me Page</title>

<style>
body{font-family:Arial;background:#f6f7fb;margin:0;padding:0}
.container{max-width:650px;margin:20px auto;background:#fff;padding:20px;border-radius:14px;box-shadow:0 3px 10px rgba(0,0,0,0.1)}
.profile{display:flex;align-items:center;gap:14px}
.profile img{width:70px;height:70px;border-radius:50%;object-fit:cover}
h2{margin:0}
.msg{margin:12px 0;color:#c0392b;font-weight:600}

.section{margin-top:20px;padding-top:14px;border-top:1px solid #eee}
button{background:#7f9cf5;color:white;border:none;padding:8px 14px;border-radius:8px;cursor:pointer}
button:hover{background:#5e7ce0}
input[type=text]{padding:8px;width:70%;border:1px solid #ccc;border-radius:6px}
.member-list{margin-top:10px}
.member-chip{display:inline-block;background:#eef0ff;padding:6px 10px;border-radius:20px;margin:4px;font-size:14px}
.code-box{font-weight:700;background:#faf9d7;padding:8px 12px;border-radius:8px;display:inline-block}

/for leave family btn/
.danger-btn {
  background:#e15858;
  color:white;
  border:none;
  padding:10px 16px;
  border-radius:8px;
  cursor:pointer;
}
.danger-btn:hover {
  background:#c14141;
}

input[type=password]{
  padding:8px;
  width:70%;
  border:1px solid #ccc;
  border-radius:6px;
}

</style>
</head>

<body>

<jsp:include page="/home/NavBar.jsp"/>

<div class="container">

  <!-- Profile -->
  <div class="profile">
    <img src="<%= profilePic %>">
    <div>
      <h2><%= username %></h2>
      <p>Member ID: <%= memberId %></p>
    </div>
  </div>

  <% if (message != null) { %>
    <div class="msg"><%= message %></div>
  <% } %>
  
  <!-- Profile Settings -->
<div class="section">
  <h3>Profile Settings</h3>

  <!-- Change Username -->
  <form method="post" action="mePage.jsp" style="margin-bottom:16px;">
    <input type="hidden" name="action" value="updateUsername">

    <label>Current Username:</label><br>
    <input type="text" value="<%= username %>" disabled><br><br>

    <label>New Username:</label><br>
    <input type="text" name="new_username" required>
    <button type="submit" style="margin-left:8px;">Update Username</button>
  </form>

  <hr style="border:0;border-top:1px solid #eee;margin:14px 0;">

  <!-- Change Password -->
  <form method="post" action="mePage.jsp">
    <input type="hidden" name="action" value="updatePassword">

    <label>Old Password:</label><br>
    <input type="password" name="old_password" required><br><br>

    <label>New Password:</label><br>
    <input type="password" name="new_password" required><br><br>

    <label>Confirm New Password:</label><br>
    <input type="password" name="confirm_password" required><br><br>

    <button type="submit">Update Password</button>
  </form>
</div>
  

  <!-- Family Section -->
  <div class="section">
    <h3>My Family</h3>

    <% if (familyId == null) { %>

      <p>You are not in a family yet.</p>

      <!-- Create Family -->
      <form method="post" action="mePage.jsp">
        <input type="hidden" name="action" value="createFamily">
        <button type="submit">Create Family</button>
      </form>

      <br>

      <!-- Join Family -->
      <form method="post" action="mePage.jsp">
        <input type="hidden" name="action" value="joinFamily">
        <label>Enter family code:</label><br>
        <input type="text" name="family_code" required>
        <button type="submit">Join Family</button>
      </form>

    <% } else { %>

      <p>Your family code:</p>
      <div class="code-box"><%= familyCode %></div>

      <div class="member-list">
        <p><strong>Family Members:</strong></p>
        <% for(String m : familyMembers){ %>
          <span class="member-chip"><%= m %></span>
        <% } %>
        <form method="post" action="mePage.jsp" onsubmit="return confirm('Are you sure you want to leave your family?');">
    <input type="hidden" name="action" value="leaveFamily">
    <button type="submit" style="background:#e15858;color:white;border:0;padding:8px 14px;border-radius:8px;">
        Leave Family
    </button>
</form>
        
      </div>

    <% } %>
  </div>

</div>

<%
conn.close();
%>

</body>
</html>