
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>
<jsp:include page="/auth/AuthCheckAdmin.jsp" />

<%
Class.forName("com.mysql.cj.jdbc.Driver");
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";
Connection conn = DriverManager.getConnection(connURL);

String username = (String) session.getAttribute("username");
if (username == null) username = "Admin";

String ctx = request.getContextPath();

// Get categories
PreparedStatement psCat = conn.prepareStatement(
    "SELECT id, category_name, category_picture FROM category"
);
ResultSet rsCat = psCat.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>

<style>
body{
  font-family: Arial;
  margin: 0;
  padding: 0;
  background: #f4f4f8;
}

.header{
  background: #7f9cf5;
  padding: 16px;
  color: white;
  font-size: 22px;
  font-weight: bold;
}

.cards {
  display: flex;
  gap: 40px;
  justify-content: center;
  flex-wrap: wrap;
  padding: 40px 0;
}


.card img {
  width: 150px;
  height: 150px;
  object-fit: cover;
  border-radius: 14px;
}

/* Card wrapper */
.card {
  position: relative;
  background: white;
  width: 220px;
  padding: 18px;
  border-radius: 16px;
  text-align: center;
  cursor: pointer;
  box-shadow: 0 4px 10px rgba(0,0,0,0.08);
  transition: 0.2s;
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 14px rgba(0,0,0,0.15);
}

/* Dropdown container */
.dropdown-content {
  display: none !important;
  position: absolute;
  top: 210px;
  left: 50%;
  transform: translateX(-50%);
  width: 200px;
  background: #ffffff;
  border-radius: 14px;
  padding: 10px 0;
  box-shadow: 0 6px 16px rgba(0,0,0,0.18);
  z-index: 9999;
  overflow: hidden; /* smooth rounded edges */
}

/* When card is opened */
.card.open .dropdown-content,
.card:hover .dropdown-content {
  display: block !important;
}

/* Each menu item */
.dropdown-content a {
  display: block;
  padding: 12px 18px;
  font-size: 15px;
  font-weight: 500;
  color: #333;
  text-decoration: none;
  transition: 0.15s ease;
  text-align: left;
}

/* Hover effect */
.dropdown-content a:hover {
  background: #f2f5ff;
  color: #5060d6;
  padding-left: 24px; /* slide effect */
}

/* Optional: add icons next to items */
.dropdown-content a::before {
  content: "›"; 
  margin-right: 8px;
  color: #7f9cf5;
}



/*fot plus sign*/
.edit-btn {
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: #7f9cf5;
  color: white;
  width: 56px;
  height: 56px;
  border-radius: 50%;
  font-size: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  box-shadow: 0 4px 8px rgba(0,0,0,0.25);
  z-index: 9999;
  transition: 0.2s;
}

.edit-btn:hover {
  background: #5e7ce0;
  transform: translateY(-3px);
}


</style>

</head>
<body>
<jsp:include page="/admin/adminNavBar.jsp"/>
<div class="header">Admin Dashboard</div>

<section class="cards">
<%
while (rsCat.next()) {
    int catId   = rsCat.getInt("id");
    String catName = rsCat.getString("category_name");
    String catPic  = rsCat.getString("category_picture");
    String catPicPath = ctx + "/home/Images/" + catPic;
%>

  <div class="card">
    <img src="<%= catPicPath %>" alt="<%= catName %>">
    <h3><%= catName %></h3>

    <div class="dropdown-content">

<%
    // LOWERCASE category name for easy comparison
    String nameLower = catName.toLowerCase();

    // CLEANING CATEGORY
    if (nameLower.contains("clean") || nameLower.equals("cleaning")) {
%>

    <a href="<%= ctx %>/admin/editCleaningService.jsp?catId=<%= catId %>">
        Edit Services
    </a>
    <a href="<%= ctx %>/admin/editCleaners.jsp?catId=<%= catId %>">
        Edit Cleaners
    </a>
    <a href="<%= ctx %>/admin/cleaningReviews.jsp?catId=<%= catId %>">
        Edit Cleaning Reviews
    </a>

<%
    } 
    // CAREGIVING CATEGORY
    else if (nameLower.contains("care") || nameLower.contains("caregiving")) {
%>

    <a href="<%= ctx %>/admin/editGroceryDiscount.jsp?catId=<%= catId %>">
        Edit Grocery Discounts
    </a>

    <a href="<%= ctx %>/admin/editGroceryItem.jsp?catId=<%= catId %>">
        Edit Grocery Items
    </a>

    <a href="<%= ctx %>/admin/editMealDiscount.jsp?catId=<%= catId %>">
        Edit Meal Discounts
    </a>

    <a href="<%= ctx %>/admin/editMealItems.jsp?catId=<%= catId %>">
        Edit Meals
    </a>

    <a href="<%= ctx %>/admin/mealProviderReviews.jsp?catId=<%= catId %>">
        Edit Meal Providers Reviews
    </a>
    
    <a href="<%= ctx %>/admin/groceryCompanyReviews.jsp?catId=<%= catId %>">
        Edit Grocery Company Reviews
    </a>
    

<%
    } 
    // OTHER CATEGORIES (fallback)
    else {
%>

     		<a href="<%= ctx %>/admin/Doctor/DoctorAppt/AdminDocAppt/AdminDoctorReviews.jsp"
               class="block px-4 py-2 text-sm text-red-600 hover:bg-red-50">
                Delete Online Consult Review & Reply
            </a>
            <a href="<%= ctx %>/admin/Doctor/DoctorAppt/AdminDocAppt/AdminDoctorList.jsp"
			   class="block px-4 py-2 text-sm text-blue-600 hover:bg-blue-50">
			    Edit Online Consult Packages
			</a>
			<a href="<%= ctx %>/admin/Doctor/Specialist/Appointments/ViewAppointments.jsp"
			   class="block px-4 py-2 text-sm text-blue-600 hover:bg-blue-50">
			    Edit Specialist Appointments
				</a>
				<a href="<%= ctx %>/admin/Doctor/Specialist/Packages/ViewPackages.jsp"
				   class="block px-4 py-2 text-sm text-blue-600 hover:bg-blue-50">
				    Edit Specialist Packages
				</a>
				<a href="<%= ctx %>/admin/Doctor/Specialist/Reviews/ViewReviews.jsp"
				   class="block px-4 py-2 text-sm text-blue-600 hover:bg-blue-50">
				    Edit Specialist Reviews
				</a>
				
				
			
            
<%
    }
%>

</div>

  </div>

<%
}
psCat.close();
conn.close();
%>
</section>

<a href="<%= ctx %>/admin/editCategories.jsp" class="edit-btn">+</a>

<!-- script for the drop down -->
<script>
  document.querySelectorAll(".card").forEach(card => {
    card.addEventListener("click", (e) => {
      // if clicking a link inside dropdown, let it go
      if (e.target.tagName.toLowerCase() === "a") return;

      // close other cards
      document.querySelectorAll(".card").forEach(c => {
        if (c !== card) c.classList.remove("open");
      });

      // toggle this dropdown
      card.classList.toggle("open");
    });
  });

  // click outside closes all
  document.addEventListener("click", (e) => {
    if (!e.target.closest(".card")) {
      document.querySelectorAll(".card").forEach(c => c.classList.remove("open"));
    }
  });
</script>

</body>
</html>
