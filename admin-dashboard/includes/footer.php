            </main>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-light text-center text-muted py-4 mt-5">
        <div class="container">
            <p>&copy; <?php echo date('Y'); ?> Bus Passenger Connect Admin Dashboard. All rights reserved.</p>
            <p>
                <small>
                    <i class="fas fa-bus text-success me-1"></i>
                    Connecting Kenya's Commuters
                </small>
            </p>
        </div>
    </footer>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Custom JS -->
    <script>
        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                if (alert.classList.contains('show')) {
                    const bsAlert = new bootstrap.Alert(alert);
                    bsAlert.close();
                }
            });
        }, 5000);

        // Confirm delete actions
        function confirmDelete(message = 'Are you sure you want to delete this item?') {
            return confirm(message);
        }

        // Add loading spinner to forms
        document.addEventListener('DOMContentLoaded', function() {
            const forms = document.querySelectorAll('form');
            forms.forEach(function(form) {
                form.addEventListener('submit', function() {
                    const submitBtn = form.querySelector('button[type="submit"]');
                    if (submitBtn) {
                        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';
                        submitBtn.disabled = true;
                    }
                });
            });
        });

        // Phone number formatting
        function formatPhone(input) {
            let value = input.value.replace(/\D/g, '');
            if (value.startsWith('254')) {
                value = '+' + value;
            } else if (value.startsWith('0')) {
                value = '+254' + value.substring(1);
            } else if (value.length === 9) {
                value = '+254' + value;
            }
            input.value = value;
        }

        // ID number validation (Kenya format)
        function validateIdNumber(input) {
            const value = input.value.replace(/\D/g, '');
            if (value.length > 8) {
                input.value = value.substring(0, 8);
            } else {
                input.value = value;
            }
        }

        // License plate formatting (Kenya format)
        function formatLicensePlate(input) {
            let value = input.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
            input.value = value;
        }
    </script>
</body>
</html>
