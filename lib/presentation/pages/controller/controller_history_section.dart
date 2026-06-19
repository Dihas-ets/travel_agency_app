part of '../collector/collector_home_page.dart';

// Historique controleur: liste les tickets deja scannes pendant les validations.

class _ControllerHistoryTabContent extends StatelessWidget {
  const _ControllerHistoryTabContent();

  @override
  Widget build(BuildContext context) {
    return const _ControllerScannedTicketList();
  }
}

class _ControllerHistoryPage extends StatelessWidget {
  const _ControllerHistoryPage();

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tickets scannes',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: _ControllerScannedTicketList(),
        ),
      ),
    );
  }
}

class _ControllerScannedTicketList extends StatelessWidget {
  const _ControllerScannedTicketList();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<_ControllerScannedTicket>>(
      valueListenable: _ControllerScannedTicketStore.tickets,
      builder: (context, tickets, _) {
        if (tickets.isEmpty) {
          return const _CollectorEmptyCard(
            title: 'Aucun ticket scanne',
            message:
                'Les tickets valides par le controleur apparaitront ici apres chaque scan.',
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 18),
          itemCount: tickets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _ControllerScannedTicketCard(ticket: tickets[index]);
          },
        );
      },
    );
  }
}

class _ControllerScannedTicketCard extends StatelessWidget {
  final _ControllerScannedTicket ticket;

  const _ControllerScannedTicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);
    const red = Color(0xFFE53935);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ticket.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: deepBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ticket.status,
                  style: const TextStyle(
                    color: green,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _TicketInfoRow(title: 'Passager', value: ticket.passenger),
          _TicketInfoRow(title: 'Trajet', value: ticket.route),
          _TicketInfoRow(title: 'Depart', value: ticket.departure),
          _TicketInfoRow(title: 'Siege', value: ticket.seat),
          _TicketInfoRow(title: 'Scanne le', value: ticket.scannedAt),
        ],
      ),
    );
  }
}
