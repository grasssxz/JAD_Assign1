<jsp:include page="/auth/AuthCheck.jsp" />
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>

<%
Class.forName("com.mysql.cj.jdbc.Driver");
String connURL = "jdbc:mysql://localhost:3306/JAD_Assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC";
Connection conn = DriverManager.getConnection(connURL);

// ====== GET USER FROM SESSION ======
String username = (String) session.getAttribute("username");
if (username == null) username = "Guest";

String ctx = request.getContextPath();
String baseImg = ctx + "/home/Images";

// DEFAULT PROFILE PIC
String profilePic = baseImg + "/profile.jpg";

PreparedStatement psUser = conn.prepareStatement(
    "SELECT profile_pic FROM member WHERE username = ?"
);
psUser.setString(1, username);
ResultSet rsUser = psUser.executeQuery();
if (rsUser.next()) {
    String pp = rsUser.getString("profile_pic");
    if (pp != null && !pp.isEmpty()) {
        profilePic = baseImg + "/" + pp;
    }
}
rsUser.close();
psUser.close();

// ====== GET CATEGORIES ======
PreparedStatement psCat = conn.prepareStatement(
    "SELECT id, category_name, category_picture FROM category"
);
ResultSet rsCat = psCat.executeQuery();

PreparedStatement psSvc = conn.prepareStatement(
    "SELECT name, service_link FROM service WHERE category_id = ?"
);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Care Services</title>

<!-- Tailwind CSS -->
<script src="https://cdn.tailwindcss.com"></script>

</head>

<body class="bg-gray-50 text-gray-900">

<jsp:include page="NavBar.jsp"/>

<!-- TOP RIGHT ICONS -->
<div class="flex justify-end gap-6 px-8 py-4 text-xl text-gray-600">
    <button class="hover:text-black">🔔</button>
    <button class="hover:text-black">♡</button>
</div>

<!-- PROFILE -->
<section class="max-w-6xl mx-auto flex items-center gap-4 px-8">
    <img src="<%= profilePic %>" 
         class="w-14 h-14 rounded-full object-cover shadow-md">
    <div>
        <p class="text-lg font-semibold"><%= username %></p>
        <p class="text-sm text-gray-500">Welcome back</p>
    </div>
</section>

<!-- SEARCH BAR -->
<div class="max-w-6xl mx-auto px-8 mt-6">
    <div class="flex items-center bg-white shadow-sm border rounded-xl px-4 py-3">
        <span class="text-gray-400 text-xl mr-3">🔍</span>
        <input type="text" placeholder="Search services..."
               class="w-full bg-transparent focus:outline-none text-gray-700">
    </div>
</div>

<!-- HERO BANNER -->
<section class="max-w-6xl mx-auto px-8 mt-8 relative">
    <div class="relative w-full h-64 md:h-80 lg:h-96 rounded-2xl overflow-hidden">

    <div class="absolute inset-0 bg-black/40 z-10"></div>

    <div class="absolute z-20 top-10 left-10">
        <h2 class="text-3xl font-bold text-white">We care about you</h2>
        <p class="text-white mt-2">Select a service with us now</p>
    </div>

    <img class="slide active absolute inset-0 w-full h-full object-cover" 
         src="<%= baseImg %>/CaregiverBanner.png">

    <img class="slide absolute inset-0 w-full h-full object-cover opacity-0" 
         src="<%= baseImg %>/CleannerBanner.png">

    <img class="slide absolute inset-0 w-full h-full object-cover opacity-0" 
         src="<%= baseImg %>/DoctorBanner.png">
</div>


    <!-- DOTS -->
    <div class="absolute bottom-4 left-1/2 -translate-x-1/2 flex space-x-2 z-30">
        <span class="dot w-3 h-3 rounded-full bg-white opacity-90 cursor-pointer"></span>
        <span class="dot w-3 h-3 rounded-full bg-white opacity-50 cursor-pointer"></span>
        <span class="dot w-3 h-3 rounded-full bg-white opacity-50 cursor-pointer"></span>
    </div>
</section>

<!-- TITLE SECTION -->
<div class="max-w-6xl mx-auto px-8 mt-12 text-center">
    <span class="px-5 py-2 bg-yellow-100 rounded-full font-medium text-gray-700">
       services
    </span>
</div>

<!-- CATEGORY CARDS -->
<section class="max-w-6xl mx-auto px-8 mt-10 grid grid-cols-1 md:grid-cols-3 gap-10">

<%
while (rsCat.next()) {
    int catId = rsCat.getInt("id");
    String catName = rsCat.getString("category_name");
    String pic = rsCat.getString("category_picture");
    String catPicPath = baseImg + "/" + pic;

    psSvc.setInt(1, catId);
    ResultSet rsSvc = psSvc.executeQuery();
%>

    <div class="group relative bg-white rounded-2xl shadow hover:shadow-lg transition p-6 cursor-pointer">
        <img src="<%= catPicPath %>"
             class="w-28 h-28 mx-auto rounded-xl object-cover">
        
        <h3 class="mt-4 text-center text-lg font-semibold tracking-wide">
            <%= catName.toUpperCase() %>
        </h3>

        <!-- DROPDOWN -->
        <div class="absolute left-0 right-0 mt-2 hidden group-hover:block">
            <div class="bg-white shadow-xl border rounded-lg py-2">
                <% while (rsSvc.next()) { %>
                    <a href="<%= ctx + rsSvc.getString("service_link") %>" 
                       class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                        <%= rsSvc.getString("name") %>
                    </a>
                <% } rsSvc.close(); %>
            </div>
        </div>
    </div>

<%
}
psSvc.close();
rsCat.close();
psCat.close();
conn.close();
%>

</section>

<script>
// -------- BANNER SLIDES ----------
const slides = document.querySelectorAll('.slide');
const dots = document.querySelectorAll('.dot');
let index = 0;

function updateSlides(i) {
    slides.forEach((s, k) => {
        s.style.opacity = k === i ? "1" : "0";
        s.classList.toggle("active", k === i);
    });
    dots.forEach((d, k) => d.style.opacity = (k === i ? "1" : "0.4"));
}
function nextSlide() {
    index = (index + 1) % slides.length;
    updateSlides(index);
}
let timer = setInterval(nextSlide, 4000);

dots.forEach((d, i) => {
    d.addEventListener("click", () => {
        clearInterval(timer);
        index = i;
        updateSlides(i);
        timer = setInterval(nextSlide, 4000);
    });
});
</script>

</body>
</html>
