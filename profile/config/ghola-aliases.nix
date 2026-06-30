{ config, pkgs, ... }:

{
  programs.zsh.shellAliases = {
    # ─── GHOLA — Offensive Security Framework ───

    ghola-up = "cd ~/ghola && docker compose ps";
    ghola-health = "docker exec ghola-wireguard wg show | grep handshake";
    ghola-ops = "hermes --profile recon -s ghola-opsec chat -q 'Run full pre-engagement OPSEC checklist. Report all results.'";
    ghola-recon = "hermes --profile recon -s ghola-orchestrator chat -q 'Full engagement pass on scope.txt. Run all stages and gates.'";
    ghola-findings = "cat ~/ghola/pipeline/output/latest/confirmed_findings.json 2>/dev/null | python3 -m json.tool | head -40";
    ghola-logs = "sudo journalctl -u ghola-pipeline-stage1 -n 30 --no-pager";

    # ─── Other Memory — Search & Crawl ───

    om-status = "cd ~/other-memory && docker compose ps";
    om-search = "hermes chat -q 'Use web_search to find'";

    # ─── Honcho — Memory Layer ───

    honcho-status = "cd ~/honcho && docker compose ps";
    honcho-logs = "cd ~/honcho && docker compose logs deriver --tail 20";

    # ─── Polymarket Trading ───

    pm-scan = "hermes -s polymarket -s polymarket-trading chat -q 'Scan Polymarket for opportunities. Log to ~/polymarket/opportunities.md. Do NOT place orders.'";
    pm-journal = "cat ~/polymarket/journal.md | tail -40";
    pm-review = "hermes -s polymarket -s polymarket-trading chat -q 'Weekly strategy review from ~/polymarket/journal.md'";

    # ─── Stack Overview ───

    stack-status = ''
      echo "=== GHOLA ===" && docker compose -f ~/ghola/docker-compose.yml ps --format "table {{.Name}}\t{{.Status}}" 2>/dev/null
      echo "=== Other Memory ===" && docker compose -f ~/other-memory/docker-compose.yml ps --format "table {{.Name}}\t{{.Status}}" 2>/dev/null
      echo "=== Honcho ===" && docker compose -f ~/honcho/docker-compose.yml ps --format "table {{.Name}}\t{{.Status}}" 2>/dev/null
      echo "=== Hermes ===" && hermes doctor 2>/dev/null | head -5
    '';

    # ─── tmux Sessions ───

    # tmux-hermes = "tmux new-session -d -s hermes-main -x 120 -y 40 'hermes' 2>/dev/null; tmux attach -t hermes-main";
    # tmux-recon = "tmux new-session -d -s ghola-recon -x 120 -y 40 'hermes --profile recon' 2>/dev/null; tmux attach -t ghola-recon";
    # tmux-list = "tmux list-sessions 2>/dev/null || echo 'No tmux sessions running'";
  };
}
