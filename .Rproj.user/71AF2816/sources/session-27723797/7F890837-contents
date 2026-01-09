ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$style(HTML("
      /* --- GLOBAL STYLES --- */
      body { background-color: #f4f7f6; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
      
      /* --- LOGIN PAGE STYLES --- */
      .login-wrapper {
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: linear-gradient(135deg, #B71C1C 0%, #311B92 100%); 
        display: flex; align-items: center; justify-content: center;
        z-index: 999;
      }
      .login-card {
        background: white; padding: 40px; border-radius: 15px;
        box-shadow: 0 15px 35px rgba(0,0,0,0.3);
        width: 100%; max-width: 420px; text-align: center;
        animation: fadeIn 0.8s ease-out;
      }
      @keyframes fadeIn { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
      .login-card h2 { color: #B71C1C; font-weight: 800; margin-bottom: 5px; margin-top: 10px; }
      .login-card p { color: #757575; margin-bottom: 30px; }
      .input-block, .password-container { position: relative; text-align: left; margin-bottom: 20px; }
      .password-toggle { position: absolute; right: 15px; top: 35px; cursor: pointer; color: #757575; z-index: 100; }
      .password-toggle a { color: #757575 !important; text-decoration: none !important; }
      .btn-login { 
        background-color: #B71C1C !important; color: white !important; width: 100%; 
        padding: 12px; font-size: 18px; font-weight: bold; border-radius: 8px; margin-top: 20px; border: none; 
      }
      .btn-login:hover { background-color: #D32F2F !important; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0,0,0,0.2); }
      
      /* --- DASHBOARD STYLES --- */
      .red-header { background-color: #B71C1C; color: white; font-size: 26px; font-weight: bold; padding: 15px 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.2); }
      .btn-red { background-color: #D32F2F !important; color: white !important; border-radius: 5px; }
      .btn-gray { background-color: #757575 !important; color: white !important; border-radius: 5px; }
      .data-section { padding: 25px; background-color: white; border-radius: 0 0 10px 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
      .form-control { border-radius: 6px; height: 45px; border: 1px solid #ddd; }
      .well { border-radius: 10px; border: none; box-shadow: inset 0 1px 3px rgba(0,0,0,0.05); }
    "))
  ),
  uiOutput("page_content")
)