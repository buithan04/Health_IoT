const reminderService = require('../services/reminder_service');

const getAll = async (req, res) => {
    try {
        const list = await reminderService.getReminders(req.user.id);
        res.json(list);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
};

const create = async (req, res) => {
    try {
        const reminder = await reminderService.createReminder(req.user.id, req.body);
        res.json(reminder);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
};

const update = async (req, res) => {
    try {
        const updated = await reminderService.updateReminder(req.params.id, req.user.id, req.body);
        if (!updated) return res.status(404).json({ error: "Không tìm thấy" });
        res.json(updated);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
};

// Xóa nhắc nhở
const remove = async (req, res) => {
    try {
        const success = await reminderService.deleteReminder(req.params.id, req.user.id);
        if (!success) return res.status(404).json({ error: "Không tìm thấy" });
        res.json({ message: "Đã xóa" });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
};

module.exports = { getAll, create, update, remove };