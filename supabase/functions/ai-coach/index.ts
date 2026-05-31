import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { GoogleGenerativeAI } from "npm:@google/generative-ai";
const genAI = new GoogleGenerativeAI(Deno.env.get("GEMINI_API_KEY"));
Deno.serve(async (req)=>{
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response("Unauthorized", {
      status: 401
    });
  }
  const supabase = createClient(Deno.env.get("SUPABASE_URL"), Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"));
  const { data: { user }, error: authError } = await supabase.auth.getUser(authHeader.replace("Bearer ", ""));
  if (authError || !user) {
    return new Response("Unauthorized", {
      status: 401
    });
  }
  const { regimenData, doseLogs } = await req.json();
  const prompt = `
    Analyze this user's current regimen: ${JSON.stringify(regimenData)}
    And their recent dose logs: ${JSON.stringify(doseLogs)}
    
    Domain Context (Pharmacology Principles):
    The app uses a psychopharmacology simulator modeling pharmacokinetics (T½), 
    neurotransmitter receptor activity (Dopamine, Serotonin, Norepinephrine, GABA, Sedation), 
    and subjective clinical experience (Focus, Energy, Mood, Calm).
    
    Provide a professional, concise, and safety-conscious coaching summary. 
    Focus on potential tolerance risks, homeostasis impacts, and metabolic interactions 
    based on the pharmacology principles defined in the SteadyState-Coach simulator.
    
    Return as a structured JSON object: { "summary": string, "recommendations": string[] }
  `;
  try {
    const model = genAI.getGenerativeModel({
      model: "gemini-1.5-flash"
    });
    const result = await model.generateContent(prompt);
    const response = await result.response;
    return new Response(response.text(), {
      headers: {
        "Content-Type": "application/json"
      }
    });
  } catch (error) {
    console.error("AI Generation Error:", error);
    return new Response("Internal Server Error", {
      status: 500
    });
  }
});
