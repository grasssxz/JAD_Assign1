<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<style>
:root {
    --purple: #d4d6e0;
    --purple-border: #7f9cf5;
    --text-light: #ffffff;
}

/* NAVBAR CONTAINER */
.navbar {
    background: var(--purple);
    border-bottom: 2px solid var(--purple-border);
    padding: 16px 32px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
    box-sizing: border-box;
}

/* GROUPS */
.nav-left, .nav-right {
    display: flex;
    align-items: center;
    gap: 28px;
}

/* LINKS */
.nav-link {
    color: var(--text-light);
    text-decoration: none;
    font-size: 15px;
    font-weight: 500;
    padding: 8px 14px;
    border-radius: 6px;
    transition: all 0.25s;
}

.nav-link:hover {
    background: rgba(255,255,255,0.2);
}

/* BUTTON STYLE */
.nav-btn {
    background: #7f9cf5 !important;
    padding: 8px 18px;
    border-radius: 6px;
    color: white !important;
    font-weight: 600;
    transition: background 0.25s ease-in-out;
}
.nav-btn:hover {
    background: #6f8ce0 !important;
}

/* WELCOME LABEL */
.nav-welcome {
    color: white;
    font-size: 15px;
    font-weight: 500;
}

/* DROPDOWN MENU */
.dropdown {
    position: relative;
}
.dropdown-menu {
    position: absolute;
    top: 110%;
    left: 0;
    background: white;
    min-width: 200px;
    padding: 10px 0;
    border-radius: 10px;
    display: none;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
.dropdown:hover .dropdown-menu {
    display: block;
}
.dropdown-menu a {
    display: block;
    padding: 12px 18px;
    color: #333;
    text-decoration: none;
    transition: background 0.2s;
}
.dropdown-menu a:hover {
    background: #f2f2f2;
}
</style>

<%
    // SESSION VALUES
    Integer memberId = (Integer) session.getAttribute("member_id");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("type");

    if (role == null) role = "guest";
    if (username == null) username = "Guest";

    // READ COOKIE
    String cookieUser = null;
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie c : cookies) {
            if ("username".equals(c.getName())) {
                cookieUser = c.getValue();
            }
        }
    }

    boolean isGuest = (memberId == null || "guest".equals(role));
%>

<header class="navbar">

    <!-- LEFT SIDE -->
    <nav class="nav-left">

        <!-- WELCOME MESSAGE ONLY (LEFT SIDE) -->
        <% if (!isGuest) { %>
            <span class="nav-welcome">Welcome, <%= username %></span>
        <% } else if (cookieUser != null) { %>
            <span class="nav-welcome">Welcome back, <%= cookieUser %></span>
        <% } else { %>
            <span class="nav-welcome">Welcome, Guest</span>
        <% } %>

        <!-- HOME -->
        <a class="nav-link" href="<%= request.getContextPath() %>/home/HomePage.jsp">Home</a>

        <!-- CART -->
        <a class="nav-link" href="<%= request.getContextPath() %>/Services/Meal_Delivery/view_cart.html">Cart</a>

        <!-- BOOKINGS DROPDOWN -->
        <div class="dropdown">
            <a class="nav-link">Bookings ▼</a>
            <div class="dropdown-menu">
                <a href="#">Doctor Bookings</a>
				<a href="<%= request.getContextPath() %>/Services/Cleaning/viewCleaningBooking.jsp">Cleaning Bookings</a>                
				<a href="#">Caregiver Bookings</a>
            </div>
        </div>

        <!-- Family page -->
       <a class="nav-link" href="<%= request.getContextPath() %>/family/myFamily.jsp">My Family</a>
        
        <!-- Me page -->
       <a class="nav-link" href="<%= request.getContextPath() %>/me/mePage.jsp">Profile</a>


        <!-- ADMIN PANEL -->
        <% if ("admin".equals(role)) { %>
            <a class="nav-link" href="<%= request.getContextPath() %>/admin/admin_homePage.html">Admin Panel</a>
        <% } %>

    </nav>

    <!-- RIGHT SIDE -->
    <nav class="nav-right">

        <% if (isGuest) { %>
            <!-- Guest – show Login + Sign Up -->
            <a class="nav-link nav-btn" href="<%= request.getContextPath() %>/login/login.html">Login</a>
            <a class="nav-link nav-btn" href="<%= request.getContextPath() %>/login/signUp.html">Sign Up</a>

        <% } else { %>
            <!-- Logged in – show Logout -->
            <a class="nav-link nav-btn" href="<%= request.getContextPath() %>/login/logout.jsp">Logout</a>
        <% } %>

    </nav>

</header>
