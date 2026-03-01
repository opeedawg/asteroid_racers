// supabase/functions/revenuecat-webhook/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    const { event } = await req.json();
    const pilotId = event.app_user_id; 

    // Create the Supabase Admin client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Filter for purchase or renewal events
    if (event.type === 'INITIAL_PURCHASE' || event.type === 'RENEWAL') {
      // 1. Get current settings for this pilot
      const { data, error: fetchError } = await supabase
        .from('pilots')
        .select('settings')
        .eq('id', pilotId)
        .single();
      
      if (fetchError) throw fetchError;

      // 2. Update the JSONB to set is_premium to true
      const updatedSettings = { ...data.settings, is_premium: true };

      // 3. Update the database record
      const { error: updateError } = await supabase
        .from('pilots')
        .update({ settings: updatedSettings })
        .eq('id', pilotId);

      if (updateError) throw updateError;
      
      console.log(`Successfully upgraded Pilot ${pilotId} to Premium.`);
    }

    return new Response(JSON.stringify({ ok: true }), { 
      headers: { "Content-Type": "application/json" } 
    });

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { 
      status: 400, 
      headers: { "Content-Type": "application/json" } 
    });
  }
})